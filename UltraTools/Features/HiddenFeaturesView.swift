import SwiftUI
import UIKit

struct HiddenFeaturesView: View {
    var body: some View {
        NavigationStack { HiddenFeaturesContent() }
    }
}

struct HiddenSecret: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

struct HiddenFeaturesContent: View {
    @State private var showCopied = false

    private let codes: [HiddenSecret] = [
        HiddenSecret(
            icon: "number",
            title: "*#06#",
            detail: "«Паспорт» устройства: IMEI, EID, статус SIM. Больше нигде в интерфейсе не показывается."
        ),
        HiddenSecret(
            icon: "phone.arrow.down.left.fill",
            title: "*#21#",
            detail: "Проверка, не переадресованы ли ваши звонки и SMS — главный признак прослушки номера."
        ),
        HiddenSecret(
            icon: "phone.badge.waveform",
            title: "*#62#",
            detail: "Показывает, куда уходят звонки, когда телефон выключен или вне сети."
        ),
        HiddenSecret(
            icon: "phone.fill.badge.plus",
            title: "*#67#",
            detail: "Проверка переадресации, когда линия занята."
        ),
        HiddenSecret(
            icon: "xmark.shield.fill",
            title: "##002#",
            detail: "Отключает ВСЮ переадресацию одной командой — антивыслеживающая мера."
        ),
        HiddenSecret(
            icon: "eye.slash.fill",
            title: "#31# + номер",
            detail: "Позвонить со скрытого номера: наберите #31#, затем номер, и вызов."
        ),
        HiddenSecret(
            icon: "antenna.radiowaves.left.and.right",
            title: "*3001#12345#*",
            detail: "Field Test: скрытое сервисное меню — точный сигнал в dBm, данные о соте и модеме."
        )
    ]

    private let gestures: [HiddenSecret] = [
        HiddenSecret(
            icon: "waveform.and.mic",
            title: "Запись экрана со звуком",
            detail: "Удерживайте кнопку записи экрана в Пункте управления — появится включение микрофона. Об этом почти никто не знает."
        ),
        HiddenSecret(
            icon: "flashlight.on.fill",
            title: "Яркость фонарика",
            detail: "Удерживайте значок фонарика в Пункте управления — появится слайдер яркости на 4 уровня."
        ),
        HiddenSecret(
            icon: "keyboard.onehanded.left",
            title: "Клавиатура одной рукой",
            detail: "Удерживайте значок глобуса на клавиатуре — она сдвинется к краю экрана для удобной печати большим пальцем."
        ),
        HiddenSecret(
            icon: "cursorarrow.rays",
            title: "Клавиатура-трекпад",
            detail: "Зажмите пробел — клавиатура станет трекпадом, и курсор в тексте двигается пальцем, как мышкой."
        ),
        HiddenSecret(
            icon: "safari.fill",
            title: "Мгновенные вкладки в Safari",
            detail: "Проведите пальцем вдоль нижней адресной строки влево-вправо — вкладки переключаются без карусели."
        ),
        HiddenSecret(
            icon: "camera.fill",
            title: "Серийная съёмка",
            detail: "Удерживайте кнопку спуска в Камере — серия снимков. Кнопки громкости тоже снимают, а в настройках им можно включить быструю серию."
        ),
        HiddenSecret(
            icon: "sos.circle.fill",
            title: "Экстренный SOS",
            detail: "5 быстрых нажатий боковой кнопки — звонок 112 и сообщение экстренным контактам с геопозицией."
        ),
        HiddenSecret(
            icon: "stethoscope",
            title: "sysdiagnose — полный лог системы",
            detail: "Громкость вверх + громкость вниз + питание одновременно (коротко) — iPhone скрыто собирает полную диагностику. В интерфейсе этого нет."
        )
    ]

    var body: some View {
        List {
            Section("Скрытые коды (набирать в «Телефоне»)") {
                ForEach(codes) { secret in
                    CodeRow(secret: secret) { copyCode(secret.title) }
                }
            }

            Section("Скрытые жесты") {
                ForEach(gestures) { secret in
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(secret.title)
                                .font(.subheadline.weight(.semibold))
                            Text(secret.detail)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: secret.icon)
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(.vertical, 2)
                }
            }

            Section {
                Text("Этих функций нет в Настройках — это скрытые коды и жесты самой системы. iOS запрещает приложениям набирать коды за вас, поэтому по кнопке «Скопировать» код улетает в буфер — вставьте его в «Телефоне» и нажмите вызов.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Секреты iOS")
        .alert("Код скопирован", isPresented: $showCopied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Откройте «Телефон», вставьте код в набор номера и нажмите вызов.")
        }
    }

    private func copyCode(_ code: String) {
        UIPasteboard.general.string = code
        showCopied = true
    }
}

private struct CodeRow: View {
    let secret: HiddenSecret
    let action: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: secret.icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(secret.title)
                    .font(.subheadline.weight(.bold).monospaced())
                Text(secret.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Скопировать", action: action)
                .buttonStyle(.borderless)
                .font(.subheadline.weight(.medium))
        }
        .padding(.vertical, 2)
    }
}
