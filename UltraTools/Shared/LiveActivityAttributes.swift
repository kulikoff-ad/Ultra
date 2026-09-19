import ActivityKit
import Foundation

/// Общий тип активности для таймера на Dynamic Island.
/// Используется и приложением, и виджетом-расширением.
struct UltraTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var emoji: String
        var startsAt: Date
        var endsAt: Date
    }

    var label: String
}
