import SwiftUI
import Combine

// MARK: - Defines animation curves/transitions for shelf show/hide

enum ShelfAnimation {
    /// The spring used for every stage of the capsule → shelf expansion.
    static let spring = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.82)

    /// Size of the collapsed, capsule-shaped trigger indicator.
    static let collapsedSize = CGSize(width: 140, height: 8)
    /// Size of the fully expanded shelf matching the widescreen custom notch dock.
    static let expandedSize = CGSize(width: 880, height: 320)

    /// How long each stage is given before the next one starts, so
    /// width → height → content-fade read as sequential beats rather than
    /// one blended motion.
    static let stageInterval: TimeInterval = 0.12
}

/// The three discrete stages of the capsule → shelf expansion. Traversed
/// forward (`.expandingWidth` → `.expandingHeight` → `.expanded`) to open
/// and in reverse to close, so opening and closing share one definition of
/// "what each stage looks like."
enum ShelfPhase: Equatable {
    case collapsed
    case expandingWidth
    case expandingHeight
    case expanded

    /// Width grows first; height only grows once width has; both are full
    /// size once expanded — content fade (below) is the only thing left to
    /// animate between `.expandingHeight` and `.expanded`.
    var size: CGSize {
        switch self {
        case .collapsed:
            return ShelfAnimation.collapsedSize
        case .expandingWidth:
            return CGSize(width: ShelfAnimation.expandedSize.width, height: ShelfAnimation.collapsedSize.height)
        case .expandingHeight, .expanded:
            return ShelfAnimation.expandedSize
        }
    }

    /// Content is only visible once fully expanded.
    var contentOpacity: Double {
        self == .expanded ? 1 : 0
    }
}

/// Publishes the shelf's current `ShelfPhase` and drives it through the
/// width → height → content-fade sequence (or its reverse) using
/// `ShelfAnimation.spring`. Owned by `ShelfController`; observed by
/// whatever SwiftUI content renders the shelf.
@MainActor
final class ShelfAnimationState: ObservableObject {
    @Published private(set) var phase: ShelfPhase = .collapsed

    private var sequenceTask: Task<Void, Never>?

    /// Capsule → full shelf: width, then height, then content fades in.
    func expand() {
        runSequence([.expandingWidth, .expandingHeight, .expanded])
    }

    /// Full shelf → capsule: content fades out, then height, then width.
    func collapse() {
        runSequence([.expandingHeight, .expandingWidth, .collapsed])
    }

    private func runSequence(_ phases: [ShelfPhase]) {
        sequenceTask?.cancel()
        sequenceTask = Task { [weak self] in
            for (index, nextPhase) in phases.enumerated() {
                guard let self, !Task.isCancelled else { return }
                withAnimation(ShelfAnimation.spring) { self.phase = nextPhase }

                guard index < phases.count - 1 else { return }
                try? await Task.sleep(nanoseconds: UInt64(ShelfAnimation.stageInterval * 1_000_000_000))
            }
        }
    }
}
