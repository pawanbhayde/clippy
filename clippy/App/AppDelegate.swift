import AppKit
import SwiftUI

// MARK: - Application Delegate running Clippy as an accessory menu bar app

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private(set) static var shared: AppDelegate?

    override init() {
        super.init()
        AppDelegate.shared = self
    }

    private var statusItem: NSStatusItem?
    private var shelfController: ShelfController?
    private var settingsWindow: NSWindow?
    private var pauseMenuItem: NSMenuItem?
    private var queueMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as a pure menu-bar / accessory app (no Dock icon, no default window)
        NSApp.setActivationPolicy(.accessory)

        // Bootstrap clipboard capture pipeline
        ClipboardService.shared.start()

        // Initialize and display shelf controller
        let controller = ShelfController()
        controller.start()
        self.shelfController = controller

        // Set up the menu bar status item
        setupStatusItem()

        // Show first-run onboarding window if needed
        OnboardingWindowController.showIfNeeded()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running in the menu bar even when windows (like Settings) are closed
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        ClipboardService.shared.stop()
        shelfController?.stop()
    }

    // MARK: - Status Item & Menu Setup

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "Clippy")
            button.image?.isTemplate = true
            button.toolTip = "Clippy"
        }

        let menu = NSMenu()
        menu.delegate = self

        // 1. Open Clipboard
        let openItem = NSMenuItem(title: "Open Clipboard", action: #selector(openClipboard), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)

        // 2. Search
        let searchItem = NSMenuItem(title: "Search", action: #selector(openSearch), keyEquivalent: "")
        searchItem.target = self
        menu.addItem(searchItem)

        // 3. History
        let historyItem = NSMenuItem(title: "History", action: #selector(openHistory), keyEquivalent: "")
        historyItem.target = self
        menu.addItem(historyItem)

        // 4. Favorites
        let favoritesItem = NSMenuItem(title: "Favorites", action: #selector(openFavorites), keyEquivalent: "")
        favoritesItem.target = self
        menu.addItem(favoritesItem)

        // 5. Queue Mode
        let queueItem = NSMenuItem(title: "Start Queue Mode (⌘⌥V)", action: #selector(toggleQueueMode), keyEquivalent: "")
        queueItem.target = self
        self.queueMenuItem = queueItem
        menu.addItem(queueItem)

        // 6. Clear All History
        let clearHistoryItem = NSMenuItem(title: "Clear All History...", action: #selector(clearAllHistory), keyEquivalent: "")
        clearHistoryItem.target = self
        menu.addItem(clearHistoryItem)

        menu.addItem(NSMenuItem.separator())

        // 7. Pause / Resume Clipboard
        let pauseItem = NSMenuItem(title: "Pause Clipboard", action: #selector(togglePauseClipboard), keyEquivalent: "")
        pauseItem.target = self
        self.pauseMenuItem = pauseItem
        menu.addItem(pauseItem)

        menu.addItem(NSMenuItem.separator())

        // 8. Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettingsWindow), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let onboardingItem = NSMenuItem(title: "Welcome & Permissions...", action: #selector(openOnboarding), keyEquivalent: "")
        onboardingItem.target = self
        menu.addItem(onboardingItem)

        menu.addItem(NSMenuItem.separator())

        // 9. Quit
        let quitItem = NSMenuItem(title: "Quit Clippy", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
        self.statusItem = item
    }

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        updatePauseMenuItem()
        updateQueueMenuItem()
    }

    private func updatePauseMenuItem() {
        let isPaused = ClipboardService.shared.isPaused
        pauseMenuItem?.title = isPaused ? "Resume Clipboard" : "Pause Clipboard"
        pauseMenuItem?.state = isPaused ? .on : .off
    }

    private func updateQueueMenuItem() {
        let isQueueActive = PasteQueueManager.shared.isActive
        let count = PasteQueueManager.shared.queue.count
        if isQueueActive {
            queueMenuItem?.title = count > 0 ? "Stop Queue Mode (\(count) left)" : "Stop Queue Mode"
            queueMenuItem?.state = .on
        } else {
            queueMenuItem?.title = "Start Queue Mode (⌘⌥V)"
            queueMenuItem?.state = .off
        }
    }

    // MARK: - Actions

    @objc private func openClipboard() {
        shelfController?.openClipboard()
    }

    @objc private func openSearch() {
        shelfController?.openSearch()
    }

    @objc private func openHistory() {
        shelfController?.openHistory()
    }

    @objc private func openFavorites() {
        shelfController?.openFavorites()
    }

    @objc private func toggleQueueMode() {
        PasteQueueManager.shared.toggle()
        updateQueueMenuItem()
    }

    @objc func clearAllHistory() {
        shelfController?.confirmAndClearHistory()
    }

    @objc private func togglePauseClipboard() {
        if ClipboardService.shared.isPaused {
            ClipboardService.shared.resume()
        } else {
            ClipboardService.shared.pause()
        }
        updatePauseMenuItem()
    }

    @objc func openSettingsWindow() {
        openSettings(tab: .general)
    }

    func openSettings(tab: SettingsTab = .general) {
        if let settingsWindow = settingsWindow {
            settingsWindow.contentView = NSHostingView(rootView: SettingsView(selectedTab: tab))
            settingsWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Clippy Settings"
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SettingsView(selectedTab: tab))
        self.settingsWindow = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openOnboarding() {
        OnboardingWindowController.shared.show()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
