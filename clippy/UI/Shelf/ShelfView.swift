import SwiftUI

// MARK: - SwiftUI root view for the clipboard shelf

/// Renders the capsule → shelf shape driven by `ShelfAnimationState`, with
/// `CollectionTabBar` + `ClipboardGrid` as its content. Also owns keyboard
/// navigation once expanded: arrow keys move the selection, Enter activates
/// it via the same path as a card tap, Esc collapses, and ⌘1/⌘2/⌘3 switch
/// collection tabs by index.
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
            RoundedRectangle(cornerRadius: state.phase == .collapsed ? state.phase.size.height / 2 : 16)
                .fill(.thinMaterial)
                .frame(width: state.phase.size.width, height: state.phase.size.height)
                .overlay {
                    VStack(spacing: 8) {
                        SearchBar(text: $store.searchQuery)
                        CollectionTabBar(collections: store.collections, selection: $store.selectedCollectionID)
                        ClipboardGrid(store: store, selectedID: selectedID) { _ in onCopied() }
                    }
                    .padding(12)
                    .opacity(state.phase.contentOpacity)
                    .allowsHitTesting(state.phase == .expanded)
                }
        }
        .frame(width: ShelfAnimation.expandedSize.width, height: ShelfAnimation.expandedSize.height, alignment: .top)
        .focusable()
        .focused($isFocused)
        .onKeyPress(.upArrow) { move(rowDelta: -1); return .handled }
        .onKeyPress(.downArrow) { move(rowDelta: 1); return .handled }
        .onKeyPress(.leftArrow) { move(columnDelta: -1); return .handled }
        .onKeyPress(.rightArrow) { move(columnDelta: 1); return .handled }
        .onKeyPress(.return) { activateSelection(); return .handled }
        .onKeyPress(.escape) { onCollapseRequested(); return .handled }
        .onKeyPress(characters: ["1", "2", "3"]) { press in
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

    // MARK: Selection movement — items fill the 2-row grid column-major,
    // so "row" is index % 2 and "column" is index / 2.

    private func move(rowDelta: Int) {
        let items = store.visibleItems
        guard let index = currentIndex(in: items) else {
            selectedID = items.first?.id
            return
        }
        let row = index % 2
        let newRow = row + rowDelta
        guard newRow == 0 || newRow == 1 else { return }
        let newIndex = index - row + newRow
        guard items.indices.contains(newIndex) else { return }
        selectedID = items[newIndex].id
    }

    private func move(columnDelta: Int) {
        let items = store.visibleItems
        guard let index = currentIndex(in: items) else {
            selectedID = items.first?.id
            return
        }
        let newIndex = index + columnDelta * 2
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
