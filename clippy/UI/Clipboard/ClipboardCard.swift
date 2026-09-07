import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - SwiftUI view rendering a single clipboard item card

struct ClipboardCard: View {
    let item: ClipboardItem
    /// Highlights this card as the keyboard-navigation target — set by the
    /// shelf's arrow-key handling in `ShelfView`.
    var isSelected: Bool = false
    /// Whether this card is part of a multi-item selection for merging
    var isMultiSelected: Bool = false
    /// Whether multi-selection mode is currently active (e.g. 1+ items selected)
    var isMultiSelectActive: Bool = false
    /// Called when the user activates this card, either by tapping it or
    /// via keyboard Enter — the caller is responsible for writing the item
    /// to the pasteboard (see `ClipboardStore.activate`).
    var onActivate: ((ClipboardItem) -> Void)?
    /// Called when the user toggles selection of this card for multi-item actions.
    var onToggleSelect: ((ClipboardItem) -> Void)?
    /// Called when the user shift-clicks this card for range selection.
    var onRangeSelect: ((ClipboardItem) -> Void)?
    /// Called when the user starts dragging this card — updates clipboard and history.
    var onDragStarted: ((ClipboardItem) -> Void)?
    /// Called when the user toggles the favorite status of this card.
    var onToggleFavorite: ((ClipboardItem) -> Void)?
    /// Called when the user requests Apple Writing Tools for this card.
    var onOpenWritingTools: ((ClipboardItem) -> Void)?
    /// Called when the user requests immediate deletion/purging of this card.
    var onDelete: ((ClipboardItem) -> Void)?

    @State private var isRevealed: Bool = false
    @State private var revealedContent: String?
    @State private var isMenuTracking: Bool = false
    @ObservedObject private var devPrefs = DeveloperPreferences.shared
    @ObservedObject private var privacyPrefs = PrivacyPreferences.shared
    @State private var toastMessage: String?
    @State private var isHovered: Bool = false

    static let size = CGSize(width: 200, height: 135)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            cardContent
                .frame(width: Self.size.width, height: Self.size.height)
                .clipped()

