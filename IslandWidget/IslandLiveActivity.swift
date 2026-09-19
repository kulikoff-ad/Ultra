import ActivityKit
import SwiftUI
import WidgetKit

@main
struct IslandWidgetBundle: WidgetBundle {
    var body: some Widget {
        IslandLiveActivity()
    }
}

struct IslandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: UltraTimerAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.emoji)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(
                        timerInterval: context.state.startsAt...context.state.endsAt,
                        countsDown: true
                    )
                    .font(.title3.monospacedDigit().bold())
                    .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: progress(for: context.state))
                        .tint(.orange)
                        .padding(.horizontal, 4)
                }
            } compactLeading: {
                Text(context.state.emoji)
            } compactTrailing: {
                Text(
                    timerInterval: context.state.startsAt...context.state.endsAt,
                    countsDown: true
                )
                .font(.caption2.monospacedDigit())
            } minimal: {
                Text(context.state.emoji)
            }
        }
    }

    private func progress(for state: UltraTimerAttributes.ContentState) -> Double {
        let total = state.endsAt.timeIntervalSince(state.startsAt)
        guard total > 0 else { return 1 }
        let elapsed = Date().timeIntervalSince(state.startsAt)
        return min(max(elapsed / total, 0), 1)
    }

    private func lockScreenView(context: ActivityViewContext<UltraTimerAttributes>) -> some View {
        HStack(spacing: 12) {
            Text(context.state.emoji)
                .font(.largeTitle)
            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.title)
                    .font(.headline)
                Text(
                    timerInterval: context.state.startsAt...context.state.endsAt,
                    countsDown: true
                )
                .font(.title2.monospacedDigit())
            }
            Spacer()
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.75))
    }
}
