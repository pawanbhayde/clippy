import AppKit
import KeyboardShortcuts

// MARK: - Registers and handles the system-wide hotkey to toggle the shelf

extension KeyboardShortcuts.Name {
    /// ⌘⇧V by default — toggles the shelf open/closed regardless of mouse
    /// hover. Rebindable later from Settings > General.
    static let toggleShelf = Self("toggleShelf", default: .init(.v, modifiers: [.command, .shift]))
}

/// Binds the configurable toggle-shelf hotkey to a handler. Owned by
/// `ShelfController` alongside `MouseTracker`, so hover- and hotkey-driven
/// show/hide both funnel through the same toggle call.
@MainActor
final class GlobalShortcut {
    var onToggle: (() -> Void)?

    private var isActive = false

    func start() {
        guard !isActive else { return }
        isActive = true
        KeyboardShortcuts.onKeyUp(for: .toggleShelf) { [weak self] in
            guard let self, self.isActive else { return }
            self.onToggle?()
        }
    }

    func stop() {
        isActive = false
    }
}