            bottomMetadataOverlay
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .background(cardBackground)
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture {
            let flags = NSEvent.modifierFlags
            if flags.contains(.command) {
                onToggleSelect?(item)
            } else if flags.contains(.shift) {
                onRangeSelect?(item)
            } else if isMultiSelectActive {
                onToggleSelect?(item)
            } else {
                onActivate?(item)
            }
        }
        .onDrag {
            onDragStarted?(item)
            return item.makeItemProvider()
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    isMultiSelected ? Color.blue.opacity(0.85) : (isSelected ? Color.white : Color.white.opacity(0.08)),
                    lineWidth: (isMultiSelected || isSelected) ? 2 : 1
                )
                .allowsHitTesting(false)
        )
        .overlay(alignment: .topLeading) {
            // Multi-selection checkmark indicator
            if isMultiSelected || isMultiSelectActive || isHovered {
                Button {
                    onToggleSelect?(item)
                } label: {
                    Image(systemName: isMultiSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isMultiSelected ? Color.white : Color.white.opacity(0.75))
                        .background(
                            Circle().fill(isMultiSelected ? Color.blue : Color.black.opacity(0.55))
                        )
                }
                .buttonStyle(.plain)
                .padding(7)
                .help(isMultiSelected ? "Deselect item" : "Select item for merge (⌘-click)")
                .transition(.opacity.combined(with: .scale))
            }
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 5) {
                // Queue Button (add/remove from sequential paste queue)
                if isHovered || PasteQueueManager.shared.isActive {
                    let isQueued = PasteQueueManager.shared.queue.contains(where: { $0.id == item.id })
                    Button {
                        if isQueued {
                            if let idx = PasteQueueManager.shared.queue.firstIndex(where: { $0.id == item.id }) {
                                PasteQueueManager.shared.remove(at: idx)
                                showCopiedToast("Removed from Queue")
                            }
                        } else {
                            PasteQueueManager.shared.enqueue(item)
                            showCopiedToast("Added to Queue")
                        }
                    } label: {
                        Image(systemName: isQueued ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(isQueued ? Color.white : Color(white: 0.8))
                            .padding(5)
                            .background(
                                Circle().fill(isQueued ? Color.white.opacity(0.25) : Color.black.opacity(0.65))
                            )
                    }
                    .buttonStyle(.plain)
                    .help(isQueued ? "Remove from Queue" : "Add to Sequential Paste Queue")
                }

                // Favorite Star Button (interactive tap to mark/unmark as favorite)
                if item.isFavorite || isHovered {
                    Button {
                        onToggleFavorite?(item)
                        showCopiedToast(item.isFavorite ? "Removed from Favorites" : "Marked as Favorite")
                    } label: {
                        Image(systemName: item.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white)
                            .padding(5)
                            .background(
                                Circle().fill(item.isFavorite ? Color.white.opacity(0.25) : Color.black.opacity(0.65))
                            )
                    }
                    .buttonStyle(.plain)
                    .help(item.isFavorite ? "Remove from Favorites" : "Mark as Favorite")
                }
            }
            .padding(8)
        }
        .overlay {
            if let toastMessage {
                Text(toastMessage)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.85), in: Capsule())
                    .padding(4)
                    .allowsHitTesting(false)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSMenu.didBeginTrackingNotification)) { _ in
            isMenuTracking = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSMenu.didEndTrackingNotification)) { _ in
            isMenuTracking = false
        }
        .onHover { hovering in
            if !isMenuTracking {
                isHovered = hovering
            }
        }
        .contextMenu {
            let isQueued = PasteQueueManager.shared.queue.contains(where: { $0.id == item.id })
            Button {
                if isQueued {
                    if let idx = PasteQueueManager.shared.queue.firstIndex(where: { $0.id == item.id }) {
                        PasteQueueManager.shared.remove(at: idx)
                        showCopiedToast("Removed from Queue")
                    }
                } else {
                    PasteQueueManager.shared.enqueue(item)
                    showCopiedToast("Added to Queue")
                }
            } label: {
                Label(isQueued ? "Remove from Queue" : "Add to Sequential Queue", systemImage: isQueued ? "minus.circle" : "plus.circle")
            }

            Button {
                onToggleFavorite?(item)
                showCopiedToast(item.isFavorite ? "Removed from Favorites" : "Marked as Favorite")
            } label: {
                Label(item.isFavorite ? "Remove from Favorites" : "Mark as Favorite", systemImage: item.isFavorite ? "star.slash" : "star.fill")
            }

            if item.type == .text || item.type == .code || item.type == .url || item.type == .richText {
                Button {
                    onOpenWritingTools?(item)
                } label: {
                    Label("Gemini Writing Tools...", systemImage: "sparkles")
                }
            }

            if item.type == .image, let ocrText = item.extractedText, !ocrText.isEmpty {
                Button {
                    ClipboardWriter.writeText(ocrText)
                    showCopiedToast("Copied Text")
                } label: {
                    Label("Copy Extracted Text (OCR)", systemImage: "text.viewfinder")
                }
            }

            if let color = detectedColor {
                Menu {
                    colorMenuItems(for: color)
                } label: {
                    Label("Color Formats", systemImage: "paintpalette")
                }
            }

            if isSensitiveOrMasked {
                Button {
                    toggleReveal()
                } label: {
                    Label(isRevealed ? "Hide Secret" : "Reveal Secret", systemImage: isRevealed ? "eye.slash" : "eye")
                }
            }

            Divider()

            if isConnectionString, let text = resolvedItemText {
                connectionStringMenuItems(for: text)
            } else if isJSON, let text = resolvedItemText {
                jsonMenuItems(for: text)
            }

            Divider()

            Button(role: .destructive) {
                onDelete?(item)
            } label: {
                Label(item.isSensitive || item.scheduledPurgeAt != nil ? "Purge Secret Immediately" : "Delete Item", systemImage: "trash")
            }
        }
    }

    // MARK: - Card Background

    private var cardBackground: some View {
        Group {
            switch item.type {
            case .color:
                (detectedColor?.swiftUIColor ?? Color(cssColorString: item.preview ?? "") ?? Color(white: 0.14))
            case .image:
                Color.black
            default:
                Color(white: 0.13)
            }
        }
    }

    private var isSensitiveOrMasked: Bool {
        (item.isSensitive || item.isEncrypted) && (privacyPrefs.autoMaskSensitive || item.isEncrypted)
    }

    // MARK: - Card Content

    @ViewBuilder
    private var cardContent: some View {
        if isSensitiveOrMasked {
            maskedSensitivePreview
        } else {
            switch item.type {
            case .image:
                imagePreview
            case .color:
                colorPreview
            case .file:
                filePreview
            case .text, .richText, .url, .code:
                textPreview
            }
        }
    }

    private var maskedSensitivePreview: some View {
        VStack(spacing: 6) {
            if isRevealed, let content = revealedContent {
                Text(content)
                    .font(item.type == .code ? .system(.caption, design: .monospaced) : .system(size: 12))
                    .foregroundStyle(.white)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(12)
            } else {
                VStack(spacing: 6) {
                    Image(systemName: item.isEncrypted ? "lock.shield.fill" : "lock.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.white.opacity(0.7))

                    Text("••••••••••••")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .tracking(3)
                        .foregroundStyle(Color.white.opacity(0.85))

                    Text(item.isEncrypted ? "Encrypted Secret" : "Sensitive Secret")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 6)
            }

            Button {
                toggleReveal()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                    Text(isRevealed ? "Hide" : "Reveal")
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.85))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.white.opacity(0.15)))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 36)
        }
        .padding(6)
    }

    private func toggleReveal() {
        if isRevealed {
            isRevealed = false
            revealedContent = nil
        } else {
            if let text = AssetStore.readText(for: item) {
                revealedContent = text
                isRevealed = true
            } else if let rtfData = AssetStore.readRichText(for: item),
                      let plain = (try? NSAttributedString(data: rtfData, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil))?.string {
                revealedContent = plain
                isRevealed = true
            } else if let preview = item.preview, preview != "••••••••" {
                revealedContent = preview
                isRevealed = true
            }
        }
    }

    private var textPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.preview ?? "")
                .font(item.type == .code ? .system(.caption, design: .monospaced) : .system(size: 13, weight: .regular))
                .lineSpacing(3)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 36)
        }
    }

    @ViewBuilder
    private var imagePreview: some View {
        CachedThumbnailView(item: item, targetSize: Self.size)
    }

    private var colorPreview: some View {
        Color.clear
    }

    private var filePreview: some View {
        VStack(spacing: 6) {
            Image(systemName: "doc.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color(white: 0.7))
            Text(item.preview ?? "File")
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 12)
        .padding(.bottom, 34)
    }

    private func placeholder(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 28))
            .foregroundStyle(Color(white: 0.5))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom Metadata Overlay

    private var bottomMetadataOverlay: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Color code header (from screenshot) or image domain title
            if item.type == .color {
                Text(detectedColor?.hexString ?? item.preview?.uppercased() ?? "COLOR")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.55), radius: 2, y: 1)
                    .lineLimit(1)
            } else if item.type == .image, let domain = domainOrTitle {
                Text(domain)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, y: 1)
                    .lineLimit(1)
            }

            // Bottom bar: App icon, relative time, and optional indicators
            HStack(spacing: 6) {
                sourceIcon

                Text(item.lastUsedAt.shelfRelativeDescription)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(isDarkContentCard ? Color(white: 0.6) : Color.white.opacity(0.9))
                    .shadow(color: (item.type == .color || item.type == .image) ? .black.opacity(0.55) : .clear, radius: 1, y: 1)

                Spacer(minLength: 4)

                if let purgeAt = item.scheduledPurgeAt {
                    TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                        let remaining = max(0, Int(ceil(purgeAt.timeIntervalSince(timeline.date))))
                        HStack(spacing: 3) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 8, weight: .bold))
                            Text("\(remaining)s")
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white.opacity(0.18)))
                        .help("Auto-purges in \(remaining)s")
                    }
                } else if item.isEncrypted {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(isDarkContentCard ? Color(white: 0.6) : Color.white.opacity(0.9))
                }

                if item.type == .image && item.extractedText != nil {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.85))
                }

                if let color = detectedColor, item.type != .color {
                    ColorSwatchView(color: color, size: CGSize(width: 12, height: 12), cornerRadius: 3)
                }

                if let sizeString = formattedFileSize, (item.type == .image || item.type == .file) {
                    Text(sizeString)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(isDarkContentCard ? Color(white: 0.6) : Color.white.opacity(0.9))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .padding(.top, (item.type == .image || item.type == .color) ? 26 : 0)
        .background(
            (item.type == .image || item.type == .color)
                ? AnyView(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.32), Color.black.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                : AnyView(Color.clear)
        )
    }

    private var isDarkContentCard: Bool {
        item.type != .image && item.type != .color
    }

    private var domainOrTitle: String? {
        guard let text = item.preview else { return nil }
        if text.hasPrefix("http://") || text.hasPrefix("https://") {
            if let url = URL(string: text), let host = url.host {
                return host.replacingOccurrences(of: "www.", with: "")
            }
        }
        if text.contains(".") && !text.contains(" ") && text.count < 30 {
            return text
        }
        return nil
    }

    private var formattedFileSize: String? {
        guard let size = item.fileSize, size > 0 else { return nil }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    @ViewBuilder
    private var sourceIcon: some View {
        if let path = item.sourceApp?.cachedIconPath, let nsImage = ImageCache.shared.icon(at: path) {
            Image(nsImage: nsImage)
                .resizable()
                .frame(width: 18, height: 18)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            Image(systemName: "app.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(white: 0.6))
                .frame(width: 18, height: 18)
        }
    }

    // MARK: - Developer Mode Contextual Actions

    private var resolvedItemText: String? {
        if item.isEncrypted || item.preview == "••••••••" {
            return AssetStore.readText(for: item)
        }
        return item.preview ?? AssetStore.readText(for: item)
    }

    private var isConnectionString: Bool {
        guard devPrefs.isDeveloperModeEnabled, let text = resolvedItemText else { return false }
        return ConnectionStringTransformations.isConnectionString(text)
    }

    private var isJSON: Bool {
        guard devPrefs.isDeveloperModeEnabled, let text = resolvedItemText else { return false }
        return JSONTransformations.isJSON(text)
    }

    // MARK: - Color Inspector & Palette Actions

    private var detectedColor: ParsedColor? {
        if item.type == .color {
            return ColorTransformations.parse(item.preview ?? "") ?? (resolvedItemText.flatMap { ColorTransformations.parse($0) })
        }
        if let text = resolvedItemText {
            return ColorDetector.extractFirstColor(from: text)
        }
        return nil
    }

    @ViewBuilder
    private func colorMenuItems(for color: ParsedColor) -> some View {
        Button {
            ClipboardWriter.writeText(color.hexString)
            showCopiedToast("Copied Hex")
        } label: {
            Label("Hex: \(color.hexString)", systemImage: "number")
        }

        Button {
            ClipboardWriter.writeText(color.cssRGB)
            showCopiedToast("Copied CSS RGB")
        } label: {
            Label("CSS RGB: \(color.cssRGB)", systemImage: "circle.grid.3x3.fill")
        }

        Button {
            ClipboardWriter.writeText(color.cssHSL)
            showCopiedToast("Copied CSS HSL")
        } label: {
            Label("CSS HSL: \(color.cssHSL)", systemImage: "circle.lefthalf.filled")
        }

        Button {
            ClipboardWriter.writeText(color.swiftColor)
            showCopiedToast("Copied Swift Color")
        } label: {
            Label("Swift: \(color.swiftColor)", systemImage: "swift")
        }

        Button {
            ClipboardWriter.writeText(color.swiftNSColor)
            showCopiedToast("Copied NSColor")
        } label: {
            Label("NSColor: \(color.swiftNSColor)", systemImage: "apple.logo")
        }

        Button {
            ClipboardWriter.writeText(color.androidCompose)
            showCopiedToast("Copied Compose Color")
        } label: {
            Label("Android: \(color.androidCompose)", systemImage: "laptopcomputer.and.iphone")
        }
    }

    @ViewBuilder
    private func connectionStringMenuItems(for text: String) -> some View {
        Button {
            ClipboardWriter.writeText(text)
            showCopiedToast("Copied Raw")
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }

        Button {
            let parsed = ConnectionStringTransformations.formatParsedConnection(text)
            ClipboardWriter.writeText(parsed)
            showCopiedToast("Copied Parsed Connection")
        } label: {
            Label("Parse connection", systemImage: "text.alignleft")
        }

        Button {
            let masked = ConnectionStringTransformations.maskPassword(in: text)
            ClipboardWriter.writeText(masked)
            showCopiedToast("Copied Masked Password")
        } label: {
            Label("Mask password", systemImage: "eye.slash")
        }

        Button {
            let env = ConnectionStringTransformations.generateDotEnv(from: text)
            ClipboardWriter.writeText(env)
            showCopiedToast("Copied .env")
        } label: {
            Label("Generate .env", systemImage: "gearshape.2")
        }

        Button {
            let prisma = ConnectionStringTransformations.generatePrismaURL(from: text)
            ClipboardWriter.writeText(prisma)
            showCopiedToast("Copied Prisma URL")
        } label: {
            Label("Generate Prisma URL", systemImage: "triangle")
        }
    }

    @ViewBuilder
    private func jsonMenuItems(for text: String) -> some View {
        Button {
            if let formatted = JSONTransformations.formatJSON(text) {
                ClipboardWriter.writeText(formatted)
                showCopiedToast("Copied Formatted JSON")
            }
        } label: {
            Label("Format JSON", systemImage: "text.alignleft")
        }

        Button {
            if let minified = JSONTransformations.minifyJSON(text) {
                ClipboardWriter.writeText(minified)
                showCopiedToast("Copied Minified JSON")
            }
        } label: {
            Label("Minify", systemImage: "arrow.right.to.line.compact")
        }

        Button {
            let ts = JSONTransformations.convertToTypeScriptInterface(text)
            ClipboardWriter.writeText(ts)
            showCopiedToast("Copied TypeScript Interface")
        } label: {
            Label("Convert to TypeScript interface", systemImage: "curlybraces")
        }

        Button {
            let zod = JSONTransformations.convertToZodSchema(text)
            ClipboardWriter.writeText(zod)
            showCopiedToast("Copied Zod Schema")
        } label: {
            Label("Convert to Zod schema", systemImage: "checkmark.shield")
        }

        Button {
            let codeBlock = JSONTransformations.copyAsCodeBlock(text)
            ClipboardWriter.writeText(codeBlock)
            showCopiedToast("Copied Code Block")
        } label: {
            Label("Copy as code block", systemImage: "chevron.left.forwardslash.chevron.right")
        }
    }

    private func showCopiedToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}

extension Date {
    /// Compact relative time for the card footer: "just now", "35 min ago", "1 hr ago", "2 hr ago".
    var shelfRelativeDescription: String {
        let seconds = max(0, Date().timeIntervalSince(self))
        switch seconds {
        case ..<60: return "just now"
        case ..<3600: return "\(max(1, Int(seconds / 60))) min ago"
        case ..<86400:
            let hours = max(1, Int(seconds / 3600))
            return "\(hours) \(hours == 1 ? "hr" : "hrs") ago"
        default:
            let days = max(1, Int(seconds / 86400))
            return "\(days) \(days == 1 ? "day" : "days") ago"
        }
    }
}

extension Color {
    /// Parses a CSS or hex color string using `ColorTransformations`.
    init?(cssColorString raw: String) {
        guard let parsed = ColorTransformations.parse(raw) else { return nil }
        self = parsed.swiftUIColor
    }
}

// MARK: - Cached Thumbnail View

private struct CachedThumbnailView: View {
    let item: ClipboardItem
    let targetSize: CGSize

    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image = image ?? ImageCache.shared.image(for: item.id.uuidString) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: targetSize.width, height: targetSize.height)
                    .clipped()
            } else {
                ZStack {
                    Color.black
                    Image(systemName: "photo")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(white: 0.28))
                }
                .frame(width: targetSize.width, height: targetSize.height)
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: item.id) { _, _ in
            loadImage()
        }
    }

    private func loadImage() {
        if let cached = ImageCache.shared.image(for: item.id.uuidString) {
            self.image = cached
            return
        }
        Task.detached(priority: .userInitiated) {
            let loaded = await ImageCache.shared.loadThumbnail(for: item, maxDimension: max(targetSize.width, targetSize.height) * 2)
            if let loaded {
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.12)) {
                        self.image = loaded
                    }
                }
            }
        }
    }
}

