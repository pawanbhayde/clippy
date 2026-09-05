import Foundation

// MARK: - Instant Text Transformers ("Paste As...")

enum TextTransformations {
    // MARK: - 1. Clean Plain Text

    /// List of standard marketing, analytics, and social tracking query keys to strip from URLs.
    static let trackingParameters: Set<String> = [
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
        "utm_id", "utm_source_platform", "utm_creative_format", "utm_marketing_tactic",
        "fbclid", "gclid", "gclsrc", "dclid", "wbraid", "gbraid",
        "igshid", "mc_eid", "yclid", "_ga", "_gl", "msclkid",
        "si", "ref", "ref_src", "source"
    ]

    /// Strips HTML tags, decodes basic HTML entities, removes URL tracking parameters,
    /// and normalizes whitespace.
    static func cleanAll(_ text: String) -> String {
        let withoutHTML = stripHTMLTags(text)
        let withoutTracking = stripTrackingParameters(withoutHTML)
        return stripFormatting(withoutTracking)
    }

    /// Strips rich formatting, normalizes irregular whitespace, and trims leading/trailing whitespace.
    static func stripFormatting(_ text: String) -> String {
        var cleaned = text.replacingOccurrences(of: "\r\n", with: "\n")
        cleaned = cleaned.replacingOccurrences(of: "\r", with: "\n")
        // Collapse 3+ newlines into double newlines
        let regex = try? NSRegularExpression(pattern: "\n{3,}", options: [])
        let range = NSRange(location: 0, length: cleaned.utf16.count)
        cleaned = regex?.stringByReplacingMatches(in: cleaned, options: [], range: range, withTemplate: "\n\n") ?? cleaned
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Removes HTML and XML tags (e.g. `<p>`, `<b>`, `<div class="...">`) and decodes basic entities.
    static func stripHTMLTags(_ text: String) -> String {
        // Strip tags <...>
        var result = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        result = htmlEntitiesDecode(result)
        return result
    }

    /// Detects HTTP/HTTPS URLs within text and strips known tracking/analytics query parameters.
    static func stripTrackingParameters(_ text: String) -> String {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) ?? []

        guard !matches.isEmpty else { return text }

        var cleanedText = text
        // Process matches in reverse to preserve NSRange character indices
        for match in matches.reversed() {
            guard let range = Range(match.range, in: cleanedText) else { continue }
            let originalURLString = String(cleanedText[range])

            if var components = URLComponents(string: originalURLString) {
                if let queryItems = components.queryItems, !queryItems.isEmpty {
                    let filtered = queryItems.filter { !trackingParameters.contains($0.name.lowercased()) }
                    components.queryItems = filtered.isEmpty ? nil : filtered
                    if let newURLString = components.string {
                        cleanedText.replaceSubrange(range, with: newURLString)
                    }
                }
            }
        }

        return cleanedText
    }

    // MARK: - 2. Case Conversions

    /// Splits an input string into lowercase word tokens, handling camelCase transitions,
    /// uppercase acronyms (e.g., `HTTPServer`), and common delimiters (`_`, `-`, `.`, spaces).
    static func tokenizeWords(_ text: String) -> [String] {
        var str = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !str.isEmpty else { return [] }

        // Step 1: Insert space between lowercase/number and uppercase letter (e.g., "helloWorld" -> "hello World")
        let camelRegex = try? NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: [])
        let range1 = NSRange(location: 0, length: str.utf16.count)
        str = camelRegex?.stringByReplacingMatches(in: str, options: [], range: range1, withTemplate: "$1 $2") ?? str

        // Step 2: Insert space between acronym and capitalized word (e.g., "HTTPServer" -> "HTTP Server")
        let acronymRegex = try? NSRegularExpression(pattern: "([A-Z]+)([A-Z][a-z])", options: [])
        let range2 = NSRange(location: 0, length: str.utf16.count)
        str = acronymRegex?.stringByReplacingMatches(in: str, options: [], range: range2, withTemplate: "$1 $2") ?? str

        // Step 3: Replace non-alphanumeric characters with spaces
        let separatorRegex = try? NSRegularExpression(pattern: "[^a-zA-Z0-9]+", options: [])
        let range3 = NSRange(location: 0, length: str.utf16.count)
        str = separatorRegex?.stringByReplacingMatches(in: str, options: [], range: range3, withTemplate: " ") ?? str

