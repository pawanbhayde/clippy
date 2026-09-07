import AppKit
import SwiftUI

// MARK: - AppKit Window for Writing Tools Floating Panel

/// Floating, borderless panel positioned directly below the Dynamic Island shelf.
final class WritingToolsWindow: NSPanel {
    convenience init(contentRect: NSRect = .zero) {
        self.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
    }

    override var canBecomeKey: Bool { true }
}

// MARK: - Writing Tools Panel Controller

@MainActor
final class WritingToolsPanelController: NSObject {
    private var window: WritingToolsWindow?
    private var keyMonitor: Any?
    private var clickOutsideMonitor: Any?
    private var currentItem: ClipboardItem?
    private(set) var isOpen: Bool = false

    static let panelSize = NSSize(width: 780, height: 470)

    func show(
        for item: ClipboardItem,
        shelfFrame: NSRect,
        onSaved: @escaping (String) -> Void,
        onPasteToApp: @escaping (String) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.currentItem = item

        // Compute position: centered horizontally under shelf, 10pt below bottom edge
        let originX = shelfFrame.midX - Self.panelSize.width / 2
        let originY = shelfFrame.minY - 10 - Self.panelSize.height
        let targetFrame = NSRect(x: originX, y: originY, width: Self.panelSize.width, height: Self.panelSize.height)

        if window == nil {
            let win = WritingToolsWindow(contentRect: targetFrame)
            self.window = win
        }

        guard let window = self.window else { return }
        window.setFrame(targetFrame, display: true)

        let rootView = WritingToolsPanelView(
            item: item,
            onClose: { [weak self] in
                self?.close()
                onClose()
            },
            onSaved: { refinedText in
                onSaved(refinedText)
            },
            onPasteToApp: { [weak self] refinedText in
                self?.close()
                onPasteToApp(refinedText)
            }
        )

        let hostingView = NSHostingView(rootView: rootView)
        hostingView.focusRingType = .none
        window.contentView = hostingView

        window.alphaValue = 0
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().alphaValue = 1
        }

        isOpen = true
        setupEventMonitors(shelfFrame: shelfFrame, onClose: onClose)
    }

    func close() {
        guard isOpen, let window = self.window else { return }
        isOpen = false
        removeEventMonitors()

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.16
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            MainActor.assumeIsolated {
                window.orderOut(nil)
                self?.window = nil
            }
        })
    }

    var frame: NSRect {
        window?.frame ?? .zero
    }

    private func setupEventMonitors(shelfFrame: NSRect, onClose: @escaping () -> Void) {
        removeEventMonitors()

        // Monitor Escape key to close panel
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.isOpen else { return event }
            if event.keyCode == 53 { // Escape
                self.close()
                onClose()
                return nil
            }
            return event
        }

        // Click outside both shelf and writing tools panel
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self, self.isOpen, let win = self.window else { return }
            let mouseLoc = NSEvent.mouseLocation
            if !win.frame.contains(mouseLoc) && !shelfFrame.contains(mouseLoc) {
                self.close()
                onClose()
            }
        }
    }

    private func removeEventMonitors() {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            self.keyMonitor = nil
        }
        if let clickOutsideMonitor {
            NSEvent.removeMonitor(clickOutsideMonitor)
            self.clickOutsideMonitor = nil
        }
    }

    deinit {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
        if let clickOutsideMonitor {
            NSEvent.removeMonitor(clickOutsideMonitor)
        }
    }
}

// MARK: - AppKit TextView Host with Native Apple Intelligence Writing Tools

struct WritingToolsTextViewHost: NSViewRepresentable {
    @Binding var text: String
    var triggerWritingTools: Bool
    var onWritingToolsTriggered: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(containerSize: NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)

        let textView = NSTextView(frame: NSRect(origin: .zero, size: contentSize), textContainer: textContainer)
        textView.minSize = NSSize(width: 0.0, height: contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.insertionPointColor = .white
        textView.font = .systemFont(ofSize: 14.5, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.delegate = context.coordinator

        if #available(macOS 15.0, *) {
            textView.writingToolsBehavior = .complete
            textView.allowedWritingToolsResultOptions = [.plainText, .richText, .list, .table]
        }

        textView.string = text
        scrollView.documentView = textView
        context.coordinator.textView = textView

        // Make first responder cleanly without opening any unwanted popovers
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let window = textView.window else { return }
            window.makeFirstResponder(textView)
        }

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.selectedRanges = selectedRanges
        }

        if triggerWritingTools {
            DispatchQueue.main.async {
                guard let window = textView.window else {
                    onWritingToolsTriggered()
                    return
                }
                window.makeFirstResponder(textView)
                if textView.selectedRange().length == 0 {
                    textView.selectAll(nil)
                }
                if #available(macOS 15.2, *) {
                    textView.showWritingTools(nil)
                }
                onWritingToolsTriggered()
            }
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: WritingToolsTextViewHost
        weak var textView: NSTextView?

        init(_ parent: WritingToolsTextViewHost) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}

