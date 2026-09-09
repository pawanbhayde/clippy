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
    let animationState = ShelfAnimationState()
    private let clipboardStore = ClipboardStore()
    private var previousApp: NSRunningApplication?
    private var workspaceObserver: Any?
    private var dropObserver: Any?
    private var newItemObserver: Any?
    private var copyNotificationDismissWorkItem: DispatchWorkItem?
    private var clickOutsideGlobalMonitor: Any?
    private var clickOutsideLocalMonitor: Any?
    private var screenshotKeyMonitor: Any?
    private var writingToolsPanelController: WritingToolsPanelController?

    init(mouseTracker: MouseTracker? = nil, globalShortcut: GlobalShortcut? = nil) {
        self.mouseTracker = mouseTracker ?? MouseTracker()
        self.globalShortcut = globalShortcut ?? GlobalShortcut()

        panel = ShelfWindow(contentRect: NSRect(origin: .zero, size: ShelfAnimation.collapsedSize))
        panel.ignoresMouseEvents = true
        let hostingView = NonFocusRingHostingView(rootView: ShelfView(
            state: animationState,
            store: clipboardStore,
            onCopied: { [weak self] in
                guard let self else { return }
                var target = self.previousApp
                if target == nil || target?.isTerminated == true {
                    if let menuBarApp = NSWorkspace.shared.menuBarOwningApplication,
                       menuBarApp.processIdentifier != NSRunningApplication.current.processIdentifier,
                       menuBarApp.activationPolicy == .regular {
                        target = menuBarApp
                    }
                }
                self.collapseImmediately()
                let isDirectPasteEnabled = UserDefaults.standard.object(forKey: "isDirectPasteEnabled") as? Bool ?? true
                if isDirectPasteEnabled {
                    ClipboardWriter.pasteToFrontmostApp(targetApp: target)
                }
            },
            onCollapseRequested: { [weak self] in self?.collapse() },
            onExpandRequested: { [weak self] in self?.expand() },
            onStartScreenshot: { [weak self] in self?.startScreenshotFlow() },
            onCaptureScreenshot: { [weak self] mode in self?.executeScreenshotCapture(mode: mode) },
            onCancelScreenshot: { [weak self] in self?.cancelScreenshotHUD() },
            onOpenWritingToolsPanel: { [weak self] item in self?.openWritingToolsPanel(for: item) }
        ))
        hostingView.focusRingType = .none
        hostingView.shelfController = self
        hostingView.registerForDraggedTypes([
            .fileURL,
            .URL,
            .tiff,
            .png,
            .string,
            NSPasteboard.PasteboardType("public.file-url"),
            NSPasteboard.PasteboardType("com.apple.pasteboard.promised-file-url")
        ])
        panel.contentView = hostingView

        panel.onDragEntered = { [weak self] _ in
            self?.expandForDropZone()
            return .copy
        }
        panel.onDragUpdated = { [weak self] sender in
            StashManager.shared.isDropZoneActive = true
            if let window = self?.panel {
                let localX = sender.draggingLocation.x
                if localX < window.frame.width / 2 {
                    StashManager.shared.activeDropTarget = .stash
                } else {
                    StashManager.shared.activeDropTarget = .clippy
                }
            }
            return .copy
        }
        panel.onDragExited = { [weak self] _ in
            StashManager.shared.isDropZoneActive = false
            StashManager.shared.activeDropTarget = .none
            self?.scheduleCollapseAfterDragExited()
        }
        panel.onPerformDrag = { [weak self] sender in
            let target = StashManager.shared.activeDropTarget
            StashManager.shared.isDropZoneActive = false
            StashManager.shared.activeDropTarget = .none

            if target == .clippy {
                let success = ClipboardService.shared.saveToClippy(from: sender.draggingPasteboard)
                if success {
                    NSSound(named: "Glass")?.play()
                    Task { @MainActor in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            StashManager.shared.isStashViewSelected = false
                        }
                    }
                    self?.expand()
                    return true
                }
                return false
            } else {
                let count = StashManager.shared.addItems(from: sender.draggingPasteboard)
                if count > 0 {
                    self?.expand()
                    return true
                }
                return false
            }
        }

        self.mouseTracker.onExpand = { [weak self] in self?.expand() }
        self.mouseTracker.onCollapse = { [weak self] in self?.collapse() }
        self.globalShortcut.onToggle = { [weak self] in self?.toggle() }

        // Track active application changes system-wide so previousApp is always up-to-date
        self.workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            MainActor.assumeIsolated {
                guard let self else { return }
                if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                   app.processIdentifier != NSRunningApplication.current.processIdentifier,
                   app.activationPolicy == .regular {
                    self.previousApp = app
                }
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
            MainActor.assumeIsolated {
                self?.collapseImmediately()
            }
        }

        // Show Dynamic Island notch pill notification whenever a new item is captured and saved
        self.newItemObserver = NotificationCenter.default.addObserver(
            forName: .clippyNewItemSaved,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            MainActor.assumeIsolated {
                guard let self, let item = notification.userInfo?["item"] as? ClipboardItem else { return }
                self.showCopyNotification(for: item)
            }
        }
    }

    /// Anchors the panel top-center on the active screen, shows the
    /// collapsed capsule, and starts mouse tracking and the global hotkey.
    func start() {
        panel.updateFrame(for: ShelfAnimation.collapsedSize)
        panel.ignoresMouseEvents = true
        panel.orderFrontRegardless()
        mouseTracker.start()
        globalShortcut.start()
    }

    func stop() {
        dismissCopyNotificationImmediately()
        if let workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(workspaceObserver)
            self.workspaceObserver = nil
        }
        if let dropObserver {
            NotificationCenter.default.removeObserver(dropObserver)
            self.dropObserver = nil
        }
        if let newItemObserver {
            NotificationCenter.default.removeObserver(newItemObserver)
            self.newItemObserver = nil
        }
        mouseTracker.stop()
        globalShortcut.stop()
        panel.orderOut(nil)
    }

    deinit {
        copyNotificationDismissWorkItem?.cancel()
        if let clickOutsideGlobalMonitor {
            NSEvent.removeMonitor(clickOutsideGlobalMonitor)
        }
        if let clickOutsideLocalMonitor {
            NSEvent.removeMonitor(clickOutsideLocalMonitor)
        }
        if let screenshotKeyMonitor {
            NSEvent.removeMonitor(screenshotKeyMonitor)
        }
        if let workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(workspaceObserver)
        }
        if let dropObserver {
            NotificationCenter.default.removeObserver(dropObserver)
        }
        if let newItemObserver {
            NotificationCenter.default.removeObserver(newItemObserver)
        }
    }

    /// Opens/closes the shelf independent of mouse hover — the global-hotkey
    /// path (⌘⇧V by default).
    func toggle() {
        if animationState.isScreenshotHUDActive {
            cancelScreenshotHUD()
            return
        }
        if writingToolsPanelController?.isOpen == true {
            closeWritingToolsPanel()
            collapse()
            return
        }
        isExpanded ? collapse() : expand()
    }

    /// Collapses immediately (e.g. after a card tap copies an item to paste),
    /// bypassing the animation delay so target app receives focus instantly.
    func collapseImmediately() {
        dismissCopyNotificationImmediately()
        closeWritingToolsPanel()
        if animationState.isScreenshotHUDActive {
            cancelScreenshotHUD()
        }
        // Resign any focused text fields (such as search bar) immediately
        panel.makeFirstResponder(nil)
        panel.canReceiveKeyFocus = false
        panel.ignoresMouseEvents = true
        isExpanded = false
        animationState.collapseImmediately()
        mouseTracker.forceCollapse()

        // Order out to force window server to yield key window back to the target application
        panel.orderOut(nil)
        panel.updateFrame(for: ShelfAnimation.collapsedSize)
        panel.orderFront(nil)
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
        dismissCopyNotificationImmediately()
        guard !isExpanded else { return }
        let frontmost = NSWorkspace.shared.frontmostApplication
        if let frontmost, frontmost.processIdentifier != NSRunningApplication.current.processIdentifier, frontmost.activationPolicy == .regular {
            previousApp = frontmost
        } else if previousApp == nil || previousApp?.isTerminated == true {
            if let menuBarApp = NSWorkspace.shared.menuBarOwningApplication,
               menuBarApp.processIdentifier != NSRunningApplication.current.processIdentifier,
               menuBarApp.activationPolicy == .regular {
                previousApp = menuBarApp
            }
        }
        isExpanded = true
        panel.canReceiveKeyFocus = true
        panel.updateFrame(for: ShelfAnimation.expandedSize)
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

    func expandForDropZone() {
        StashManager.shared.isDropZoneActive = true
        StashManager.shared.isStashViewSelected = true
        expand()
    }

    func scheduleCollapseAfterDragExited() {
        if StashManager.shared.items.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                guard let self else { return }
                if !StashManager.shared.isDropZoneActive && StashManager.shared.items.isEmpty {
                    self.collapseImmediately()
                }
            }
        }
    }

    // MARK: - Screenshot Capture Flow

    private func startScreenshotEventMonitoring() {
        stopScreenshotEventMonitoring()

        // Dismiss HUD if user clicks outside the notch pill anywhere on the screen
        clickOutsideGlobalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self, self.animationState.isScreenshotHUDActive else { return }
            let mouseLoc = NSEvent.mouseLocation
            if !self.panel.frame.contains(mouseLoc) {
                self.cancelScreenshotHUD()
            }
        }

        // Local clicks in our own app outside the panel frame
        clickOutsideLocalMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, self.animationState.isScreenshotHUDActive else { return event }
            let mouseLoc = NSEvent.mouseLocation
            if !self.panel.frame.contains(mouseLoc) {
                self.cancelScreenshotHUD()
            }
            return event
        }

        // Keyboard shortcuts while screenshot HUD is displayed: Esc cancels; 1/A (Area), 2/W (Window), 3/S (Screen)
        screenshotKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.animationState.isScreenshotHUDActive else { return event }

            if event.keyCode == 53 { // Escape
                self.cancelScreenshotHUD()
                return nil
            }

            guard let chars = event.characters?.lowercased() else { return event }
            if chars == "1" || chars == "a" {
                self.executeScreenshotCapture(mode: .area)
                return nil
            } else if chars == "2" || chars == "w" {
                self.executeScreenshotCapture(mode: .window)
                return nil
            } else if chars == "3" || chars == "s" {
                self.executeScreenshotCapture(mode: .screen)
                return nil
            }
            return event
        }
    }

    private func stopScreenshotEventMonitoring() {
        if let clickOutsideGlobalMonitor {
            NSEvent.removeMonitor(clickOutsideGlobalMonitor)
            self.clickOutsideGlobalMonitor = nil
        }
        if let clickOutsideLocalMonitor {
            NSEvent.removeMonitor(clickOutsideLocalMonitor)
            self.clickOutsideLocalMonitor = nil
        }
        if let screenshotKeyMonitor {
            NSEvent.removeMonitor(screenshotKeyMonitor)
            self.screenshotKeyMonitor = nil
        }
    }

    func startScreenshotFlow() {
        dismissCopyNotificationImmediately()
        guard !animationState.isScreenshotHUDActive else { return }

        // 1. Immediately pause mouseTracker so hover does not auto-collapse or interfere
        mouseTracker.isPaused = true
        mouseTracker.forceCollapse()

        // 2. Collapse the big shelf
        isExpanded = false
        panel.canReceiveKeyFocus = false
        panel.ignoresMouseEvents = true
        animationState.collapse()
        mouseTracker.updateShelfFrame(nil)

        // 3. After the big shelf retracts, present the compact Screenshot HUD at the camera notch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { [weak self] in
            guard let self, !self.isExpanded else { return }
            self.animationState.isScreenshotHUDActive = true
            self.panel.updateFrame(for: ShelfAnimation.screenshotHUDSize)
            self.panel.canReceiveKeyFocus = true
            self.panel.ignoresMouseEvents = false
            self.panel.makeKeyAndOrderFront(nil)
            self.startScreenshotEventMonitoring()
        }
    }

    func cancelScreenshotHUD() {
        stopScreenshotEventMonitoring()
        guard animationState.isScreenshotHUDActive else { return }
        animationState.isScreenshotHUDActive = false
        panel.canReceiveKeyFocus = false
        panel.ignoresMouseEvents = true
        panel.updateFrame(for: ShelfAnimation.collapsedSize)
        mouseTracker.updateShelfFrame(nil)

        // Unpause mouseTracker after a brief buffer so the cursor's current position doesn't immediately expand
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.mouseTracker.isPaused = false
        }
    }

    func executeScreenshotCapture(mode: ScreenshotManager.CaptureMode) {
        stopScreenshotEventMonitoring()
        // Hide the HUD completely before capture begins so Clippy UI isn't captured in the screenshot
        animationState.isScreenshotHUDActive = false
        panel.canReceiveKeyFocus = false
        panel.ignoresMouseEvents = true
        panel.orderOut(nil)
        panel.updateFrame(for: ShelfAnimation.collapsedSize)
        mouseTracker.updateShelfFrame(nil)

        // Small delay to ensure Quartz compositor clears the window
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            ScreenshotManager.shared.capture(mode: mode) { [weak self] didCapture in
                guard let self else { return }
                self.panel.orderFrontRegardless()
                self.mouseTracker.isPaused = false
                if didCapture {
                    // Re-open shelf so user sees the newly captured screenshot in Clippy!
                    self.expand()
                }
            }
        }
    }

    func collapse() {
        if animationState.isScreenshotHUDActive {
            cancelScreenshotHUD()
            return
        }
        closeWritingToolsPanel(andCollapseShelf: false)
        guard isExpanded else { return }
        panel.makeFirstResponder(nil)
        isExpanded = false
        panel.canReceiveKeyFocus = false
        panel.ignoresMouseEvents = true
        animationState.collapse()
        mouseTracker.updateShelfFrame(nil)
        mouseTracker.forceCollapse()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
            guard let self, !self.isExpanded else { return }
            self.panel.orderOut(nil)
            self.panel.updateFrame(for: ShelfAnimation.collapsedSize)
            self.panel.orderFront(nil)
        }
    }

    // MARK: - Apple Intelligence Writing Tools Floating Panel

    func openWritingToolsPanel(for item: ClipboardItem) {
        if !isExpanded {
            expand()
        }

        // Pause mouse tracking so hover does not auto-collapse while interacting with Writing Tools
        mouseTracker.isPaused = true

        if writingToolsPanelController == nil {
            writingToolsPanelController = WritingToolsPanelController()
        }

        writingToolsPanelController?.show(
            for: item,
            shelfFrame: panel.frame,
            onSaved: { refinedText in
                let pb = NSPasteboard.general
                pb.clearContents()
                pb.setString(refinedText, forType: .string)
                ClipboardService.shared.saveToClippy(from: pb)
            },
            onPasteToApp: { [weak self] refinedText in
                guard let self else { return }
                let pb = NSPasteboard.general
                pb.clearContents()
                pb.setString(refinedText, forType: .string)
                ClipboardService.shared.saveToClippy(from: pb)
                var target = self.previousApp
                if target == nil || target?.isTerminated == true {
                    if let menuBarApp = NSWorkspace.shared.menuBarOwningApplication,
                       menuBarApp.processIdentifier != NSRunningApplication.current.processIdentifier,
                       menuBarApp.activationPolicy == .regular {
                        target = menuBarApp
                    }
                }
                self.closeWritingToolsPanel(andCollapseShelf: false)
                self.collapseImmediately()
                let isDirectPasteEnabled = UserDefaults.standard.object(forKey: "isDirectPasteEnabled") as? Bool ?? true
                if isDirectPasteEnabled {
                    ClipboardWriter.pasteToFrontmostApp(targetApp: target)
                }
            },
            onClose: { [weak self] in
                self?.closeWritingToolsPanel(andCollapseShelf: true)
            }
        )
    }

    func closeWritingToolsPanel(andCollapseShelf: Bool = false) {
        mouseTracker.isPaused = false
        if let controller = writingToolsPanelController, controller.isOpen {
            controller.close()
        }
        if andCollapseShelf {
            collapse()
        } else {
            mouseTracker.updateShelfFrame(panel.frame)
        }
    }

    // MARK: - Dynamic Island Copy Notification Pill

    func showCopyNotification(for item: ClipboardItem) {
        guard !isExpanded, !animationState.isScreenshotHUDActive else { return }
        let isEnabled = UserDefaults.standard.object(forKey: "isCopyNotificationEnabled") as? Bool ?? true
        guard isEnabled else { return }

        // Cancel previous dismissal work item
        copyNotificationDismissWorkItem?.cancel()
        copyNotificationDismissWorkItem = nil

        panel.updateFrame(for: ShelfAnimation.copyNotificationSize)
        panel.ignoresMouseEvents = false

        animationState.activeCopyNotificationItem = item
        withAnimation(ShelfAnimation.expandSpring) {
            animationState.isCopyNotificationActive = true
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.dismissCopyNotification()
        }
        copyNotificationDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: workItem)
    }

    func dismissCopyNotification() {
        copyNotificationDismissWorkItem?.cancel()
        copyNotificationDismissWorkItem = nil

        guard animationState.isCopyNotificationActive, !isExpanded else { return }

        withAnimation(ShelfAnimation.collapseSpring) {
            animationState.isCopyNotificationActive = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self, !self.isExpanded, !self.animationState.isCopyNotificationActive, !self.animationState.isScreenshotHUDActive else { return }
            self.animationState.activeCopyNotificationItem = nil
            self.panel.updateFrame(for: ShelfAnimation.collapsedSize)
            self.panel.ignoresMouseEvents = true
        }
    }

    func dismissCopyNotificationImmediately() {
        copyNotificationDismissWorkItem?.cancel()
        copyNotificationDismissWorkItem = nil
        animationState.isCopyNotificationActive = false
        animationState.activeCopyNotificationItem = nil
    }
}

