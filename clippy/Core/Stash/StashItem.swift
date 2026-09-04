import AppKit
import Foundation
import UniformTypeIdentifiers

// MARK: - Model representing an item held in the temporary notch drop stash

public struct StashItem: Identifiable, Hashable {
    public let id: UUID
    public let url: URL?
    public let name: String
    public let fileExtension: String
    public let sizeDescription: String?
    public let icon: NSImage
    public let isImage: Bool
    public let imageThumbnail: NSImage?
    public let textContent: String?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        url: URL? = nil,
        name: String,
        fileExtension: String = "",
        sizeDescription: String? = nil,
        icon: NSImage? = nil,
        isImage: Bool = false,
        imageThumbnail: NSImage? = nil,
        textContent: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.url = url
        self.name = name
        self.fileExtension = fileExtension
        self.sizeDescription = sizeDescription
        self.isImage = isImage
        self.imageThumbnail = imageThumbnail
        self.textContent = textContent
        self.createdAt = createdAt

        if let icon {
            self.icon = icon
        } else if let url {
            self.icon = NSWorkspace.shared.icon(forFile: url.path)
        } else {
            self.icon = NSImage(systemSymbolName: isImage ? "photo" : "doc", accessibilityDescription: nil) ?? NSImage()
        }
    }

    /// Creates a StashItem from an existing file URL on disk
    public static func from(fileURL: URL) -> StashItem {
        let name = fileURL.lastPathComponent
        let ext = fileURL.pathExtension.lowercased()
        let icon = NSWorkspace.shared.icon(forFile: fileURL.path)

        // Calculate human readable file size
        var sizeDesc: String?
        if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let size = attrs[.size] as? Int64 {
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
            bcf.countStyle = .file
            sizeDesc = bcf.string(fromByteCount: size)
        }

        let isImg = ["png", "jpg", "jpeg", "gif", "webp", "heic", "tiff", "svg"].contains(ext)
        var thumb: NSImage?
        if isImg, let data = try? Data(contentsOf: fileURL) {
            thumb = NSImage(data: data)
        }

        return StashItem(
            url: fileURL,
            name: name,
            fileExtension: ext,
            sizeDescription: sizeDesc,
            icon: icon,
            isImage: isImg,
            imageThumbnail: thumb,
            createdAt: Date()
        )
    }

    /// Creates a StashItem from raw NSImage data saved into the stash directory
    public static func from(image: NSImage, filename: String? = nil) -> StashItem? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }

        try? LocalStorage.bootstrap()
        let id = UUID()
        let fname = filename ?? "Dropped_Image_\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = LocalStorage.stashDirectoryURL.appendingPathComponent("\(id.uuidString)_\(fname)")

        do {
            try pngData.write(to: fileURL, options: .atomic)
        } catch {
            return nil
        }

        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useBytes, .useKB, .useMB]
        bcf.countStyle = .file
        let sizeDesc = bcf.string(fromByteCount: Int64(pngData.count))

        return StashItem(
            id: id,
            url: fileURL,
            name: fname,
            fileExtension: "png",
            sizeDescription: sizeDesc,
            icon: image,
            isImage: true,
            imageThumbnail: image,
            createdAt: Date()
        )
    }

    /// Creates a StashItem from plain text snippet
    public static func from(text: String) -> StashItem {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstLine = trimmed.components(separatedBy: .newlines).first ?? "Text Snippet"
        let preview = String(firstLine.prefix(40))

        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useBytes, .useKB]
        bcf.countStyle = .file
        let sizeDesc = bcf.string(fromByteCount: Int64(trimmed.utf8.count))

        return StashItem(
            name: preview.isEmpty ? "Snippet" : preview,
            fileExtension: "txt",
            sizeDescription: sizeDesc,
            icon: NSImage(systemSymbolName: "doc.text.fill", accessibilityDescription: nil),
            isImage: false,
            textContent: trimmed,
            createdAt: Date()
        )
    }

    /// Creates an NSItemProvider for dragging this item out into any macOS application (Finder, Slack, Chrome, Mail, etc.)
    /// Invokes `onConsumed` when the destination app reads and accepts the drop.
    public func makeItemProvider(onConsumed: @escaping () -> Void) -> NSItemProvider {
        let provider = NSItemProvider()

        if let url = self.url {
            // Register as standard file URL object
            provider.registerObject(url as NSURL, visibility: .all)

            // Register standard file URL data representation
            provider.registerDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier, visibility: .all) { completion in
                completion(url.dataRepresentation, nil)
                DispatchQueue.main.async {
                    onConsumed()
                }
                return nil
            }

            // Register as image if applicable
            if isImage, let data = try? Data(contentsOf: url) {
                let typeId = (url.pathExtension.lowercased() == "png") ? UTType.png.identifier : UTType.jpeg.identifier
                provider.registerDataRepresentation(forTypeIdentifier: typeId, visibility: .all) { completion in
                    completion(data, nil)
                    DispatchQueue.main.async {
                        onConsumed()
                    }
                    return nil
                }
            }
        } else if let text = self.textContent {
            provider.registerObject(text as NSString, visibility: .all)
            if let data = text.data(using: .utf8) {
                provider.registerDataRepresentation(forTypeIdentifier: UTType.utf8PlainText.identifier, visibility: .all) { completion in
                    completion(data, nil)
                    DispatchQueue.main.async {
                        onConsumed()
                    }
                    return nil
                }
            }
        }

        return provider
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: StashItem, rhs: StashItem) -> Bool {
        lhs.id == rhs.id
    }
}
