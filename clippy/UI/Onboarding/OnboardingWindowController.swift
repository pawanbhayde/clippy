import AppKit
import SwiftUI

// MARK: - Manages the first-run onboarding window

@MainActor
final class OnboardingWindowController {
    static let shared = OnboardingWindowController()

    private var window: NSWindow?

    /// Shows the onboarding window if the user has not previously completed it.
    static func showIfNeeded() {
        guard !PermissionsManager.hasCompletedOnboarding else { return }
        shared.show()
    }

    /// Presents the onboarding window.
    func show() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 560),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "Welcome to Clippy"
        newWindow.center()
        newWindow.isReleasedWhenClosed = false

        let hostingView = NSHostingView(rootView: OnboardingView { [weak self, weak newWindow] in
            newWindow?.close()
            self?.window = nil
        })

        newWindow.contentView = hostingView
        self.window = newWindow

        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        window?.close()
        window = nil
    }
}
