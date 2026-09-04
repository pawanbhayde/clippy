import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - SwiftUI view rendering a single clipboard item card

struct ClipboardCard: View {
    let item: ClipboardItem
    /// Highlights this card as the keyboard-navigation target — set by the
    /// shelf's arrow-key handling in `ShelfView`.
    var isSelected: Bool = false
    /// Called when the user activates this card, either by tapping it or
    /// via keyboard Enter — the caller is responsible for writing the item
    /// to the pasteboard (see `ClipboardStore.activate`).
    var onActivate: ((ClipboardItem) -> Void)?
    /// Called when the user toggles the favorite status of this card.
    var onToggleFavorite: ((ClipboardItem) -> Void)?

    @State private var isRevealed: Bool = false
    @State private var revealedContent: String?
    @ObservedObject private var devPrefs = DeveloperPreferences.shared
    @State private var toastMessage: String?
    @State private var isHovered: Bool = false

    static let size = CGSize(width: 175, height: 165)

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
            onActivate?(item)
        }
        .onDrag {
            item.makeItemProvider()
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(isSelected ? Color.white : Color.white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                .allowsHitTesting(false)
        )
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 5) {
                if devPrefs.isDeveloperModeEnabled, let text = resolvedItemText {
                    if isConnectionString {
                        Menu {
                            connectionStringMenuItems(for: text)
                        } label: {
                            Image(systemName: "cable.connector")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(Color.blue, in: Circle())
                        }
                        .menuStyle(.borderlessButton)
                        .frame(width: 22, height: 22)
                    } else if isJSON {
                        Menu {
                            jsonMenuItems(for: text)
                        } label: {
                            Image(systemName: "curlybraces")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(Color.green, in: Circle())
                        }
                        .menuStyle(.borderlessButton)
                        .frame(width: 22, height: 22)
                    }
                }

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
                            .foregroundStyle(isQueued ? Color.orange : Color.white)
                            .padding(5)
                            .background(
                                Circle().fill(Color.black.opacity(0.65))
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
                            .foregroundStyle(item.isFavorite ? Color.yellow : Color.white)
                            .padding(5)
                            .background(
                                Circle().fill(Color.black.opacity(0.65))
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
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button {
                onToggleFavorite?(item)
                showCopiedToast(item.isFavorite ? "Removed from Favorites" : "Marked as Favorite")
            } label: {
                Label(item.isFavorite ? "Remove from Favorites" : "Mark as Favorite", systemImage: item.isFavorite ? "star.slash" : "star.fill")
            }

            Divider()

            if isConnectionString, let text = resolvedItemText {
                connectionStringMenuItems(for: text)
            } else if isJSON, let text = resolvedItemText {
                jsonMenuItems(for: text)
            }
        }
    }

    // MARK: - Card Background

    private var cardBackground: some View {
        Group {
            switch item.type {
            case .color:
                (Color(cssColorString: item.preview ?? "") ?? Color(white: 0.14))
            case .image:
                Color.black
            default:
                Color(white: 0.13)
            }
        }
    }

    // MARK: - Card Content

    @ViewBuilder
    private var cardContent: some View {
        if item.isEncrypted {
            encryptedPreview
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

    private var encryptedPreview: some View {
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
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(white: 0.6))
                    Text("Encrypted")
                        .font(.caption)
                        .foregroundStyle(Color(white: 0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Button {
                toggleReveal()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                    Text(isRevealed ? "Hide" : "Reveal")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.white.opacity(0.15)))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 36)
        }
        .padding(8)
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
            }
        }
    }

    private var textPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.preview ?? "")
                .font(item.type == .code ? .system(.caption, design: .monospaced) : .system(size: 13, weight: .regular))
                .lineSpacing(3)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 38)
        }
    }

    @ViewBuilder
    private var imagePreview: some View {
        if let path = item.thumbnailPath ?? item.storagePath, let nsImage = NSImage(contentsOfFile: path) {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Self.size.width, height: Self.size.height)
                .clipped()
        } else {
            placeholder(systemImage: "photo")
        }
    }

    private var colorPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let preview = item.preview {
                Text(preview.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 2)
                    .padding(.horizontal, 12)
                    .padding(.top, 14)
            }
            Spacer()
        }
    }

    private var filePreview: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color(white: 0.7))
            Text(item.preview ?? "File")
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 12)
        .padding(.bottom, 36)
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
            // Optional domain or title overlay (seen on image cards in screenshot)
            if item.type == .image, let domain = domainOrTitle {
                Text(domain)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, y: 1)
                    .lineLimit(1)
            }

            // Bottom bar: App icon, relative time, and optional file size
            HStack(spacing: 6) {
                sourceIcon

                Text(item.lastUsedAt.shelfRelativeDescription)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(isDarkContentCard ? Color(white: 0.6) : Color.white.opacity(0.9))

                Spacer(minLength: 4)

                if item.isEncrypted {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(isDarkContentCard ? Color(white: 0.6) : Color.white.opacity(0.9))
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
        .padding(.top, (item.type == .image || item.type == .color) ? 20 : 0)
        .background(
            (item.type == .image || item.type == .color)
                ? AnyView(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.4), Color.black.opacity(0.88)],
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
        if let path = item.sourceApp?.cachedIconPath, let nsImage = NSImage(contentsOfFile: path) {
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
        if item.isEncrypted {
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
    /// Compact relative time for the card footer: "now", "23m ago",
    /// "2h ago", "3d ago".
    var shelfRelativeDescription: String {
        let seconds = max(0, Date().timeIntervalSince(self))
        switch seconds {
        case ..<60: return "now"
        case ..<3600: return "\(Int(seconds / 60))m ago"
        case ..<86400: return "\(Int(seconds / 3600))h ago"
        default: return "\(Int(seconds / 86400))d ago"
        }
    }
}

extension Color {
    /// Parses a hex (#rgb/#rgba/#rrggbb/#rrggbbaa), rgb()/rgba(), or
    /// hsl()/hsla() string as captured by `ColorDetector`.
    init?(cssColorString raw: String) {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#"), let color = Color.fromHex(value) {
            self = color
        } else if value.lowercased().hasPrefix("rgb"), let color = Color.fromRGBFunction(value) {
            self = color
        } else if value.lowercased().hasPrefix("hsl"), let color = Color.fromHSLFunction(value) {
            self = color
        } else {
            return nil
        }
    }

    private static func fromHex(_ hex: String) -> Color? {
        var digits = Array(hex.dropFirst())
        switch digits.count {
        case 3, 4:
            digits = digits.flatMap { [$0, $0] }
        case 6, 8:
            break
        default:
            return nil
        }
        guard let value = UInt64(String(digits), radix: 16) else { return nil }

        let hasAlpha = digits.count == 8
        let r, g, b, a: Double
        if hasAlpha {
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8) & 0xFF) / 255
            a = Double(value & 0xFF) / 255
        } else {
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = 1
        }
        return Color(red: r, green: g, blue: b, opacity: a)
    }

    private static func fromRGBFunction(_ string: String) -> Color? {
        let components = numericComponents(in: string)
        guard components.count >= 3 else { return nil }
        return Color(
            red: components[0] / 255,
            green: components[1] / 255,
            blue: components[2] / 255,
            opacity: components.count > 3 ? components[3] : 1
        )
    }

    private static func fromHSLFunction(_ string: String) -> Color? {
        let components = numericComponents(in: string)
        guard components.count >= 3 else { return nil }
        let (r, g, b) = hslToRGB(h: components[0] / 360, s: components[1] / 100, l: components[2] / 100)
        return Color(red: r, green: g, blue: b, opacity: components.count > 3 ? components[3] : 1)
    }

    private static func numericComponents(in string: String) -> [Double] {
        guard let open = string.firstIndex(of: "("), let close = string.firstIndex(of: ")") else { return [] }
        return string[string.index(after: open)..<close]
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "%", with: "")) }
    }

    private static func hslToRGB(h: Double, s: Double, l: Double) -> (Double, Double, Double) {
        guard s > 0 else { return (l, l, l) }

        func hueToRGB(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var t = t
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1 / 6 { return p + (q - p) * 6 * t }
            if t < 1 / 2 { return q }
            if t < 2 / 3 { return p + (q - p) * (2 / 3 - t) * 6 }
            return p
        }

        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        return (hueToRGB(p, q, h + 1 / 3), hueToRGB(p, q, h), hueToRGB(p, q, h - 1 / 3))
    }
}

// MARK: - Drag & Drop Item Provider Support

extension ClipboardItem {
    /// Constructs an `NSItemProvider` representing this clipboard item for
    /// drag-and-drop operations into external apps (WhatsApp, Telegram, Finder, Slack, Discord, etc.).
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
            if let url = URL(string: text) {
                return NSItemProvider(object: url as NSURL)
            }
            return NSItemProvider(object: text as NSString)

        case .text, .code:
            let text = (isEncrypted ? preview : AssetStore.readText(for: self)) ?? preview ?? ""
            return NSItemProvider(object: text as NSString)

        case .color:
            let hex = preview ?? ""
            return NSItemProvider(object: hex as NSString)

        case .richText:
            let provider = NSItemProvider()
            if let rtfData = AssetStore.readRichText(for: self) {
                provider.registerDataRepresentation(forTypeIdentifier: UTType.rtf.identifier, visibility: .all) { completion in
                    completion(rtfData, nil)
                    return nil
                }
            }
            let plain = (isEncrypted ? preview : AssetStore.readText(for: self)) ?? preview ?? ""
            provider.registerObject(plain as NSString, visibility: .all)
            return provider
        }
    }
}

