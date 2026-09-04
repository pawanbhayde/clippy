import Foundation

// MARK: - Executes search queries against indexed clipboard history

/// Owns a `SearchIndex` and answers queries against it. Matching is
/// intentionally simple for now (`localizedCaseInsensitiveContains`) — the
/// index is what lets this get smarter later (ranking, fuzzy match, etc.)
/// without changing how callers use it.
final class SearchEngine {
    private var index = SearchIndex()

    /// Builds the index from the full clipboard history. Call once, at launch.
    func buildIndex(from items: [ClipboardItem]) {
        index.build(from: items)
    }

    /// Indexes a single new item incrementally, without rebuilding the rest.
    func indexNewItem(_ item: ClipboardItem) {
        index.add(item)
    }

    func removeFromIndex(id: UUID) {
        index.remove(id: id)
    }

    /// Filters `items` down to those whose indexed text contains `query`.
    /// An empty/whitespace-only query matches everything.
    func search(_ query: String, in items: [ClipboardItem]) -> [ClipboardItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }

        return items.filter { item in
            let text = index.text(for: item.id) ?? (item.preview ?? "")
            return text.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
