import AppKit

// MARK: - Coordinates detectors to classify clipboard content type

/// Entry point that runs a captured clipboard payload through the URL,
/// color, code, and sensitive-data detectors to produce a refined
/// `ClipboardType` and a sensitivity flag.
enum ContentClassifier {
    struct Result {
        var type: ClipboardType
        var isSensitive: Bool
    }

    static func classify(_ payload: ClipboardPayload) -> Result {
        switch payload {
        case .text(let string):
            return classify(text: string)
        case .richText(let data):
            return Result(type: .richText, isSensitive: SensitiveDataDetector.isSensitive(plainText(fromRTF: data)))
        case .image:
            return Result(type: .image, isSensitive: false)
        case .fileURL(let url):
            return Result(type: .file, isSensitive: SensitiveDataDetector.isSensitive(url.lastPathComponent))
        }
    }

    private static func classify(text: String) -> Result {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isSensitive = SensitiveDataDetector.isSensitive(text)

        if ColorDetector.isColor(trimmed) {
            return Result(type: .color, isSensitive: isSensitive)
        }
        if URLDetector.isURL(trimmed) {
            return Result(type: .url, isSensitive: isSensitive)
        }
        if CodeDetector.isCode(trimmed) {
            return Result(type: .code, isSensitive: isSensitive)
        }
        return Result(type: .text, isSensitive: isSensitive)
    }

    private static func plainText(fromRTF data: Data) -> String {
        (try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        ))?.string ?? ""
    }
}
