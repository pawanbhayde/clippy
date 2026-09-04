import Foundation
import AppKit

// MARK: - Composition root wiring the clipboard capture pipeline together

/// Owns the `ClipboardMonitor` (which itself drives `ContentClassifier`,
/// `AppInfoProvider`, and `MetadataStore` on every captured item) and pairs
/// it with `StorageCleanup`, so a single call at app launch stands up the
/// whole capture → classify → hash → persist → prune pipeline.
final class ClipboardService {
    static let shared = ClipboardService()

    private let monitor = ClipboardMonitor()
    private(set) var isRunning = false

    var isPaused: Bool {
        !isRunning
    }

    private init() {
        monitor.onNewItem = { [weak self] _ in
            self?.runCleanup()
        }
    }

    /// Bootstraps on-disk storage, prunes anything already over the
    /// configured limits, and starts polling the pasteboard. Call once,
    /// at app launch.
    func start() {
        guard !isRunning else { return }
        isRunning = true

        do {
            try LocalStorage.bootstrap()
            try StorageCleanup.runIfNeeded()
        } catch {
            print("ClipboardService: startup failed: \(error)")
        }

        monitor.start()
    }

    func stop() {
        isRunning = false
        monitor.stop()
    }

    /// Pauses clipboard monitoring so incoming pasteboard copies are ignored.
    func pause() {
        stop()
    }

    /// Resumes clipboard monitoring.
    func resume() {
        start()
    }

    /// Ingests an item directly into Clippy clipboard history (such as from drag-and-drop into the drop zone)
    @discardableResult
    func saveToClippy(from pasteboard: NSPasteboard) -> Bool {
        return monitor.ingest(from: pasteboard)
    }

    private func runCleanup() {
        do {
            try StorageCleanup.runIfNeeded()
        } catch {
            print("ClipboardService: cleanup failed: \(error)")
        }
    }
}
