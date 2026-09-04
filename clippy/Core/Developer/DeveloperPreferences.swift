import Foundation
import Combine

// MARK: - Preferences for Developer Mode tools and transformations

final class DeveloperPreferences: ObservableObject, @unchecked Sendable {
    static let shared = DeveloperPreferences()

    private enum Keys {
        static let isDeveloperModeEnabled = "Developer_isDeveloperModeEnabled"
    }

    @Published var isDeveloperModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isDeveloperModeEnabled, forKey: Keys.isDeveloperModeEnabled)
        }
    }

    private init() {
        if UserDefaults.standard.object(forKey: Keys.isDeveloperModeEnabled) != nil {
            self.isDeveloperModeEnabled = UserDefaults.standard.bool(forKey: Keys.isDeveloperModeEnabled)
        } else {
            // Default to enabled so developer features are immediately accessible
            self.isDeveloperModeEnabled = true
        }
    }
}
