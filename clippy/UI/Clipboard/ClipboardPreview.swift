import SwiftUI
import AppKit

// MARK: - SwiftUI view showing an expanded preview of a clipboard item

struct ClipboardPreview: View {
    let item: ClipboardItem
    @State private var isRevealed: Bool = false
    @State private var decryptedContent: String?

    init(item: ClipboardItem) {
        self.item = item
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            Divider()

            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(16)
        .frame(minWidth: 320, minHeight: 200)
    }

    private var header: some View {
        HStack {
            Label(item.type.rawValue.capitalized, systemImage: iconName(for: item.type))
                .font(.headline)

            if item.isSensitive {
                Text("SENSITIVE")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(white: 0.22))
                    .clipShape(Capsule())
            }

            if item.isEncrypted {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                    Text("ENCRYPTED")
                }
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(white: 0.22))
                .clipShape(Capsule())
            }

            Spacer()

            if let appName = item.sourceApp?.name {
                Text(appName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if item.isEncrypted {
            encryptedView
        } else {
            standardContentView
        }
    }

    private var encryptedView: some View {
        VStack(spacing: 12) {
            if isRevealed, let content = decryptedContent {
                ScrollView {
                    Text(content)
                        .font(item.type == .code ? .system(.body, design: .monospaced) : .body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("This sensitive item is encrypted at rest.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Button {
                toggleReveal()
            } label: {
                Label(isRevealed ? "Hide Content" : "Reveal Content", systemImage: isRevealed ? "eye.slash" : "eye")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private var standardContentView: some View {
        switch item.type {
        case .text, .url, .code:
            let text = AssetStore.readText(for: item) ?? item.preview ?? ""
            let detectedColor = ColorDetector.extractFirstColor(from: text)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(text)
                        .font(item.type == .code ? .system(.body, design: .monospaced) : .body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)

                    if let detectedColor {
                        Divider()
                            .padding(.vertical, 4)
                        ColorInspectorView(color: detectedColor)
                    }
                }
            }
        case .richText:
            ScrollView {
                Text(AssetStore.readText(for: item) ?? item.preview ?? "")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        case .image:
            VStack(spacing: 12) {
                if let path = item.storagePath ?? item.thumbnailPath, let nsImage = NSImage(contentsOfFile: path) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Image unavailable")
                        .foregroundStyle(.secondary)
                }

                if let ocrText = item.extractedText, !ocrText.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label("Extracted Text (OCR)", systemImage: "text.viewfinder")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                ClipboardWriter.writeText(ocrText)
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                                    .font(.caption2)
                            }
                            .buttonStyle(.bordered)
                        }

                        Text(ocrText)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(Color(white: 0.8))
                            .lineLimit(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(Color(white: 0.15), in: RoundedRectangle(cornerRadius: 6))
                            .textSelection(.enabled)
                    }
                    .padding(.top, 4)
                }
            }
        case .file:
            VStack(spacing: 8) {
                Image(systemName: "doc")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                Text(item.preview ?? "File")
                    .font(.headline)
                if let path = item.storagePath {
                    Text(path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .color:
            let color = ColorDetector.parseColor(item.preview ?? "")
                ?? (AssetStore.readText(for: item).flatMap { ColorDetector.parseColor($0) })
                ?? ColorDetector.extractFirstColor(from: AssetStore.readText(for: item) ?? "")
            if let color {
                ScrollView {
                    ColorInspectorView(color: color)
                }
            } else if let preview = item.preview, let fallbackColor = Color(cssColorString: preview) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(fallbackColor)
                    .overlay {
                        Text(preview)
                            .font(.title2.monospaced())
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.4), in: Capsule())
                    }
            }
        }
    }

    private func toggleReveal() {
        if isRevealed {
            isRevealed = false
            decryptedContent = nil
        } else {
            if let text = AssetStore.readText(for: item) {
                decryptedContent = text
                isRevealed = true
            } else if let rtfData = AssetStore.readRichText(for: item),
                      let plain = (try? NSAttributedString(data: rtfData, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil))?.string {
                decryptedContent = plain
                isRevealed = true
            }
        }
    }

    private func iconName(for type: ClipboardType) -> String {
        switch type {
        case .text: return "doc.plaintext"
        case .richText: return "doc.richtext"
        case .image: return "photo"
        case .file: return "doc"
        case .url: return "link"
        case .color: return "paintpalette"
        case .code: return "chevron.left.forwardslash.chevron.right"
        }
    }
}

// MARK: - Color Inspector & Palette Converter View

private struct ColorInspectorView: View {
    let color: ParsedColor
    @State private var copiedFormat: ColorFormat?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with Large Swatch and Specs
            HStack(spacing: 14) {
                ColorSwatchView(color: color, size: CGSize(width: 50, height: 50), cornerRadius: 10)

                VStack(alignment: .leading, spacing: 3) {
                    Text(color.hexString)
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    Text(color.cssRGB)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color(white: 0.7))

                    Text(color.cssHSL)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color(white: 0.5))
                }

                Spacer()
            }
            .padding(12)
            .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 10))

            // Palette Converter Grid / List
            VStack(alignment: .leading, spacing: 8) {
                Text("CONVERT & COPY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(white: 0.5))

                ForEach(ColorFormat.allCases) { format in
                    let value = format.formattedValue(for: color)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(format.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color(white: 0.55))

                            Text(value)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .textSelection(.enabled)
                        }

                        Spacer()

                        Button {
                            ClipboardWriter.writeText(value)
                            copiedFormat = format
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                if copiedFormat == format {
                                    copiedFormat = nil
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: copiedFormat == format ? "checkmark" : "doc.on.doc")
                                Text(copiedFormat == format ? "Copied" : "Copy")
                            }
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(copiedFormat == format ? Color.black : Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(copiedFormat == format ? Color.white : Color(white: 0.22))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.14), in: RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }
}

