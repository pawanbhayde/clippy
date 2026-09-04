import Foundation

// MARK: - Model representing a user-defined collection/group of clipboard items

/// Describes which items belong to a collection. Expressed as a Codable enum
/// rather than a closure so collections can be persisted like other models.
enum CollectionFilter: Codable, Equatable {
    case all
    case favorites
    case type(ClipboardType)
    case types(Set<ClipboardType>)
    case category(UUID)
    case sourceApp(bundleId: String)
    case keyword(String)

    /// Evaluates whether a given item satisfies this filter.
    func matches(_ item: ClipboardItem) -> Bool {
        switch self {
        case .all:
            return true
        case .favorites:
            return item.isFavorite
        case .type(let type):
            return item.type == type
        case .types(let types):
            return types.contains(item.type)
        case .category(let id):
            return item.categoryIDs.contains(id)
        case .sourceApp(let bundleId):
            return item.sourceApp?.bundleId == bundleId
        case .keyword(let keyword):
            let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return true }
            return (item.preview ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }
}

struct Collection: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var filter: CollectionFilter
}

extension Collection {
    /// Reserved category tag for items classified as LLM-style prompts.
    /// Nothing assigns this automatically yet — future classification work
    /// can append it to `ClipboardItem.categoryIDs` and items will show up
    /// under Prompts with no further wiring here.
    static let promptsCategoryID = UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000001")!

    static let inspirationsCategoryID = UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000002")!

    static let history = Collection(
        id: UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000010")!,
        name: "History", icon: "clock", filter: .all
    )
    static let prompts = Collection(
        id: UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000011")!,
        name: "Prompts", icon: "text.bubble", filter: .category(promptsCategoryID)
    )
    static let colors = Collection(
        id: UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000012")!,
        name: "Colors", icon: "paintpalette", filter: .type(.color)
    )
    static let assets = Collection(
        id: UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000013")!,
        name: "Images", icon: "photo.on.rectangle", filter: .types([.image, .file])
    )
    static let inspirations = Collection(
        id: UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000017")!,
        name: "Inspirations", icon: "sparkles", filter: .category(inspirationsCategoryID)
    )
    static let links = Collection(
        id: UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000014")!,
        name: "Links", icon: "link", filter: .type(.url)
    )
    static let favorites = Collection(
        id: UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000016")!,
        name: "Favorites", icon: "star.fill", filter: .favorites
    )
    static let code = Collection(
        id: UUID(uuidString: "8A1D9C1E-0000-4000-8000-000000000015")!,
        name: "Code", icon: "chevron.left.forwardslash.chevron.right", filter: .type(.code)
    )

    /// The built-in collections, in the shelf's tab order. Never
    /// persisted — `CollectionStore` only holds user-created ones.
    static let defaults: [Collection] = [.history, .prompts, .colors, .assets, .inspirations, .favorites, .links, .code]
}
