import SwiftUI
import UIKit

struct JailbreakView: View {
    var body: some View {
        NavigationStack { JailbreakContent() }
    }
}

struct JailbreakContent: View {
    @State private var iosVersion = "16.0–16.5"
    @State private var isOldChip = false

    private let versions = ["15.0–15.8", "16.0–16.5", "16.6–16.7", "17.x", "18 и новее"]

    private struct Recommendation {
        let tool: String
        let kind: String
        let linkTitle: String
        let link: String
    }

    var body: some View {
        List {
            Section {
                Label("Приложение не может сделать джейлбрейк само — ни одно приложение на iPhone не может. Джейлбрейк ставится специальными утилитами. Здесь вы узнаете, какой настоящий инструмент подходит именно вашему устройству и что с данными.", systemImage: "info.circle.fill")
                    .font(.footnote)
            }

            Section("Выберите своё устройство") {
                Picker("Версия iOS", selection: $iosVersion) {
                    ForEach(versions, id: \.self) { Text($0) }
                }
                Picker("Процессор", selection: $isOldChip) {
                    Text("A11 и старше (iPhone 8/X и раньше)").tag(true)
                    Text("A12 и новее (XS и позже)").tag(false)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section("Результат") {
                resultView
            }

            Section("Без потери файлов — как это работает") {
                bullet(icon: "checkmark.circle.fill", text: "palera1n и Dopamine — rootless/rootfs джейлбрейки: они не трогают раздел с вашими данными, файлы остаются на месте.")
                bullet(icon: "exclamationmark.triangle.fill", text: "Но при ошибке или «полном» джейлбрейке через восстановление можно всё стереть. Поэтому:")
                bullet(icon: "externaldrive.badge.icloud", text: "Перед началом обязательно сделайте резервную копию в Finder или iCloud — тогда файлы не потеряются гарантированно.")
                bullet(icon: "shippingbox.fill", text: "После джейлбрейка появятся Sileo/Zebra — магазины твиков. Твики и открывают по-настоящему скрытые функции системы, недоступные из Настроек.")
            }

            Section {
                Text("Джейлбрейк снижает защищённость iPhone. Используйте только официальные инструменты — palera1n и Dopamine с их сайтов. Никогда не ставьте «джейлбрейк-профили» с неизвестных сайтов: это мошенничество.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Джейлбрейк")
    }

    private var recommendation: Recommendation? {
        if isOldChip {
            return Recommendation(
                tool: "palera1n",
                kind: "Semi-tethered джейлбрейк на аппаратном эксплойте checkm8: не лечится обновлениями, работает на iOS 15–17 для A11 и старше. Данные не стирает.",
                linkTitle: "palera.in — официальный сайт",
                link: "https://palera.in"
            )
        }
        switch iosVersion {
        case "15.0–15.8", "16.0–16.5":
            return Recommendation(
                tool: "Dopamine",
                kind: "Semi-untethered rootless-джейлбрейк для A12+ на iOS 15.0–16.5. Ставится через приложение на самом iPhone, данные не стирает.",
                linkTitle: "Dopamine — официальный GitHub",
                link: "https://github.com/opa334/Dopamine"
            )
        default:
            return nil
        }
    }

    @ViewBuilder
    private var resultView: some View {
        if let rec = recommendation {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(rec.tool)
                        .font(.title3.bold())
                    Spacer()
                    Label("без потери данных", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.green)
                }
                Text(rec.kind)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let link = URL(string: rec.link) {
                    Link(destination: link) {
                        Label(rec.linkTitle, systemImage: "arrow.up.right.square")
                            .font(.subheadline.weight(.medium))
                    }
                }
            }
            .padding(.vertical, 4)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Label("Для iOS \(iosVersion) на этом процессоре публичного джейлбрейка пока нет", systemImage: "lock.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                Text("Apple закрыла уязвимости в этих версиях. Варианты: дождаться релиза, либо использовать устройство A11 и старше, где навсегда работает palera1n. Не верьте сайтам, обещающим «джейлбрейк онлайн» — таких не бывает.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private func bullet(icon: String, text: String) -> some View {
        Label {
            Text(text)
                .font(.footnote)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
        }
        .padding(.vertical, 2)
    }
}
