import Foundation

// MARK: - Executes search queries against indexed clipboard history with Search Operators & Fuzzy Matching

/// Owns a `SearchIndex` and answers queries against it.
/// Supports structured search operators:
/// - `app:<name>` (e.g. `app:xcode`, `app:slack`, `app:chrome`, `app:"visual studio code"`)
/// - `type:<type>` (e.g. `type:image`, `type:text`, `type:code`, `type:color`, `type:url`, `type:file`)
/// - `is:<flag>` (e.g. `is:favorite`, `is:sensitive`, `is:encrypted`, `is:image`, `is:code`)
/// - `has:<feature>` (e.g. `has:url`, `has:color`, `has:code`, `has:image`, `has:text`, `has:file`)
/// - Free text terms with subsequence fuzzy matching and relevance scoring.
final class SearchEngine {
    private var index = SearchIndex()

    /// Builds the index from the full clipboard history. Call once, at launch.
    func buildIndex(from items: [ClipboardItem]) {
        index.build(from: items)
    }

    /// Indexes a single new item incrementally, without rebuilding the rest.
    func indexNewItem(_ item: ClipboardItem) {
        index.add(item)
    }

    func removeFromIndex(id: UUID) {
        index.remove(id: id)
    }

    /// Filters and ranks `items` matching `query` via search operators and fuzzy text search.
    func search(_ query: String, in items: [ClipboardItem]) -> [ClipboardItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }

        let criteria = SearchCriteria.parse(trimmed)
        guard criteria.hasAnyFilter else { return items }

        var scoredItems: [(item: ClipboardItem, score: Int)] = []

        for item in items {
            let text = index.text(for: item.id) ?? (item.preview ?? "")
            let (isMatch, score) = Self.matches(item: item, criteria: criteria, text: text)
            if isMatch {
                scoredItems.append((item, score))
            }
        }

        // If free text was entered, rank by match score descending, breaking ties by lastUsedAt descending
        if !criteria.textTerms.isEmpty {
            scoredItems.sort { a, b in
                if a.score != b.score {
                    return a.score > b.score
                }
                return a.item.lastUsedAt > b.item.lastUsedAt
            }
        }
        // If only operators were entered (no free text), preserve date ordering (already sorted by lastUsedAt)