// MARK: - Writing Tools Panel SwiftUI View

struct WritingToolsPanelView: View {
    let item: ClipboardItem
    var onClose: () -> Void
    var onSaved: (String) -> Void
    var onPasteToApp: (String) -> Void

    @State private var text: String
    @State private var originalText: String
    @State private var currentToolName: String = ""
    @State private var triggerWritingTools: Bool = false
    @State private var toastMessage: String?
    @State private var isProcessing: Bool = false

    init(
        item: ClipboardItem,
        onClose: @escaping () -> Void,
        onSaved: @escaping (String) -> Void,
        onPasteToApp: @escaping (String) -> Void
    ) {
        self.item = item
        self.onClose = onClose
        self.onSaved = onSaved
        self.onPasteToApp = onPasteToApp
        let initial = AssetStore.readText(for: item) ?? item.preview ?? ""
        _text = State(initialValue: initial)
        _originalText = State(initialValue: initial)
    }

    private var wordCount: Int {
        let words = text.split { $0.isWhitespace || $0.isNewline }
        return words.count
    }

    private var characterCount: Int {
        text.count
    }

    private var canRevert: Bool {
        text != originalText
    }

    var body: some View {
        ZStack {
            // Dark obsidian frosted background panel
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(red: 0.06, green: 0.06, blue: 0.07).opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.6), radius: 28, x: 0, y: 14)

