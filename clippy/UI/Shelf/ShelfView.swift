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

    @ObservedObject private var queueManager = PasteQueueManager.shared
    @ObservedObject private var stashManager = StashManager.shared
    @State private var selectedID: ClipboardItem.ID?
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear

            // Dynamic Island / Notch container
            NotchShelfShape()
                .fill(Color.black)
                .frame(width: state.currentSize.width, height: state.currentSize.height)
                .opacity(state.isExpanded ? 1 : ((queueManager.isActive && (!queueManager.queue.isEmpty || queueManager.isCompletedFeedback)) || !stashManager.items.isEmpty ? 1 : 0))

            // Collapsed Pill Indicator (if Queue is active or Stash has items)
            if !state.isExpanded {
                if queueManager.isActive && (!queueManager.queue.isEmpty || queueManager.isCompletedFeedback) {
                    QueueCollapsedPill(queueManager: queueManager)
                        .padding(.top, 4)
                        .transition(.opacity)
                } else if !stashManager.items.isEmpty {
                    StashCollapsedPill(stashManager: stashManager)
                        .padding(.top, 4)
                        .transition(.opacity)
                }
            }

            // Expanded content: permanently mounted for zero layout thrashing, smoothly animated
            VStack(spacing: 12) {
                // Row 1: Search bar & utility action icons
                SearchBar(
                    text: $store.searchQuery,
                    isFavoritesActive: store.selectedCollectionID == Collection.favorites.id,
                    isQueueActive: queueManager.isActive,
                    queueCount: queueManager.queue.count,
                    isStashActive: stashManager.isStashViewSelected || stashManager.isDropZoneActive,
                    stashCount: stashManager.items.count,
                    onToggleFavorites: {
                        if store.selectedCollectionID == Collection.favorites.id {
                            store.selectedCollectionID = Collection.history.id
                        } else {
                            store.selectedCollectionID = Collection.favorites.id
                        }
                    },
                    onToggleQueue: {
                        queueManager.toggle()
                    },
                    onToggleStash: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            stashManager.isStashViewSelected.toggle()
                        }
                    },
                    onClearAll: {
                        store.clearAllHistory(preserveFavorites: false)
                    },
                    onOpenSettings: {
                        onCollapseRequested()
                        AppDelegate.shared?.openSettings()
                    },
                    onPinOrPopout: {
                        // Collapse or toggle action
                        onCollapseRequested()
                    }
                )

                if stashManager.isStashViewSelected || stashManager.isDropZoneActive {
                    StashShelfView {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            stashManager.isStashViewSelected = false
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                } else {
                    // Queue active strip if queue mode is active
                    if queueManager.isActive {
                        QueueActiveStrip(queueManager: queueManager)
                    }

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
            }
            .padding(.top, 14)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .frame(width: ShelfAnimation.expandedSize.width, alignment: .top)
            .opacity(state.contentOpacity)
            .scaleEffect(state.isExpanded ? 1.0 : 0.95, anchor: .top)
            .offset(y: state.isExpanded ? 0 : -6)
            .allowsHitTesting(state.isExpanded)
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
        .onChange(of: state.isExpanded) { _, expanded in
            guard expanded else { return }
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

// MARK: - Collapsed Live Activity Pill for Dynamic Island

private struct QueueCollapsedPill: View {
    @ObservedObject var queueManager: PasteQueueManager

    var body: some View {
        HStack(spacing: 6) {
            if queueManager.isCompletedFeedback {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 11, weight: .bold))
                Text("Done")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: 7, height: 7)
                Image(systemName: "list.number")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(queueManager.queue.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black)
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        )
        .frame(height: 24)
    }
}

// MARK: - Expanded Queue Active Strip

private struct QueueActiveStrip: View {
    @ObservedObject var queueManager: PasteQueueManager

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                Text("QUEUE ACTIVE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)

                Text("• \(queueManager.queue.count) items ready to paste (⌘V)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                if let first = queueManager.queue.first?.preview, !first.isEmpty {
                    Text("• Next: \"\(first)\"")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer()

            if !queueManager.queue.isEmpty {
                Button {
                    queueManager.skipNext()
                } label: {
                    Label("Skip Next", systemImage: "forward.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .help("Skip current front item and move to next in queue")

                Button {
                    queueManager.clearQueue()
                } label: {
                    Text("Clear")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .help("Clear all queued items")
            }

            Button {
                queueManager.stopQueue()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(5)
                    .background(Circle().fill(Color.white.opacity(0.12)))
            }
            .buttonStyle(.plain)
            .help("Stop Queue Mode")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Collapsed Stash Indicator for Dynamic Island

private struct StashCollapsedPill: View {
    @ObservedObject var stashManager: StashManager

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "tray.full.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
            Text("\(stashManager.items.count)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black)
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        )
        .frame(height: 24)
    }
}

