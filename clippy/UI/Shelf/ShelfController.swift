import AppKit
import SwiftUI

// MARK: - Controls shelf presentation lifecycle (show/hide/toggle)

/// Owns the shelf's `isExpanded` state and coordinates `MouseTracker`
/// callbacks with `ShelfWindow`'s show/hide and the capsule → shelf
/// expansion animation (`ShelfAnimation`).
@MainActor
final class ShelfController {
    private(set) var isExpanded = false

    private let panel: ShelfWindow
    private let mouseTracker: MouseTracker
    private let globalShortcut: GlobalShortcut
    private let animationState = ShelfAnimationState()
    private let clipboardStore = ClipboardStore()
    private var previousApp: NSRunningApplication?

    init(mouseTracker: MouseTracker = MouseTracker(), globalShortcut: GlobalShortcut? = nil) {
        self.mouseTracker = mouseTracker
        self.globalShortcut = globalShortcut ?? GlobalShortcut()

        panel = ShelfWindow(contentRect: NSRect(origin: .zero, size: ShelfAnimation.expandedSize))
        panel.ignoresMouseEvents = true
        let hostingView = NonFocusRingHostingView(rootView: ShelfView(
            state: animationState,
            store: clipboardStore,
            onCopied: { [weak self] in
                guard let self else { return }
                let target = self.previousApp
                self.collapseImmediately()
                let isDirectPasteEnabled = UserDefaults.standard.object(forKey: "isDirectPasteEnabled") as? Bool ?? true
                if isDirectPasteEnabled {
                    ClipboardWriter.pasteToFrontmostApp(targetApp: target)
                }
            },
            onCollapseRequested: { [weak self] in self?.collapseImmediately() }
        ))
        hostingView.focusRingType = .none
        panel.contentView = hostingView

        self.mouseTracker.onExpand = { [weak self] in self?.expand() }
        self.mouseTracker.onCollapse = { [weak self] in self?.collapse() }
        self.globalShortcut.onToggle = { [weak self] in self?.toggle() }
    }

    /// Anchors the panel top-center on the active screen, shows the
    /// collapsed capsule, and starts mouse tracking and the global hotkey.
    func start() {
        panel.positionAtTopCenter()
        panel.orderFrontRegardless()
        mouseTracker.start()
        globalShortcut.start()
    }

    func stop() {
        mouseTracker.stop()
        globalShortcut.stop()
        panel.orderOut(nil)
    }

    /// Opens/closes the shelf independent of mouse hover — the global-hotkey
    /// path (⌘⇧V by default).
    func toggle() {
        isExpanded ? collapse() : expand()
    }

    /// Collapses immediately (e.g. after a card tap copies an item, or Esc),
    /// bypassing the normal hover-based delay.
    func collapseImmediately() {
        collapse()
        mouseTracker.forceCollapse()
    }

    /// Opens the expanded clipboard shelf.
    func openClipboard() {
        expand()
    }

    /// Opens the shelf for searching items.
    func openSearch() {
        expand()
    }

    /// Selects the History collection and opens the shelf.
    func openHistory() {
        clipboardStore.selectedCollectionID = Collection.history.id
        expand()
    }

    /// Selects the Favorites collection and opens the shelf.
    func openFavorites() {
        clipboardStore.selectedCollectionID = Collection.favorites.id
        expand()
    }

    func expand() {
        guard !isExpanded else { return }
        let frontmost = NSWorkspace.shared.frontmostApplication
        if let frontmost, frontmost.processIdentifier != NSRunningApplication.current.processIdentifier {
            previousApp = frontmost
        }
        isExpanded = true
        panel.ignoresMouseEvents = false
        animationState.expand()
        // Once expanded, hovering anywhere over the shelf's footprint
        // counts as "still in use" — not just the narrow trigger strip.
        mouseTracker.updateShelfFrame(panel.frame)
        // Grabs keyboard focus for arrow-key navigation without activating
        // the app — `.nonactivatingPanel` (see ShelfWindow) keeps whatever
        // app was frontmost from losing that status.
        panel.makeKeyAndOrderFront(nil)
    }

    private func collapse() {
        guard isExpanded else { return }
        isExpanded = false
        panel.ignoresMouseEvents = true
        animationState.collapse()
        mouseTracker.updateShelfFrame(nil)
        panel.resignKey()
    }
}

// MARK: - Hosting View without Focus Ring

/// An `NSHostingView` subclass that completely suppresses the AppKit focus ring
/// to prevent macOS from drawing a light blue accent border around the panel.
private final class NonFocusRingHostingView<Content: View>: NSHostingView<Content> {
    override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }

    override func drawFocusRingMask() {
        // Suppress drawing any focus ring mask
    }
}



