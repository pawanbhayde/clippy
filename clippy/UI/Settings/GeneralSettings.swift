import SwiftUI
import LaunchAtLogin
import KeyboardShortcuts

// MARK: - Settings pane for general app preferences (launch at login, shortcuts, etc.)

struct GeneralSettingsView: View {
    @ObservedObject private var devPrefs = DeveloperPreferences.shared
    @AppStorage("isDirectPasteEnabled") private var isDirectPasteEnabled = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("General Settings")
                    .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                Text("Startup")
                    .font(.subheadline)
                    .fontWeight(.medium)

                LaunchAtLogin.Toggle {
                    Text("Launch Clippy automatically at login")
                }
                .font(.body)

                Text("Keep Clippy running in the menu bar so your clipboard history is always captured.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Keyboard Shortcut")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack {
                    Text("Toggle Clipboard Shelf:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleShelf)
                }

                Text("Default is ⌘⇧V. Press this shortcut from any application to quickly toggle the clipboard shelf.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Developer Mode")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Toggle("Enable Developer Mode", isOn: $devPrefs.isDeveloperModeEnabled)
                    .font(.body)

                Text("Detects connection strings and JSON payloads, showing contextual actions (parse connection, mask password, generate .env, generate Prisma URL, format JSON, minify, convert to TypeScript interface, convert to Zod schema, copy as code block) directly on clipboard cards.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Direct Paste")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Toggle("Automatically paste on click", isOn: $isDirectPasteEnabled)
                    .font(.body)

                Text("When clicking a card in Clippy Island, automatically paste the item directly into the active application.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Clipboard History")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Manage your saved clipboard history, cached images, and file previews.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Button(role: .destructive) {
                        AppDelegate.shared?.clearAllHistory()
                    } label: {
                        Label("Clear All Clipboard History...", systemImage: "trash")
                    }

                    Spacer()
                }
            }

            Spacer()
        }
        .padding(20)
        }
    }
}
