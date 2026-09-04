import AppKit
import ApplicationServices

// MARK: - Writes clipboard items back to the system pasteboard and simulates direct paste

enum ClipboardWriter {
    /// Writes `item`'s stored content back to the pasteboard using its
    /// native representation. Resolves the payload from disk via
    /// `AssetStore`, keyed by `item.id`, based on the item's type.
    static func write(_ item: ClipboardItem) {
        switch item.type {
        case .text, .url, .code, .color:
            let text = AssetStore.readText(for: item) ?? item.preview
            guard let text, !text.isEmpty else {
                print("ClipboardWriter: no stored text found for item \(item.id)")
                return
            }
            writeText(text)
        case .richText:
            if let data = AssetStore.readRichText(for: item) {
                writeRichText(data)
            } else if let text = item.preview, !text.isEmpty {
                writeText(text)
            } else {
                print("ClipboardWriter: no stored rich text found for item \(item.id)")
                return
            }
        case .image:
            var data = AssetStore.readImage(for: item.id, format: .png)
            if data == nil, let path = item.storagePath ?? item.thumbnailPath {
                data = try? Data(contentsOf: URL(fileURLWithPath: path))
            }
            guard let imageData = data else {
                print("ClipboardWriter: no stored image found for item \(item.id)")
                return
            }

            var fileURL: URL?
            if let path = item.storagePath ?? item.thumbnailPath, FileManager.default.fileExists(atPath: path) {
                fileURL = URL(fileURLWithPath: path)
            } else {
                let defaultURL = LocalStorage.imagesDirectoryURL.appendingPathComponent("\(item.id.uuidString).png")
                if FileManager.default.fileExists(atPath: defaultURL.path) {
                    fileURL = defaultURL
                } else {
                    fileURL = try? AssetStore.writeImage(imageData, for: item.id, format: .png)
                }
            }
            writeImage(imageData, fileURL: fileURL)
        case .file:
            guard let path = item.storagePath, FileManager.default.fileExists(atPath: path) else {
                print("ClipboardWriter: no stored file path for item \(item.id)")
                return
            }
            writeFile(at: URL(fileURLWithPath: path))
        }
    }

    static func writeText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        markAsClippyWrite()
    }

    static func writeRichText(_ data: Data) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .rtf)
        // Apps that only understand plain text still get something useful.
        if let plainText = (try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        ))?.string {
            pasteboard.setString(plainText, forType: .string)
        }
        markAsClippyWrite()
    }

    /// Writes an image to the system pasteboard providing all standard macOS representations:
    /// - `fileURL as NSURL` & `NSFilenamesPboardType` (essential for WhatsApp, Telegram, Finder, Slack)
    /// - `NSImage` & `public.tiff` (essential for Cocoa apps like Apple Notes, Pages, TextEdit, Mail)
    /// - `public.png` (essential for Chromium, Web apps, Electron, Figma)
    static func writeImage(_ data: Data, fileURL: URL? = nil) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        var objectsToWrite: [NSPasteboardWriting] = []

        if let fileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            objectsToWrite.append(fileURL as NSURL)
        }

        if let image = NSImage(data: data) {
            objectsToWrite.append(image)
        }

        if !objectsToWrite.isEmpty {
            pasteboard.writeObjects(objectsToWrite)
        }

        pasteboard.setData(data, forType: .png)
        if let image = NSImage(data: data), let tiff = image.tiffRepresentation {
            pasteboard.setData(tiff, forType: .tiff)
        }
        markAsClippyWrite()
    }

    /// Writes a file URL to the system pasteboard. If the file is an image, also provides
    /// direct image data representations so document apps and text editors can paste it inline.
    static func writeFile(at url: URL) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        var objects: [NSPasteboardWriting] = [url as NSURL]
        if let image = NSImage(contentsOf: url) {
            objects.append(image)
        }
        pasteboard.writeObjects(objects)

        if let image = NSImage(contentsOf: url), let tiff = image.tiffRepresentation {
            pasteboard.setData(tiff, forType: .tiff)
            if let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
                pasteboard.setData(png, forType: .png)
            }
        }
        markAsClippyWrite()
    }

    private static func markAsClippyWrite() {
        let pasteboard = NSPasteboard.general
        pasteboard.setString("1", forType: .clippyInternalMarker)
        ClipboardMonitor.recordOwnWrite(changeCount: pasteboard.changeCount)
    }

    // MARK: - Direct Paste Automation

    private static var lastPasteTimestamp: TimeInterval = 0

    /// Directly pastes the current clipboard content into the target application by activating
    /// it and simulating a `⌘V` keystroke.
    /// - Parameters:
    ///   - targetApp: The application to receive the paste (defaults to frontmost app if not self).
    ///   - delay: Time interval in seconds to wait for target app window focus to settle (default 0.15s).
    static func pasteToFrontmostApp(targetApp: NSRunningApplication? = nil, delay: TimeInterval = 0.15) {
        let now = Date().timeIntervalSince1970
        guard now - lastPasteTimestamp > 0.4 else { return }
        lastPasteTimestamp = now

        if !PermissionsManager.isAccessibilityGranted() {
            PermissionsManager.requestAccessibilityPermission()
            return
        }

        let appToActivate: NSRunningApplication? = {
            let currentPID = NSRunningApplication.current.processIdentifier
            if let target = targetApp, !target.isTerminated, target.processIdentifier != currentPID {
                return target
            }
            if let frontmost = NSWorkspace.shared.frontmostApplication, !frontmost.isTerminated, frontmost.processIdentifier != currentPID {
                return frontmost
            }
            return NSWorkspace.shared.runningApplications
                .filter { $0.activationPolicy == .regular && !$0.isTerminated && $0.processIdentifier != currentPID }
                .first
        }()

        if let appToActivate {
            appToActivate.activate(options: .activateIgnoringOtherApps)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            simulatePasteKeystroke()
        }
    }

    /// Simulates the ⌘V keyboard shortcut using `CGEvent`.
    static func simulatePasteKeystroke() {
        guard let source = CGEventSource(stateID: .combinedSessionState) else { return }

        // Disable local keyboard events while pasting to avoid modifier interference
        source.setLocalEventsFilterDuringSuppressionState(
            [.permitLocalMouseEvents, .permitSystemDefinedEvents],
            state: .eventSuppressionStateSuppressionInterval
        )

        let vKeyCode: CGKeyCode = 9 // Carbon kVK_ANSI_V

        // Combined device-independent and device-dependent Command modifier flag (0x08 = NX_DEVICELCMDKEYMASK)
        let cmdFlag = CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | 0x000008)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false) else {
            return
        }

        keyDown.flags = cmdFlag
        keyUp.flags = cmdFlag

        // Post once to .cgSessionEventTap so it reaches the session's active window/responder
        keyDown.post(tap: .cgSessionEventTap)
        keyUp.post(tap: .cgSessionEventTap)
    }
}

// MARK: - Pasteboard Type Marker

extension NSPasteboard.PasteboardType {
    /// Internal marker placed on the pasteboard when Clippy writes an item,
    /// instructing ClipboardMonitor to ignore this write and prevent duplicates.
    static let clippyInternalMarker = NSPasteboard.PasteboardType("com.pawan.clippy.internal")
}
