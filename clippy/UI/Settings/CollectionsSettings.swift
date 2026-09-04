import SwiftUI

// MARK: - Settings pane for managing clipboard collections

/// Lists the six built-in collections (read-only — their filters are fixed
/// in `Collection.defaults`) and the user's custom ones loaded from
/// `CollectionStore`, with a sheet for creating new custom collections.
struct CollectionsSettings: View {
    @State private var customCollections: [Collection] = []
    @State private var loadError: String?
    @State private var isPresentingAddSheet = false

    var body: some View {
        Form {
            Section("Built-in") {
                ForEach(Collection.defaults) { collection in
                    Label(collection.name, systemImage: collection.icon)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Custom") {
                if customCollections.isEmpty {
                    Text("No custom collections yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(customCollections) { collection in
                        Label(collection.name, systemImage: collection.icon)
                    }
                    .onDelete(perform: delete)
                }

                Button {
                    isPresentingAddSheet = true
                } label: {
                    Label("Add Collection", systemImage: "plus")
                }
            }

            if let loadError {
                Text(loadError)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: reload)
        .sheet(isPresented: $isPresentingAddSheet) {
            AddCollectionSheet { newCollection in
                add(newCollection)
            }
        }
    }

    private func reload() {
        do {
            customCollections = try CollectionStore.load()
            loadError = nil
        } catch {
            loadError = "\(error)"
        }
    }

    private func add(_ collection: Collection) {
        do {
            try CollectionStore.add(collection)
            reload()
        } catch {
            loadError = "\(error)"
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            try? CollectionStore.remove(id: customCollections[index].id)
        }
        reload()
    }
}
