import AppKit

// MARK: - Resolves metadata (name, icon, bundle ID) for the source app of a clipboard item

/// Captures the frontmost app's name/bundle id/icon. Icons are cached to
/// disk under thumbnails/, keyed by bundle id, so NSWorkspace icon lookup
/// and PNG conversion only happen once per app.

struct ExcludedApp: Codable, Equatable, Hashable, Identifiable {
    var id: String { bundleId }
    let name: String
    let bundleId: String

    init(name: String, bundleId: String) {
        self.name = name
        self.bundleId = bundleId
    }
}

extension AppInfoProvider {
    private static let excludedAppsKey = "ClipboardMonitor_ExcludedApps"

    static var excludedApps: [ExcludedApp] {
        guard let data = UserDefaults.standard.data(forKey: excludedAppsKey),
              let decoded = try? JSONDecoder().decode([ExcludedApp].self, from: data) else {
            return []
        }
        return decoded.filter { !$0.bundleId.isEmpty }
    }

    static func saveExcludedApps(_ apps: [ExcludedApp]) {
        try? JSONEncoder().encode(apps).map { UserDefaults.standard.set($0, forKey: excludedAppsKey) }
    }

    static var excludedAppIDs: [String] {
        return excludedApps.map { $0.bundleId }.filter { !$0.isEmpty }
    }
}

enum AppInfoProvider {
    private static var iconPathCache: [String: String] = [:]

    /// Snapshots whichever app is frontmost at the moment of the call.
    static func currentSource() -> AppSource? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        let bundleId = app.bundleIdentifier ?? ""
        return AppSource(
            name: app.localizedName ?? "Unknown",
            bundleId: bundleId,
            cachedIconPath: bundleId.isEmpty ? nil : iconPath(for: bundleId, app: app)
        )
    }

    /// Returns the on-disk path to `bundleId`'s cached icon, writing it to
    /// thumbnails/ the first time this bundle id is seen.
    private static func iconPath(for bundleId: String, app: NSRunningApplication) -> String? {
        if let cached = iconPathCache[bundleId] {
            return cached
        }

        let url = LocalStorage.thumbnailsDirectoryURL.appendingPathComponent("app-\(bundleId).png")
        if FileManager.default.fileExists(atPath: url.path) {
            iconPathCache[bundleId] = url.path
            return url.path
        }

        guard let icon = app.icon, let pngData = pngData(from: icon) else {
            return nil
        }
        do {
            try LocalStorage.bootstrap()
            try pngData.write(to: url, options: .atomic)
            iconPathCache[bundleId] = url.path
            return url.path
        } catch {
            return nil
        }
    }

    private static func pngData(from image: NSImage) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
}