            VStack(spacing: 10) {
                // Row 1: Header Bar (Metadata on Left, Utility Actions on Right)
                HStack(spacing: 10) {
                    // Left: Snippet document icon & preview/title
                    HStack(spacing: 7) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.preview?.prefix(40) ?? "Snippet")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text("\(wordCount) words • \(characterCount) chars")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.white.opacity(0.45))
                        }
                    }

                    Spacer()

                    // Right: Utility Actions & Close
                    HStack(spacing: 8) {
                        Button {
                            copyCurrentText()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Copy")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4.5)
                            .background(Capsule().fill(Color.white.opacity(0.1)))
                        }
                        .buttonStyle(.plain)
                        .help("Copy refined text (⌘C)")

                        Button {
                            pasteToFrontmostApp()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.right.doc.on.clipboard")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("Paste to App")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4.5)
                            .background(Capsule().fill(Color.white.opacity(0.14)))
                        }
                        .buttonStyle(.plain)
                        .help("Paste refined text into active application")

                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(6)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                        .buttonStyle(.plain)
                        .help("Close panel (Esc)")
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)

                // Row 2: One-Click Rewrite Chips & Action Capsule
                HStack(spacing: 6) {
                    // Revert Button
                    Button {
                        revertText()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Revert")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(canRevert ? .white : .white.opacity(0.35))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(canRevert ? 0.12 : 0.04)))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canRevert)
                    .help("Revert to original text")

                    Divider()
                        .frame(height: 14)
                        .opacity(0.25)

                    // One-Click Rewrite Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            WritingToolChip(
                                title: "Proofread",
                                icon: "text.badge.checkmark",
                                isSelected: currentToolName == "Proofread",
                                action: { applyProofread() }
                            )

                            WritingToolChip(
                                title: "Concise",
                                icon: "arrow.down.right.and.arrow.up.left",
                                isSelected: currentToolName == "Concise",
                                action: { applyRewrite(style: "Concise") }
                            )

                            WritingToolChip(
                                title: "Friendly",
                                icon: "face.smiling",
                                isSelected: currentToolName == "Friendly",
                                action: { applyRewrite(style: "Friendly") }
                            )

                            WritingToolChip(
                                title: "Professional",
                                icon: "briefcase",
                                isSelected: currentToolName == "Professional",
                                action: { applyRewrite(style: "Professional") }
                            )

                            WritingToolChip(
                                title: "Summary",
                                icon: "text.quote",
                                isSelected: currentToolName == "Summary",
                                action: { applyTransform(type: "Summary") }
                            )

                            WritingToolChip(
                                title: "Key Points",
                                icon: "list.bullet.indent",
                                isSelected: currentToolName == "Key Points",
                                action: { applyTransform(type: "Key Points") }
                            )

                            WritingToolChip(
                                title: "List",
                                icon: "list.bullet",
                                isSelected: currentToolName == "List",
                                action: { applyTransform(type: "List") }
                            )

                            WritingToolChip(
                                title: "Table",
                                icon: "tablecells",
                                isSelected: currentToolName == "Table",
                                action: { applyTransform(type: "Table") }
                            )

                            WritingToolChip(
                                title: "Apple Tools",
                                icon: "wand.and.sparkles",
                                isSelected: false,
                                isGradient: true,
                                action: { invokeNativeWritingTools() }
                            )
                        }
                        .padding(.vertical, 2)
                    }

                    Divider()
                        .frame(height: 14)
                        .opacity(0.25)

                    // Done Button (Vibrant Apple Blue Pill)
                    Button {
                        finishAndSave()
                    } label: {
                        Text("Done")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(.plain)
                    .help("Save refined text and finish")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 0.8))
                )
                .padding(.horizontal, 18)

                // Main Editor Area with Apple Intelligence motif watermark
                ZStack {
                    // Subtle 3D Apple Intelligence wand/crystal emblem in background
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 110, weight: .ultraLight))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.06),
                                    Color.blue.opacity(0.06),
                                    Color.pink.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 2)
                        .allowsHitTesting(false)

                    WritingToolsTextViewHost(
                        text: $text,
                        triggerWritingTools: triggerWritingTools,
                        onWritingToolsTriggered: {
                            triggerWritingTools = false
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                        )
                )
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }

            // Floating Toast Notification
            if let toast = toastMessage {
                Text(toast)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.black.opacity(0.88)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 3)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 30)
            }
        }
        .frame(width: WritingToolsPanelController.panelSize.width, height: WritingToolsPanelController.panelSize.height)
    }

    // MARK: - Actions

    private func revertText() {
        withAnimation(.easeInOut(duration: 0.2)) {
            text = originalText
            currentToolName = ""
        }
        showToast("Reverted to Original")
    }

    private func copyCurrentText() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        onSaved(text)
        showToast("Copied to Clipboard")
    }

    private func finishAndSave() {
        onSaved(text)
        showToast("Saved to Clippy")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onClose()
        }
    }

    private func pasteToFrontmostApp() {
        onPasteToApp(text)
    }

    private func invokeNativeWritingTools() {
        triggerWritingTools = true
        currentToolName = "Writing Tools"
    }

    private func applyRewrite(style: String) {
        currentToolName = style
        switch style {
        case "Concise":
            text = WritingToolsTransformer.makeConcise(text)
        case "Friendly":
            text = WritingToolsTransformer.makeFriendly(text)
        case "Professional":
            text = WritingToolsTransformer.makeProfessional(text)
        default:
            break
        }
        showToast("Rewritten: \(style)")
    }

    private func applyTransform(type: String) {
        currentToolName = type
        switch type {
        case "Summary":
            text = WritingToolsTransformer.summarize(text)
        case "Key Points":
            text = WritingToolsTransformer.extractKeyPoints(text)
        case "List":
            text = WritingToolsTransformer.convertToList(text)
        case "Table":
            text = WritingToolsTransformer.convertToTable(text)
        default:
            break
        }
        showToast("Transformed: \(type)")
    }

    private func applyProofread() {
        currentToolName = "Proofread"
        text = WritingToolsTransformer.proofread(text)
        showToast("Proofread Applied")
    }

    private func showToast(_ msg: String) {
        withAnimation(.easeInOut(duration: 0.15)) {
            toastMessage = msg
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.2)) {
                toastMessage = nil
            }
        }
    }
}

// MARK: - Writing Tool Chip View

private struct WritingToolChip: View {
    let title: String
    let icon: String
    var isSelected: Bool = false
    var isGradient: Bool = false
    let action: () -> Void

    @State private var isHovered: Bool = false

    private var iconColor: Color {
        if isSelected { return .white }
        return isHovered ? .white : Color.white.opacity(0.75)
    }

    private var textColor: Color {
        if isSelected { return .white }
        return isHovered ? .white : Color.white.opacity(0.85)
    }

    private var backgroundColor: Color {
        if isSelected { return Color.blue.opacity(0.38) }
        return isHovered ? Color.white.opacity(0.14) : Color.white.opacity(0.07)
    }

