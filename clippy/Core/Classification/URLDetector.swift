import Foundation

// MARK: - Detects whether clipboard content is a URL

enum URLDetector {
    /// Returns true when the entire (trimmed, single-line) string is a URL,
    /// as opposed to text that merely contains one somewhere inside it.
    static func isURL(_ text: String) -> Bool {
        guard !text.isEmpty, !text.contains(where: { $0.isNewline }) else { return false }
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }

        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let matches = detector.matches(in: text, options: [], range: range)

        guard matches.count == 1, let match = matches.first else { return false }
        return match.range.location == 0 && match.range.length == nsText.length
    }
}
