import AppKit

// MARK: - Resolves screen/display geometry for positioning app windows

enum ScreenManager {
    private static let topGap: CGFloat = 8

    /// The screen to treat as "active" for positioning: the one under the
    /// mouse cursor, falling back to the main screen for multi-monitor
    /// setups where the cursor position can't be resolved to a screen.
    static func activeScreen() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(mouseLocation) } ?? NSScreen.main
    }

    /// The height reserved at the top of `screen` by the notch/camera
    /// housing on notched displays, or by the plain menu bar otherwise.
    static func topInset(for screen: NSScreen) -> CGFloat {
        screen.safeAreaInsets.top > 0
            ? screen.safeAreaInsets.top
            : screen.frame.maxY - screen.visibleFrame.maxY
    }

    /// The top-left origin for a panel of `panelSize`, horizontally
    /// centered and docked flush to the top edge of `screen` (matching
    /// the Dynamic Island / notch silhouette) — defaulting to `activeScreen()`.
    static func topCenterPosition(for screen: NSScreen? = nil, panelSize: NSSize) -> NSPoint {
        guard let screen = screen ?? activeScreen() else { return .zero }

        let frame = screen.frame
        let originX = frame.midX - panelSize.width / 2
        let originY = frame.maxY - panelSize.height
        return NSPoint(x: originX, y: originY)
    }
}
