import SwiftUI
import AppKit

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

    @State private var isRevealed: Bool = false
    @State private var revealedContent: String?
    @ObservedObject private var devPrefs = DeveloperPreferences.shared
    @State private var toastMessage: String?

    static let size = CGSize(width: 160, height: 140)
    private let footerHeight: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            preview
                .frame(width: Self.size.width, height: Self.size.height - footerHeight)
                .clipped()
            footer
                .frame(width: Self.size.width, height: footerHeight)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isSelected ? Color.accentColor : Color.white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
        )
        .overlay(alignment: .topTrailing) {
            if devPrefs.isDeveloperModeEnabled, let text = resolvedItemText {
                if isConnectionString {
                    Menu {
                        connectionStringMenuItems(for: text)
                    } label: {
                        Image(systemName: "cable.connector")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.blue, in: Circle())
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 20, height: 20)
                    .padding(5)
                } else if isJSON {
                    Menu {
                        jsonMenuItems(for: text)
                    } label: {
                        Image(systemName: "curlybraces")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.green, in: Circle())
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 20, height: 20)
                    .padding(5)
                }
            }
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
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            onActivate?(item)
        }
        .contextMenu {
            if isConnectionString, let text = resolvedItemText {
                connectionStringMenuItems(for: text)
            } else if isJSON, let text = resolvedItemText {
                jsonMenuItems(for: text)
            }
        }
    }

    // MARK: Preview area — varies by content type

    @ViewBuilder
    private var preview: some View {
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
        VStack(spacing: 4) {
            if isRevealed, let content = revealedContent {
                Text(content)
                    .font(item.type == .code ? .system(.caption, design: .monospaced) : .caption)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                    Text("Encrypted")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Button {
                toggleReveal()
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                    Text(isRevealed ? "Hide" : "Reveal")
                }
                .font(.system(size: 10, weight: .medium))
            }
            .buttonStyle(.borderless)
            .padding(.bottom, 2)
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
            }
        }
    }

    private var textPreview: some View {
        Text(item.preview ?? "")
            .font(item.type == .code ? .system(.caption, design: .monospaced) : .caption)
            .lineLimit(6)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(8)
    }

    @ViewBuilder
    private var imagePreview: some View {
        if let path = item.thumbnailPath ?? item.storagePath, let nsImage = NSImage(contentsOfFile: path) {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            placeholder(systemImage: "photo")
        }
    }

    private var colorPreview: some View {
        (Color(cssColorString: item.preview ?? "") ?? Color.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomLeading) {
                if let preview = item.preview {
                    Text(preview)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.35), in: Capsule())
                        .padding(6)
                }
            }
    }

    private var filePreview: some View {
        VStack(spacing: 6) {
            Image(systemName: "doc")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text(item.preview ?? "File")
                .font(.caption2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }

    private func placeholder(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 28))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Footer — source app icon + relative timestamp

    private var footer: some View {
        HStack(spacing: 6) {
            sourceIcon
            Text(item.sourceApp?.name ?? "Unknown")
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(.secondary)
            Spacer(minLength: 4)
            if item.isEncrypted {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            Text(item.lastUsedAt.shelfRelativeDescription)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    private var sourceIcon: some View {
        if let path = item.sourceApp?.cachedIconPath, let nsImage = NSImage(contentsOfFile: path) {
            Image(nsImage: nsImage)
                .resizable()
                .frame(width: 14, height: 14)
                .clipShape(RoundedRectangle(cornerRadius: 3))
        } else {
            Image(systemName: "app.dashed")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
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
