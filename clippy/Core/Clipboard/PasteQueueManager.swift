import AppKit
import Carbon.HIToolbox
import Combine

// MARK: - Manages Sequential / Queue Paste ("Paste Queue")

/// Coordinates FIFO queue paste workflows:
/// 1. When active, multiple copies (⌘C) are collected sequentially.
/// 2. The first item in the queue is primed onto `NSPasteboard.general`.
/// 3. In any target application, each ⌘V pastes the current front item, then advances
///    the next queued item onto the pasteboard.
/// 4. Displays live queue progress in the notch Dynamic Island.
@MainActor
final class PasteQueueManager: ObservableObject {
    static let shared = PasteQueueManager()

    @Published private(set) var isActive: Bool = false
    @Published private(set) var queue: [ClipboardItem] = []
    @Published private(set) var isCompletedFeedback: Bool = false

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isAdvancing = false
    private var lastAdvanceTime: TimeInterval = 0

    private init() {}

    // MARK: - Lifecycle

    func startQueue() {
        guard !isActive else { return }
        isActive = true
        isCompletedFeedback = false
        startEventTap()
        primeCurrentFrontItem()
        NSSound(named: "Pop")?.play()
    }

    func stopQueue() {
        guard isActive else { return }
        isActive = false
        stopEventTap()
        queue.removeAll()
        isCompletedFeedback = false
    }

    func toggle() {
        if isActive {
            stopQueue()
        } else {
            startQueue()
        }
    }

    // MARK: - Queue Operations

    /// Appends an item to the queue.
    func enqueue(_ item: ClipboardItem) {
        if !isActive {
            startQueue()
        }

        // Avoid adding exact duplicate back-to-back
        if let last = queue.last, last.contentHash == item.contentHash {
            return
        }

        queue.append(item)

        // Ensure the FIRST item in the FIFO queue is always primed on the system pasteboard
        primeCurrentFrontItem()

        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
    }

    /// Removes a specific item from the queue by index.
    func remove(at index: Int) {
        guard queue.indices.contains(index) else { return }
        queue.remove(at: index)
        if queue.isEmpty {
            stopQueue()
        } else {
            primeCurrentFrontItem()
        }
    }

    /// Clears the queue without stopping queue mode.
    func clearQueue() {
        queue.removeAll()
        stopQueue()
    }

    /// Skips the current front item and moves to the next.
    func skipNext() {
        guard !queue.isEmpty else { return }
        queue.removeFirst()
        if queue.isEmpty {
            finishQueue()
        } else {
            primeCurrentFrontItem()
        }
    }

    // MARK: - Pasteboard Priming

    private func primeCurrentFrontItem() {
        guard let front = queue.first else { return }
        ClipboardWriter.write(front)
    }

    // MARK: - Paste Keystroke Handling

    fileprivate func handlePasteKeystrokeDetected() {
        guard isActive, !queue.isEmpty, !isAdvancing else { return }

        let now = Date().timeIntervalSince1970
        guard now - lastAdvanceTime > 0.35 else { return }
        lastAdvanceTime = now
        isAdvancing = true

        // Allow target application 80ms to read the current pasteboard item before advancing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            guard let self, self.isActive, !self.queue.isEmpty else {
                self?.isAdvancing = false
                return
            }

            self.queue.removeFirst()

            if self.queue.isEmpty {
                self.finishQueue()
            } else {
                self.primeCurrentFrontItem()
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
            }
            self.isAdvancing = false
        }
    }

    private func finishQueue() {
        isCompletedFeedback = true
        NSSound(named: "Glass")?.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            guard let self, self.isCompletedFeedback else { return }
            self.isCompletedFeedback = false
            self.stopQueue()
        }
    }

    // MARK: - CGEventTap Listener for ⌘V

    private func startEventTap() {
        stopEventTap()

        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard type == .keyDown, let refcon else {
                return Unmanaged.passUnretained(event)
            }
            let flags = event.flags
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

            // KeyCode 9 is 'V' on ANSI/standard keyboards
            if flags.contains(.maskCommand) && !flags.contains(.maskControl) && !flags.contains(.maskAlternate) && keyCode == 9 {
                DispatchQueue.main.async {
                    let manager = Unmanaged<PasteQueueManager>.fromOpaque(refcon).takeUnretainedValue()
                    manager.handlePasteKeystrokeDetected()
                }
            }
            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("PasteQueueManager: failed to create event tap — check Accessibility permission")
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        eventTap = tap
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func stopEventTap() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }
}
