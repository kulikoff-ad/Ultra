import SwiftUI
import UIKit

struct CertificatesView: View {
    var body: some View {
        NavigationStack { CertificatesContent() }
    }
}

struct CertificatesContent: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Честно о сертификатах", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Text("""
                    Ни одно приложение на iPhone не может само «установить сертификат навсегда» — так обещают только фейковые приложения. Сертификаты выдаёт только Apple, и у каждого есть срок действия. Ниже — реальные способы ставить любые IPA.
                    """)
                    .font(.footnote)
                }
                .padding(.vertical, 4)
            }

            Section("Как на самом деле работает подпись") {
                SigningOptionRow(
                    title: "Бесплатный Apple ID",
                    term: "7 дней",
                    detail: "AltStore или Sideloadly подписывают IPA вашим аккаунтом прямо с компьютера. Продлевать нужно раз в неделю — AltStore делает это автоматически по Wi-Fi."
                )
                SigningOptionRow(
                    title: "Apple Developer Program",
                    term: "1 год",
                    detail: "Платный аккаунт разработчика ($99/год). Приложения подписываются на срок до года — это максимально «надолго», который разрешает Apple."
                )
                SigningOptionRow(
                    title: "«Вечные» корпоративные сертификаты",
                    term: "до отзыва",
                    detail: "Неофициальные сервисы, которые обещают установку «навсегда». Apple отзывает такие сертификаты — приложения перестают запускаться. Не рекомендуем."
                )
            }

            Section("Установка любого IPA — по шагам") {
                StepRow(index: 1, text: "Установите на компьютер AltStore (altstore.io) или Sideloadly (sideloadly.io).")
                StepRow(index: 2, text: "Войдите в программу под своим Apple ID.")
                StepRow(index: 3, text: "Перетащите нужный .ipa-файл в окно программы — приложение появится на iPhone.")
                StepRow(index: 4, text: "Включите Wi-Fi-синхронизацию в AltStore, чтобы подпись обновлялась автоматически и приложение не «протухало».")
            }

            Section("Полезные ссылки") {
                LinkRow(title: "AltStore", subtitle: "altstore.io", url: "https://altstore.io")
                LinkRow(title: "Sideloadly", subtitle: "sideloadly.io", url: "https://sideloadly.io")
                LinkRow(title: "Apple Developer Program", subtitle: "developer.apple.com", url: "https://developer.apple.com/programs/")
            }

            Section("Почему здесь нет кнопки «установить сертификат»") {
                Text("Такой кнопки не существует в принципе: приложения на iOS не имеют доступа к системному хранилищу сертификатов для подписи других приложений. Любой сайт или приложение, обещающее «сертификат навсегда за одну кнопку», в лучшем случае обманывает, в худшем — крадёт данные.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Сертификаты")
    }
}

private struct SigningOptionRow: View {
    let title: String
    let term: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                Text(term)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.orange.opacity(0.2)))
                    .foregroundStyle(.orange)
            }
            Text(detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

private struct StepRow: View {
    let index: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(index)")
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.accentColor.opacity(0.15)))
                .foregroundStyle(Color.accentColor)
            Text(text).font(.footnote)
        }
        .padding(.vertical, 2)
    }
}

private struct LinkRow: View {
    let title: String
    let subtitle: String
    let url: String

    var body: some View {
        if let link = URL(string: url) {
            Link(destination: link) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.subheadline.weight(.medium))
                        Text(subtitle).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
