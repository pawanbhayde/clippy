import Foundation
import SwiftUI
import AppKit

// MARK: - Parsed Color Model

public struct ParsedColor: Equatable, Hashable {
    public let red: Double     // 0.0 ... 1.0
    public let green: Double   // 0.0 ... 1.0
    public let blue: Double    // 0.0 ... 1.0
    public let alpha: Double   // 0.0 ... 1.0
    public let originalString: String

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0, originalString: String = "") {
        self.red = min(max(red, 0.0), 1.0)
        self.green = min(max(green, 0.0), 1.0)
        self.blue = min(max(blue, 0.0), 1.0)
        self.alpha = min(max(alpha, 0.0), 1.0)
        self.originalString = originalString
    }

    public var red255: Int { Int(round(red * 255.0)) }
    public var green255: Int { Int(round(green * 255.0)) }
    public var blue255: Int { Int(round(blue * 255.0)) }

    /// Standard uppercase hex code: `#RRGGBB` or `#RRGGBBAA`
    public var hexString: String {
        if alpha < 0.999 {
            let a255 = Int(round(alpha * 255.0))
            return String(format: "#%02X%02X%02X%02X", red255, green255, blue255, a255)
        } else {
            return String(format: "#%02X%02X%02X", red255, green255, blue255)
        }
    }

    /// Lowercase hex code
    public var hexStringLower: String {
        hexString.lowercased()
    }

    /// CSS rgb(...) or rgba(...)
    public var cssRGB: String {
        if alpha < 0.999 {
            let aFormatted = String(format: "%.2f", alpha).replacingOccurrences(of: "\\.?0+$", with: "", options: .regularExpression)
            return "rgba(\(red255), \(green255), \(blue255), \(aFormatted))"
        } else {
            return "rgb(\(red255), \(green255), \(blue255))"
        }
    }

    /// CSS hsl(...) or hsla(...)
    public var cssHSL: String {
        let (h, s, l) = hslComponents
        let hInt = Int(round(h))
        let sInt = Int(round(s * 100.0))
        let lInt = Int(round(l * 100.0))
        if alpha < 0.999 {
            let aFormatted = String(format: "%.2f", alpha).replacingOccurrences(of: "\\.?0+$", with: "", options: .regularExpression)
            return "hsla(\(hInt), \(sInt)%, \(lInt)%, \(aFormatted))"
        } else {
            return "hsl(\(hInt), \(sInt)%, \(lInt)%)"
        }
    }

    /// SwiftUI Color initializer
    public var swiftColor: String {
        let r = String(format: "%.3f", red)
        let g = String(format: "%.3f", green)
        let b = String(format: "%.3f", blue)
        if alpha < 0.999 {
            let a = String(format: "%.2f", alpha)
            return "Color(red: \(r), green: \(g), blue: \(b), opacity: \(a))"
        } else {
            return "Color(red: \(r), green: \(g), blue: \(b))"
        }
    }

    /// AppKit NSColor initializer
    public var swiftNSColor: String {
        let r = String(format: "%.3f", red)
        let g = String(format: "%.3f", green)
        let b = String(format: "%.3f", blue)
        let a = alpha < 0.999 ? String(format: "%.2f", alpha) : "1.0"
        return "NSColor(red: \(r), green: \(g), blue: \(b), alpha: \(a))"
    }

    /// Android Jetpack Compose Color(0xAARRGGBB)
    public var androidCompose: String {
        let a255 = Int(round(alpha * 255.0))
        let hexVal = String(format: "%02X%02X%02X%02X", a255, red255, green255, blue255)
        return "Color(0x\(hexVal))"
    }

    public var swiftUIColor: SwiftUI.Color {
        SwiftUI.Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    public var nsColor: NSColor {
        NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }

    /// Calculates HSL components (h: 0...360, s: 0...1, l: 0...1)
    public var hslComponents: (h: Double, s: Double, l: Double) {
        let maxC = max(red, green, blue)
        let minC = min(red, green, blue)
        let delta = maxC - minC
        let l = (maxC + minC) / 2.0
        var s = 0.0
        var h = 0.0

        if delta > 0.00001 {
            s = l > 0.5 ? delta / (2.0 - maxC - minC) : delta / (maxC + minC)
            if maxC == red {
                h = ((green - blue) / delta) + (green < blue ? 6.0 : 0.0)
            } else if maxC == green {
                h = ((blue - red) / delta) + 2.0
            } else {
                h = ((red - green) / delta) + 4.0
            }
            h *= 60.0
        }
        return (h, s, l)
    }
}

