import SwiftUI
import UIKit
import ActivityKit

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("UltraTools")
                            .font(.largeTitle.bold())
                        Text("Сертификаты · Секреты iOS · Dynamic Island")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                Section("Устройство") {
                    LabeledContent("Модель", value: UIDevice.current.model)
                    LabeledContent("Имя", value: UIDevice.current.name)
                    LabeledContent("Версия iOS", value: UIDevice.current.systemVersion)
                    LabeledContent("Live Activities", value: liveActivitiesStatus)
                }

                Section("Инструменты") {
                    NavigationLink {
                        InstallIPAContent()
                    } label: {
                        Label("Установка IPA и трекер 7 дней", systemImage: "square.and.arrow.down.fill")
                    }
                    NavigationLink {
                        CertificatesContent()
                    } label: {
                        Label("Сертификаты и установка приложений", systemImage: "checkmark.seal.fill")
                    }
                    NavigationLink {
                        HiddenFeaturesContent()
                    } label: {
                        Label("Скрытые функции iPhone", systemImage: "eye.slash.fill")
                    }
                    NavigationLink {
                        JailbreakContent()
                    } label: {
                        Label("Джейлбрейк без потери данных", systemImage: "lock.open.fill")
                    }
                    NavigationLink {
                        DynamicIslandContent()
                    } label: {
                        Label("Dynamic Island", systemImage: "circle.dotted")
                    }
                }

                Section {
                    Text("UltraTools использует только официальные возможности iOS: Live Activities для «острова», системные настройки и честные способы подписи IPA. Без джейлбрейка и без «магии» — зато всё реально работает.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("UltraTools")
        }
    }

    private var liveActivitiesStatus: String {
        guard #available(iOS 16.2, *) else { return "Нужна iOS 16.2+" }
        return ActivityAuthorizationInfo().areActivitiesEnabled ? "Включены" : "Выключены"
    }
}
