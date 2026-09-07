import SwiftUI
import Combine

// MARK: - Defines animation curves/transitions for shelf show/hide

enum ShelfAnimation {
    /// Apple-grade spring for Dynamic Island expansion:
    /// energetic initial velocity, silky deceleration, perfectly cushioned.
    static let expandSpring = SwiftUI.Animation.spring(response: 0.34, dampingFraction: 0.80, blendDuration: 0)

    /// Apple-grade spring for Dynamic Island collapse:
    /// instant, snappy retraction into the notch with zero bounce or linger.
    static let collapseSpring = SwiftUI.Animation.spring(response: 0.26, dampingFraction: 0.86, blendDuration: 0)

    /// Legacy reference
    static let spring = expandSpring

    /// Size of the resting collapsed notch capsule.
    static let collapsedSize = CGSize(width: 140, height: 28)
    /// Size of the copy notification mini notch island pill.
    static let copyNotificationSize = CGSize(width: 330, height: 40)
    /// Size of the screenshot options mini notch HUD.
    static let screenshotHUDSize = CGSize(width: 340, height: 42)
    /// Size of the fully expanded shelf matching the widescreen custom notch dock.
    static let expandedSize = CGSize(width: 880, height: 290)
}

/// The discrete stages of the capsule ↔ shelf state.
enum ShelfPhase: Equatable {
    case collapsed
    case expanded

    var size: CGSize {
        switch self {
        case .collapsed:
            return ShelfAnimation.collapsedSize
        case .expanded:
            return ShelfAnimation.expandedSize
        }
    }

    var contentOpacity: Double {
        self == .expanded ? 1 : 0
    }
}

/// Publishes the shelf's animation state and drives it with native SwiftUI springs
/// locked to the display's V-Sync (ProMotion 120Hz) with zero Task.sleep timer jitter.
@MainActor
final class ShelfAnimationState: ObservableObject {
    @Published private(set) var isExpanded: Bool = false
    @Published private(set) var contentOpacity: Double = 0
    @Published var isScreenshotHUDActive: Bool = false
    @Published var isCopyNotificationActive: Bool = false
    @Published var activeCopyNotificationItem: ClipboardItem? = nil

    var phase: ShelfPhase {
        isExpanded ? .expanded : .collapsed
    }

    var currentSize: CGSize {
        isExpanded ? ShelfAnimation.expandedSize : ShelfAnimation.collapsedSize
    }

    /// Dynamic Island drop-down opening: slides down from the camera notch (top to bottom)
    /// while content fades gracefully into place.
    func expand() {
        guard !isExpanded else { return }
        withAnimation(ShelfAnimation.expandSpring) {
            self.isExpanded = true
        }
        withAnimation(.easeOut(duration: 0.22)) {
            self.contentOpacity = 1.0
        }
    }

    /// Dynamic Island retraction closing: slides back up into the camera notch (bottom to top)
    /// with zero linger.
    func collapse() {
        guard isExpanded else { return }
        withAnimation(.easeOut(duration: 0.22)) {
            self.contentOpacity = 0.0
        }
        withAnimation(ShelfAnimation.collapseSpring) {
            self.isExpanded = false
        }
    }

    /// Instantly marks the state as collapsed without animation delay (for direct paste execution).
    func collapseImmediately() {
        self.isExpanded = false
        self.contentOpacity = 0.0
        self.isScreenshotHUDActive = false
        self.isCopyNotificationActive = false
        self.activeCopyNotificationItem = nil
    }
}
