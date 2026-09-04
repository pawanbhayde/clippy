import AppKit
import ApplicationServices

// MARK: - Manages system permissions (Accessibility / Input Monitoring) and onboarding state

enum PermissionsManager {
    static let onboardingCompletedKey = "hasCompletedOnboarding"

    /// Returns whether the user has completed the first-run onboarding.
    static var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingCompletedKey) }
    }

    /// Checks if Accessibility permissions have been granted to this process.
    static func isAccessibilityGranted() -> Bool {
        return AXIsProcessTrusted()
    }

    /// Prompts the system Accessibility permission dialog if not already trusted.
    @discardableResult
    static func requestAccessibilityPermission() -> Bool {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    /// Deep-links to macOS System Settings -> Privacy & Security -> Accessibility.
    static func openAccessibilitySettings() {
        let urlStrings = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
            "x-apple.systempreferences:com.apple.preference.security"
        ]

        for urlString in urlStrings {
            if let url = URL(string: urlString), NSWorkspace.shared.open(url) {
                return
            }
        }
    }

    /// Deep-links to macOS System Settings -> Privacy & Security -> Input Monitoring.
    static func openInputMonitoringSettings() {
        let urlStrings = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent",
            "x-apple.systempreferences:com.apple.preference.security"
        ]

        for urlString in urlStrings {
            if let url = URL(string: urlString), NSWorkspace.shared.open(url) {
                return
            }
        }
    }
}