// MARK: - Color Format Enumeration

public enum ColorFormat: String, CaseIterable, Identifiable {
    case hex = "Hex"
    case cssRGB = "CSS RGB"
    case cssHSL = "CSS HSL"
    case swift = "Swift Color"
    case nsColor = "AppKit NSColor"
    case compose = "Android Compose"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .hex: return "number"
        case .cssRGB: return "circle.grid.3x3.fill"
        case .cssHSL: return "circle.lefthalf.filled"
        case .swift: return "swift"
        case .nsColor: return "apple.logo"
        case .compose: return "laptopcomputer.and.iphone"
        }
    }

    public func formattedValue(for color: ParsedColor) -> String {
        switch self {
        case .hex: return color.hexString
        case .cssRGB: return color.cssRGB
        case .cssHSL: return color.cssHSL
        case .swift: return color.swiftColor
        case .nsColor: return color.swiftNSColor
        case .compose: return color.androidCompose
        }
    }
}

// MARK: - Color Transformations & Parsing Engine

public enum ColorTransformations {

    // Regex matchers
    private static let hexRegex = try! NSRegularExpression(
        pattern: #"^#(?:[0-9A-Fa-f]{3,4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$"#
    )
    private static let rgbRegex = try! NSRegularExpression(
        pattern: #"^rgba?\(\s*([0-9.]+)(%?)\s*[, ]\s*([0-9.]+)(%?)\s*[, ]\s*([0-9.]+)(%?)(?:\s*[,/]\s*([0-9.]+)(%?))?\s*\)$"#,
        options: [.caseInsensitive]
    )
    private static let hslRegex = try! NSRegularExpression(
        pattern: #"^hsla?\(\s*([0-9.]+)(?:deg|turn|rad)?\s*[, ]\s*([0-9.]+)%\s*[, ]\s*([0-9.]+)%(?:\s*[,/]\s*([0-9.]+)(%?))?\s*\)$"#,
        options: [.caseInsensitive]
    )
    private static let hexLiteralRegex = try! NSRegularExpression(
        pattern: #"^(?:Color\()?(?:0x)([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})\)?$"#,
        options: [.caseInsensitive]
    )
    private static let swiftColorRegex = try! NSRegularExpression(
        pattern: #"^(?:NSColor|Color)\(\s*red:\s*([0-9.]+)\s*,\s*green:\s*([0-9.]+)\s*,\s*blue:\s*([0-9.]+)(?:\s*,\s*(?:alpha|opacity):\s*([0-9.]+))?\s*\)$"#,
        options: [.caseInsensitive]
    )

    // Embedded scanner regexes
    private static let embeddedHex = try! NSRegularExpression(
        pattern: #"#(?:[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8}|[0-9A-Fa-f]{3,4})\b"#
    )
    private static let embeddedRGB = try! NSRegularExpression(
        pattern: #"rgba?\(\s*[0-9.]+%?\s*[, ]\s*[0-9.]+%?\s*[, ]\s*[0-9.]+%?(?:\s*[,/]\s*[0-9.]+%?)?\s*\)"#,
        options: [.caseInsensitive]
    )
    private static let embeddedHSL = try! NSRegularExpression(
        pattern: #"hsla?\(\s*[0-9.]+(?:deg)?\s*[, ]\s*[0-9.]+%\s*[, ]\s*[0-9.]+%(?:\s*[,/]\s*[0-9.]+%?)?\s*\)"#,
        options: [.caseInsensitive]
    )
    private static let embeddedCompose = try! NSRegularExpression(
        pattern: #"Color\(0x[0-9A-Fa-f]{6,8}\)"#,
        options: [.caseInsensitive]
    )

