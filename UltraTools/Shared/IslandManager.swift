import SwiftUI
import ActivityKit
import WidgetKit

/// Управляет Live Activity (настоящий Dynamic Island на поддерживаемых
/// моделях) и плавающим «островом» внутри приложения.
@MainActor
final class IslandManager: ObservableObject {
    @Published var isActivityRunning = false
    @Published var showOverlay = false
    @Published var overlayTitle = ""
    @Published var overlayEmoji = "🏝️"
    @Published var overlayStartsAt = Date()
    @Published var overlayEndsAt = Date()
    @Published var activitiesEnabled = false
    @Published var errorMessage: String?

    private var currentActivity: Activity<UltraTimerAttributes>?

    init() {
        if #available(iOS 16.1, *) {
            activitiesEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
        }
    }

    func start(title: String, emoji: String, minutes: Double) {
        let startsAt = Date()
        let endsAt = startsAt.addingTimeInterval(minutes * 60)

        overlayTitle = title
        overlayEmoji = emoji
        overlayStartsAt = startsAt
        overlayEndsAt = endsAt
        showOverlay = true

        guard #available(iOS 16.1, *) else {
            errorMessage = "Для настоящего Dynamic Island нужна iOS 16.1 или новее."
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            activitiesEnabled = false
            errorMessage = "Live Activities выключены. Откройте Настройки → UltraTools → Live Activities и включите их."
            return
        }

        let attributes = UltraTimerAttributes(label: title)
        let state = UltraTimerAttributes.ContentState(
            title: title,
            emoji: emoji,
            startsAt: startsAt,
            endsAt: endsAt
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
            isActivityRunning = true
            activitiesEnabled = true
            errorMessage = nil
        } catch {
            isActivityRunning = false
            errorMessage = "Не удалось запустить Live Activity: \(error.localizedDescription)"
        }
    }

    func stop() {
        if #available(iOS 16.1, *), let activity = currentActivity {
            let finalState = UltraTimerAttributes.ContentState(
                title: overlayTitle,
                emoji: overlayEmoji,
                startsAt: overlayStartsAt,
                endsAt: overlayEndsAt
            )
            Task {
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
            currentActivity = nil
        }
        isActivityRunning = false
        showOverlay = false
    }
}
