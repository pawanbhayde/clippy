import AppKit

// MARK: - AppKit window hosting the shelf UI

/// Borderless, non-activating floating panel that hosts the clipboard
/// shelf UI. Floats above normal windows on every Space, positioned just
/// below the notch/menu bar at the top-center of the active screen.
final class ShelfWindow: NSPanel, NSDraggingDestination {
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

        registerForDraggedTypes([
            .fileURL,
            .URL,
            .tiff,
            .png,
            .string,
            NSPasteboard.PasteboardType("public.file-url"),
            NSPasteboard.PasteboardType("com.apple.pasteboard.promised-file-url")
        ])
    }

    var onDragEntered: ((NSDraggingInfo) -> NSDragOperation)?
    var onDragUpdated: ((NSDraggingInfo) -> NSDragOperation)?
    var onDragExited: ((NSDraggingInfo?) -> Void)?
    var onPerformDrag: ((NSDraggingInfo) -> Bool)?

    func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        return onDragEntered?(sender) ?? .copy
    }

    func draggingUpdated(_ sender: any NSDraggingInfo) -> NSDragOperation {
        return onDragUpdated?(sender) ?? .copy
    }

    func draggingExited(_ sender: (any NSDraggingInfo)?) {
        onDragExited?(sender)
    }

    func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        return onPerformDrag?(sender) ?? false
    }

    /// Dynamically controls whether the panel can accept keyboard focus.
    /// While expanded, this is true so arrow keys and shortcuts work.
    /// The instant the shelf collapses or an item is clicked to paste,
    /// this is set to false so the target app immediately regains key focus.
    var canReceiveKeyFocus: Bool = false

    override var canBecomeKey: Bool { canReceiveKeyFocus }

    /// Moves the panel to the top-center of the active screen, just below
    /// the notch/menu bar.
    func positionAtTopCenter() {
        setFrameOrigin(ScreenManager.topCenterPosition(panelSize: frame.size))
    }

    /// Updates the panel's size and re-centers it at top-center of active screen.
    func updateFrame(for size: NSSize, animated: Bool = false) {
        let origin = ScreenManager.topCenterPosition(panelSize: size)
        let targetFrame = NSRect(origin: origin, size: size)
        setFrame(targetFrame, display: true, animate: animated)
    }
}