    /// Parses a string into a `ParsedColor` if it represents a valid color.
    public static func parse(_ raw: String) -> ParsedColor? {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasSuffix(";") { text.removeLast() }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        // 1. Hex format (#RGB, #RGBA, #RRGGBB, #RRGGBBAA)
        if text.hasPrefix("#") && matches(text, hexRegex) {
            return parseHex(text)
        }

        // 2. RGB/RGBA function
        if text.lowercased().hasPrefix("rgb") && matches(text, rgbRegex) {
            return parseRGB(text)
        }

        // 3. HSL/HSLA function
        if text.lowercased().hasPrefix("hsl") && matches(text, hslRegex) {
            return parseHSL(text)
        }

        // 4. Hex literal: 0xFF6366F1 or Color(0xFF6366F1)
        if matches(text, hexLiteralRegex) {
            return parseHexLiteral(text)
        }

        // 5. Swift Color / NSColor initializer
        if matches(text, swiftColorRegex) {
            return parseSwiftColor(text)
        }

        return nil
    }

    /// Searches text for the first embedded color code (e.g. in code or CSS snippets)
    public static func extractFirstColor(from text: String) -> ParsedColor? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Check direct match first
        if let direct = parse(trimmed) {
            return direct
        }

        let nsString = trimmed as NSString
        let fullRange = NSRange(location: 0, length: nsString.length)

        // Try embedded Compose
        if let match = embeddedCompose.firstMatch(in: trimmed, options: [], range: fullRange) {
            let matchedStr = nsString.substring(with: match.range)
            if let parsed = parse(matchedStr) { return parsed }
        }

        // Try embedded Hex
        if let match = embeddedHex.firstMatch(in: trimmed, options: [], range: fullRange) {
            let matchedStr = nsString.substring(with: match.range)
            if let parsed = parse(matchedStr) { return parsed }
        }

        // Try embedded RGB
        if let match = embeddedRGB.firstMatch(in: trimmed, options: [], range: fullRange) {
            let matchedStr = nsString.substring(with: match.range)
            if let parsed = parse(matchedStr) { return parsed }
        }

        // Try embedded HSL
        if let match = embeddedHSL.firstMatch(in: trimmed, options: [], range: fullRange) {
            let matchedStr = nsString.substring(with: match.range)
            if let parsed = parse(matchedStr) { return parsed }
        }

