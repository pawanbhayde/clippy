import SwiftUI

// MARK: - Main Application Entry Point

@main
struct clippyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