// MARK: - Drag & Drop Item Provider Support

extension Notification.Name {
    static let shelfShouldCollapseAfterDrop = Notification.Name("clippy.shelfShouldCollapseAfterDrop")
}

extension ClipboardItem {
    /// Constructs an `NSItemProvider` representing this clipboard item for
    /// drag-and-drop operations into external apps (browser text inputs, textareas,
    /// WhatsApp, Telegram, Finder, Slack, Discord, code editors, etc.).
    func makeItemProvider() -> NSItemProvider {
        switch type {
        case .image:
            var fileURL: URL?
            if let path = storagePath ?? thumbnailPath, FileManager.default.fileExists(atPath: path) {
                fileURL = URL(fileURLWithPath: path)
            } else if let data = AssetStore.readImage(for: id, format: .png) {
                fileURL = try? AssetStore.writeImage(data, for: id, format: .png)
            }

            if let fileURL, let provider = NSItemProvider(contentsOf: fileURL) {
                return provider
            } else if let data = AssetStore.readImage(for: id, format: .png) {
                let provider = NSItemProvider()
                provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
                    completion(data, nil)
                    Self.scheduleDropCollapse()
                    return nil
                }
                return provider
            } else {
                return NSItemProvider()
            }

        case .file:
            if let path = storagePath, FileManager.default.fileExists(atPath: path) {
                let fileURL = URL(fileURLWithPath: path)
                if let provider = NSItemProvider(contentsOf: fileURL) {
                    return provider
                }
                return NSItemProvider(object: fileURL as NSURL)
            }
            return NSItemProvider()

        case .url:
            let text = AssetStore.readText(for: self) ?? preview ?? ""
            let provider = NSItemProvider()
            // Provide plain text representations so input/textarea fields fill with the URL string
            registerPlainText(text, on: provider)
            // Also provide NSURL so dropping onto browser tab bar, bookmarks, or Finder creates a link
            if let url = URL(string: text) {
                provider.registerObject(url as NSURL, visibility: .all)
            }
            return provider

        case .text, .code:
            let text = AssetStore.readText(for: self) ?? preview ?? ""
            let provider = NSItemProvider()
            registerPlainText(text, on: provider)
            return provider

        case .color:
            let hex = preview ?? ""
            let provider = NSItemProvider()
            registerPlainText(hex, on: provider)
            return provider

        case .richText:
            let provider = NSItemProvider()
            if let rtfData = AssetStore.readRichText(for: self) {
                provider.registerDataRepresentation(forTypeIdentifier: UTType.rtf.identifier, visibility: .all) { completion in
                    completion(rtfData, nil)
                    Self.scheduleDropCollapse()
                    return nil
                }
            }
            let plain = AssetStore.readText(for: self) ?? preview ?? ""
            registerPlainText(plain, on: provider)
            return provider
        }
    }

    private func registerPlainText(_ text: String, on provider: NSItemProvider) {
        provider.registerObject(text as NSString, visibility: .all)
        guard let data = text.data(using: .utf8) else { return }

        let types = [
            UTType.utf8PlainText.identifier,
            UTType.plainText.identifier,
            UTType.text.identifier,
            "NSStringPboardType"
        ]

        for typeIdentifier in types {
            provider.registerDataRepresentation(forTypeIdentifier: typeIdentifier, visibility: .all) { completion in
                completion(data, nil)
                Self.scheduleDropCollapse()
                return nil
            }
        }
    }

    private static func scheduleDropCollapse() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            NotificationCenter.default.post(name: .shelfShouldCollapseAfterDrop, object: nil)
        }
    }
}

