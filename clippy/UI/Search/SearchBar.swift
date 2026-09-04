import SwiftUI

// MARK: - SwiftUI search input field for filtering clipboard history

struct SearchBar: View {
    @Binding var text: String
    var isFavoritesActive: Bool = false
    var isQueueActive: Bool = false
    var queueCount: Int = 0
    var isStashActive: Bool = false
    var stashCount: Int = 0
    var onToggleFavorites: (() -> Void)? = nil
    var onToggleQueue: (() -> Void)? = nil
    var onToggleStash: (() -> Void)? = nil
    var onClearAll: (() -> Void)? = nil
    var onOpenSettings: (() -> Void)? = nil
    var onPinOrPopout: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 8) {
                Menu {
                    Section("App Filters") {
                        Button("app:xcode") { insertOperator("app:xcode ") }
                        Button("app:chrome") { insertOperator("app:chrome ") }
                        Button("app:slack") { insertOperator("app:slack ") }
                        Button("app:code (VS Code)") { insertOperator("app:code ") }
                        Button("app:safari") { insertOperator("app:safari ") }
                        Button("app:finder") { insertOperator("app:finder ") }
                    }

                    Section("Type Filters") {
                        Button("type:image") { insertOperator("type:image ") }
                        Button("type:text") { insertOperator("type:text ") }
                        Button("type:code") { insertOperator("type:code ") }
                        Button("type:color") { insertOperator("type:color ") }
                        Button("type:url") { insertOperator("type:url ") }
                        Button("type:file") { insertOperator("type:file ") }
                    }

                    Section("Attributes & Features") {
                        Button("is:favorite") { insertOperator("is:favorite ") }
                        Button("has:url") { insertOperator("has:url ") }
                        Button("has:color") { insertOperator("has:color ") }
                        Button("has:code") { insertOperator("has:code ") }
                        Button("has:text (OCR)") { insertOperator("has:text ") }
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(white: 0.55))
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .help("Search operators: app:, type:, is:, has:")

                TextField(
                    "",
                    text: $text,
                    prompt: Text("Search history or app:, type:, is:, has:...").foregroundColor(Color(white: 0.45))
                )
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
                .focusEffectDisabled()

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(white: 0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minWidth: 60, maxWidth: .infinity, alignment: .leading)

            // Right utility buttons
            HStack(spacing: 8) {
                // 1. Favorites toggle
                Button {
                    onToggleFavorites?()
                } label: {
                    Image(systemName: isFavoritesActive ? "star.fill" : "star")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isFavoritesActive ? Color.white : Color(white: 0.75))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(isFavoritesActive ? Color.white.opacity(0.25) : Color(white: 0.16))
                        )
                }
                .buttonStyle(.plain)
                .help("Filter Favorites")

                // 2. Queue Mode toggle
                Button {
                    onToggleQueue?()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "list.number")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(isQueueActive ? Color.white : Color(white: 0.75))
                            .frame(width: 30, height: 30)
                            .background(
                                Circle().fill(isQueueActive ? Color.white.opacity(0.25) : Color(white: 0.16))
                            )

                        if queueCount > 0 {
                            Text("\(queueCount)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Color.black)
                                .frame(width: 14, height: 14)
                                .background(Circle().fill(Color.white))
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help(isQueueActive ? "Queue Mode Active (\(queueCount) items) - Click to Stop" : "Start Sequential Queue Paste (⌘⌥V)")

                // 3. Notch Drop Zone / Stash toggle
                Button {
                    onToggleStash?()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: isStashActive ? "tray.full.fill" : "tray.and.arrow.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(isStashActive ? Color.white : Color(white: 0.75))
                            .frame(width: 30, height: 30)
                            .background(
                                Circle().fill(isStashActive ? Color.white.opacity(0.25) : Color(white: 0.16))
                            )

                        if stashCount > 0 {
                            Text("\(stashCount)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Color.black)
                                .frame(width: 14, height: 14)
                                .background(Circle().fill(Color.white))
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help(isStashActive ? "Return to Clipboard History" : (stashCount > 0 ? "Temporary Stash (\(stashCount) items)" : "Open Notch Drop Zone / Stash"))

                // 4. Clear All History
                Button {
                    onClearAll?()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(white: 0.75))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(Color(white: 0.16))
                        )
                }
                .buttonStyle(.plain)
                .help("Clear All Clipboard History")

                // 3. Settings button
                Button {
                    onOpenSettings?()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(white: 0.75))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(Color(white: 0.16))
                        )
                }
                .buttonStyle(.plain)
                .help("Clippy Settings")

                // 3. Close Clippy button
                Button {
                    onPinOrPopout?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(white: 0.75))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(Color(white: 0.16))
                        )
                }
                .buttonStyle(.plain)
                .help("Close Clippy")
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }

    private func insertOperator(_ op: String) {
        if text.isEmpty {
            text = op
        } else {
            text = text.trimmingCharacters(in: .whitespaces) + " " + op
        }
    }
}
