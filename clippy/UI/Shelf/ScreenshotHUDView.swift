import SwiftUI

// MARK: - Compact Dynamic Island Notch Pill for Screenshot Capture Options

struct ScreenshotHUDView: View {
    var onSelectMode: (ScreenshotManager.CaptureMode) -> Void
    var onCancel: () -> Void

    @State private var hoveredMode: ScreenshotManager.CaptureMode?

    var body: some View {
        HStack(spacing: 8) {
            // Camera Indicator
            HStack(spacing: 5) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .padding(.leading, 6)

            Divider()
                .frame(height: 14)
                .background(Color.white.opacity(0.2))

            // Capture Options
            ForEach(ScreenshotManager.CaptureMode.allCases) { mode in
                Button {
                    onSelectMode(mode)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: mode.iconName)
                            .font(.system(size: 10, weight: .semibold))
                        Text(mode.title)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(hoveredMode == mode ? .white : Color(white: 0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(hoveredMode == mode ? Color.white.opacity(0.22) : Color.white.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
                .onHover { isHovered in
                    hoveredMode = isHovered ? mode : nil
                }
                .help(mode.helpText)
            }

            Divider()
                .frame(height: 14)
                .background(Color.white.opacity(0.2))

            // Cancel Button
            Button {
                onCancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(white: 0.7))
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            .buttonStyle(.plain)
            .help("Cancel Screenshot (Esc)")
            .padding(.trailing, 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black)
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 4)
        )
        .frame(height: 32)
    }
}
