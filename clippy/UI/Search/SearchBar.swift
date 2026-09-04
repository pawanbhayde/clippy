import SwiftUI

// MARK: - SwiftUI search input field for filtering clipboard history

struct SearchBar: View {
    @Binding var text: String
    var isFavoritesActive: Bool = false
    var onToggleFavorites: (() -> Void)? = nil
    var onToggleGrid: (() -> Void)? = nil
    var onPinOrPopout: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(white: 0.45))

                TextField(
                    "",
                    text: $text,
                    prompt: Text("Search...").foregroundColor(Color(white: 0.45))
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
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right utility buttons
            HStack(spacing: 8) {
                // 1. Favorites toggle
                Button {
                    onToggleFavorites?()
                } label: {
                    Image(systemName: isFavoritesActive ? "star.fill" : "star")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isFavoritesActive ? Color.yellow : Color(white: 0.75))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(isFavoritesActive ? Color.yellow.opacity(0.25) : Color(white: 0.16))
                        )
                }
                .buttonStyle(.plain)
                .help("Filter Favorites")

                // 2. Grid / Collections toggle
                Button {
                    onToggleGrid?()
                } label: {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(white: 0.75))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(Color(white: 0.16))
                        )
                }
                .buttonStyle(.plain)
                .help("Collections Overview")

                // 3. Pop-out / Detach window
                Button {
                    onPinOrPopout?()
                } label: {
                    Image(systemName: "macwindow.on.rectangle")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(white: 0.75))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(Color(white: 0.16))
                        )
                }
                .buttonStyle(.plain)
                .help("Open Full Window")
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}
