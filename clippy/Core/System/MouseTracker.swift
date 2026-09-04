import AppKit
import CoreGraphics

// MARK: - Tracks mouse position/events for shelf trigger gestures

/// Abstracts "notify me of the global mouse location on every move" so the
/// trigger-region logic below doesn't care which OS mechanism supplies it.
protocol MouseTrackingService: AnyObject {
    /// Called with the current global mouse location (bottom-left-origin
    /// screen coordinates, matching `NSScreen.frame`) on every move while
    /// tracking is active.
    var onMouseMoved: ((NSPoint) -> Void)? { get set }

    func start()
    func stop()
}

/// Default implementation: a global `NSEvent` monitor. Simple, no special
/// entitlements, but only reports moves — it can't see clicks/drags in
/// other apps and won't fire while this app itself is inactive+unfocused
/// in certain edge cases.
final class GlobalMouseMonitor: MouseTrackingService {
    var onMouseMoved: ((NSPoint) -> Void)?

    private var monitor: Any?

    func start() {
        stop()
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            // Global monitors' event coordinates are relative to whatever
            // app owns the event, not us — read the absolute location instead.
            self?.onMouseMoved?(NSEvent.mouseLocation)
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }

    deinit { stop() }
}

/// Alternative implementation: a low-level CGEvent tap. Sees mouse moves
/// system-wide with lower latency than the NSEvent monitor, at the cost of
/// requiring Accessibility/Input Monitoring permission.
final class CGEventMouseMonitor: MouseTrackingService {
    var onMouseMoved: ((NSPoint) -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    func start() {
        stop()

        let eventMask = CGEventMask(1 << CGEventType.mouseMoved.rawValue)
        let callback: CGEventTapCallBack = { _, _, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let monitor = Unmanaged<CGEventMouseMonitor>.fromOpaque(refcon).takeUnretainedValue()
            monitor.onMouseMoved?(CGEventMouseMonitor.cocoaPoint(from: event.location))
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
            print("CGEventMouseMonitor: failed to create event tap — check Input Monitoring/Accessibility permission")
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        eventTap = tap
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    /// CGEvent locations are top-left-origin (CG global display space).
    /// `NSScreen`/`NSEvent.mouseLocation` are bottom-left-origin (Cocoa
    /// global space). The primary screen (index 0, the one with the menu
    /// bar) anchors both systems at y=0, so its height is the flip point.
    private static func cocoaPoint(from cgPoint: CGPoint) -> NSPoint {
        let primaryScreenHeight = NSScreen.screens.first?.frame.height ?? 0
        return NSPoint(x: cgPoint.x, y: primaryScreenHeight - cgPoint.y)
    }

    deinit { stop() }
}

/// Watches the mouse for two things: entering a small trigger region
/// directly under the notch/menu bar, and hovering the shelf itself once
/// it's open. Expands on either; collapses ~300ms after leaving both.
final class MouseTracker {
    private static let defaultTriggerSize = NSSize(width: 220, height: 6)
    private static let collapseDelay: TimeInterval = 0.3

    /// Called when the mouse enters the trigger region (or the shelf,
    /// while already expanded) and the shelf should expand.
    var onExpand: (() -> Void)?
    /// Called ~300ms after the mouse has left both the trigger region and
    /// the shelf's frame.
    var onCollapse: (() -> Void)?

    private let trackingService: MouseTrackingService
    private let triggerSize: NSSize
    private var triggerRegion: NSRect = .zero
    private var shelfFrame: NSRect?
    private var isExpanded = false
    private var collapseTimer: Timer?

    init(trackingService: MouseTrackingService = GlobalMouseMonitor(), triggerSize: NSSize = MouseTracker.defaultTriggerSize) {
        self.trackingService = trackingService
        self.triggerSize = triggerSize
        trackingService.onMouseMoved = { [weak self] location in
            self?.handleMouseMoved(location)
        }
    }

    /// Recomputes the trigger region for the active screen and starts
    /// tracking. Call again if the active screen may have changed.
    func start() {
        triggerRegion = Self.triggerRegion(size: triggerSize)
        trackingService.start()
    }

    func stop() {
        trackingService.stop()
        collapseTimer?.invalidate()
        collapseTimer = nil
    }

    /// Informs the tracker of the shelf's current on-screen frame so
    /// hovering it counts as "still in use." Pass `nil` while the shelf is
    /// hidden/closed.
    func updateShelfFrame(_ frame: NSRect?) {
        shelfFrame = frame
    }

    /// Marks the shelf as already-collapsed without firing `onCollapse` —
    /// for callers (e.g. a click-driven dismiss) that collapsed it
    /// themselves and just need the tracker's own state to catch up, so it
    /// doesn't wait for a "mouse left" event before it'll expand again.
    func forceCollapse() {
        collapseTimer?.invalidate()
        collapseTimer = nil
        isExpanded = false
    }

    private static func triggerRegion(size: NSSize) -> NSRect {
        guard let screen = ScreenManager.activeScreen() else { return .zero }
        let originX = screen.frame.midX - size.width / 2
        let originY = screen.frame.maxY - size.height
        return NSRect(origin: NSPoint(x: originX, y: originY), size: size)
    }

    private func handleMouseMoved(_ location: NSPoint) {
        let isInsideTrigger = triggerRegion.contains(location)
        let isInsideShelf = shelfFrame?.contains(location) ?? false

        guard isInsideTrigger || isInsideShelf else {
            scheduleCollapseIfNeeded()
            return
        }

        collapseTimer?.invalidate()
        collapseTimer = nil

        guard !isExpanded else { return }
        isExpanded = true
        onExpand?()
    }

    private func scheduleCollapseIfNeeded() {
        guard isExpanded, collapseTimer == nil else { return }
        collapseTimer = Timer.scheduledTimer(withTimeInterval: Self.collapseDelay, repeats: false) { [weak self] _ in
            self?.collapse()
        }
    }

    private func collapse() {
        collapseTimer = nil
        isExpanded = false
        onCollapse?()
    }
}
