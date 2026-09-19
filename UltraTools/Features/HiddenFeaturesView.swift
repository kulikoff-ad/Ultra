import SwiftUI
import UIKit

struct HiddenFeaturesView: View {
    var body: some View {
        NavigationStack { HiddenFeaturesContent() }
    }
}

struct HiddenFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
    var deepLink: String? = nil
    var manualPath: String? = nil
}

struct HiddenFeaturesContent: View {
    @State private var manualFeature: HiddenFeature?
    @State private var showManualAlert = false

    private let linkedFeatures: [HiddenFeature] = [
        HiddenFeature(
            icon: "hand.tap.fill",
            title: "Back Tap — стук по корпусу",
            detail: "Двойной или тройной стук по спинке телефона выполняет действие: скриншот, фонарик, жест и т.д.",
            deepLink: "App-prefs:root=ACCESSIBILITY&path=TOUCH",
            manualPath: "Настройки → Универсальный доступ → Касание → Касание задней панели"
        ),
        HiddenFeature(
            icon: "keyboard.fill",
            title: "Вибрация клавиатуры",
            detail: "Клавиатура может откликаться лёгкой вибрацией на каждое нажатие.",
            deepLink: "App-prefs:root=General&path=Keyboard",
            manualPath: "Настройки → Звуки, тактильные сигналы → Отклик клавиатуры"
        ),
        HiddenFeature(
            icon: "battery.100.bolt",
            title: "Процент заряда в статус-баре",
            detail: "Цифра заряда прямо в значке батареи.",
            deepLink: "App-prefs:root=BATTERY_USAGE",
            manualPath: "Настройки → Аккумулятор"
        ),
        HiddenFeature(
            icon: "moon.fill",
            title: "Тёмный режим по расписанию",
            detail: "Автоматическое включение тёмной темы вечером.",
            deepLink: "App-prefs:root=DISPLAY",
            manualPath: "Настройки → Экран и яркость → Тёмный режим → Автоматически"
        ),
        HiddenFeature(
            icon: "photo.on.rectangle",
            title: "Фото и скрытый альбом",
            detail: "Скрытые альбомы и настройка блокировки скрытых фото по Face ID.",
            deepLink: "App-prefs:root=Photos",
            manualPath: "Настройки → Фото"
        ),
        HiddenFeature(
            icon: "internaldrive.fill",
            title: "Что занимает память",
            detail: "Детальная разбивка хранилища по приложениям и файлам.",
            deepLink: "App-prefs:root=General&path=IPHONE_STORAGE",
            manualPath: "Настройки → Основные → Хранилище iPhone"
        )
    ]

    private let secretFeatures: [HiddenFeature] = [
        HiddenFeature(
            icon: "antenna.radiowaves.left.and.right",
            title: "Field Test — точный сигнал",
            detail: "Наберите в «Телефоне» код *3001#12345#* и нажмите вызов: откроется сервисное меню с уровнем сигнала в dBm и данными о соте."
        ),
        HiddenFeature(
            icon: "cursorarrow.rays",
            title: "Клавиатура-трекпад",
            detail: "Зажмите пробел на клавиатуре — она превратится в трекпад для точного перемещения курсора в тексте."
        ),
        HiddenFeature(
            icon: "text.viewfinder",
            title: "Live Text — текст с фото",
            detail: "В Камере или Фото нажмите значок текста: любой текст с картинки можно скопировать, перевести или набрать с него номер."
        ),
        HiddenFeature(
            icon: "power",
            title: "Выключение без кнопок",
            detail: "Настройки → Основные → Выключить. Полезно, если кнопки сломаны. Принудительная перезагрузка: громкость вверх, громкость вниз, зажать боковую кнопку."
        ),
        HiddenFeature(
            icon: "timer",
            title: "Таймер со сном",
            detail: "В Таймере → «Когда таймер закончится» → «Остановить воспроизведение»: музыка перестаёт играть и экран блокируется — удобно для засыпания."
        ),
        HiddenFeature(
            icon: "moon.zzz.fill",
            title: "Скрытые возможности Фокусирования",
            detail: "Режимы Фокусирования могут скрывать целые рабочие столы приложений и менять экран блокировки по расписанию или геолокации."
        )
    ]

    var body: some View {
        List {
            Section("Быстрый доступ к настройкам") {
                ForEach(linkedFeatures) { feature in
                    FeatureRow(feature: feature) { open(feature) }
                }
            }

            Section("Скрытые коды и жесты") {
                ForEach(secretFeatures) { feature in
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.title)
                                .font(.subheadline.weight(.semibold))
                            Text(feature.detail)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: feature.icon)
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(.vertical, 2)
                }
            }

            Section {
                Text("Это реальные системные функции iOS. Deep-link открывает страницу Настроек напрямую; если на вашей версии iOS он не сработал — приложение подскажет путь вручную.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Секреты iOS")
        .alert("Откройте вручную", isPresented: $showManualAlert) {
            Button("Понятно", role: .cancel) {}
        } message: {
            Text(manualFeature?.manualPath ?? "Откройте эту функцию через приложение «Настройки».")
        }
    }

    private func open(_ feature: HiddenFeature) {
        guard let link = feature.deepLink, let url = URL(string: link) else {
            presentManual(feature)
            return
        }
        UIApplication.shared.open(url) { success in
            if !success {
                presentManual(feature)
            }
        }
    }

    private func presentManual(_ feature: HiddenFeature) {
        manualFeature = feature
        showManualAlert = true
    }
}

private struct FeatureRow: View {
    let feature: HiddenFeature
    let action: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: feature.icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.subheadline.weight(.semibold))
                Text(feature.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Открыть", action: action)
                .buttonStyle(.borderless)
                .font(.subheadline.weight(.medium))
        }
        .padding(.vertical, 2)
    }
}