        // Step 4: Split by whitespace and lowercase
        return str
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
    }

    /// Converts text to camelCase (e.g., `helloWorldExample`).
    static func toCamelCase(_ text: String) -> String {
        let words = tokenizeWords(text)
        guard let first = words.first else { return "" }
        let rest = words.dropFirst().map { $0.capitalized }
        return ([first] + rest).joined()
    }

    /// Converts text to snake_case (e.g., `hello_world_example`).
    static func toSnakeCase(_ text: String) -> String {
        let words = tokenizeWords(text)
        return words.joined(separator: "_")
    }

    /// Converts text to kebab-case (e.g., `hello-world-example`).
    static func toKebabCase(_ text: String) -> String {
        let words = tokenizeWords(text)
        return words.joined(separator: "-")
    }

    /// Converts text to PascalCase (e.g., `HelloWorldExample`).
    static func toPascalCase(_ text: String) -> String {
        let words = tokenizeWords(text)
        return words.map { $0.capitalized }.joined()
    }

    /// Converts text to CONSTANT_CASE (e.g., `HELLO_WORLD_EXAMPLE`).
    static func toConstantCase(_ text: String) -> String {
        let words = tokenizeWords(text)
        return words.map { $0.uppercased() }.joined(separator: "_")
    }

    /// Converts text to Title Case (e.g., `Hello World Example`).
    static func toTitleCase(_ text: String) -> String {
        let words = tokenizeWords(text)
        return words.map { $0.capitalized }.joined(separator: " ")
    }

    // MARK: - 3. Developer Encodings

    /// Encodes UTF-8 text into a Base64 string.
    static func base64Encode(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return "" }
        return data.base64EncodedString()
    }

    /// Decodes a Base64 string into UTF-8 text. Returns nil if invalid Base64.
    static func base64Decode(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data(base64Encoded: trimmed) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// URL encodes text with percent-encoding (`urlQueryAllowed`).
    static func urlEncode(_ text: String) -> String {
        return text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
    }

    /// Decodes percent-encoded URL text.
    static func urlDecode(_ text: String) -> String? {
        return text.removingPercentEncoding
    }

    /// Encodes special characters into HTML entities (`&`, `<`, `>`, `"`, `'`).
    static func htmlEntitiesEncode(_ text: String) -> String {
        var res = text
        res = res.replacingOccurrences(of: "&", with: "&amp;")
        res = res.replacingOccurrences(of: "<", with: "&lt;")
        res = res.replacingOccurrences(of: ">", with: "&gt;")
        res = res.replacingOccurrences(of: "\"", with: "&quot;")
        res = res.replacingOccurrences(of: "'", with: "&#39;")
        return res
    }

    /// Decodes standard HTML entities back into characters.
    static func htmlEntitiesDecode(_ text: String) -> String {
        var res = text
        res = res.replacingOccurrences(of: "&amp;", with: "&")
        res = res.replacingOccurrences(of: "&lt;", with: "<")
        res = res.replacingOccurrences(of: "&gt;", with: ">")
        res = res.replacingOccurrences(of: "&quot;", with: "\"")
        res = res.replacingOccurrences(of: "&#39;", with: "'")
        res = res.replacingOccurrences(of: "&apos;", with: "'")
        res = res.replacingOccurrences(of: "&nbsp;", with: " ")
        return res
    }

    // MARK: - 4. String Escaping

    /// Escapes string for Swift string literals (`\"`, `\\`, `\n`, `\t`).
    static func escapeForSwift(_ text: String) -> String {
        var res = text
        res = res.replacingOccurrences(of: "\\", with: "\\\\")
        res = res.replacingOccurrences(of: "\"", with: "\\\"")
        res = res.replacingOccurrences(of: "\n", with: "\\n")
        res = res.replacingOccurrences(of: "\r", with: "\\r")
        res = res.replacingOccurrences(of: "\t", with: "\\t")
        return res
    }

    /// Escapes string for JavaScript string literals (`\'`, `\"`, `\\`, `\n`, `` ` ``).
    static func escapeForJavaScript(_ text: String) -> String {
        var res = text
        res = res.replacingOccurrences(of: "\\", with: "\\\\")
        res = res.replacingOccurrences(of: "\"", with: "\\\"")
        res = res.replacingOccurrences(of: "'", with: "\\'")
        res = res.replacingOccurrences(of: "`", with: "\\`")
        res = res.replacingOccurrences(of: "\n", with: "\\n")
        res = res.replacingOccurrences(of: "\r", with: "\\r")
        res = res.replacingOccurrences(of: "\t", with: "\\t")
        return res
    }

    /// Escapes string for Python string literals (`\"`, `\'`, `\\`, `\n`).
    static func escapeForPython(_ text: String) -> String {
        var res = text
        res = res.replacingOccurrences(of: "\\", with: "\\\\")
        res = res.replacingOccurrences(of: "\"", with: "\\\"")
        res = res.replacingOccurrences(of: "'", with: "\\'")
        res = res.replacingOccurrences(of: "\n", with: "\\n")
        res = res.replacingOccurrences(of: "\r", with: "\\r")
        res = res.replacingOccurrences(of: "\t", with: "\\t")
        return res
    }

    /// Escapes string for standard JSON string representation.
    static func escapeForJSON(_ text: String) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: [text], options: []),
              let jsonString = String(data: data, encoding: .utf8) else {
            return escapeForSwift(text)
        }
        // jsonString is: `["escaped_content"]` -> trim `["` and `"]`
        if jsonString.hasPrefix("[\"") && jsonString.hasSuffix("\"]") {
            let start = jsonString.index(jsonString.startIndex, offsetBy: 2)
            let end = jsonString.index(jsonString.endIndex, offsetBy: -2)
            return String(jsonString[start..<end])
        }
        return escapeForSwift(text)
    }
}
