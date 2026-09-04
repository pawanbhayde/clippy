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
    private var workspaceObserver: Any?
    private var dropObserver: Any?

    init(mouseTracker: MouseTracker? = nil, globalShortcut: GlobalShortcut? = nil) {
        self.mouseTracker = mouseTracker ?? MouseTracker()
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

        // Track active application changes system-wide so previousApp is always up-to-date
        self.workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               app.processIdentifier != NSRunningApplication.current.processIdentifier,
               app.activationPolicy == .regular {
                self.previousApp = app
            }
        }
        if let current = NSWorkspace.shared.frontmostApplication,
           current.processIdentifier != NSRunningApplication.current.processIdentifier,
           current.activationPolicy == .regular {
            self.previousApp = current
        }

        // Collapse shelf cleanly when a drag-and-drop operation completes into a target app
        self.dropObserver = NotificationCenter.default.addObserver(
            forName: .shelfShouldCollapseAfterDrop,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.collapseImmediately()
        }
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
        if let workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(workspaceObserver)
            self.workspaceObserver = nil
        }
        if let dropObserver {
            NotificationCenter.default.removeObserver(dropObserver)
            self.dropObserver = nil
        }
        mouseTracker.stop()
        globalShortcut.stop()
        panel.orderOut(nil)
    }

    deinit {
        if let workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(workspaceObserver)
        }
        if let dropObserver {
            NotificationCenter.default.removeObserver(dropObserver)
        }
    }

    /// Opens/closes the shelf independent of mouse hover — the global-hotkey
    /// path (⌘⇧V by default).
    func toggle() {
        isExpanded ? collapse() : expand()
    }

    /// Collapses immediately (e.g. after a card tap copies an item, or Esc),
    /// bypassing the normal hover-based delay.
    func collapseImmediately() {
        panel.canReceiveKeyFocus = false
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

    /// Clears all clipboard history.
    func clearAllHistory(preserveFavorites: Bool = false) {
        clipboardStore.clearAllHistory(preserveFavorites: preserveFavorites)
    }

    /// Prompts the user with a confirmation alert before clearing history.
    func confirmAndClearHistory() {
        let alert = NSAlert()
        alert.messageText = "Clear Clipboard History"
        alert.informativeText = "Are you sure you want to clear your clipboard history? This will delete copied items and cached files."
        alert.alertStyle = .warning
        let clearAllBtn = alert.addButton(withTitle: "Clear All")
        clearAllBtn.hasDestructiveAction = true
        alert.addButton(withTitle: "Keep Favorites")
        alert.addButton(withTitle: "Cancel")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            clearAllHistory(preserveFavorites: false)
        } else if response == .alertSecondButtonReturn {
            clearAllHistory(preserveFavorites: true)
        }
    }

    func expand() {
        guard !isExpanded else { return }
        let frontmost = NSWorkspace.shared.frontmostApplication
        if let frontmost, frontmost.processIdentifier != NSRunningApplication.current.processIdentifier, frontmost.activationPolicy == .regular {
            previousApp = frontmost
        }
        isExpanded = true
        panel.canReceiveKeyFocus = true
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
        panel.canReceiveKeyFocus = false
        panel.ignoresMouseEvents = true
        animationState.collapse()
        mouseTracker.updateShelfFrame(nil)
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