// MARK: - Hosting View without Focus Ring and Selective Hit-Testing

/// An `NSHostingView` subclass that suppresses the focus ring, performs selective hit testing
/// so underlying apps receive clicks outside the notch/shelf, and accepts incoming drag-and-drop operations.
private final class NonFocusRingHostingView<Content: View>: NSHostingView<Content> {
    weak var shelfController: ShelfController?

    override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }

    override func drawFocusRingMask() {
        // Suppress drawing any focus ring mask
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let controller = shelfController, (controller.isExpanded || controller.animationState.isScreenshotHUDActive || controller.animationState.isCopyNotificationActive) else { return nil }
        return super.hitTest(point)
    }

    // MARK: - Dragging Destination on Hosting View

    override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        guard let controller = shelfController else { return [] }
        controller.expandForDropZone()
        return .copy
    }

    override func draggingUpdated(_ sender: any NSDraggingInfo) -> NSDragOperation {
        StashManager.shared.isDropZoneActive = true
        let localPoint = convert(sender.draggingLocation, from: nil)
        if localPoint.x < bounds.midX {
            StashManager.shared.activeDropTarget = .stash
        } else {
            StashManager.shared.activeDropTarget = .clippy
        }
        return .copy
    }

    override func draggingExited(_ sender: (any NSDraggingInfo)?) {
        StashManager.shared.isDropZoneActive = false
        StashManager.shared.activeDropTarget = .none
        shelfController?.scheduleCollapseAfterDragExited()
    }

    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        let target = StashManager.shared.activeDropTarget
        StashManager.shared.isDropZoneActive = false
        StashManager.shared.activeDropTarget = .none

        if target == .clippy {
            let success = ClipboardService.shared.saveToClippy(from: sender.draggingPasteboard)
            if success {
                NSSound(named: "Glass")?.play()
                Task { @MainActor in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        StashManager.shared.isStashViewSelected = false
                    }
                }
                shelfController?.expand()
                return true
            }
            return false
        } else {
            let count = StashManager.shared.addItems(from: sender.draggingPasteboard)
            if count > 0 {
                shelfController?.expand()
                return true
            }
            return false
        }
    }
}



