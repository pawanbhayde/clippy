import Foundation
import Combine

// MARK: - User privacy preferences for sensitive data handling and excluded apps

/// Manages privacy preferences such as blocking sensitive items,
/// encrypting sensitive items at rest, and excluded applications.
final class PrivacyPreferences: ObservableObject, @unchecked Sendable {
    static let shared = PrivacyPreferences()

    enum Keys {
        static let blockSensitiveItems = "Privacy_blockSensitiveItems"
        static let alwaysEncryptSensitive = "Privacy_alwaysEncryptSensitive"
        static let autoMaskSensitive = "Privacy_autoMaskSensitive"
        static let autoPurgeSensitive = "Privacy_autoPurgeSensitive"
        static let autoPurgeInterval = "Privacy_autoPurgeInterval"
    }

    @Published var blockSensitiveItems: Bool {
        didSet {
            UserDefaults.standard.set(blockSensitiveItems, forKey: Keys.blockSensitiveItems)
        }
    }

    @Published var alwaysEncryptSensitive: Bool {
        didSet {
            UserDefaults.standard.set(alwaysEncryptSensitive, forKey: Keys.alwaysEncryptSensitive)
        }
    }

    @Published var autoMaskSensitive: Bool {
        didSet {
            UserDefaults.standard.set(autoMaskSensitive, forKey: Keys.autoMaskSensitive)
        }
    }

    @Published var autoPurgeSensitive: Bool {
        didSet {
            UserDefaults.standard.set(autoPurgeSensitive, forKey: Keys.autoPurgeSensitive)
        }
    }

    @Published var autoPurgeInterval: TimeInterval {
        didSet {
            UserDefaults.standard.set(autoPurgeInterval, forKey: Keys.autoPurgeInterval)
        }
    }

    @Published var excludedApps: [ExcludedApp] {
        didSet {
            AppInfoProvider.saveExcludedApps(excludedApps)
        }
    }

    private init() {
        if UserDefaults.standard.object(forKey: Keys.blockSensitiveItems) != nil {
            self.blockSensitiveItems = UserDefaults.standard.bool(forKey: Keys.blockSensitiveItems)
        } else {
            self.blockSensitiveItems = false
        }

        if UserDefaults.standard.object(forKey: Keys.alwaysEncryptSensitive) != nil {
            self.alwaysEncryptSensitive = UserDefaults.standard.bool(forKey: Keys.alwaysEncryptSensitive)
        } else {
            self.alwaysEncryptSensitive = true
        }

        if UserDefaults.standard.object(forKey: Keys.autoMaskSensitive) != nil {
            self.autoMaskSensitive = UserDefaults.standard.bool(forKey: Keys.autoMaskSensitive)
        } else {
            self.autoMaskSensitive = true
        }

        if UserDefaults.standard.object(forKey: Keys.autoPurgeSensitive) != nil {
            self.autoPurgeSensitive = UserDefaults.standard.bool(forKey: Keys.autoPurgeSensitive)
        } else {
            self.autoPurgeSensitive = true
        }

        if UserDefaults.standard.object(forKey: Keys.autoPurgeInterval) != nil {
            let val = UserDefaults.standard.double(forKey: Keys.autoPurgeInterval)
            self.autoPurgeInterval = val > 0 ? val : 60.0
        } else {
            self.autoPurgeInterval = 60.0
        }

        self.excludedApps = AppInfoProvider.excludedApps
    }

    func addExcludedApp(name: String, bundleId: String) {
        let trimmedId = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedId.isEmpty else { return }
        if !excludedApps.contains(where: { $0.bundleId == trimmedId }) {
            excludedApps.append(ExcludedApp(name: name.isEmpty ? trimmedId : name, bundleId: trimmedId))
        }
    }

    func removeExcludedApp(bundleId: String) {
        excludedApps.removeAll { $0.bundleId == bundleId }
    }

    func isAppExcluded(_ bundleId: String) -> Bool {
        return excludedApps.contains(where: { $0.bundleId == bundleId })
    }
}
