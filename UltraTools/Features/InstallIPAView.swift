import SwiftUI
import UIKit
import UniformTypeIdentifiers
import UserNotifications
import Compression

// MARK: - Минимальный ZIP-ридер для разбора IPA

struct ZIPEntry {
    let name: String
    let method: UInt16
    let compressedSize: Int
    let uncompressedSize: Int
    let localHeaderOffset: Int
}

enum ZIPError: Error {
    case notZip
    case corrupted
    case inflateFailed
}

final class ZIPReader {
    private let data: Data

    init(data: Data) throws {
        guard data.count > 22 else { throw ZIPError.notZip }
        self.data = data
    }

    private func u16(_ o: Int) -> UInt16 {
        UInt16(data[o]) | (UInt16(data[o + 1]) << 8)
    }

    private func u32(_ o: Int) -> UInt32 {
        UInt32(data[o]) | (UInt32(data[o + 1]) << 8) | (UInt32(data[o + 2]) << 16) | (UInt32(data[o + 3]) << 24)
    }

    private func endOfCentralDirectory() throws -> Int {
        let lower = max(0, data.count - 22 - 65536)
        var o = data.count - 22
        while o >= lower {
            if u32(o) == 0x06054b50 { return o }
            o -= 1
        }
        throw ZIPError.notZip
    }

    func entries() throws -> [ZIPEntry] {
        let eocd = try endOfCentralDirectory()
        let count = Int(u16(eocd + 10))
        var offset = Int(u32(eocd + 16))
        var result: [ZIPEntry] = []
        for _ in 0..<count {
            guard offset + 46 <= data.count, u32(offset) == 0x02014b50 else { throw ZIPError.corrupted }
            let method = u16(offset + 10)
            let compSize = Int(u32(offset + 20))
            let uncompSize = Int(u32(offset + 24))
            let nameLen = Int(u16(offset + 28))
            let extraLen = Int(u16(offset + 30))
            let commentLen = Int(u16(offset + 32))
            let localOffset = Int(u32(offset + 42))
            let nameEnd = offset + 46 + nameLen
            guard nameEnd <= data.count else { throw ZIPError.corrupted }
            let name = String(decoding: data.subdata(in: (offset + 46)..<nameEnd), as: UTF8.self)
            result.append(ZIPEntry(
                name: name,
                method: method,
                compressedSize: compSize,
                uncompressedSize: uncompSize,
                localHeaderOffset: localOffset
            ))
            offset = nameEnd + extraLen + commentLen
        }
        return result
    }

    func data(for entry: ZIPEntry) throws -> Data {
        let o = entry.localHeaderOffset
        guard o + 30 <= data.count, u32(o) == 0x04034b50 else { throw ZIPError.corrupted }
        let nameLen = Int(u16(o + 26))
        let extraLen = Int(u16(o + 28))
        let start = o + 30 + nameLen + extraLen
        let end = start + entry.compressedSize
        guard end <= data.count else { throw ZIPError.corrupted }
        let raw = data.subdata(in: start..<end)
        switch entry.method {
        case 0:
            return raw
        case 8:
            guard let inflated = Self.inflate(raw, expected: entry.uncompressedSize) else { throw ZIPError.inflateFailed }
            return inflated
        default:
            throw ZIPError.corrupted
        }
    }

    private static func inflate(_ src: Data, expected: Int) -> Data? {
        guard expected > 0, !src.isEmpty else { return nil }
        var dst = Data(count: expected)
        let written = dst.withUnsafeMutableBytes { dPtr in
            src.withUnsafeBytes { sPtr in
                compression_decode_buffer(
                    dPtr.bindMemory(to: UInt8.self).baseAddress!, expected,
                    sPtr.bindMemory(to: UInt8.self).baseAddress!, src.count,
                    nil, COMPRESSION_ZLIB
                )
            }
        }
        guard written > 0 else { return nil }
        return dst.subdata(in: 0..<written)
    }
}

// MARK: - Инспектор IPA

struct IPAAppInfo {
    let name: String
    let bundleID: String
    let version: String
}

