import SwiftUI
import Combine

// MARK: - Temporary debug view listing the raw contents of metadata.json

/// Not part of the permanent UI (see UI/Shelf, UI/Clipboard, etc.) — this
/// exists only to eyeball metadata.json while validating that clipboard
/// content is captured, classified, hashed, and persisted correctly.
/// Delete once the real Shelf UI lands.
struct DebugMetadataView: View {
    @State private var items: [ClipboardItem] = []
    @State private var loadError: String?

    private let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            List {
                if let loadError {
                    Text("Error: \(loadError)")
                        .foregroundStyle(.red)
                }
                ForEach(items) { item in
                    row(for: item)
                }
            }
            .navigationTitle("metadata.json — \(items.count) items")
            .toolbar {
                ToolbarItem {
                    Button("Refresh", action: reload)
                }
            }
        }
        .frame(minWidth: 520, minHeight: 420)
        .onAppear(perform: reload)
        .onReceive(refreshTimer) { _ in reload() }
    }

    private func row(for item: ClipboardItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.type.rawValue.uppercased())
                    .font(.caption.bold())
                if item.isSensitive {
                    Text("SENSITIVE")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
                if item.isEncrypted {
                    Text("ENCRYPTED")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                Spacer()
                Text(item.sourceApp?.name ?? "Unknown app")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            DebugItemPreview(item: item)
            Text("hash \(item.contentHash.prefix(12))…  path: \(item.storagePath ?? "-")")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("created \(item.createdAt.formatted(date: .abbreviated, time: .standard))  ·  used \(item.lastUsedAt.formatted(date: .abbreviated, time: .standard))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func reload() {
        do {
            items = try MetadataStore.load().sorted { $0.createdAt > $1.createdAt }
            loadError = nil
        } catch {
            loadError = "\(error)"
        }
    }
}

private struct DebugItemPreview: View {
    let item: ClipboardItem
    @State private var isRevealed = false
    @State private var decryptedText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if item.isEncrypted {
                HStack {
                    Text(isRevealed ? (decryptedText ?? "(empty)") : (item.preview ?? "••••••••"))
                        .font(.body.monospaced())
                        .lineLimit(3)

                    Spacer()

                    Button(isRevealed ? "Hide" : "Decrypt") {
                        if isRevealed {
                            isRevealed = false
                            decryptedText = nil
                        } else {
                            decryptedText = AssetStore.readText(for: item)
                            isRevealed = true
                        }
                    }
                    .controlSize(.small)
                    .buttonStyle(.bordered)
                }
            } else {
                Text(item.preview ?? "(no preview)")
                    .font(.body.monospaced())
                    .lineLimit(3)
            }
        }
    }
}

#Preview {
    DebugMetadataView()
}
