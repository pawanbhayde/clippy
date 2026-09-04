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
    /// Returns an empty array if metadata.json is empty.
    static func load() throws -> [ClipboardItem] {
        try LocalStorage.bootstrap()
        let data = try Data(contentsOf: LocalStorage.metadataFileURL)
        guard !data.isEmpty else { return [] }
        return try decoder.decode([ClipboardItem].self, from: data)
    }

    /// Overwrites metadata.json with the given items.
    static func save(_ items: [ClipboardItem]) throws {
        try LocalStorage.bootstrap()
        let data = try encoder.encode(items)
        try data.write(to: LocalStorage.metadataFileURL, options: .atomic)
    }
}
