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

    init(mouseTracker: MouseTracker = MouseTracker(), globalShortcut: GlobalShortcut? = nil) {
        self.mouseTracker = mouseTracker
        self.globalShortcut = globalShortcut ?? GlobalShortcut()

        panel = ShelfWindow(contentRect: NSRect(origin: .zero, size: ShelfAnimation.expandedSize))
        panel.contentView = NSHostingView(rootView: ShelfView(
            state: animationState,
            store: clipboardStore,
            onCopied: { [weak self] in self?.collapseImmediately() },
            onCollapseRequested: { [weak self] in self?.collapseImmediately() }
        ))

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
        isExpanded = true
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
        animationState.collapse()
        mouseTracker.updateShelfFrame(nil)
        panel.resignKey()
    }
}
