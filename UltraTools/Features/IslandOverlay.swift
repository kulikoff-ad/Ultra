import SwiftUI

/// Плавающая капсула поверх приложения — мини-версия Dynamic Island,
/// работающая на любом iPhone внутри UltraTools.
struct IslandOverlay: View {
    @EnvironmentObject private var island: IslandManager
    @State private var expanded = false

    var body: some View {
        VStack {
            if island.showOverlay {
                capsule
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: island.showOverlay)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: expanded)
        .allowsHitTesting(island.showOverlay)
    }

    private var capsule: some View {
        HStack(spacing: 8) {
            Text(island.overlayEmoji)
            if expanded {
                Text(island.overlayTitle)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                Text(timerInterval: island.overlayStartsAt...island.overlayEndsAt, countsDown: true)
                    .font(.footnote.monospacedDigit().weight(.bold))
                    .foregroundStyle(.orange)
                Button {
                    island.stop()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, expanded ? 14 : 12)
        .padding(.vertical, expanded ? 10 : 8)
        .background(Capsule().fill(Color.black))
        .foregroundStyle(.white)
        .onTapGesture { expanded.toggle() }
        .padding(.top, 4)
    }
}
