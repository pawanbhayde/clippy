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
            ScrollView {
                Text(AssetStore.readText(for: item) ?? item.preview ?? "")
                    .font(item.type == .code ? .system(.body, design: .monospaced) : .body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
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
            if let preview = item.preview, let color = Color(cssColorString: preview) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
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
