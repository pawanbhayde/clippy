import SwiftUI

// MARK: - Dedicated view for side-by-side or unified inline diff comparison

struct DiffComparisonView: View {
    let diffResult: DiffResult
    let onClose: () -> Void
    let onCopied: () -> Void

    enum DiffMode: String, CaseIterable, Identifiable {
        case unified = "Unified"
        case split = "Side-by-Side"

        var id: String { rawValue }
    }

    @State private var mode: DiffMode = .unified
    @State private var toastMessage: String?

    var body: some View {
        VStack(spacing: 8) {
            // Header Bar
            HStack(spacing: 12) {
                // Back Button
                Button {
                    onClose()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 10, weight: .bold))
                        Text("Back")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(.plain)

                // Title & Stats
                HStack(spacing: 6) {
                    Text("Diff Compare")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)

                    HStack(spacing: 4) {
                        Text("+\(diffResult.additionsCount)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.green)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.green.opacity(0.2), in: Capsule())

                        Text("-\(diffResult.deletionsCount)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.red)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.red.opacity(0.2), in: Capsule())
                    }
                }

                Spacer()

                // Mode Picker
                Picker("", selection: $mode) {
                    ForEach(DiffMode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 170)

                Spacer()

                // Copy Buttons
                HStack(spacing: 6) {
                    Button {
                        ClipboardWriter.writeText(diffResult.unifiedDiffString)
                        showToast("Copied Unified Diff")
                        onCopied()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 9, weight: .bold))
                            Text("Copy Diff")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white))
                    }
                    .buttonStyle(.plain)
                    .help("Copy unified patch format to clipboard")

                    Menu {
                        Button("Copy Left (Original)") {
                            let text = MergerEngine.resolveText(for: diffResult.oldItem)
                            ClipboardWriter.writeText(text)
                            showToast("Copied Left")
                            onCopied()
                        }
                        Button("Copy Right (Modified)") {
                            let text = MergerEngine.resolveText(for: diffResult.newItem)
                            ClipboardWriter.writeText(text)
                            showToast("Copied Right")
                            onCopied()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.85))
                            .padding(4)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            .padding(.horizontal, 4)

            // Diff Body
            ZStack {
                if mode == .unified {
                    unifiedView
                } else {
                    splitView
                }

                if let toast = toastMessage {
                    Text(toast)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.black.opacity(0.85)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Unified View

    private var unifiedView: some View {
        ScrollView([.vertical, .horizontal], showsIndicators: true) {
            LazyVStack(alignment: .leading, spacing: 1) {
                ForEach(diffResult.unifiedLines) { line in
                    HStack(spacing: 6) {
                        // Old line number
                        Text(line.oldLineNumber.map { "\($0)" } ?? "")
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.35))
                            .frame(width: 24, alignment: .trailing)

                        // New line number
                        Text(line.newLineNumber.map { "\($0)" } ?? "")
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.35))
                            .frame(width: 24, alignment: .trailing)

                        // Sign marker
                        Text(line.type == .added ? "+" : (line.type == .deleted ? "-" : " "))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(line.type == .added ? Color.green : (line.type == .deleted ? Color.red : Color.white.opacity(0.4)))
                            .frame(width: 10, alignment: .center)

                        // Line text
                        Text(line.text.isEmpty ? " " : line.text)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundStyle(line.type == .added ? Color.green.opacity(0.95) : (line.type == .deleted ? Color.red.opacity(0.95) : Color.white.opacity(0.85)))
                            .lineLimit(1)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(
                        line.type == .added ? Color.green.opacity(0.12) :
                        (line.type == .deleted ? Color.red.opacity(0.12) : Color.clear)
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Side-by-Side (Split) View

    private var splitView: some View {
        HStack(spacing: 0) {
            // Left column (Old / Original)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Original (\(diffResult.oldItem.sourceApp?.name ?? "Item 1"))")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.5))
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.04))

                Divider().background(Color.white.opacity(0.08))

                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(diffResult.leftLines) { line in
                            HStack(spacing: 6) {
                                Text(line.lineNumber.map { "\($0)" } ?? "")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(Color.white.opacity(0.3))
                                    .frame(width: 20, alignment: .trailing)

                                Text(line.type == .spacer ? "" : (line.text.isEmpty ? " " : line.text))
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(line.type == .deleted ? Color.red.opacity(0.95) : Color.white.opacity(0.8))
                                    .lineLimit(1)

                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(line.type == .deleted ? Color.red.opacity(0.15) : Color.clear)
                        }
                    }
                    .padding(.vertical, 3)
                }
            }

            Divider().background(Color.white.opacity(0.15))

            // Right column (New / Modified)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Modified (\(diffResult.newItem.sourceApp?.name ?? "Item 2"))")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.5))
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.04))

                Divider().background(Color.white.opacity(0.08))

                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(diffResult.rightLines) { line in
                            HStack(spacing: 6) {
                                Text(line.lineNumber.map { "\($0)" } ?? "")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(Color.white.opacity(0.3))
                                    .frame(width: 20, alignment: .trailing)

                                Text(line.type == .spacer ? "" : (line.text.isEmpty ? " " : line.text))
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(line.type == .added ? Color.green.opacity(0.95) : Color.white.opacity(0.8))
                                    .lineLimit(1)

                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(line.type == .added ? Color.green.opacity(0.15) : Color.clear)
                        }
                    }
                    .padding(.vertical, 3)
                }
            }
        }
    }

    private func showToast(_ msg: String) {
        withAnimation(.easeInOut(duration: 0.15)) {
            toastMessage = msg
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                toastMessage = nil
            }
        }
    }
}
