import Foundation

// MARK: - Model representing the source application a clipboard item was copied from

struct AppSource: Codable, Equatable, Hashable {
    var name: String
    var bundleId: String
    /// Path to the app icon cached on disk, not the raw icon data.
    var cachedIconPath: String?
}