        return scoredItems.map(\.item)
    }

    // MARK: - Matching & Scoring

    static func matches(item: ClipboardItem, criteria: SearchCriteria, text: String) -> (isMatch: Bool, score: Int) {
        // 1. App Filter
        if !criteria.appFilters.isEmpty {
            let appMatched = criteria.appFilters.contains { filter in
                matchesApp(item: item, filter: filter)
            }
            if !appMatched { return (false, 0) }
        }

        // 2. Type Filter
        if !criteria.typeFilters.isEmpty {
            if !criteria.typeFilters.contains(item.type) {
                return (false, 0)
            }
        }

        // 3. isFavorite
        if let isFav = criteria.isFavorite {
            if item.isFavorite != isFav { return (false, 0) }
        }

        // 4. isSensitive
        if let isSens = criteria.isSensitive {
            if item.isSensitive != isSens { return (false, 0) }
        }

        // 5. isEncrypted
        if let isEnc = criteria.isEncrypted {
            if item.isEncrypted != isEnc { return (false, 0) }
        }

        // 6. hasURL
        if criteria.hasURL {
            if !hasURLMatch(in: item) { return (false, 0) }
        }

        // 7. hasColor
        if criteria.hasColor {
            if !hasColorMatch(in: item) { return (false, 0) }
        }

        // 8. hasCode
        if criteria.hasCode {
            if !hasCodeMatch(in: item) { return (false, 0) }
        }

        // 9. hasImage
        if criteria.hasImage {
            if !hasImageMatch(in: item) { return (false, 0) }
        }

        // 10. hasExtractedText
        if criteria.hasExtractedText {
            if !hasExtractedTextMatch(in: item) { return (false, 0) }
        }

        // 11. hasFile
        if criteria.hasFile {
            if !hasFileMatch(in: item) { return (false, 0) }
        }

        // 12. Free text & Fuzzy Match
        if criteria.textTerms.isEmpty {
            return (true, 100)
        }

        return scoreFuzzyMatch(text: text, criteria: criteria)
    }

    private static func matchesApp(item: ClipboardItem, filter: String) -> Bool {
        let lowerFilter = filter.lowercased()
        guard let sourceApp = item.sourceApp else { return false }
        let name = sourceApp.name.lowercased()
        let bundleId = sourceApp.bundleId.lowercased()

        if name.contains(lowerFilter) || bundleId.contains(lowerFilter) {
            return true
        }

        switch lowerFilter {
        case "xcode":
            return name.contains("xcode") || bundleId.contains("xcode")
        case "chrome":
            return name.contains("chrome") || bundleId.contains("chrome")
        case "slack":
            return name.contains("slack") || bundleId.contains("slack")
        case "vscode", "code":
            return name.contains("code") || bundleId.contains("vscode")
        case "safari":
            return name.contains("safari") || bundleId.contains("safari")
        case "finder":
            return name.contains("finder") || bundleId.contains("finder")
        case "terminal":
            return name.contains("terminal") || name.contains("iterm") || bundleId.contains("terminal") || bundleId.contains("iterm")
        default:
            return false
        }
    }

    private static func hasURLMatch(in item: ClipboardItem) -> Bool {
        if item.type == .url { return true }
        guard let preview = item.preview else { return false }
        if URLDetector.isURL(preview) { return true }
        if preview.contains("http://") || preview.contains("https://") || preview.contains("www.") {
            return true
        }
        return false
    }

    private static func hasColorMatch(in item: ClipboardItem) -> Bool {
        if item.type == .color { return true }
        guard let preview = item.preview else { return false }
        if ColorDetector.isColor(preview) { return true }
        if ColorDetector.extractFirstColor(from: preview) != nil { return true }
        return containsHexColor(preview)
    }

    private static func containsHexColor(_ text: String) -> Bool {
        guard text.contains("#") else { return false }
        let pattern = "#([0-9a-fA-F]{3,8})\\b"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private static func hasCodeMatch(in item: ClipboardItem) -> Bool {
        if item.type == .code { return true }
        guard let preview = item.preview else { return false }
        return CodeDetector.isCode(preview)
    }

    private static func hasImageMatch(in item: ClipboardItem) -> Bool {
        if item.type == .image { return true }
        if item.thumbnailPath != nil { return true }
        if let path = item.storagePath {
            let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
            return ["png", "jpg", "jpeg", "gif", "webp", "heic", "tiff"].contains(ext)
        }
        return false
    }

    private static func hasFileMatch(in item: ClipboardItem) -> Bool {
        if item.type == .file { return true }
        return item.fileSize != nil
    }

    private static func hasExtractedTextMatch(in item: ClipboardItem) -> Bool {
        guard let text = item.extractedText else { return false }
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Fuzzy & Substring Scoring

    private static func scoreFuzzyMatch(text: String, criteria: SearchCriteria) -> (Bool, Int) {
        let lowerText = text.lowercased()
        let rawQuery = criteria.rawTextQuery.lowercased()

        // 1. Exact full query substring match
        if lowerText.contains(rawQuery) {
            var score = 1000
            if lowerText.hasPrefix(rawQuery) { score += 500 }
            if lowerText.contains(" " + rawQuery) { score += 300 }
            score += max(0, 200 - lowerText.count)
            return (true, score)
        }

        // 2. All individual terms present
        var allTermsFound = true
        var termsScore = 600
        for term in criteria.textTerms {
            let lowerTerm = term.lowercased()
            if let range = lowerText.range(of: lowerTerm) {
                termsScore += 100
                if range.lowerBound == lowerText.startIndex || lowerText[lowerText.index(before: range.lowerBound)].isWhitespace {
                    termsScore += 50
                }
            } else {
                allTermsFound = false
                break
            }
        }
        if allTermsFound {
            return (true, termsScore)
        }

        // 3. Subsequence fuzzy match (if query >= 2 chars)
        guard rawQuery.count >= 2 else { return (false, 0) }
        if let fuzzyScore = calculateSubsequenceScore(target: lowerText, query: rawQuery) {
            return (true, 200 + fuzzyScore)
        }

        return (false, 0)
    }

    private static func calculateSubsequenceScore(target: String, query: String) -> Int? {
        let targetChars = Array(target)
        let queryChars = Array(query)
        var targetIdx = 0
        var queryIdx = 0
        var score = 0
        var consecutiveMatches = 0

        while targetIdx < targetChars.count && queryIdx < queryChars.count {
            if targetChars[targetIdx] == queryChars[queryIdx] {
                queryIdx += 1
                consecutiveMatches += 1
                score += 10 + (consecutiveMatches * 5)

                // Start of word / symbol bonus
                if targetIdx == 0 ||
                   targetChars[targetIdx - 1].isWhitespace ||
                   targetChars[targetIdx - 1] == "_" ||
                   targetChars[targetIdx - 1] == "-" ||
                   targetChars[targetIdx - 1] == "." {
                    score += 25
                }
            } else {
                consecutiveMatches = 0
            }
            targetIdx += 1
        }

        if queryIdx == queryChars.count {
            return score
        }
        return nil
    }
}

// MARK: - Search Query Criteria & Operator Parser

struct SearchCriteria: Equatable {
    var appFilters: [String] = []
    var typeFilters: Set<ClipboardType> = []
    var isFavorite: Bool? = nil
    var isSensitive: Bool? = nil
    var isEncrypted: Bool? = nil
    var hasURL: Bool = false
    var hasColor: Bool = false
    var hasCode: Bool = false
    var hasImage: Bool = false
    var hasExtractedText: Bool = false
    var hasFile: Bool = false
    var textTerms: [String] = []
    var rawTextQuery: String = ""

    var hasAnyFilter: Bool {
        !appFilters.isEmpty ||
        !typeFilters.isEmpty ||
        isFavorite != nil ||
        isSensitive != nil ||
        isEncrypted != nil ||
        hasURL ||
        hasColor ||
        hasCode ||
        hasImage ||
        hasExtractedText ||
        hasFile ||
        !textTerms.isEmpty
    }

    static func parse(_ query: String) -> SearchCriteria {
        var criteria = SearchCriteria()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return criteria }

        var tokens: [String] = []
        var currentToken = ""
        var inQuotes = false
        var quoteChar: Character = "\""

        for char in trimmed {
            if char == "\"" || char == "'" {
                if inQuotes && char == quoteChar {
                    inQuotes = false
                } else if !inQuotes {
                    inQuotes = true
                    quoteChar = char
                }
                currentToken.append(char)
            } else if char.isWhitespace && !inQuotes {
                if !currentToken.isEmpty {
                    tokens.append(currentToken)
                    currentToken = ""
                }
            } else {
                currentToken.append(char)
            }
        }
        if !currentToken.isEmpty {
            tokens.append(currentToken)
        }

        var freeWords: [String] = []

        for token in tokens {
            var cleanToken = token
            while cleanToken.hasSuffix(",") || cleanToken.hasSuffix(";") {
                cleanToken.removeLast()
            }
            guard !cleanToken.isEmpty else { continue }

            let lower = cleanToken.lowercased()
            if lower == "or" || lower == "and" {
                continue
            }

            if lower.hasPrefix("app:") {
                let val = String(cleanToken.dropFirst(4)).trimmingCharacters(in: CharacterSet(charactersIn: "\"\'"))
                if !val.isEmpty {
                    criteria.appFilters.append(val)
                }
            } else if lower.hasPrefix("type:") {
                let val = String(cleanToken.dropFirst(5)).trimmingCharacters(in: CharacterSet(charactersIn: "\"\'")).lowercased()
                parseTypeFilter(val, into: &criteria.typeFilters)
            } else if lower.hasPrefix("is:") {
                let val = String(cleanToken.dropFirst(3)).trimmingCharacters(in: CharacterSet(charactersIn: "\"\'")).lowercased()
                parseIsFilter(val, into: &criteria)
            } else if lower.hasPrefix("has:") {
                let val = String(cleanToken.dropFirst(4)).trimmingCharacters(in: CharacterSet(charactersIn: "\"\'")).lowercased()
                parseHasFilter(val, into: &criteria)
            } else {
                let word = cleanToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"\'"))
                if !word.isEmpty {
                    freeWords.append(word)
                }
            }
        }

        criteria.textTerms = freeWords
        criteria.rawTextQuery = freeWords.joined(separator: " ")
        return criteria
    }

    private static func parseTypeFilter(_ val: String, into set: inout Set<ClipboardType>) {
        switch val {
        case "image", "img", "photo", "picture":
            set.insert(.image)
        case "text", "txt", "plain":
            set.insert(.text)
            set.insert(.richText)
        case "richtext", "rtf":
            set.insert(.richText)
        case "code", "source", "dev":
            set.insert(.code)
        case "color", "colour", "hex":
            set.insert(.color)
        case "url", "link", "web", "http":
            set.insert(.url)
        case "file", "files", "doc", "document":
            set.insert(.file)
        default:
            if let type = ClipboardType(rawValue: val) {
                set.insert(type)
            }
        }
    }

    private static func parseIsFilter(_ val: String, into criteria: inout SearchCriteria) {
        switch val {
        case "favorite", "fav", "starred":
            criteria.isFavorite = true
        case "unfavorite", "unstarred":
            criteria.isFavorite = false
        case "sensitive", "secret", "password":
            criteria.isSensitive = true
        case "encrypted":
            criteria.isEncrypted = true
        case "image", "img", "photo":
            criteria.typeFilters.insert(.image)
        case "code":
            criteria.typeFilters.insert(.code)
        case "color":
            criteria.typeFilters.insert(.color)
        case "url", "link":
            criteria.typeFilters.insert(.url)
        case "file":
            criteria.typeFilters.insert(.file)
        case "text":
            criteria.typeFilters.insert(.text)
            criteria.typeFilters.insert(.richText)
        default:
            break
        }
    }

    private static func parseHasFilter(_ val: String, into criteria: inout SearchCriteria) {
        switch val {
        case "url", "link", "web":
            criteria.hasURL = true
        case "color", "colour", "hex":
            criteria.hasColor = true
        case "code":
            criteria.hasCode = true
        case "image", "photo", "thumb", "thumbnail":
            criteria.hasImage = true
        case "text", "ocr", "extracted":
            criteria.hasExtractedText = true
        case "file":
            criteria.hasFile = true
        default:
            break
        }
    }
}

