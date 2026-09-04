import Foundation

// MARK: - Prunes expired or over-limit clipboard history from storage

/// LRU eviction: once the item-count or images/files disk-usage limit is
/// exceeded, deletes the least-recently-used items' on-disk assets and
/// removes them from metadata.json. Both limits are UserDefaults-backed
/// so Settings UI can read and adjust them directly.
enum StorageCleanup {
    private static let maxItemCountKey = "Clippy.StorageCleanup.maxItemCount"
    private static let maxDiskUsageBytesKey = "Clippy.StorageCleanup.maxDiskUsageBytes"

    static let defaultMaxItemCount = 500
    static let defaultMaxDiskUsageBytes = 250 * 1024 * 1024 // 250MB

    /// Registers the defaults once so unset keys read back as the defaults
    /// above rather than 0. Swift initializes static properties lazily,
    /// exactly once, in a thread-safe manner.
    private static let didRegisterDefaults: Void = {
        UserDefaults.standard.register(defaults: [
            maxItemCountKey: defaultMaxItemCount,
            maxDiskUsageBytesKey: defaultMaxDiskUsageBytes
        ])
    }()

    /// Maximum number of items to retain.
    static var maxItemCount: Int {
        get {
            _ = didRegisterDefaults
            return UserDefaults.standard.integer(forKey: maxItemCountKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: maxItemCountKey) }
    }

    /// Maximum combined size, in bytes, of the images/ and files/ directories.
    static var maxDiskUsageBytes: Int {
        get {
            _ = didRegisterDefaults
            return UserDefaults.standard.integer(forKey: maxDiskUsageBytesKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: maxDiskUsageBytesKey) }
    }

    /// Evicts least-recently-used items (by `lastUsedAt`) until both the
    /// item-count and disk-usage limits are satisfied. Deletes each evicted
    /// item's on-disk assets and rewrites metadata.json. Returns the items
    /// that were evicted.
    @discardableResult
    static func runIfNeeded() throws -> [ClipboardItem] {
        var items = try MetadataStore.load()
        guard !items.isEmpty else { return [] }

        items.sort { $0.lastUsedAt < $1.lastUsedAt } // oldest-used first

        var diskUsage = Int64(currentDiskUsage())
        let diskLimit = Int64(maxDiskUsageBytes)
        var evicted: [ClipboardItem] = []

        while !items.isEmpty, items.count > maxItemCount || diskUsage > diskLimit {
            let item = items.removeFirst()
            evicted.append(item)
            if item.type == .image || item.type == .file {
                diskUsage -= item.fileSize ?? 0
            }
        }

        guard !evicted.isEmpty else { return [] }

        for item in evicted {
            AssetStore.deleteAssets(for: item.id)
        }

        items.sort { $0.createdAt < $1.createdAt }
        try MetadataStore.save(items)
        return evicted
    }

    /// Combined size, in bytes, of images/ and files/ — the directories
    /// that can grow large from binary clipboard content.
    static func currentDiskUsage() -> Int {
        [LocalStorage.imagesDirectoryURL, LocalStorage.filesDirectoryURL]
            .reduce(0) { $0 + directorySize($1) }
    }

    private static func directorySize(_ url: URL) -> Int {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var total = 0
        for case let fileURL as URL in enumerator {
            total += (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        }
        return total
    }
}
