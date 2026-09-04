import SwiftUI

// MARK: - Custom silhouette matching macOS Dynamic Island / notch shelf

/// Draws the pure black notch container shape with outward-flaring top
/// concave fillets, vertical side walls, and smooth rounded bottom corners.
struct NotchShelfShape: Shape {
    /// Width of the top outward ear flares.
    var flareWidth: CGFloat = 14
    /// Height of the flare transition from top edge down to the vertical walls.
    var flareHeight: CGFloat = 10
    /// Radius of the bottom corners.
    var bottomRadius: CGFloat = 24

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard rect.width > 0, rect.height > 0 else {
            return path
        }
        let w = rect.width
        let h = rect.height
        let fw = min(flareWidth, w * 0.12)
        let fh = min(flareHeight, h * 0.25)
        let r = min(bottomRadius, max(0, min((w - fw * 2) / 2, (h - fh) / 2)))

        // Fallback for very small or collapsed sizes (capsule indicator)
        guard w > fw * 2 + r * 2, h > fh + r else {
            return RoundedRectangle(cornerRadius: min(14, max(0, h / 2))).path(in: rect)
        }

        // Start at top-left origin (0, 0)
        path.move(to: CGPoint(x: 0, y: 0))

        // 1. Straight horizontal line across the top edge to top-right
        path.addLine(to: CGPoint(x: w, y: 0))

        // 2. Top-right concave flare: curves down-left from (w, 0) to (w - fw, fh)
        path.addCurve(
            to: CGPoint(x: w - fw, y: fh),
            control1: CGPoint(x: w - fw * 0.45, y: 0),
            control2: CGPoint(x: w - fw, y: fh * 0.45)
        )

        // 3. Right vertical wall down to start of bottom-right corner
        path.addLine(to: CGPoint(x: w - fw, y: h - r))

        // 4. Bottom-right convex rounded corner
        path.addArc(
            center: CGPoint(x: w - fw - r, y: h - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // 5. Horizontal bottom edge
        path.addLine(to: CGPoint(x: fw + r, y: h))

        // 6. Bottom-left convex rounded corner
        path.addArc(
            center: CGPoint(x: fw + r, y: h - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // 7. Left vertical wall up to end of top-left flare
        path.addLine(to: CGPoint(x: fw, y: fh))

        // 8. Top-left concave flare: curves up-left from (fw, fh) to (0, 0)
        path.addCurve(
            to: CGPoint(x: 0, y: 0),
            control1: CGPoint(x: fw, y: fh * 0.45),
            control2: CGPoint(x: fw * 0.45, y: 0)
        )

        path.closeSubpath()
        return path
    }
}
