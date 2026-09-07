import SwiftUI
import AppKit

// MARK: - Dynamic Island Notification Pill for Newly Copied Clipboard Items

struct CopyNotificationPill: View {
    let item: ClipboardItem
    var onTap: () -> Void

    @State private var isHovered: Bool = false
    @ObservedObject private var queueManager = PasteQueueManager.shared

    var body: some View {
        HStack(spacing: 8) {
            // Source app icon
            sourceIcon
                .frame(width: 20, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)

            // App name + Saved status and Preview text
            VStack(alignment: .leading, spacing: 1.5) {
                HStack(spacing: 5) {
                    Text(appName)
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .lineLimit(1)

                    Circle()
                        .fill(statusColor)
                        .frame(width: 4, height: 4)

                    Text(statusText)
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(statusColor)
                }

                Text(displayText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: 4)

            // Right accessory (paperclip / Clippy branding)
            Image(systemName: "paperclip")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isHovered ? Color.white.opacity(0.85) : Color.white.opacity(0.35))
                .padding(.trailing, 2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .frame(width: 320, height: 34)
        .background(
            Capsule()
                .fill(Color.black)
                .overlay(
                    Capsule().stroke(
                        isHovered ? Color.white.opacity(0.38) : Color.white.opacity(0.2),
                        lineWidth: 1
                    )
                )
                .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 4)
        )
        .contentShape(Capsule())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onTap()
        }
        .help("Copied to Clippy. Click to view history (⌘⇧V)")
    }

    private var appName: String {
        if let name = item.sourceApp?.name, !name.isEmpty {
            return name
        }
        return "Clipboard"
    }

    private var statusText: String {
        if queueManager.isActive {
            return "Queued #\(queueManager.queue.count)"
        }
        return "Saved"
    }

    private var statusColor: Color {
        if queueManager.isActive {
            return Color(red: 0.38, green: 0.72, blue: 1.0)
        }
        return Color(red: 0.35, green: 0.88, blue: 0.55)
    }

    private var displayText: String {
        if item.isSensitive || item.preview == "••••••••" {
            return "••••••••"
        }
        switch item.type {
        case .text, .code, .url, .richText:
            if let preview = item.preview?.trimmingCharacters(in: .whitespacesAndNewlines), !preview.isEmpty {
                return preview
                    .replacingOccurrences(of: "\n", with: " ")
                    .replacingOccurrences(of: "\t", with: " ")
            }
            return "Text copied"
        case .image:
            if let text = item.extractedText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                return "Image: " + text.replacingOccurrences(of: "\n", with: " ")
            }
            return "Image copied"
        case .color:
            return item.preview ?? "Color copied"
        case .file:
            return item.preview ?? "File copied"
        }
    }

    @ViewBuilder
    private var sourceIcon: some View {
        if let path = item.sourceApp?.cachedIconPath, let nsImage = ImageCache.shared.icon(at: path) {
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let bundleId = item.sourceApp?.bundleId, !bundleId.isEmpty,
                  let runningApp = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleId }),
                  let icon = runningApp.icon {
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let bundleId = item.sourceApp?.bundleId, !bundleId.isEmpty,
                  let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            let icon = NSWorkspace.shared.icon(forFile: appUrl.path)
            Image(nsImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.85))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.12))
        }
    }
}
