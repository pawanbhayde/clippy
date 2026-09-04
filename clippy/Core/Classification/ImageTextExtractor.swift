import Foundation
import Vision
import AppKit

// MARK: - Native Vision Framework Image OCR & Text Extractor

/// Asynchronously extracts text from images using Apple's native Vision framework (`VNRecognizeTextRequest`).
/// Runs 100% offline with zero external dependencies and hardware-accelerated text recognition.
enum ImageTextExtractor {
    /// Extracts plain text from an image at the specified file URL.
    static func extractText(from url: URL) async -> String? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        return await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(url: url, options: [:])
            do {
                try handler.perform([request])
                guard let observations = request.results else { return nil }
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                let fullText = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                return fullText.isEmpty ? nil : fullText
            } catch {
                print("ImageTextExtractor: OCR failed for \(url.lastPathComponent): \(error)")
                return nil
            }
        }.value
    }

    /// Extracts plain text from raw image data in memory.
    static func extractText(from data: Data) async -> String? {
        guard !data.isEmpty else { return nil }

        return await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(data: data, options: [:])
            do {
                try handler.perform([request])
                guard let observations = request.results else { return nil }
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                let fullText = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                return fullText.isEmpty ? nil : fullText
            } catch {
                print("ImageTextExtractor: OCR failed for image data: \(error)")
                return nil
            }
        }.value
    }
}
