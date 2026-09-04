import SwiftUI

// MARK: - Drop Zone target visual displaying 2 options: Temporary Stash & Save to Clippy

struct DropZoneView: View {
    @ObservedObject var stashManager = StashManager.shared

    var body: some View {
        HStack(spacing: 14) {
            // Option 1: Temporary Stash
            dropOptionBox(
                target: .stash,
                icon: "tray.and.arrow.down.fill",
                title: "Temporary Stash",
                description: "Hold across Spaces • Drag out to move",
                activePrompt: "Release to Hold in Stash"
            )

            // Option 2: Save to Clippy
            dropOptionBox(
                target: .clippy,
                icon: "square.and.arrow.down.fill",
                title: "Save to Clippy",
                description: "Permanently save to Clipboard History",
                activePrompt: "Release to Save to Clippy"
            )
        }
        .frame(height: 135)
        .padding(.horizontal, 4)
    }

    private func dropOptionBox(
        target: StashManager.DropZoneTarget,
        icon: String,
        title: String,
        description: String,
        activePrompt: String
    ) -> some View {
        let isHighlighted = stashManager.isDropZoneActive && stashManager.activeDropTarget == target

        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(white: 0.13))

            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    isHighlighted ? Color.white : (stashManager.isDropZoneActive ? Color.white.opacity(0.35) : Color.white.opacity(0.18)),
                    style: StrokeStyle(lineWidth: isHighlighted ? 2.5 : 1.5, dash: isHighlighted ? [] : [6, 6])
                )
                .animation(.easeInOut(duration: 0.2), value: isHighlighted)

            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isHighlighted ? Color.white.opacity(0.25) : Color.white.opacity(0.08))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isHighlighted ? Color.white : Color(white: 0.85))
                        .scaleEffect(isHighlighted ? 1.18 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHighlighted)
                }

                Text(isHighlighted ? activePrompt : title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white)

                Text(description)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(Color(white: 0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
