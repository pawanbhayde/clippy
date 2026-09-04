import AppKit

// MARK: - AppKit window hosting the shelf UI

/// Borderless, non-activating floating panel that hosts the clipboard
/// shelf UI. Floats above normal windows on every Space, positioned just
/// below the notch/menu bar at the top-center of the active screen.
final class ShelfWindow: NSPanel {
    convenience init(contentRect: NSRect = .zero) {
        self.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
    }

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
    }

    /// Borderless windows default to `canBecomeKey == false`. Overridden so
    /// the panel can still accept keyboard events (arrow-key navigation,
    /// Enter, Esc) while expanded — `.nonactivatingPanel` already keeps this
    /// from activating the app or stealing focus from whatever was frontmost.
    override var canBecomeKey: Bool { true }

    /// Moves the panel to the top-center of the active screen, just below
    /// the notch/menu bar.
    func positionAtTopCenter() {
        setFrameOrigin(ScreenManager.topCenterPosition(panelSize: frame.size))
    }
}
