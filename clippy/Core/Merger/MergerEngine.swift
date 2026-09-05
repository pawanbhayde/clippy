import Foundation

// MARK: - Core text merger engine for combining multiple clipboard items

enum BulletStyle: String, CaseIterable, Identifiable {
    case hyphen = "- "
    case asterisk = "* "
    case numbered = "1. "
    case task = "- [ ] "

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hyphen: return "Hyphen List (-)"
        case .asterisk: return "Asterisk List (*)"
        case .numbered: return "Numbered List (1, 2, 3)"
        case .task: return "Task Checklist (- [ ])"
        }
    }

    var iconName: String {
        switch self {
        case .hyphen: return "list.bullet"
        case .asterisk: return "asterisk"
        case .numbered: return "list.number"
        case .task: return "checklist"
        }
    }
}

enum QuoteOption: String, CaseIterable, Identifiable {
    case none = "None"
    case single = "Single Quotes ('...')"
    case double = "Double Quotes (\"...\")"
    case sqlIn = "SQL IN ('...')"

    var id: String { rawValue }
}

enum JoinPreset: String, CaseIterable, Identifiable {
    case comma = ", "
    case newline = "\n"
    case doubleNewline = "\n\n"
    case pipe = " | "
    case semicolon = "; "
    case space = " "

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .comma: return "Comma (, )"
        case .newline: return "Newline (\\n)"
        case .doubleNewline: return "Paragraph (\\n\\n)"
        case .pipe: return "Pipe ( | )"
        case .semicolon: return "Semicolon (; )"
        case .space: return "Space ( )"
        }
    }
}

enum MergerEngine {
    /// Extracts the full text content from a clipboard item, resolving from
    /// AssetStore (with decryption if needed), OCR text, preview, or file path.
    static func resolveText(for item: ClipboardItem) -> String {
        if let text = AssetStore.readText(for: item), !text.isEmpty {
            return text
        }
        if item.type == .image, let ocr = item.extractedText, !ocr.isEmpty {
            return ocr
        }
        if let preview = item.preview, !preview.isEmpty {
            return preview
        }
        if let path = item.storagePath, !path.isEmpty {
            let url = URL(fileURLWithPath: path)
            return url.lastPathComponent
        }
        return ""
    }

    /// Combines multiple items into a bullet or numbered list.
    static func mergeAsBulletList(
        items: [ClipboardItem],
        style: BulletStyle = .hyphen,
        trimWhitespace: Bool = true
    ) -> String {
        guard !items.isEmpty else { return "" }

        var lines: [String] = []
        for (index, item) in items.enumerated() {
            var text = resolveText(for: item)
            if trimWhitespace {
                text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard !text.isEmpty else { continue }

            let prefix: String
            if style == .numbered {
                prefix = "\(index + 1). "
            } else {
                prefix = style.rawValue
            }

            // Handle multi-line items by prefixing subsequent lines with indentation
            let itemLines = text.components(separatedBy: .newlines)
            if itemLines.count <= 1 {
                lines.append("\(prefix)\(text)")
            } else {
                let indent = String(repeating: " ", count: prefix.count)
                var formattedItem = "\(prefix)\(itemLines[0])"
                for subsequentLine in itemLines.dropFirst() {
                    formattedItem += "\n\(indent)\(subsequentLine)"
                }
                lines.append(formattedItem)
            }
        }

        return lines.joined(separator: "\n")
    }

    /// Combines multiple items using a custom delimiter and optional quoting.
    static func joinWithDelimiter(
        items: [ClipboardItem],
        delimiter: String = ", ",
        quote: QuoteOption = .none,
        trimWhitespace: Bool = true
    ) -> String {
        guard !items.isEmpty else { return "" }

        let formattedElements: [String] = items.compactMap { item in
            var text = resolveText(for: item)
            if trimWhitespace {
                text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard !text.isEmpty else { return nil }

            switch quote {
            case .none:
                return text
            case .single:
                let escaped = text.replacingOccurrences(of: "'", with: "\\'")
                return "'\(escaped)'"
            case .double:
                let escaped = text.replacingOccurrences(of: "\"", with: "\\\"")
                return "\"\(escaped)\""
            case .sqlIn:
                let escaped = text.replacingOccurrences(of: "'", with: "''")
                return "'\(escaped)'"
            }
        }

        guard !formattedElements.isEmpty else { return "" }

        if quote == .sqlIn {
            let joined = formattedElements.joined(separator: ", ")
            return "IN (\(joined))"
        }

        return formattedElements.joined(separator: delimiter)
    }
}
