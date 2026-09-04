import SwiftUI

// MARK: - Tab bar for switching between clipboard collections in the shelf

/// Horizontally scrolling row of custom category pill chips matching the screenshot.
/// Active chip has pure white capsule background with black bold text and gray count badge.
/// Inactive chips have dark charcoal backgrounds with light gray text and muted count badges.
/// Circular '+' button at the end allows creating a new collection.
struct CollectionTabBar: View {
    let collections: [Collection]
    @Binding var selection: UUID
    @ObservedObject var store: ClipboardStore

    @State private var isShowingAddSheet: Bool = false
    @State private var newCollectionName: String = ""

    private var visibleCollections: [Collection] {
        collections.filter { collection in
            // Always show History
            if collection.id == Collection.history.id {
                return true
            }
            // If this collection is currently selected by the user, keep it visible
            if selection == collection.id {
                return true
            }
            // Only show category chip if there are items in the clipboard for it
            return store.count(for: collection) > 0
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(visibleCollections) { collection in
                    let isSelected = selection == collection.id
                    let count = store.count(for: collection)

                    Button {
                        selection = collection.id
                    } label: {
                        HStack(spacing: 6) {
                            Text(collection.name)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                .foregroundStyle(isSelected ? Color.black : Color(white: 0.75))

                            Text("\(count)")
                                .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                                .foregroundStyle(isSelected ? Color.black.opacity(0.55) : Color(white: 0.42))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(isSelected ? Color.white : Color(white: 0.16))
                        )
                    }
                    .buttonStyle(.plain)
                }

                // Add collection button
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(white: 0.8))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(Color(white: 0.16))
                        )
                }
                .buttonStyle(.plain)
                .help("Add New Collection")
                .popover(isPresented: $isShowingAddSheet) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("New Collection")
                            .font(.headline)
                            .foregroundStyle(.white)

                        TextField("Collection Name", text: $newCollectionName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)

                        HStack {
                            Button("Cancel") {
                                newCollectionName = ""
                                isShowingAddSheet = false
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(white: 0.6))

                            Spacer()

                            Button("Create") {
                                let trimmed = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty {
                                    store.addCustomCollection(name: trimmed)
                                }
                                newCollectionName = ""
                                isShowingAddSheet = false
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .disabled(newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(14)
                    .background(Color(white: 0.12))
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
    }
}
