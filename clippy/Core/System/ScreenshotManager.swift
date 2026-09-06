import AppKit
import Combine
import Foundation

// MARK: - Manager executing native macOS screencapture commands into the clipboard

@MainActor
public final class ScreenshotManager: ObservableObject {
    public static let shared = ScreenshotManager()

    public enum CaptureMode: String, CaseIterable, Identifiable {
        case area
        case window
        case screen

        public var id: String { rawValue }

        public var title: String {
            switch self {
            case .area: return "Area"
            case .window: return "Window"
            case .screen: return "Screen"
            }
        }

        public var iconName: String {
            switch self {
            case .area: return "crop"
            case .window: return "macwindow"
            case .screen: return "display"
            }
        }

        public var helpText: String {
            switch self {
            case .area: return "Drag to select a custom area (Press 1 or A)"
            case .window: return "Click any window to capture (Press 2 or W)"
            case .screen: return "Capture the entire active display (Press 3 or S)"
            }
        }

        var arguments: [String] {
            switch self {
            case .area:
                // -i: interactive, -s: only selection, -c: to clipboard
                return ["-i", "-s", "-c"]
            case .window:
                // -i: interactive, -w: only window, -c: to clipboard
                return ["-i", "-w", "-c"]
            case .screen:
                // -c: to clipboard
                return ["-c"]
            }
        }
    }

    /// Whether a screenshot capture process is currently executing
    @Published public private(set) var isCapturing: Bool = false

    private init() {}

    /// Executes the screenshot in background and copies image data to NSPasteboard.general.
    /// Calls completion handler on MainActor with `true` if a new screenshot was captured, or `false` if cancelled.
    public func capture(mode: CaptureMode, completion: @escaping (Bool) -> Void) {
        guard !isCapturing else { return }
        isCapturing = true

        let initialChangeCount = NSPasteboard.general.changeCount
        let args = mode.arguments

        Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            process.arguments = args

            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("ScreenshotManager: failed to run screencapture: \(error)")
            }

            await MainActor.run {
                self.isCapturing = false
                let newChangeCount = NSPasteboard.general.changeCount
                let didCapture = newChangeCount != initialChangeCount
                if didCapture {
                    NSSound(named: "Glass")?.play()
                }
                completion(didCapture)
            }
        }
    }
}