enum IPAInspector {
    static func inspect(data: Data) -> IPAAppInfo? {
        guard let reader = try? ZIPReader(data: data) else { return nil }
        guard let entries = try? reader.entries() else { return nil }
        guard let infoEntry = entries.first(where: {
            $0.name.range(of: #"^Payload/[^/]+\.app/Info\.plist$"#, options: .regularExpression) != nil
        }) else { return nil }
        guard let plistData = try? reader.data(for: infoEntry) else { return nil }
        guard let plist = (try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)) as? [String: Any] else { return nil }
        let name = (plist["CFBundleDisplayName"] as? String)
            ?? (plist["CFBundleName"] as? String)
            ?? "Неизвестное приложение"
        let bundle = (plist["CFBundleIdentifier"] as? String) ?? "—"
        let version = (plist["CFBundleShortVersionString"] as? String) ?? "—"
        return IPAAppInfo(name: name, bundleID: bundle, version: version)
    }
}

// MARK: - Трекер подписей «7 дней»

struct SignedApp: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var installDate: Date
}

@MainActor
final class InstallTracker: ObservableObject {
    @Published var apps: [SignedApp] = [] { didSet { save() } }
    private let key = "ultra.signed.apps"

    init() {
        if let stored = UserDefaults.standard.data(forKey: key),
           let list = try? JSONDecoder().decode([SignedApp].self, from: stored) {
            apps = list
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(apps) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func add(name: String) {
        apps.append(SignedApp(name: name, installDate: Date()))
        scheduleReminders(for: name)
    }

    func refresh(_ app: SignedApp) {
        guard let i = apps.firstIndex(where: { $0.id == app.id }) else { return }
        apps[i].installDate = Date()
        scheduleReminders(for: app.name)
    }

    func remove(_ app: SignedApp) {
        apps.removeAll { $0.id == app.id }
    }

    func daysLeft(_ app: SignedApp) -> Int {
        let elapsed = Calendar.current.dateComponents([.day], from: app.installDate, to: Date()).day ?? 0
        return max(0, 7 - elapsed)
    }

    private func scheduleReminders(for name: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        let reminders: [(day: Int, body: String)] = [
            (6, "Завтра истекает подпись «\(name)». Оставь iPhone в одном Wi-Fi с компьютером, где запущен AltServer — AltStore продлит сам."),
            (7, "Подпись «\(name)» истекла. Обнови в AltStore или подпиши заново через Sideloadly.")
        ]
        for r in reminders {
            let content = UNMutableNotificationContent()
            content.title = "UltraTools: 7 дней"
            content.body = r.body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(r.day * 86400), repeats: false)
            let request = UNNotificationRequest(identifier: "\(name)-day\(r.day)", content: content, trigger: trigger)
            center.add(request)
        }
    }
}

// MARK: - Экран «Установка»

struct InstallIPAView: View {
    var body: some View {
        NavigationStack { InstallIPAContent() }
    }
}

struct InstallIPAContent: View {
    @StateObject private var tracker = InstallTracker()
    @State private var showImporter = false
    @State private var isImporting = false
    @State private var importedURL: URL?
    @State private var importedInfo: IPAAppInfo?
    @State private var importedSize: Int = 0
    @State private var importError: String?

    private var ipaTypes: [UTType] { [.item] }

