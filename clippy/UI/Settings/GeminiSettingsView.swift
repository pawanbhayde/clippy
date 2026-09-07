import SwiftUI

// MARK: - Gemini AI BYOK Settings View

struct GeminiSettingsView: View {
    @ObservedObject private var prefs = GeminiPreferences.shared

    @State private var isShowingKey: Bool = false
    @State private var isValidating: Bool = false
    @State private var validationResult: (isValid: Bool, message: String)?
    @State private var tempApiKey: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header Banner
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.blue.opacity(0.1)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Google Gemini AI (BYOK)")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("Use your personal Google AI Studio API key for one-click text rewrites and formatting.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 4)

                Divider()

                // Section 1: API Key
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Gemini API Key")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Spacer()

                        if prefs.isConfigured {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 7, height: 7)
                                Text("Key Configured")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.green.opacity(0.12)))
                        } else {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 7, height: 7)
                                Text("Missing Key")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.orange.opacity(0.12)))
                        }
                    }

                    HStack(spacing: 8) {
                        if isShowingKey {
                            TextField("Enter your Gemini API key (AIza...)", text: $prefs.apiKey)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 12, design: .monospaced))
                        } else {
                            SecureField("Enter your Gemini API key (AIza...)", text: $prefs.apiKey)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 12, design: .monospaced))
                        }

                        Button {
                            isShowingKey.toggle()
                        } label: {
                            Image(systemName: isShowingKey ? "eye.slash" : "eye")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help(isShowingKey ? "Hide API key" : "Show API key")

                        if let clip = NSPasteboard.general.string(forType: .string),
                           clip.starts(with: "AIza") || (clip.count > 20 && !clip.contains(" ")) {
                            Button("Paste") {
                                prefs.apiKey = clip.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }

                    // Key Actions: Test Connection & Get Free Key
                    HStack(spacing: 12) {
                        Button {
                            testConnection()
                        } label: {
                            HStack(spacing: 6) {
                                if isValidating {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "bolt.horizontal.fill")
                                        .font(.system(size: 11))
                                }
                                Text(isValidating ? "Validating..." : "Test Connection")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .disabled(prefs.apiKey.isEmpty || isValidating)

                        Button {
                            if let url = URL(string: "https://aistudio.google.com/app/apikey") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Get Free API Key")
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 9))
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Spacer()
                    }
                    .padding(.top, 2)

                    // Validation Result Feedback
                    if let result = validationResult {
                        HStack(spacing: 6) {
                            Image(systemName: result.isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(result.isValid ? .green : .red)
                                .font(.system(size: 12))

                            Text(result.message)
                                .font(.caption)
                                .foregroundColor(result.isValid ? .green : .red)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(result.isValid ? Color.green.opacity(0.08) : Color.red.opacity(0.08))
                        )
                        .transition(.opacity)
                    }

                    Text("Clippy uses standard Bring-Your-Own-Key (BYOK). Your key is stored locally on this Mac and never uploaded to any intermediary servers.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Section 2: Active Model Selection
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Active Gemini Model")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Spacer()

                        Text("Currently: \(prefs.activeModel.name)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

                    VStack(spacing: 8) {
                        ForEach(GeminiPreferences.availableModels) { model in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    prefs.selectedModel = model.id
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: prefs.selectedModel == model.id ? "largecircle.fill.circle" : "circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(prefs.selectedModel == model.id ? .blue : .secondary.opacity(0.6))

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text(model.name)
                                                .font(.system(size: 13, weight: prefs.selectedModel == model.id ? .bold : .medium))
                                                .foregroundColor(.primary)

                                            Text(model.badge)
                                                .font(.system(size: 9.5, weight: .semibold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 1.5)
                                                .background(
                                                    Capsule()
                                                        .fill(model.isRecommended ? Color.blue.opacity(0.18) : Color.secondary.opacity(0.12))
                                                )
                                                .foregroundColor(model.isRecommended ? .blue : .secondary)
                                        }

                                        Text(model.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(prefs.selectedModel == model.id ? Color.blue.opacity(0.08) : Color.secondary.opacity(0.04))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(prefs.selectedModel == model.id ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Divider()

                // Section 3: Generation Creativity / Temperature
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Temperature (Creativity)")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Spacer()

                        Text(String(format: "%.2f", prefs.temperature))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                    }

                    HStack(spacing: 12) {
                        Text("Precise (0.0)")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Slider(value: $prefs.temperature, in: 0.0...1.0, step: 0.05)

                        Text("Creative (1.0)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Text("A lower temperature (0.2–0.4) produces consistent, accurate rewrites and proofreading. Higher values allow more expressive stylistic variations.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(20)
        }
    }

    private func testConnection() {
        isValidating = true
        validationResult = nil

        Task {
            let result = await GeminiService.shared.validateApiKey(prefs.apiKey)
            await MainActor.run {
                isValidating = false
                withAnimation {
                    validationResult = result
                }
            }
        }
    }
}
