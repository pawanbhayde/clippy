import AppKit
import Combine
import Foundation

// MARK: - Manager for Temporary Drop Stash (Notch Drop Zone)

@MainActor
public final class StashManager: ObservableObject {
    public static let shared = StashManager()

    public enum DropZoneTarget: String {
        case none
        case stash
        case clippy
    }

    /// All items currently held in the temporary stash
    @Published public private(set) var items: [StashItem] = []

    /// Whether an active drag session is hovering over the notch drop zone
    @Published public var isDropZoneActive: Bool = false

    /// The specific drop target currently hovered (temporary stash vs save to clippy)
    @Published public var activeDropTarget: DropZoneTarget = .none

    /// Whether the user or drag operation has activated the Stash shelf view
    @Published public var isStashViewSelected: Bool = false

    private init() {
        try? LocalStorage.bootstrap()
    }

    /// Adds items from a dragging pasteboard (files, images, text) into the temporary stash
    @discardableResult
    public func addItems(from pasteboard: NSPasteboard) -> Int {
        var addedCount = 0

        // 1. Try reading file URLs first
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true
        ]) as? [URL], !urls.isEmpty {
            for url in urls {
                // Avoid duplicate if same file is already in stash
                if !items.contains(where: { $0.url?.path == url.path }) {
                    let item = StashItem.from(fileURL: url)
                    items.insert(item, at: 0)
                    addedCount += 1
                }
            }
        }

        // 2. Try reading image if no file URLs were found
        if addedCount == 0, let image = NSImage(pasteboard: pasteboard) {
            if let item = StashItem.from(image: image) {
                items.insert(item, at: 0)
                addedCount += 1
            }
        }

        // 3. Try reading URLs (web links)
        if addedCount == 0, let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
            for url in urls {
                let item = StashItem.from(fileURL: url)
                items.insert(item, at: 0)
                addedCount += 1
            }
        }

        // 4. Try reading text snippet
        if addedCount == 0, let text = pasteboard.string(forType: .string), !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let item = StashItem.from(text: text)
            items.insert(item, at: 0)
            addedCount += 1
        }

        if addedCount > 0 {
            isStashViewSelected = true
            NSSound(named: "Pop")?.play()
        }

        return addedCount
    }

    /// Adds explicit file URLs into the stash
    public func add(urls: [URL]) {
        for url in urls {
            if !items.contains(where: { $0.url?.path == url.path }) {
                items.insert(StashItem.from(fileURL: url), at: 0)
            }
        }
        if !urls.isEmpty {
            isStashViewSelected = true
        }
    }

    /// Removes an item by ID (called when an item is dragged out or closed)
    public func removeItem(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let item = items.remove(at: index)

        // If this was a temporary dropped file created inside stashDirectoryURL, delete it
        if let url = item.url, url.path.hasPrefix(LocalStorage.stashDirectoryURL.path) {
            try? FileManager.default.removeItem(at: url)
        }

        if items.isEmpty {
            isStashViewSelected = false
            NotificationCenter.default.post(name: .shelfShouldCollapseAfterDrop, object: nil)
        }
    }

    /// Clears all stashed items and removes temporary files
    public func clearAll() {
        for item in items {
            if let url = item.url, url.path.hasPrefix(LocalStorage.stashDirectoryURL.path) {
                try? FileManager.default.removeItem(at: url)
            }
        }
        items.removeAll()
        isStashViewSelected = false
    }

    /// Copies all stashed items to system pasteboard
    public func copyAllToClipboard() {
        let fileURLs = items.compactMap { $0.url }
        if !fileURLs.isEmpty {
            let pb = NSPasteboard.general
            pb.clearContents()
            pb.writeObjects(fileURLs as [NSURL])
        }
    }

    /// Saves a stashed item directly into Clippy clipboard history
    public func saveItemToClippy(_ item: StashItem) {
        let pb = NSPasteboard(name: NSPasteboard.Name("clippy.stash.transfer"))
        pb.clearContents()
        if let url = item.url {
            pb.writeObjects([url as NSURL])
        } else if let text = item.textContent {
            pb.setString(text, forType: .string)
        } else if let img = item.imageThumbnail {
            pb.writeObjects([img])
        }
        ClipboardService.shared.saveToClippy(from: pb)
        NSSound(named: "Glass")?.play()
    }
}
