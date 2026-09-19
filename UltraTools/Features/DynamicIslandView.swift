import SwiftUI

struct DynamicIslandView: View {
    var body: some View {
        NavigationStack { DynamicIslandContent() }
    }
}

struct DynamicIslandContent: View {
    @EnvironmentObject private var island: IslandManager
    @State private var minutes: Double = 1
    @State private var emoji = "⏱️"

    private let emojis = ["⏱️", "🎧", "🔋", "🏃‍♂️", "🍕"]
    private let durations: [(label: String, value: Double)] = [
        ("1 минута", 1), ("3 минуты", 3), ("5 минут", 5), ("10 минут", 10)
    ]

    var body: some View {
        List {
            Section {
                Text("Запустите таймер — он появится на Dynamic Island. На iPhone 14 Pro и новее это настоящий остров сверху экрана. На остальных моделях активность видна на экране блокировки, а внутри приложения работает плавающий остров.")
                    .font(.footnote)
            }

            Section("Настройка таймера") {
                Picker("Иконка", selection: $emoji) {
                    ForEach(emojis, id: \.self) { e in
                        Text(e).tag(e)
                    }
                }
                Picker("Длительность", selection: $minutes) {
                    ForEach(durations, id: \.value) { d in
                        Text(d.label).tag(d.value)
                    }
                }
            }

            Section {
                Button {
                    island.start(title: "UltraTools", emoji: emoji, minutes: minutes)
                } label: {
                    Label("Запустить на острове", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }

                if island.isActivityRunning || island.showOverlay {
                    Button(role: .destructive) {
                        island.stop()
                    } label: {
                        Label("Остановить", systemImage: "stop.circle")
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            if let message = island.errorMessage {
                Section("Внимание") {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }

            if !island.activitiesEnabled {
                Section {
                    Label("Live Activities выключены — настоящий остров не появится. Включите: Настройки → UltraTools → Live Activities.", systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }
        }
        .navigationTitle("Dynamic Island")
    }
}
