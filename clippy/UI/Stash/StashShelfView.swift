import AppKit
import SwiftUI

// MARK: - Shelf view presenting items held in the temporary stash

struct StashShelfView: View {
    @ObservedObject var stashManager = StashManager.shared
    var onReturnToHistory: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Header: Stash status & actions
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "tray.full.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.white)

                    Text("Temporary Stash")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.white)

                    Text("\(stashManager.items.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white))

                    Text("• Drag items out to move")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color(white: 0.55))
                }

                Spacer()

                HStack(spacing: 8) {
                    if !stashManager.items.isEmpty {
                        Button {
                            for item in stashManager.items {
                                stashManager.saveItemToClippy(item)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 10, weight: .medium))
                                Text("Save All to Clippy")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundStyle(Color(white: 0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.white.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                        .help("Save all stashed items to Clippy clipboard history")

                        Button {
                            stashManager.copyAllToClipboard()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 10, weight: .medium))
                                Text("Copy All")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundStyle(Color(white: 0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.white.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                        .help("Copy all stashed files to clipboard")

                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                stashManager.clearAll()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                    .font(.system(size: 10, weight: .medium))
                                Text("Clear")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundStyle(Color(white: 0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.white.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                        .help("Clear all stashed items")
                    }

                    Button {
                        onReturnToHistory()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(white: 0.7))
                            .padding(6)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                    .help("Return to Clipboard History")
                }
            }
            .padding(.horizontal, 4)

            // Content: Empty Drop Zone or Scrollable Stashed Cards
            if stashManager.items.isEmpty {
                DropZoneView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 14) {
                        ForEach(stashManager.items) { item in
                            StashItemCard(item: item) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    stashManager.removeItem(id: item.id)
                                }
                            }
                            .id(item.id)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Card rendering a single stashed file/item

struct StashItemCard: View {
    let item: StashItem
    let onRemove: () -> Void

    @State private var isHovered: Bool = false
    static let size = CGSize(width: 200, height: 135)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Card background & preview
            cardContent
                .frame(width: Self.size.width, height: Self.size.height)
                .clipped()

            // Bottom metadata bar
            bottomMetadataOverlay
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .background(Color(white: 0.13))
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(isHovered ? Color.white.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            if isHovered {
                HStack(spacing: 4) {
                    Button {
                        StashManager.shared.saveItemToClippy(item)
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.white)
                            .padding(5)
                            .background(Circle().fill(Color.black.opacity(0.75)))
                    }
                    .buttonStyle(.plain)
                    .help("Save to Clippy History")

                    Button {
                        onRemove()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.white)
                            .padding(5)
                            .background(Circle().fill(Color.black.opacity(0.75)))
                    }
                    .buttonStyle(.plain)
                    .help("Remove from Stash")
                }
                .padding(8)
            }
        }
        .onHover { hovering in
            isHovered = hovering
        }
        .onDrag {
            return item.makeItemProvider {
                Task { @MainActor in
                    onRemove()
                }
            }
        }
        .contextMenu {
            if let url = item.url {
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                } label: {
                    Label("Reveal in Finder", systemImage: "folder")
                }

                Button {
                    NSWorkspace.shared.open(url)
                } label: {
                    Label("Open File", systemImage: "arrow.up.forward.app")
                }
            }

            Button {
                StashManager.shared.saveItemToClippy(item)
            } label: {
                Label("Save to Clippy History", systemImage: "square.and.arrow.down")
            }

            Divider()

            Button(role: .destructive) {
                onRemove()
            } label: {
                Label("Remove from Stash", systemImage: "trash")
            }
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        if item.isImage, let thumb = item.imageThumbnail {
            Image(nsImage: thumb)
                .resizable()
                .scaledToFill()
                .frame(width: Self.size.width, height: Self.size.height)
        } else {
            VStack(spacing: 8) {
                Image(nsImage: item.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)

                if let text = item.textContent {
                    Text(text)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 28)
        }
    }

    private var bottomMetadataOverlay: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .truncationMode(.middle)
                .shadow(color: item.isImage ? .black.opacity(0.8) : .clear, radius: 2, y: 1)

            HStack(spacing: 4) {
                if !item.fileExtension.isEmpty {
                    Text(item.fileExtension.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(RoundedRectangle(cornerRadius: 3).fill(Color.white))
                }

                if let size = item.sizeDescription {
                    Text(size)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .shadow(color: item.isImage ? .black.opacity(0.8) : .clear, radius: 1, y: 1)
                }

                Spacer()

                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .help("Drag out to move")
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .padding(.top, item.isImage ? 24 : 0)
        .background(
            item.isImage
                ? AnyView(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.35), Color.black.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                : AnyView(Color.clear)
        )
    }
}
