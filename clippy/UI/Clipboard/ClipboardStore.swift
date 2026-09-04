import Foundation
import Combine

// MARK: - Observable store bridging MetadataStore into SwiftUI

/// Wraps `MetadataStore` so SwiftUI views can observe the clipboard history
/// without talking to disk directly. Polls on a short interval rather than
/// subscribing to `ClipboardMonitor` directly, so the UI layer stays
/// decoupled from however capture happens to be wired up.
@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []
    @Published private(set) var loadError: String?
    /// Live search text; bind a `SearchBar` to this. See `visibleItems`.
    @Published var searchQuery: String = ""
    /// Built-in collections (`Collection.defaults`) plus whatever the user
    /// has created in Settings, in tab order. Refreshed on the same poll as
    /// `items` so a collection added from Settings shows up here live.
    @Published private(set) var collections: [Collection] = Collection.defaults
    /// Active collection tab; bind a `CollectionTabBar` to this. See `visibleItems`.
    @Published var selectedCollectionID: UUID = Collection.history.id

    private let searchEngine = SearchEngine()
    private var indexedIDs: Set<UUID> = []
    private var hasBuiltIndex = false
    private var refreshTimer: Timer?

    init(autoRefresh: Bool = true) {
        reloadCollections()
        reload()
        if autoRefresh {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.reload()
                    self?.reloadCollections()
                }
            }
        }
    }

    /// `items` filtered by the selected collection's filter and then
    /// `searchQuery` via `SearchEngine`.
    var visibleItems: [ClipboardItem] {
        let filter = collections.first { $0.id == selectedCollectionID }?.filter ?? .all
        return searchEngine.search(searchQuery, in: items.filter(filter.matches))
    }

    /// Number of items matching a given collection's filter.
    func count(for collection: Collection) -> Int {
        items.filter(collection.filter.matches).count
    }

    /// Creates and persists a new custom collection.
    func addCustomCollection(name: String, icon: String = "folder") {
        let newCollection = Collection(
            id: UUID(),
            name: name,
            icon: icon,
            filter: .category(UUID())
        )
        do {
            try CollectionStore.add(newCollection)
            reloadCollections()
            selectedCollectionID = newCollection.id
        } catch {
            loadError = "\(error)"
        }
    }

    func reload() {
        do {
            let loaded = try MetadataStore.load().sorted { $0.lastUsedAt > $1.lastUsedAt }
            indexNewItems(loaded)
            items = loaded
            loadError = nil
        } catch {
            loadError = "\(error)"
        }
    }

    func reloadCollections() {
        do {
            collections = Collection.defaults + (try CollectionStore.load())
        } catch {
            collections = Collection.defaults
            loadError = "\(error)"
        }
    }

    /// Builds the search index from scratch the first time (launch), then
    /// only indexes IDs we haven't seen before — true incremental updates
    /// rather than a full rebuild on every poll.
    private func indexNewItems(_ loaded: [ClipboardItem]) {
        guard hasBuiltIndex else {
            searchEngine.buildIndex(from: loaded)
            indexedIDs = Set(loaded.map(\.id))
            hasBuiltIndex = true
            return
        }
        for item in loaded where !indexedIDs.contains(item.id) {
            searchEngine.indexNewItem(item)
            indexedIDs.insert(item.id)
        }
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    /// Writes `item` to the system pasteboard and records it as just-used —
    /// the single path both a card tap and keyboard Enter activation funnel
    /// through, so usage tracking can't drift from what's actually copied.
    func activate(_ item: ClipboardItem) {
        ClipboardWriter.write(item)
        recordUsage(of: item)
    }

    /// Marks `item` as just-used: bumps `lastUsedAt` in both the in-memory
    /// list (so the UI reflects it immediately, without waiting for the
    /// next auto-refresh) and on disk.
    func recordUsage(of item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].lastUsedAt = Date()
        do {
            try MetadataStore.save(items)
        } catch {
            loadError = "\(error)"
        }
    }

    /// Toggles the favorite status of `item` and saves the updated list to disk.
    func toggleFavorite(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isFavorite.toggle()
        do {
            try MetadataStore.save(items)
        } catch {
            loadError = "\(error)"
        }
    }

    /// Clears clipboard history from memory and on-disk storage.
    /// - Parameter preserveFavorites: If `true`, favorited items are kept; if `false`, everything is deleted.
    func clearAllHistory(preserveFavorites: Bool = false) {
        do {
            if preserveFavorites {
                let favorites = items.filter { $0.isFavorite }
                let toRemove = items.filter { !$0.isFavorite }
                for item in toRemove {
                    AssetStore.deleteAssets(for: item.id)
                }
                try MetadataStore.save(favorites)
                items = favorites
            } else {
                for item in items {
                    AssetStore.deleteAssets(for: item.id)
                }
                AssetStore.deleteAllAssets()
                try MetadataStore.save([])
                items = []
            }
            searchQuery = ""
            reload()
        } catch {
            loadError = "\(error)"
        }
    }
}
