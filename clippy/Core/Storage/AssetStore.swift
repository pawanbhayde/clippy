import Foundation

// MARK: - Stores large binary assets (images, files) referenced by clipboard items

/// Reads and writes the large content backing a clipboard item — text
/// blobs, image data, copied files, and thumbnails — keyed by item id.
/// `ClipboardItem` itself only stores the resulting paths, never raw
/// content or bytes. Pure Foundation, no UI dependencies — usable from a
/// command-line Swift script or unit tests.
enum AssetStore {
    enum ImageFormat: String {
        case webp
        case png
    }

    // MARK: Text content (items/)

    @discardableResult
    static func writeText(_ text: String, for id: UUID) throws -> URL {
        try LocalStorage.bootstrap()
        let url = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).txt")
        try Data(text.utf8).write(to: url, options: .atomic)
        return url
    }

    static func readText(for id: UUID) -> String? {
        let encUrl = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).enc")
        if FileManager.default.fileExists(atPath: encUrl.path) {
            if let decrypted = try? readDecryptedData(for: id) {
                return String(data: decrypted, encoding: .utf8)
            }
        }
        let url = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).txt")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func readText(for item: ClipboardItem) -> String? {
        if item.isEncrypted {
            if let decrypted = try? readDecryptedData(for: item.id) {
                return String(data: decrypted, encoding: .utf8)
            }
            return nil
        }
        return readText(for: item.id)
    }

    @discardableResult
    static func writeRichText(_ data: Data, for id: UUID) throws -> URL {
        try LocalStorage.bootstrap()
        let url = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).rtf")
        try data.write(to: url, options: .atomic)
        return url
    }

    static func readRichText(for id: UUID) -> Data? {
        let encUrl = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).enc")
        if FileManager.default.fileExists(atPath: encUrl.path) {
            if let decrypted = try? readDecryptedData(for: id) {
                return decrypted
            }
        }
        let url = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).rtf")
        return try? Data(contentsOf: url)
    }

    static func readRichText(for item: ClipboardItem) -> Data? {
        if item.isEncrypted {
            return try? readDecryptedData(for: item.id)
        }
        return readRichText(for: item.id)
    }

    // MARK: Encrypted content

    @discardableResult
    static func writeEncrypted(_ data: Data, for id: UUID) throws -> URL {
        try LocalStorage.bootstrap()
        let url = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).enc")
        try data.write(to: url, options: .atomic)
        return url
    }

    @discardableResult
    static func writeEncryptedText(_ data: Data, for id: UUID) throws -> URL {
        try writeEncrypted(data, for: id)
    }

    @discardableResult
    static func writeEncryptedRichText(_ encryptedData: Data, for id: UUID) throws -> URL {
        try writeEncrypted(encryptedData, for: id)
    }

    static func readEncryptedData(for id: UUID) throws -> Data {
        let url = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).enc")
        return try Data(contentsOf: url)
    }

    static func readDecryptedData(for id: UUID) throws -> Data {
        let encrypted = try readEncryptedData(for: id)
        return try ContentEncryptor.decrypt(encrypted)
    }

    static func readEncryptedText(for id: UUID) throws -> Data {
        return try readDecryptedData(for: id)
    }

    static func readEncryptedRichText(for id: UUID) throws -> Data {
        return try readDecryptedData(for: id)
    }

    static func isEncryptedAssetPresent(for id: UUID) -> Bool {
        let encUrl = LocalStorage.itemsDirectoryURL.appendingPathComponent("\(id.uuidString).enc")
        return FileManager.default.fileExists(atPath: encUrl.path)
    }

    // MARK: Image content (images/)

    @discardableResult
    static func writeImage(_ data: Data, for id: UUID, format: ImageFormat) throws -> URL {
        try LocalStorage.bootstrap()
        let url = LocalStorage.imagesDirectoryURL.appendingPathComponent("\(id.uuidString).\(format.rawValue)")
        try data.write(to: url, options: .atomic)
        return url
    }

    static func readImage(for id: UUID, format: ImageFormat) -> Data? {
        let url = LocalStorage.imagesDirectoryURL.appendingPathComponent("\(id.uuidString).\(format.rawValue)")
        return try? Data(contentsOf: url)
    }

    // MARK: Copied files (files/)

    /// Copies an arbitrary file into storage, preserving its original
    /// extension so the file can still be opened/previewed by type.
    @discardableResult
    static func writeFile(from sourceURL: URL, for id: UUID) throws -> URL {
        try LocalStorage.bootstrap()
        let fileManager = FileManager.default
        var destinationURL = LocalStorage.filesDirectoryURL.appendingPathComponent(id.uuidString)
        if !sourceURL.pathExtension.isEmpty {
            destinationURL.appendPathExtension(sourceURL.pathExtension)
        }
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }

    // MARK: Thumbnails (thumbnails/)

    @discardableResult
    static func writeThumbnail(_ data: Data, for id: UUID, format: ImageFormat = .webp) throws -> URL {
        try LocalStorage.bootstrap()
        let url = LocalStorage.thumbnailsDirectoryURL.appendingPathComponent("\(id.uuidString).\(format.rawValue)")
        try data.write(to: url, options: .atomic)
        return url
    }

    static func readThumbnail(for id: UUID, format: ImageFormat = .webp) -> Data? {
        let url = LocalStorage.thumbnailsDirectoryURL.appendingPathComponent("\(id.uuidString).\(format.rawValue)")
        return try? Data(contentsOf: url)
    }

    // MARK: Cleanup

    /// Removes every asset stored for the given id — text, image, file, and
    /// thumbnail — regardless of extension/format.
    static func deleteAssets(for id: UUID) {
        let fileManager = FileManager.default
        let directories = [
            LocalStorage.itemsDirectoryURL,
            LocalStorage.imagesDirectoryURL,
            LocalStorage.filesDirectoryURL,
            LocalStorage.thumbnailsDirectoryURL
        ]
        for directory in directories {
            guard let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { continue }
            for url in contents where url.deletingPathExtension().lastPathComponent == id.uuidString {
                try? fileManager.removeItem(at: url)
            }
        }
    }

    /// Removes all stored assets across all directories (items, images, files, thumbnails).
    static func deleteAllAssets() {
        let fileManager = FileManager.default
        let directories = [
            LocalStorage.itemsDirectoryURL,
            LocalStorage.imagesDirectoryURL,
            LocalStorage.filesDirectoryURL,
            LocalStorage.thumbnailsDirectoryURL
        ]
        for directory in directories {
            if let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) {
                for url in contents {
                    try? fileManager.removeItem(at: url)
                }
            }
        }
    }
}