    var body: some View {
        List {
            Section("1. Выбери IPA") {
                Button {
                    showImporter = true
                } label: {
                    Label("Выбрать .ipa файл", systemImage: "square.and.arrow.down.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .disabled(isImporting)

                if isImporting {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Читаю файл…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if let info = importedInfo {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "shippingbox.fill")
                                .foregroundStyle(Color.accentColor)
                            Text(info.name).font(.headline)
                            Spacer()
                            Text(sizeLabel).font(.caption).foregroundStyle(.secondary)
                        }
                        Text("Bundle ID: \(info.bundleID)").font(.caption.monospaced())
                        Text("Версия: \(info.version)").font(.caption)

                        if let url = importedURL {
                            ShareLink(item: url) {
                                Label("Передать в приложение для подписи (AltStore, ESign, Файлы…)", systemImage: "square.and.arrow.up.fill")
                                    .font(.subheadline.weight(.medium))
                            }
                        }
                        Button {
                            tracker.add(name: info.name)
                        } label: {
                            Label("Я установил — включить отсчёт 7 дней", systemImage: "calendar.badge.clock")
                                .font(.subheadline.weight(.medium))
                        }
                    }
                    .padding(.vertical, 4)
                } else if let importedURL {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(importedURL.lastPathComponent).font(.subheadline.weight(.semibold))
                        Text("Не удалось прочитать Info.plist — возможно, файл повреждён. Но поделиться им можно:")
                            .font(.footnote).foregroundStyle(.secondary)
                        ShareLink(item: importedURL) {
                            Label("Передать дальше", systemImage: "square.and.arrow.up.fill")
                        }
                    }
                }

                if let importError {
                    Text(importError).font(.footnote).foregroundStyle(.red)
                }
            }

            Section("2. Подписанные приложения (7 дней)") {
                if tracker.apps.isEmpty {
                    Text("Пока пусто. После установки подпиши IPA через AltStore/Sideloadly и нажми «включить отсчёт» — UltraTools напомнит обновить подпись до её истечения.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                ForEach(tracker.apps) { app in
                    SignedAppRow(app: app, daysLeft: tracker.daysLeft(app)) {
                        tracker.refresh(app)
                    } onDelete: {
                        tracker.remove(app)
                    }
                }
            }

            Section("Как это работает (как в AltStore)") {
                bullet("free", "Бесплатный Apple ID подписывает приложение ровно на 7 дней — это правило Apple, обойти его нельзя.")
                bullet("arrow.triangle.2.circlepath", "Поэтому раз в неделю подпись надо обновлять: AltStore делает это сам, когда iPhone и компьютер с AltServer в одном Wi-Fi. Либо вручную через Sideloadly.")
                bullet("bell.badge.fill", "UltraTools следит за сроками: за день до истечения и в день истечения придёт напоминание.")
                bullet("exclamationmark.shield.fill", "Честно: сам iPhone не может подписать IPA — это делает AltStore/Sideloadly на компьютере. UltraTools здесь — инспектор IPA, экспорт в программу подписи и трекер сроков.")
            }
        }
        .navigationTitle("Установка IPA")
        .fileImporter(isPresented: $showImporter, allowedContentTypes: ipaTypes) { result in
            switch result {
            case .success(let url):
                importIPA(from: url)
            case .failure(let error):
                importError = error.localizedDescription
            }
        }
    }

    private var sizeLabel: String {
        String(format: "%.1f МБ", Double(importedSize) / 1_048_576)
    }

    private func bullet(_ icon: String, _ text: String) -> some View {
        Label {
            Text(text).font(.footnote)
        } icon: {
            Image(systemName: icon).foregroundStyle(Color.accentColor)
        }
        .padding(.vertical, 2)
    }

    private func importIPA(from url: URL) {
        importError = nil
        importedInfo = nil
        importedURL = nil
        let ext = url.pathExtension.lowercased()
        guard ext == "ipa" || ext == "zip" else {
            importError = "Файл .\(ext) — не IPA. Выбери файл с расширением .ipa."
            return
        }
        isImporting = true
        Task {
            let result = await Self.loadIPA(from: url)
            isImporting = false
            switch result {
            case .success(let dest, let size, let info):
                importedURL = dest
                importedSize = size
                importedInfo = info
            case .failure(let error):
                importError = "Не удалось открыть файл: \(error.localizedDescription)"
            }
        }
    }

    /// Тяжёлая работа (копия файла + разбор ZIP) вне главного потока,
    /// чтобы системное окно выбора файла закрывалось мгновенно.
    nonisolated private static func loadIPA(from url: URL) async -> Result<(dest: URL, size: Int, info: IPAAppInfo?), any Error> {
        let didStart = url.startAccessingSecurityScopedResource()
        defer { if didStart { url.stopAccessingSecurityScopedResource() } }
        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dest = docs.appendingPathComponent(url.lastPathComponent)
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: url, to: dest)
            let data = try Data(contentsOf: dest, options: .alwaysMapped)
            return .success((dest, data.count, IPAInspector.inspect(data: data)))
        } catch {
            return .failure(error)
        }
    }
}

private struct SignedAppRow: View {
    let app: SignedApp
    let daysLeft: Int
    let onRefresh: () -> Void
    let onDelete: () -> Void

    private var badgeColor: Color {
        if daysLeft == 0 { return .red }
        if daysLeft <= 2 { return .orange }
        return .green
    }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name).font(.subheadline.weight(.semibold))
                Text("установлено \(app.installDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(daysLeft == 0 ? "истекло!" : "осталось \(daysLeft) дн.")
                .font(.caption.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(badgeColor.opacity(0.18)))
                .foregroundStyle(badgeColor)
        }
        .swipeActions(edge: .leading) {
            Button("Обновлено", action: onRefresh).tint(.green)
        }
        .swipeActions(edge: .trailing) {
            Button("Удалить", role: .destructive, action: onDelete)
        }
        .contextMenu {
            Button("Отметить обновлённым", action: onRefresh)
            Button("Удалить", role: .destructive, action: onDelete)
        }
    }
}
