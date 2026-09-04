import AppKit
import Combine
import SwiftUI

// MARK: - Settings pane for privacy controls (excluded apps, sensitive data handling)

struct PrivacySettingsView: View {
    @ObservedObject private var privacyPrefs = PrivacyPreferences.shared
    @State private var manualBundleId: String = ""
    @State private var manualAppName: String = ""
    @State private var showingAddSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Privacy & Security")
                .font(.headline)

            // Sensitive data handling
            VStack(alignment: .leading, spacing: 12) {
                Text("Sensitive Content Handling")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Toggle("Block sensitive items entirely", isOn: $privacyPrefs.blockSensitiveItems)
                    .help("When enabled, items containing passwords, API keys, or verification codes will not be saved.")

                Text("Automatically detect and discard sensitive content before it is saved to history or disk.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)

                Toggle("Encrypt sensitive content at rest", isOn: $privacyPrefs.alwaysEncryptSensitive)
                    .disabled(privacyPrefs.blockSensitiveItems)
                    .help("Encrypt sensitive items on disk using CryptoKit AES-GCM and macOS Keychain.")

                Text("When not blocked, sensitive content is encrypted at rest using 256-bit AES-GCM with a key stored in your macOS Keychain. Content is only decrypted on demand when copied or revealed.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
            }

            Divider()

            // Excluded Applications
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Excluded Applications")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add App", systemImage: "plus")
                    }
                }

                Text("Clipboard changes made in excluded applications will be ignored.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if privacyPrefs.excludedApps.isEmpty {
                    VStack {
                        Spacer()
                        Text("No apps are excluded. All clipboard activity is monitored.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.1)))
                } else {
                    List {
                        ForEach(privacyPrefs.excludedApps) { app in
                            ExcludedAppRow(app: app) {
                                privacyPrefs.removeExcludedApp(bundleId: app.bundleId)
                            }
                        }
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                    .frame(minHeight: 120, maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Spacer()
        }
        .padding(20)
        .sheet(isPresented: $showingAddSheet) {
            AddExcludedAppSheet(isPresented: $showingAddSheet)
        }
    }
}

private struct ExcludedAppRow: View {
    let app: ExcludedApp
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            if let icon = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleId).flatMap({ NSWorkspace.shared.icon(forFile: $0.path) }) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "app.dashed")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.body)
                Text(app.bundleId)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}

private struct AddExcludedAppSheet: View {
    @Binding var isPresented: Bool
    @State private var runningApps: [ExcludedApp] = []
    @State private var manualName: String = ""
    @State private var manualBundleId: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Add Excluded Application")
                .font(.headline)

            Text("Select a currently running application:")
                .font(.subheadline)

            List(runningApps) { app in
                HStack {
                    if let icon = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleId).flatMap({ NSWorkspace.shared.icon(forFile: $0.path) }) {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    Text(app.name)
                    Spacer()
                    Text(app.bundleId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Exclude") {
                        PrivacyPreferences.shared.addExcludedApp(name: app.name, bundleId: app.bundleId)
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            Divider()

            Text("Or enter bundle identifier manually:")
                .font(.subheadline)

            HStack {
                TextField("App Name (e.g. 1Password)", text: $manualName)
                    .textFieldStyle(.roundedBorder)
                TextField("Bundle ID (e.g. com.1password.1password)", text: $manualBundleId)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    let id = manualBundleId.trimmingCharacters(in: .whitespacesAndNewlines)
                    let name = manualName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !id.isEmpty else { return }
                    PrivacyPreferences.shared.addExcludedApp(name: name.isEmpty ? id : name, bundleId: id)
                    isPresented = false
                }
                .disabled(manualBundleId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderedProminent)
            }

            HStack {
                Spacer()
                Button("Close") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding(20)
        .frame(width: 500, height: 420)
        .onAppear {
            let existingIds = Set(PrivacyPreferences.shared.excludedApps.map(\.bundleId))
            runningApps = NSWorkspace.shared.runningApplications
                .filter { $0.activationPolicy == .regular }
                .compactMap { app -> ExcludedApp? in
                    guard let id = app.bundleIdentifier, !id.isEmpty, !existingIds.contains(id) else { return nil }
                    return ExcludedApp(name: app.localizedName ?? id, bundleId: id)
                }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }
}
