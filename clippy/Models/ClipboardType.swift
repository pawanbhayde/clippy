import Foundation

// MARK: - Enum defining the classified content types of a clipboard item

enum ClipboardType: String, Codable, CaseIterable, Identifiable {
    case text
    case richText
    case image
    case url
    case file
    case color
    case code

    var id: String { rawValue }
}
