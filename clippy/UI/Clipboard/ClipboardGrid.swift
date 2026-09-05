import SwiftUI

// MARK: - SwiftUI view laying out clipboard cards in a grid

/// Horizontally scrolling single-row list of `ClipboardCard`s matching the custom dock layout.
/// Reads live from a `ClipboardStore`.
struct ClipboardGrid: View {
    @ObservedObject var store: ClipboardStore
    /// The currently keyboard-selected item, if any — highlighted via
    /// `ClipboardCard.isSelected` and auto-scrolled into view.
    var selectedID: ClipboardItem.ID?
    /// Multi-selected item IDs for batch actions and merger
    @Binding var multiSelectedIDs: Set<ClipboardItem.ID>
    /// Preserves user selection order for ordered merging
    @Binding var orderedSelectedIDs: [ClipboardItem.ID]
    /// Called after a card writes its item back to the pasteboard, after
    /// this grid has already recorded the usage on `store`.
    var onCopied: ((ClipboardItem) -> Void)?

    init(
        store: ClipboardStore,
        selectedID: ClipboardItem.ID? = nil,
        multiSelectedIDs: Binding<Set<ClipboardItem.ID>> = .constant([]),
        orderedSelectedIDs: Binding<[ClipboardItem.ID]> = .constant([]),
        onCopied: ((ClipboardItem) -> Void)? = nil
    ) {
        self.store = store
        self.selectedID = selectedID
        self._multiSelectedIDs = multiSelectedIDs
        self._orderedSelectedIDs = orderedSelectedIDs
        self.onCopied = onCopied
    }

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
                                    isMultiSelected: multiSelectedIDs.contains(item.id),
                                    isMultiSelectActive: !multiSelectedIDs.isEmpty,
                                    onActivate: { activatedItem in
                                        store.activate(activatedItem)
                                        onCopied?(activatedItem)
                                    },
                                    onToggleSelect: { itemToToggle in
                                        toggleSelection(of: itemToToggle)
                                    },
                                    onRangeSelect: { itemToRangeSelect in
                                        rangeSelect(to: itemToRangeSelect)
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

    // MARK: - Multi-Selection Logic

    private func toggleSelection(of item: ClipboardItem) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if multiSelectedIDs.contains(item.id) {
                multiSelectedIDs.remove(item.id)
                orderedSelectedIDs.removeAll { $0 == item.id }
            } else {
                multiSelectedIDs.insert(item.id)
                orderedSelectedIDs.append(item.id)
            }
        }
    }

    private func rangeSelect(to item: ClipboardItem) {
        let items = store.visibleItems
        guard let targetIndex = items.firstIndex(where: { $0.id == item.id }) else { return }

        // Find anchor index: last item in selection or keyboard selected ID
        let anchorID = orderedSelectedIDs.last ?? selectedID
        let anchorIndex = items.firstIndex(where: { $0.id == anchorID }) ?? targetIndex

        let startIndex = min(anchorIndex, targetIndex)
        let endIndex = max(anchorIndex, targetIndex)

        withAnimation(.easeInOut(duration: 0.15)) {
            for index in startIndex...endIndex {
                let currentItem = items[index]
                if !multiSelectedIDs.contains(currentItem.id) {
                    multiSelectedIDs.insert(currentItem.id)
                    orderedSelectedIDs.append(currentItem.id)
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