    private var strokeColor: Color {
        if isSelected { return Color.blue.opacity(0.85) }
        return isHovered ? Color.white.opacity(0.28) : Color.white.opacity(0.12)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if isGradient {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [.purple, .blue, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 10.5, weight: isSelected ? .bold : .semibold))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(textColor)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(backgroundColor)
                    .overlay(Capsule().stroke(strokeColor, lineWidth: isSelected ? 1.2 : 0.8))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - On-Device Writing Tools Transformer (Zero-latency fallback & instant rewrite)

enum WritingToolsTransformer {
    static func proofread(_ input: String) -> String {
        var result = input
        // Remove trailing spaces on lines
        result = result.replacingOccurrences(of: "[ \\t]+$", with: "", options: .regularExpression)
        // Collapse 3+ consecutive newlines to 2
        result = result.replacingOccurrences(of: "\\n{3,}", with: "\n\n", options: .regularExpression)
        // Capitalize sentences
        result = capitalizeSentences(result)
        return result
    }

    static func makeConcise(_ input: String) -> String {
        var result = input
        let fluffReplacements: [(String, String)] = [
            ("(?i)\\bin order to\\b", "to"),
            ("(?i)\\bat this point in time\\b", "now"),
            ("(?i)\\bdue to the fact that\\b", "because"),
            ("(?i)\\bfor the purpose of\\b", "for"),
            ("(?i)\\bwith regards to\\b", "regarding"),
            ("(?i)\\bit is important to note that\\b", ""),
            ("(?i)\\bneedless to say\\b,?", ""),
            ("(?i)\\bas a matter of fact\\b,?", "in fact,"),
            ("(?i)\\bin the event that\\b", "if"),
            ("(?i)\\ba large number of\\b", "many"),
            ("(?i)\\bat the present time\\b", "currently")
        ]
        for (pattern, replacement) in fluffReplacements {
            result = result.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
        }
        // Collapse spaces
        result = result.replacingOccurrences(of: "[ ]{2,}", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func makeFriendly(_ input: String) -> String {
        var result = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if !result.hasPrefix("Hi") && !result.hasPrefix("Hello") && !result.hasPrefix("Hey") {
            result = "Hi,\n\n" + result
        }
        if !result.contains("Thanks") && !result.contains("Cheers") && !result.contains("Best") {
            result += "\n\nThanks and have a great day!"
        }
        return result
    }

    static func makeProfessional(_ input: String) -> String {
        var result = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("Hi,") || result.hasPrefix("Hey,") {
            result = result.replacingOccurrences(of: "^(Hi|Hey),?", with: "Dear recipient,", options: .regularExpression)
        }
        if !result.contains("Best regards") && !result.contains("Sincerely") {
            result += "\n\nBest regards,"
        }
        return result
    }

    static func summarize(_ input: String) -> String {
        let lines = input.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        if lines.count <= 2 { return input }
        let summaryLines = Array(lines.prefix(3))
        return summaryLines.joined(separator: " ")
    }

    static func extractKeyPoints(_ input: String) -> String {
        let lines = input.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        var points: [String] = []
        for line in lines {
            let cleaned = line.replacingOccurrences(of: "^[•\\-*0-9.]+\\s*", with: "", options: .regularExpression)
            if !cleaned.isEmpty {
                points.append("• \(cleaned)")
            }
        }
        return points.isEmpty ? input : points.joined(separator: "\n")
    }

    static func convertToList(_ input: String) -> String {
        let lines = input.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        var listItems: [String] = []
        for (i, line) in lines.enumerated() {
            let cleaned = line.replacingOccurrences(of: "^[•\\-*0-9.]+\\s*", with: "", options: .regularExpression)
            listItems.append("\(i + 1). \(cleaned)")
        }
        return listItems.isEmpty ? input : listItems.joined(separator: "\n")
    }

    static func convertToTable(_ input: String) -> String {
        let lines = input.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard !lines.isEmpty else { return input }

        // Check if comma or colon separated
        var table = "| Item | Details |\n| :--- | :--- |\n"
        for line in lines {
            if line.contains(":") {
                let parts = line.split(separator: ":", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
                table += "| \(parts[0]) | \(parts.count > 1 ? parts[1] : "") |\n"
            } else if line.contains(",") {
                let parts = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                table += "| \(parts[0]) | \(parts.dropFirst().joined(separator: ", ")) |\n"
            } else {
                table += "| \(line) | - |\n"
            }
        }
        return table
    }

    private static func capitalizeSentences(_ text: String) -> String {
        var result = ""
        var capitalizeNext = true
        for char in text {
            if capitalizeNext && char.isLetter {
                result.append(char.uppercased())
                capitalizeNext = false
            } else {
                result.append(char)
                if char == "." || char == "!" || char == "?" || char == "\n" {
                    capitalizeNext = true
                }
            }
        }
        return result
    }
}
