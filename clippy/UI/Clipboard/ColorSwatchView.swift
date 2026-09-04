import SwiftUI

// MARK: - Color Swatch Component with Alpha Checkerboard & Contrast Border

public struct ColorSwatchView: View {
    public let color: ParsedColor
    public var size: CGSize
    public var cornerRadius: CGFloat

    public init(
        color: ParsedColor,
        size: CGSize = CGSize(width: 24, height: 24),
        cornerRadius: CGFloat = 6
    ) {
        self.color = color
        self.size = size
        self.cornerRadius = cornerRadius
    }

    public init(
        color: ParsedColor,
        dimension: CGFloat,
        cornerRadius: CGFloat = 6
    ) {
        self.color = color
        self.size = CGSize(width: dimension, height: dimension)
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        ZStack {
            if color.alpha < 0.999 {
                CheckerboardPattern()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }

            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color.swiftUIColor)

            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
        }
        .frame(width: size.width, height: size.height)
        .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
    }
}

private struct CheckerboardPattern: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 4
            let cols = Int(ceil(size.width / step))
            let rows = Int(ceil(size.height / step))
            for r in 0..<rows {
                for c in 0..<cols {
                    let isWhite = (r + c) % 2 == 0
                    let rect = CGRect(x: CGFloat(c) * step, y: CGFloat(r) * step, width: step, height: step)
                    context.fill(
                        Path(rect),
                        with: .color(isWhite ? Color(white: 0.8) : Color(white: 0.4))
                    )
                }
            }
        }
    }
}
