import Foundation

// MARK: - Detects whether clipboard content represents a color value

enum ColorDetector {
    private static let hexRegex = try! NSRegularExpression(
        pattern: #"^#(?:[0-9A-Fa-f]{3,4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$"#
    )
    private static let rgbRegex = try! NSRegularExpression(
        pattern: #"^rgba?\(\s*\d{1,3}%?\s*,\s*\d{1,3}%?\s*,\s*\d{1,3}%?\s*(?:,\s*[\d.]+\s*)?\)$"#,
        options: [.caseInsensitive]
    )
    private static let hslRegex = try! NSRegularExpression(
        pattern: #"^hsla?\(\s*\d{1,3}\s*,\s*\d{1,3}%\s*,\s*\d{1,3}%\s*(?:,\s*[\d.]+\s*)?\)$"#,
        options: [.caseInsensitive]
    )

    /// Returns true when the entire (trimmed) string is a hex color or an
    /// rgb()/rgba()/hsl()/hsla() function call.
    static func isColor(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        return matches(text, hexRegex) || matches(text, rgbRegex) || matches(text, hslRegex)
    }

    private static func matches(_ text: String, _ regex: NSRegularExpression) -> Bool {
        let range = NSRange(location: 0, length: (text as NSString).length)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
}
