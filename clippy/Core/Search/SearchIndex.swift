import Foundation

// MARK: - Maintains a searchable index of clipboard item content

/// An in-memory `id -> normalized searchable text` index built from each
/// item's preview and source app name. Built once from the full history at
/// launch, then kept current incrementally — `add`/`update` a single item
/// as it's captured rather than rebuilding the whole index.
struct SearchIndex {
    private var textByID: [UUID: String] = [:]

    var indexedCount: Int { textByID.count }

    /// Rebuilds the index from scratch. Call once, at launch.
    mutating func build(from items: [ClipboardItem]) {
        textByID.removeAll(keepingCapacity: true)
        for item in items {
            textByID[item.id] = Self.searchableText(for: item)
        }
    }

    /// Indexes a single new (or changed) item without touching the rest of
    /// the index.
    mutating func add(_ item: ClipboardItem) {
        textByID[item.id] = Self.searchableText(for: item)
    }

    mutating func remove(id: UUID) {
        textByID.removeValue(forKey: id)
    }

    /// The normalized searchable text for `id`, if it's been indexed.
    func text(for id: UUID) -> String? {
        textByID[id]
    }

    private static func searchableText(for item: ClipboardItem) -> String {
        var parts: [String] = []
        if let preview = item.preview { parts.append(preview) }
        if let sourceAppName = item.sourceApp?.name { parts.append(sourceAppName) }
        if let extractedText = item.extractedText { parts.append(extractedText) }
        return parts.joined(separator: " ")
    }
}
