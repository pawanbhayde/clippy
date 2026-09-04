import SwiftUI

// MARK: - Sheet for creating a custom collection with a user-defined filter

/// Lets the user name a new collection and pick one of three filter kinds —
/// content type, source app, or a keyword — producing a `Collection` that
/// the caller is responsible for persisting (see `CollectionsSettings`).
struct AddCollectionSheet: View {
    var onCreate: (Collection) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var kind: FilterKind = .type
    @State private var selectedTypes: Set<ClipboardType> = []
    @State private var sourceAppBundleId = ""
    @State private var knownApps: [AppSource] = []
    @State private var keyword = ""

    private enum FilterKind: String, CaseIterable, Identifiable {
        case type = "Content Type"
        case sourceApp = "Source App"
        case keyword = "Keyword"
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .type: return "square.grid.2x2"
            case .sourceApp: return "app.badge"
            case .keyword: return "magnifyingglass"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Collection")
                .font(.headline)

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)

            Picker("Filter by", selection: $kind) {
                ForEach(FilterKind.allCases) { kind in
                    Text(kind.rawValue).tag(kind)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            filterEditor

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                Button("Create") { create() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!isValid)
            }
        }
        .padding(20)
        .frame(width: 360)
        .onAppear(perform: loadKnownApps)
    }

    @ViewBuilder
    private var filterEditor: some View {
        switch kind {
        case .type:
            VStack(alignment: .leading, spacing: 4) {
                ForEach(ClipboardType.allCases) { type in
                    Toggle(type.displayName, isOn: Binding(
                        get: { selectedTypes.contains(type) },
                        set: { isOn in
                            if isOn { selectedTypes.insert(type) } else { selectedTypes.remove(type) }
                        }
                    ))
                }
            }
        case .sourceApp:
            VStack(alignment: .leading, spacing: 8) {
                if !knownApps.isEmpty {
                    Picker("Recent apps", selection: $sourceAppBundleId) {
                        Text("Choose an app").tag("")
                        ForEach(knownApps, id: \.bundleId) { app in
                            Text(app.name).tag(app.bundleId)
                        }
                    }
                }
                TextField("Bundle identifier (e.g. com.apple.Safari)", text: $sourceAppBundleId)
                    .textFieldStyle(.roundedBorder)
            }
        case .keyword:
            TextField("Keyword", text: $keyword)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        switch kind {
        case .type: return !selectedTypes.isEmpty
        case .sourceApp: return !sourceAppBundleId.trimmingCharacters(in: .whitespaces).isEmpty
        case .keyword: return !keyword.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private func loadKnownApps() {
        guard let items = try? MetadataStore.load() else { return }
        var seen = Set<String>()
        knownApps = items.compactMap(\.sourceApp)
            .filter { seen.insert($0.bundleId).inserted }
            .sorted { $0.name < $1.name }
    }

    private func create() {
        let filter: CollectionFilter
        switch kind {
        case .type:
            filter = selectedTypes.count == 1 ? .type(selectedTypes.first!) : .types(selectedTypes)
        case .sourceApp:
            filter = .sourceApp(bundleId: sourceAppBundleId.trimmingCharacters(in: .whitespaces))
        case .keyword:
            filter = .keyword(keyword.trimmingCharacters(in: .whitespaces))
        }
        let collection = Collection(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            icon: kind.icon,
            filter: filter
        )
        onCreate(collection)
        dismiss()
    }
}

private extension ClipboardType {
    var displayName: String {
        switch self {
        case .text: return "Text"
        case .richText: return "Rich Text"
        case .image: return "Image"
        case .url: return "Link"
        case .file: return "File"
        case .color: return "Color"
        case .code: return "Code"
        }
    }
}
