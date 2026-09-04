import Foundation

// MARK: - Persists user-created custom collections

/// Loads and saves the array of user-created `Collection`s as JSON at
/// `LocalStorage.collectionsFileURL`. The six built-in collections
/// (`Collection.defaults`) are compile-time constants and never live here.
enum CollectionStore {
    private static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private static let decoder = JSONDecoder()

    /// Loads custom collections from disk, bootstrapping storage first.
    /// Returns an empty array if collections.json is empty.
    static func load() throws -> [Collection] {
        try LocalStorage.bootstrap()
        let data = try Data(contentsOf: LocalStorage.collectionsFileURL)
        guard !data.isEmpty else { return [] }
        return try decoder.decode([Collection].self, from: data)
    }

    /// Overwrites collections.json with the given collections.
    static func save(_ collections: [Collection]) throws {
        try LocalStorage.bootstrap()
        let data = try encoder.encode(collections)
        try data.write(to: LocalStorage.collectionsFileURL, options: .atomic)
    }

    static func add(_ collection: Collection) throws {
        var existing = try load()
        existing.append(collection)
        try save(existing)
    }

    static func remove(id: UUID) throws {
        var existing = try load()
        existing.removeAll { $0.id == id }
        try save(existing)
    }
}
