import AppKit

// MARK: - Writes clipboard items back to the system pasteboard

enum ClipboardWriter {
    /// Writes `item`'s stored content back to the pasteboard using its
    /// native representation. Resolves the payload from disk via
    /// `AssetStore`, keyed by `item.id`, based on the item's type.
    static func write(_ item: ClipboardItem) {
        switch item.type {
        case .text, .url, .code, .color:
            guard let text = AssetStore.readText(for: item) else {
                print("ClipboardWriter: no stored text found for item \(item.id)")
                return
            }
            writeText(text)
        case .richText:
            guard let data = AssetStore.readRichText(for: item) else {
                print("ClipboardWriter: no stored rich text found for item \(item.id)")
                return
            }
            writeRichText(data)
        case .image:
            guard let data = AssetStore.readImage(for: item.id, format: .png) else {
                print("ClipboardWriter: no stored image found for item \(item.id)")
                return
            }
            writeImage(data)
        case .file:
            guard let path = item.storagePath else {
                print("ClipboardWriter: no stored file path for item \(item.id)")
                return
            }
            writeFile(at: URL(fileURLWithPath: path))
        }
    }

    static func writeText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    static func writeRichText(_ data: Data) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .rtf)
        // Apps that only understand plain text still get something useful.
        if let plainText = (try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        ))?.string {
            pasteboard.setString(plainText, forType: .string)
        }
    }

    static func writeImage(_ data: Data) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .png)
    }

    static func writeFile(at url: URL) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([url as NSURL])
    }
}
