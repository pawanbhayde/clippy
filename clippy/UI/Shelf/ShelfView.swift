import SwiftUI

// MARK: - SwiftUI root view for the clipboard shelf

/// Renders the custom black Dynamic Island / notch shelf driven by `ShelfAnimationState`,
/// featuring the top search & utility bar, category chips with counts, and horizontally
/// scrollable clipboard cards matching the screenshot.
struct ShelfView: View {
    @ObservedObject var state: ShelfAnimationState
    @ObservedObject var store: ClipboardStore
    var onCopied: () -> Void
    var onCollapseRequested: () -> Void

    @State private var selectedID: ClipboardItem.ID?
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear

            if state.phase == .collapsed {
                Color.clear
                    .frame(width: state.phase.size.width, height: state.phase.size.height)
            } else {
                NotchShelfShape()
                    .fill(Color.black)
                    .frame(width: state.phase.size.width, height: state.phase.size.height)
                    .shadow(color: Color.black.opacity(0.4), radius: 14, x: 0, y: 6)
                    .overlay(alignment: .top) {
                        VStack(spacing: 12) {
                            // Row 1: Search bar & utility action icons
                            SearchBar(
                                text: $store.searchQuery,
                                isFavoritesActive: store.selectedCollectionID == Collection.favorites.id,
                                onToggleFavorites: {
                                    if store.selectedCollectionID == Collection.favorites.id {
                                        store.selectedCollectionID = Collection.history.id
                                    } else {
                                        store.selectedCollectionID = Collection.favorites.id
                                    }
                                },
                                onToggleGrid: {
                                    // Cycles to next collection tab
                                    if let idx = store.collections.firstIndex(where: { $0.id == store.selectedCollectionID }) {
                                        let nextIdx = (idx + 1) % store.collections.count
                                        store.selectedCollectionID = store.collections[nextIdx].id
                                    }
                                },
                                onPinOrPopout: {
                                    // Collapse or toggle action
                                    onCollapseRequested()
                                }
                            )

                            // Row 2: Category chips with counts + Add button
                            CollectionTabBar(
                                collections: store.collections,
                                selection: $store.selectedCollectionID,
                                store: store
                            )

                            // Row 3: Horizontally scrollable clipboard cards
                            ClipboardGrid(store: store, selectedID: selectedID) { _ in
                                onCopied()
                            }
                        }
                        .padding(.top, 14)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .opacity(state.phase.contentOpacity)
                        .allowsHitTesting(state.phase == .expanded)
                    }
            }
        }
        .frame(width: ShelfAnimation.expandedSize.width, height: ShelfAnimation.expandedSize.height, alignment: .top)
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .onKeyPress(.leftArrow) { move(delta: -1); return .handled }
        .onKeyPress(.rightArrow) { move(delta: 1); return .handled }
        .onKeyPress(.upArrow) { move(delta: -1); return .handled }
        .onKeyPress(.downArrow) { move(delta: 1); return .handled }
        .onKeyPress(.return) { activateSelection(); return .handled }
        .onKeyPress(.escape) { onCollapseRequested(); return .handled }
        .onKeyPress(characters: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]) { press in
            guard press.modifiers.contains(.command), let digit = Int(String(press.characters)) else {
                return .ignored
            }
            selectCollection(tabIndex: digit - 1)
            return .handled
        }
        .onChange(of: store.selectedCollectionID) { _, _ in resetSelectionToFirstVisible() }
        .onChange(of: store.searchQuery) { _, _ in resetSelectionToFirstVisible() }
        .onChange(of: state.phase) { _, phase in
            guard phase == .expanded else { return }
            isFocused = true
            if selectedID == nil { resetSelectionToFirstVisible() }
        }
    }

    // MARK: Selection movement for horizontal card row

    private func move(delta: Int) {
        let items = store.visibleItems
        guard let index = currentIndex(in: items) else {
            selectedID = items.first?.id
            return
        }
        let newIndex = index + delta
        guard items.indices.contains(newIndex) else { return }
        selectedID = items[newIndex].id
    }

    private func currentIndex(in items: [ClipboardItem]) -> Int? {
        guard let selectedID else { return nil }
        return items.firstIndex { $0.id == selectedID }
    }

    private func activateSelection() {
        guard let selectedID, let item = store.visibleItems.first(where: { $0.id == selectedID }) else { return }
        store.activate(item)
        onCopied()
    }

    private func selectCollection(tabIndex: Int) {
        guard store.collections.indices.contains(tabIndex) else { return }
        store.selectedCollectionID = store.collections[tabIndex].id
    }

    private func resetSelectionToFirstVisible() {
        let items = store.visibleItems
        if let selectedID, items.contains(where: { $0.id == selectedID }) { return }
        selectedID = items.first?.id
    }
}
