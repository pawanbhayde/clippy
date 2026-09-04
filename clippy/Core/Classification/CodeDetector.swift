import Foundation

// MARK: - Detects whether clipboard content is source code

enum CodeDetector {
    private static let sqlKeywords = [
        "SELECT ", "INSERT INTO", "UPDATE ", "DELETE FROM",
        "CREATE TABLE", "ALTER TABLE", "DROP TABLE", "WHERE "
    ]

    private static let codeSignals = [
        "function ", "=>", "const ", "let ", "var ", "import ", "export ",
        "def ", "class ", "public ", "private static", "return ",
        "#include", "package ", "func ", "fn ", "console.log", "SELECT "
    ]

    /// Heuristic check for JSON, SQL, or general source-code shape.
    static func isCode(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        return isJSON(text) || isSQL(text) || looksLikeCode(text)
    }

    private static func isJSON(_ text: String) -> Bool {
        guard let first = text.first, first == "{" || first == "[" else { return false }
        guard let data = text.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])) != nil
    }

    private static func isSQL(_ text: String) -> Bool {
        let upper = text.uppercased()
        return sqlKeywords.contains { upper.contains($0) }
    }

    /// Multi-line text with braces/semicolons plus at least one language
    /// keyword/operator reads as source code rather than prose.
    private static func looksLikeCode(_ text: String) -> Bool {
        let signalCount = codeSignals.reduce(0) { count, signal in
            text.contains(signal) ? count + 1 : count
        }
        guard signalCount > 0 else { return false }

        let isMultiline = text.contains(where: { $0.isNewline })
        let hasBraces = text.contains("{") && text.contains("}")
        let hasSemicolons = text.contains(";")

        return signalCount >= 2 || (isMultiline && (hasBraces || hasSemicolons))
    }
}
