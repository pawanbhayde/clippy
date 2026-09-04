import AppKit

// MARK: - Polls/observes the system pasteboard for new clipboard content

/// Polls `NSPasteboard.general.changeCount` on a timer and turns new
/// content into persisted `ClipboardItem`s. If the new content's hash
/// matches the most recent item, no duplicate is created — that item's
/// `lastUsedAt` is refreshed instead.
final class ClipboardMonitor {
    static let pollInterval: TimeInterval = 0.3

    /// Called after a new item has been created and persisted.
    var onNewItem: ((ClipboardItem) -> Void)?
    /// Called after an existing item's `lastUsedAt` has been refreshed.
    var onUpdateItem: ((ClipboardItem) -> Void)?

    private var timer: Timer?
    private var lastChangeCount: Int

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    deinit {
        stop()
    }

    func start() {
        stop()
        let timer = Timer(timeInterval: Self.pollInterval, repeats: true) { [weak self] _ in
            self?.pollPasteboard()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func pollPasteboard() {
        let currentChangeCount = NSPasteboard.general.changeCount
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        // Captured immediately, before reading pasteboard content, so it
        // reflects whichever app was frontmost at the moment of the change.
        let sourceApp = AppInfoProvider.currentSource()

        // Check if the source app is in the excluded apps list
        if let bundleId = sourceApp?.bundleId, !bundleId.isEmpty, AppInfoProvider.excludedAppIDs.contains(bundleId) {
            return
        }

        guard let (item, payload) = ClipboardReader.readCurrent() else { return }

        handle(item: item, payload: payload, sourceApp: sourceApp)
    }

    private func handle(item rawItem: ClipboardItem, payload: ClipboardPayload, sourceApp: AppSource?) {
        // Classify (and flag sensitivity) before this item ever touches disk.
        let classification = ContentClassifier.classify(payload)

        // If sensitive content is configured to be blocked entirely, drop it immediately.
        if classification.isSensitive && PrivacyPreferences.shared.blockSensitiveItems {
            return
        }

        var item = rawItem
        item.type = classification.type
        item.isSensitive = classification.isSensitive
        item.sourceApp = sourceApp

        let shouldEncrypt = classification.isSensitive && PrivacyPreferences.shared.alwaysEncryptSensitive
        item.isEncrypted = shouldEncrypt

        // Mask preview if encrypted so plaintext sensitive data is never saved to metadata.json
        if shouldEncrypt {
            item.preview = "••••••••"
        }

        do {
            var items = try MetadataStore.load()

            if let lastIndex = items.indices.last, items[lastIndex].contentHash == item.contentHash {
                items[lastIndex].lastUsedAt = item.createdAt
                try MetadataStore.save(items)
                onUpdateItem?(items[lastIndex])
                return
            }

            // Persist content (encrypted at rest if sensitive)
            item.storagePath = try persist(payload: payload, for: item)
            items.append(item)
            try MetadataStore.save(items)
            onNewItem?(item)
        } catch {
            print("ClipboardMonitor: failed to persist clipboard item: \(error)")
        }
    }

    private func persist(payload: ClipboardPayload, for item: ClipboardItem) throws -> String {
        switch payload {
        case .text(let string):
            if item.isEncrypted {
                let data = try ContentEncryptor.encrypt(Data(string.utf8))
                return try AssetStore.writeEncryptedText(data, for: item.id).path
            } else {
                return try AssetStore.writeText(string, for: item.id).path
            }
        case .richText(let data):
            if item.isEncrypted {
                let encrypted = try ContentEncryptor.encrypt(data)
                return try AssetStore.writeEncryptedRichText(encrypted, for: item.id).path
            } else {
                return try AssetStore.writeRichText(data, for: item.id).path
            }
        case .image(let data):
            return try AssetStore.writeImage(data, for: item.id, format: .png).path
        case .fileURL(let url):
            return try AssetStore.writeFile(from: url, for: item.id).path
        }
    }
}