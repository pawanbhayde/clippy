import SwiftUI

// MARK: - Floating context bar for multi-item merge actions

struct MergerBar: View {
    let selectedCount: Int
    let onMergeBullet: (BulletStyle) -> Void
    let onJoinPreset: (JoinPreset, QuoteOption) -> Void
    let onCustomJoin: (String, QuoteOption) -> Void
    let onDiffCompare: () -> Void
    let onSelectAll: () -> Void
    let onClearSelection: () -> Void
    let onQuickCombine: () -> Void

    @State private var showingCustomPopover: Bool = false
    @State private var customDelimiter: String = " | "
    @State private var customQuoteOption: QuoteOption = .none

    var body: some View {
        HStack(spacing: 10) {
            // Selected Count Badge & Clear
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)

                Text("\(selectedCount) selected")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)

                Button {
                    onClearSelection()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.6))
                        .padding(3)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .help("Clear selection (Esc)")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white.opacity(0.1)))

            Divider()
                .frame(height: 16)
                .background(Color.white.opacity(0.2))

            // Merge Action 1: Bullet List
            Menu {
                ForEach(BulletStyle.allCases) { style in
                    Button {
                        onMergeBullet(style)
                    } label: {
                        Label(style.displayName, systemImage: style.iconName)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 11, weight: .medium))
                    Text("Bullet List")
                        .font(.system(size: 11, weight: .semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.14)))
            }
            .menuStyle(.borderlessButton)
            .help("Combine as bulleted, numbered, or task list")

            // Merge Action 2: Join with Delimiter
            Menu {
                Section("Common Delimiters") {
                    Button {
                        onJoinPreset(.comma, .none)
                    } label: {
                        Label("Comma (, )", systemImage: "character")
                    }

                    Button {
                        onJoinPreset(.newline, .none)
                    } label: {
                        Label("Newline (\\n)", systemImage: "return")
                    }

                    Button {
                        onJoinPreset(.doubleNewline, .none)
                    } label: {
                        Label("Paragraph (\\n\\n)", systemImage: "paragraphsign")
                    }

                    Button {
                        onJoinPreset(.pipe, .none)
                    } label: {
                        Label("Pipe ( | )", systemImage: "line.diagonal")
                    }
                }

                Section("Code & SQL Formats") {
                    Button {
                        onJoinPreset(.comma, .sqlIn)
                    } label: {
                        Label("SQL IN ('a', 'b', 'c')", systemImage: "cylinder.split.1x2")
                    }

                    Button {
                        onJoinPreset(.comma, .double)
                    } label: {
                        Label("Double Quotes (\"a\", \"b\")", systemImage: "quote.opening")
                    }

                    Button {
                        onJoinPreset(.comma, .single)
                    } label: {
                        Label("Single Quotes ('a', 'b')", systemImage: "quote.opening")
                    }
                }

                Divider()

                Button {
                    showingCustomPopover = true
                } label: {
                    Label("Custom Delimiter...", systemImage: "slider.horizontal.3")
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 11, weight: .medium))
                    Text("Join")
                        .font(.system(size: 11, weight: .semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.14)))
            }
            .menuStyle(.borderlessButton)
            .help("Join items with delimiter (comma, SQL IN, newline, etc.)")
            .popover(isPresented: $showingCustomPopover, arrowEdge: .top) {
                customDelimiterPopover
            }

            // Merge Action 3: Diff Comparison (only 2 items)
            if selectedCount == 2 {
                Button {
                    onDiffCompare()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left.and.right.text.vertical")
                            .font(.system(size: 11, weight: .medium))
                        Text("Diff Compare")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.75))
                            .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    )
                }
                .buttonStyle(.plain)
                .help("Compare side-by-side or inline diff between the 2 selected items")
            }

            Spacer()

            // Quick Combine Button (primary action)
            Button {
                onQuickCombine()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("Combine & Paste")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(Color.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.white))
            }
            .buttonStyle(.plain)
            .help("Combine items with newline and copy to clipboard")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color(white: 0.12))
                .shadow(color: Color.black.opacity(0.55), radius: 10, x: 0, y: 4)
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
    }

    // MARK: - Custom Delimiter Popover

    private var customDelimiterPopover: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Custom Delimiter")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                Text("Separator:")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.8))

                TextField("e.g. \" | \" or \" AND \"", text: $customDelimiter)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
                    .frame(width: 130)
            }

            HStack(spacing: 8) {
                Text("Quote:")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.8))

                Picker("", selection: $customQuoteOption) {
                    Text("None").tag(QuoteOption.none)
                    Text("Single '").tag(QuoteOption.single)
                    Text("Double \"").tag(QuoteOption.double)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }

            HStack {
                Button("Cancel") {
                    showingCustomPopover = false
                }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundStyle(Color.white.opacity(0.6))

                Spacer()

                Button("Join & Copy") {
                    showingCustomPopover = false
                    onCustomJoin(customDelimiter, customQuoteOption)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.white))
            }
        }
        .padding(12)
        .frame(width: 230)
        .background(Color(white: 0.15))
    }
}
