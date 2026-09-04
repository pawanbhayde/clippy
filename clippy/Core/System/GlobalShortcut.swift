import AppKit
import Cocoa
import KeyboardShortcuts

// MARK: - Registers and handles the system-wide hotkey to toggle the shelf

extension KeyboardShortcuts.Name {
    /// ⌘⇧V by default — toggles the shelf open/closed regardless of mouse
    /// hover. Rebindable later from Settings > General.
    static let toggleShelf = Self(
        "toggleShelf",
        default: KeyboardShortcuts.Shortcut(.v, modifiers: [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.shift])
    )

    /// ⌘⌥V by default — activates or stops Sequential Queue Paste mode.
    static let toggleQueueMode = Self(
        "toggleQueueMode",
        default: KeyboardShortcuts.Shortcut(.v, modifiers: [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.option])
    )
}

/// Binds the configurable toggle-shelf and toggle-queue hotkeys to handlers. Owned by
/// `ShelfController` alongside `MouseTracker`.
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
        KeyboardShortcuts.onKeyUp(for: .toggleQueueMode) { [weak self] in
            guard let self, self.isActive else { return }
            PasteQueueManager.shared.toggle()
        }
    }

    func stop() {
        isActive = false
    }
}
