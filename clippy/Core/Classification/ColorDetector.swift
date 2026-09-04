import Foundation

// MARK: - Detects and extracts color values from clipboard content

public enum ColorDetector {
    /// Returns true when the entire (trimmed) string represents a recognized color value.
    public static func isColor(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return ColorTransformations.parse(trimmed) != nil
    }

    /// Parses the entire string into a `ParsedColor` if it represents a valid color.
    public static func parseColor(_ text: String) -> ParsedColor? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return ColorTransformations.parse(trimmed)
    }

    /// Finds the first embedded or direct color in the given string.
    public static func extractFirstColor(from text: String) -> ParsedColor? {
        ColorTransformations.extractFirstColor(from: text)
    }
}

