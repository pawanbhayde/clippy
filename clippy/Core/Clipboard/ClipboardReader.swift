import AppKit

// MARK: - Reads and extracts content/data from the system pasteboard

/// The raw content extracted from the pasteboard. Never stored on
/// `ClipboardItem` directly — callers persist it via `AssetStore` and keep
/// only the resulting path.
enum ClipboardPayload {
    case text(String)
    case richText(Data)
    case image(Data)
    case fileURL(URL)

    /// A stable byte representation used for content hashing.
    var hashableData: Data {
        switch self {
        case .text(let string):
            return Data(string.utf8)
        case .richText(let data):
            return data
        case .image(let data):
            return data
        case .fileURL(let url):
            return Data(url.absoluteString.utf8)
        }
    }
}

enum ClipboardReader {
    /// Reads the current pasteboard content, preferring file URLs, then
    /// images, then rich text, then plain text. Returns `nil` if the
    /// pasteboard holds none of these representations.
    static func readCurrent() -> (item: ClipboardItem, payload: ClipboardPayload)? {
        let pasteboard = NSPasteboard.general

        if let (payload, preview, fileSize) = readFile(pasteboard) {
            return makeItem(type: .file, payload: payload, preview: preview, fileSize: fileSize)
        }
        if let (payload, preview) = readImage(pasteboard) {
            return makeItem(type: .image, payload: payload, preview: preview, fileSize: Int64(payload.hashableData.count))
        }
        if let (payload, preview) = readRichText(pasteboard) {
            return makeItem(type: .richText, payload: payload, preview: preview)
        }
        if let (payload, preview) = readPlainText(pasteboard) {
            return makeItem(type: .text, payload: payload, preview: preview)
        }
        return nil
    }

    private static func readFile(_ pasteboard: NSPasteboard) -> (ClipboardPayload, String, Int64?)? {
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL],
              let url = urls.first else { return nil }
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? nil
        return (.fileURL(url), url.lastPathComponent, fileSize)
    }

    private static func readImage(_ pasteboard: NSPasteboard) -> (ClipboardPayload, String)? {
        if let pngData = pasteboard.data(forType: .png) {
            return (.image(pngData), "Image")
        }
        if let tiffData = pasteboard.data(forType: .tiff),
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            return (.image(pngData), "Image")
        }
        return nil
    }

    private static func readRichText(_ pasteboard: NSPasteboard) -> (ClipboardPayload, String)? {
        guard let data = pasteboard.data(forType: .rtf) else { return nil }
        let preview = (try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        ))?.string ?? ""
        return (.richText(data), preview)
    }

    private static func readPlainText(_ pasteboard: NSPasteboard) -> (ClipboardPayload, String)? {
        guard let string = pasteboard.string(forType: .string), !string.isEmpty else { return nil }
        return (.text(string), string)
    }

    private static func makeItem(
        type: ClipboardType,
        payload: ClipboardPayload,
        preview: String,
        fileSize: Int64? = nil
    ) -> (ClipboardItem, ClipboardPayload) {
        let now = Date()
        let item = ClipboardItem(
            id: UUID(),
            type: type,
            createdAt: now,
            lastUsedAt: now,
            categoryIDs: [],
            isFavorite: false,
            contentHash: ClipboardHasher.hash(payload.hashableData),
            preview: String(preview.prefix(500)),
            sourceApp: nil,
            storagePath: nil,
            thumbnailPath: nil,
            fileSize: fileSize,
            isSensitive: false,
            isEncrypted: false
        )
        return (item, payload)
    }
}
