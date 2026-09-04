import SwiftUI

// MARK: - SwiftUI view laying out clipboard cards in a grid

/// Horizontally scrolling, two-row grid of `ClipboardCard`s sized to fit
/// inside the shelf. Reads live from an `ClipboardStore`.
struct ClipboardGrid: View {
    @ObservedObject var store: ClipboardStore
    /// The currently keyboard-selected item, if any — highlighted via
    /// `ClipboardCard.isSelected` and auto-scrolled into view.
    var selectedID: ClipboardItem.ID?
    /// Called after a card writes its item back to the pasteboard, after
    /// this grid has already recorded the usage on `store`.
    var onCopied: ((ClipboardItem) -> Void)?

    private let rows = [
        GridItem(.fixed(ClipboardCard.size.height), spacing: 12),
        GridItem(.fixed(ClipboardCard.size.height), spacing: 12)
    ]

    var body: some View {
        Group {
            if store.visibleItems.isEmpty {
                emptyState
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 12) {
                            ForEach(store.visibleItems) { item in
                                ClipboardCard(item: item, isSelected: item.id == selectedID) { activatedItem in
                                    store.activate(activatedItem)
                                    onCopied?(activatedItem)
                                }
                                .id(item.id)
                            }
                        }
                        .padding(12)
                    }
                    .onChange(of: selectedID) { _, newValue in
                        guard let newValue else { return }
                        withAnimation { proxy.scrollTo(newValue, anchor: .center) }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: store.items.isEmpty ? "clipboard" : "magnifyingglass")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text(store.items.isEmpty ? "Nothing copied yet" : "No matches for \"\(store.searchQuery)\"")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
