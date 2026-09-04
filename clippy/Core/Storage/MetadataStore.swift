import Foundation

// MARK: - Persists metadata (type, source, timestamps) for clipboard items

/// Loads and saves the full array of `ClipboardItem` as JSON at
/// `LocalStorage.metadataFileURL`. Pure Foundation, no UI dependencies —
/// usable from a command-line Swift script or unit tests.
enum MetadataStore {
    private static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    /// Loads all clipboard items from disk, bootstrapping storage first.
    /// Deduplicates items by contentHash (preserving the most recent use and favorite status)
    /// and persists back if duplicates were found. Returns an empty array if metadata.json is empty.
    static func load() throws -> [ClipboardItem] {
        try LocalStorage.bootstrap()
        let data = try Data(contentsOf: LocalStorage.metadataFileURL)
        guard !data.isEmpty else { return [] }
        let items = try decoder.decode([ClipboardItem].self, from: data)
        let unique = deduplicate(items)
        if unique.count != items.count {
            try? save(unique)
        }
        return unique
    }

    /// Overwrites metadata.json with the given items.
    static func save(_ items: [ClipboardItem]) throws {
        try LocalStorage.bootstrap()
        let data = try encoder.encode(items)
        try data.write(to: LocalStorage.metadataFileURL, options: .atomic)
    }

    /// Deduplicates items by contentHash, preserving the most recent timestamp and favorite status.
    static func deduplicate(_ items: [ClipboardItem]) -> [ClipboardItem] {
        var seenHashes = Set<String>()
        var deduplicated: [ClipboardItem] = []

        // Sort descending by lastUsedAt so the most recent version of each content hash wins
        let sorted = items.sorted { $0.lastUsedAt > $1.lastUsedAt }
        for var item in sorted {
            if seenHashes.insert(item.contentHash).inserted {
                // If any duplicate had favorite set, preserve favorite
                if items.contains(where: { $0.contentHash == item.contentHash && $0.isFavorite }) {
                    item.isFavorite = true
                }
                deduplicated.append(item)
            }
        }
        return Array(deduplicated.reversed())
    }
}
