import Foundation

// MARK: - Manages on-disk persistence of clipboard history

/// Owns Clippy's on-disk directory layout under
/// ~/Library/Application Support/Clippy/. Pure Foundation, no UI
/// dependencies — usable from a command-line Swift script or unit tests.
enum LocalStorage {
    /// Root directory. A `var` so tests/scripts can point it at a temp
    /// directory instead of the real Application Support folder.
    static var rootURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let clippyURL = appSupport.appendingPathComponent("Clippy", isDirectory: true)
        let legacyURL = appSupport.appendingPathComponent("Supaste", isDirectory: true)
        let fm = FileManager.default
        if fm.fileExists(atPath: legacyURL.path) && !fm.fileExists(atPath: clippyURL.path) {
            try? fm.moveItem(at: legacyURL, to: clippyURL)
        }
        return clippyURL
    }()

    static var metadataFileURL: URL {
        rootURL.appendingPathComponent("metadata.json")
    }

    static var collectionsFileURL: URL {
        rootURL.appendingPathComponent("collections.json")
    }

    static var itemsDirectoryURL: URL {
        rootURL.appendingPathComponent("items", isDirectory: true)
    }

    static var imagesDirectoryURL: URL {
        rootURL.appendingPathComponent("images", isDirectory: true)
    }

    static var filesDirectoryURL: URL {
        rootURL.appendingPathComponent("files", isDirectory: true)
    }

    static var thumbnailsDirectoryURL: URL {
        rootURL.appendingPathComponent("thumbnails", isDirectory: true)
    }

    private static var subdirectories: [URL] {
        [itemsDirectoryURL, imagesDirectoryURL, filesDirectoryURL, thumbnailsDirectoryURL]
    }

    /// Creates the root directory, its subdirectories, and an empty
    /// metadata.json if any are missing. Idempotent — safe to call on
    /// every launch and before every read/write.
    static func bootstrap() throws {
        let fileManager = FileManager.default

        for directory in [rootURL] + subdirectories {
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
        }

        if !fileManager.fileExists(atPath: metadataFileURL.path) {
            try Data("[]".utf8).write(to: metadataFileURL, options: .atomic)
        }

        if !fileManager.fileExists(atPath: collectionsFileURL.path) {
            try Data("[]".utf8).write(to: collectionsFileURL, options: .atomic)
        }
    }
}