        return nil
    }

    // MARK: - Format Parsers

    private static func parseHex(_ hex: String) -> ParsedColor? {
        var digits = Array(hex.dropFirst())
        switch digits.count {
        case 3, 4:
            digits = digits.flatMap { [$0, $0] }
        case 6, 8:
            break
        default:
            return nil
        }
        guard let value = UInt64(String(digits), radix: 16) else { return nil }

        let r, g, b, a: Double
        if digits.count == 8 {
            r = Double((value >> 24) & 0xFF) / 255.0
            g = Double((value >> 16) & 0xFF) / 255.0
            b = Double((value >> 8) & 0xFF) / 255.0
            a = Double(value & 0xFF) / 255.0
        } else {
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1.0
        }
        return ParsedColor(red: r, green: g, blue: b, alpha: a, originalString: hex)
    }

    private static func parseHexLiteral(_ text: String) -> ParsedColor? {
        let cleaned = text
            .replacingOccurrences(of: "Color(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: "0X", with: "")
            .trimmingCharacters(in: .whitespaces)

        guard let value = UInt64(cleaned, radix: 16) else { return nil }

        let r, g, b, a: Double
        if cleaned.count == 8 {
            // ARGB format standard in Compose / Android (0xAARRGGBB)
            a = Double((value >> 24) & 0xFF) / 255.0
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
        } else if cleaned.count == 6 {
            // RRGGBB
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1.0
        } else {
            return nil
        }
        return ParsedColor(red: r, green: g, blue: b, alpha: a, originalString: text)
    }

    private static func parseRGB(_ string: String) -> ParsedColor? {
        let nsString = string as NSString
        let range = NSRange(location: 0, length: nsString.length)
        guard let match = rgbRegex.firstMatch(in: string, options: [], range: range) else { return nil }

        func component(at index: Int, isPercentIndex: Int) -> Double? {
            guard match.range(at: index).location != NSNotFound else { return nil }
            let valStr = nsString.substring(with: match.range(at: index))
            guard let val = Double(valStr) else { return nil }
            let hasPercent = match.range(at: isPercentIndex).location != NSNotFound
            return hasPercent ? (val / 100.0) : (val / 255.0)
        }

        guard let r = component(at: 1, isPercentIndex: 2),
              let g = component(at: 3, isPercentIndex: 4),
              let b = component(at: 5, isPercentIndex: 6) else {
            return nil
        }

        var alpha = 1.0
        if match.range(at: 7).location != NSNotFound {
            let aStr = nsString.substring(with: match.range(at: 7))
            if let aVal = Double(aStr) {
                let hasPercent = match.range(at: 8).location != NSNotFound
                alpha = hasPercent ? (aVal / 100.0) : aVal
            }
        }

        return ParsedColor(red: r, green: g, blue: b, alpha: alpha, originalString: string)
    }

    private static func parseHSL(_ string: String) -> ParsedColor? {
        let nsString = string as NSString
        let range = NSRange(location: 0, length: nsString.length)
        guard let match = hslRegex.firstMatch(in: string, options: [], range: range) else { return nil }

        guard let hVal = Double(nsString.substring(with: match.range(at: 1))),
              let sVal = Double(nsString.substring(with: match.range(at: 2))),
              let lVal = Double(nsString.substring(with: match.range(at: 3))) else {
            return nil
        }

        var alpha = 1.0
        if match.range(at: 4).location != NSNotFound {
            let aStr = nsString.substring(with: match.range(at: 4))
            if let aVal = Double(aStr) {
                let hasPercent = match.range(at: 5).location != NSNotFound
                alpha = hasPercent ? (aVal / 100.0) : aVal
            }
        }

        let hNorm = (hVal.truncatingRemainder(dividingBy: 360.0) + 360.0).truncatingRemainder(dividingBy: 360.0) / 360.0
        let sNorm = min(max(sVal / 100.0, 0.0), 1.0)
        let lNorm = min(max(lVal / 100.0, 0.0), 1.0)

        let (r, g, b) = hslToRGB(h: hNorm, s: sNorm, l: lNorm)
        return ParsedColor(red: r, green: g, blue: b, alpha: alpha, originalString: string)
    }

    private static func parseSwiftColor(_ string: String) -> ParsedColor? {
        let nsString = string as NSString
        let range = NSRange(location: 0, length: nsString.length)
        guard let match = swiftColorRegex.firstMatch(in: string, options: [], range: range) else { return nil }

        guard let r = Double(nsString.substring(with: match.range(at: 1))),
              let g = Double(nsString.substring(with: match.range(at: 2))),
              let b = Double(nsString.substring(with: match.range(at: 3))) else {
            return nil
        }

        var alpha = 1.0
        if match.range(at: 4).location != NSNotFound, let a = Double(nsString.substring(with: match.range(at: 4))) {
            alpha = a
        }

        return ParsedColor(red: r, green: g, blue: b, alpha: alpha, originalString: string)
    }

    private static func hslToRGB(h: Double, s: Double, l: Double) -> (Double, Double, Double) {
        if s <= 0.00001 { return (l, l, l) }

        func hue2rgb(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var t = t
            if t < 0 { t += 1.0 }
            if t > 1 { t -= 1.0 }
            if t < 1.0 / 6.0 { return p + (q - p) * 6.0 * t }
            if t < 1.0 / 2.0 { return q }
            if t < 2.0 / 3.0 { return p + (q - p) * (2.0 / 3.0 - t) * 6.0 }
            return p
        }

        let q = l < 0.5 ? l * (1.0 + s) : l + s - l * s
        let p = 2.0 * l - q
        let r = hue2rgb(p, q, h + 1.0 / 3.0)
        let g = hue2rgb(p, q, h)
        let b = hue2rgb(p, q, h - 1.0 / 3.0)
        return (r, g, b)
    }

    private static func matches(_ text: String, _ regex: NSRegularExpression) -> Bool {
        let range = NSRange(location: 0, length: (text as NSString).length)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
}
