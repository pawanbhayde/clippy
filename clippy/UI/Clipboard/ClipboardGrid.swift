import SwiftUI

// MARK: - SwiftUI view laying out clipboard cards in a grid

/// Horizontally scrolling single-row list of `ClipboardCard`s matching the custom dock layout.
/// Reads live from a `ClipboardStore`.
struct ClipboardGrid: View {
    @ObservedObject var store: ClipboardStore
    /// The currently keyboard-selected item, if any — highlighted via
    /// `ClipboardCard.isSelected` and auto-scrolled into view.
    var selectedID: ClipboardItem.ID?
    /// Called after a card writes its item back to the pasteboard, after
    /// this grid has already recorded the usage on `store`.
    var onCopied: ((ClipboardItem) -> Void)?

    var body: some View {
        Group {
            if store.visibleItems.isEmpty {
                emptyState
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 14) {
                            ForEach(store.visibleItems) { item in
                                ClipboardCard(
                                    item: item,
                                    isSelected: item.id == selectedID,
                                    onActivate: { activatedItem in
                                        store.activate(activatedItem)
                                        onCopied?(activatedItem)
                                    },
                                    onDragStarted: { draggedItem in
                                        store.activate(draggedItem)
                                    },
                                    onToggleFavorite: { favoritedItem in
                                        store.toggleFavorite(favoritedItem)
                                    },
                                    onDelete: { deletedItem in
                                        store.deleteItem(deletedItem)
                                    }
                                )
                                .id(item.id)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                    }
                    .onChange(of: selectedID) { _, newValue in
                        guard let newValue else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: store.items.isEmpty ? "clipboard" : "magnifyingglass")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color(white: 0.4))
            Text(store.items.isEmpty ? "Clipboard is empty" : "No matches for \"\(store.searchQuery)\"")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(white: 0.45))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
