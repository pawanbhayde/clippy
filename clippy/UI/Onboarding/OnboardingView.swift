import SwiftUI
import Combine

// MARK: - First-run onboarding view explaining features and requesting permissions

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var isAccessibilityGranted: Bool = PermissionsManager.isAccessibilityGranted()
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            headerSection

            featuresSection

            permissionSection

            Spacer(minLength: 0)

            footerSection
        }
        .padding(32)
        .frame(width: 540, height: 560)
        .onReceive(timer) { _ in
            isAccessibilityGranted = PermissionsManager.isAccessibilityGranted()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.18))
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "paperclip")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Welcome to Clippy")
                .font(.title)
                .fontWeight(.bold)

            Text("Your lightweight clipboard shelf and productivity companion for macOS.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            featureRow(
                icon: "menubar.dock.rectangle",
                title: "Top-Edge Shelf & ⌘⇧V",
                subtitle: "Hover under the notch/menu bar or press ⌘⇧V to instantly reveal your clipboard shelf."
            )

            featureRow(
                icon: "lock.shield",
                title: "At-Rest CryptoKit Encryption",
                subtitle: "Sensitive credentials, passwords, and API keys are automatically encrypted using macOS Keychain."
            )

            featureRow(
                icon: "curlybraces",
                title: "Developer Mode",
                subtitle: "Contextual actions on connection strings and JSON: TypeScript interfaces, Zod schemas, and .env generation."
            )
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Permissions Card

    private var permissionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Accessibility & Mouse Tracking", systemImage: "hand.raised.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                if isAccessibilityGranted {
                    Label("Granted", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                } else {
                    Label("Action Required", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Color(white: 0.8))
                }
            }

            Text("Clippy uses low-level mouse tracking (CGEventTap) so the shelf slides down naturally when your cursor enters the top screen edge.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if !isAccessibilityGranted {
                HStack {
                    Button {
                        PermissionsManager.requestAccessibilityPermission()
                        PermissionsManager.openAccessibilitySettings()
                    } label: {
                        Label("Open System Settings", systemImage: "gear")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button("Open Input Monitoring") {
                        PermissionsManager.openInputMonitoringSettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 8) {
            Button {
                PermissionsManager.hasCompletedOnboarding = true
                onComplete()
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)

            Text("You can change settings and permissions at any time from the menu bar icon.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
