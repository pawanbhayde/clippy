import Foundation

// MARK: - Gemini Action Types

public enum GeminiAction: Hashable {
    case proofread
    case concise
    case friendly
    case professional
    case summary
    case keyPoints
    case list
    case table
    case custom(prompt: String)

    public var title: String {
        switch self {
        case .proofread: return "Proofread"
        case .concise: return "Concise"
        case .friendly: return "Friendly"
        case .professional: return "Professional"
        case .summary: return "Summary"
        case .keyPoints: return "Key Points"
        case .list: return "List"
        case .table: return "Table"
        case .custom: return "Custom"
        }
    }

    public var icon: String {
        switch self {
        case .proofread: return "text.badge.checkmark"
        case .concise: return "arrow.down.right.and.arrow.up.left"
        case .friendly: return "face.smiling"
        case .professional: return "briefcase"
        case .summary: return "text.quote"
        case .keyPoints: return "list.bullet.indent"
        case .list: return "list.bullet"
        case .table: return "tablecells"
        case .custom: return "wand.and.stars"
        }
    }

    var taskPrompt: String {
        switch self {
        case .proofread:
            return "Proofread and fix all grammar, punctuation, spelling, and phrasing errors in the following text while preserving original formatting, markdown, and code blocks."
        case .concise:
            return "Rewrite the following text to make it clear, concise, and direct. Eliminate wordiness, fluff phrases, and passive voice while preserving all essential meaning and key facts."
        case .friendly:
            return "Rewrite the following text in a warm, polite, and friendly tone suitable for casual, collaborative, or supportive communication."
        case .professional:
            return "Rewrite the following text in an executive, polished, and professional tone suitable for business correspondence."
        case .summary:
            return "Provide a clear, high-signal summary of the following text, capturing the main conclusions or key messages."
        case .keyPoints:
            return "Extract the main points and key takeaways from the following text as a clean bulleted list."
        case .list:
            return "Organize and format the following text into a clean, numbered or bulleted list."
        case .table:
            return "Convert the following information into a structured GitHub-flavored Markdown table with appropriate headers."
        case .custom(let prompt):
            return prompt
        }
    }
}

// MARK: - Gemini Error

public enum GeminiError: LocalizedError {
    case missingApiKey
    case invalidURL
    case networkError(Error)
    case apiError(String)
    case emptyResponse
    case decodingError

    public var errorDescription: String? {
        switch self {
        case .missingApiKey:
            return "Gemini API key is missing. Please configure your key in Settings."
        case .invalidURL:
            return "Invalid Gemini API endpoint URL."
        case .networkError(let error):
            return "Network connection error: \(error.localizedDescription)"
        case .apiError(let message):
            return "Gemini API Error: \(message)"
        case .emptyResponse:
            return "Received an empty response from Gemini."
        case .decodingError:
            return "Failed to parse the response from Gemini."
        }
    }
}

// MARK: - Gemini Service Client (BYOK)

final class GeminiService: @unchecked Sendable {
    static let shared = GeminiService()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 25.0
        config.timeoutIntervalForResource = 60.0
        self.session = URLSession(configuration: config)
    }

    private static let systemInstruction = """
    You are an expert, precise text editor and writing assistant inside the macOS clipboard app Clippy.
    Output ONLY the transformed or refined text.
    Do NOT include any preamble, introductory text, conversational greetings, explanations, or quotes wrapping the entire output.
    Preserve technical syntax, indentation, and code formatting unless explicitly told to transform them.
    """

    // MARK: - Validate API Key

    func validateApiKey(_ rawKey: String) async -> (isValid: Bool, message: String) {
        let key = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            return (false, "API key cannot be empty.")
        }

        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models?key=\(key)") else {
            return (false, "Invalid endpoint URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return (false, "Unexpected network response.")
            }

            if httpResponse.statusCode == 200 {
                // Parse model count if possible
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let models = json["models"] as? [[String: Any]] {
                    return (true, "Valid API key! Connected with \(models.count) models available.")
                }
                return (true, "API key is valid and connected!")
            } else {
                // Extract error message from Google API error response
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let err = json["error"] as? [String: Any],
                   let msg = err["message"] as? String {
                    return (false, msg)
                }
                return (false, "HTTP \(httpResponse.statusCode): Verification failed.")
            }
        } catch {
            return (false, "Connection error: \(error.localizedDescription)")
        }
    }

    // MARK: - Transform Text with Gemini LLM

    func transformText(
        _ text: String,
        action: GeminiAction,
        preferences: GeminiPreferences = .shared
    ) async throws -> String {
        let apiKey = preferences.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else {
            throw GeminiError.missingApiKey
        }

        let model = preferences.selectedModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "gemini-2.5-flash"
            : preferences.selectedModel

        let endpointString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: endpointString) else {
            throw GeminiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build Payload
        let promptPayload: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": "\(action.taskPrompt)\n\n---\n\(text)"]
                    ]
                ]
            ],
            "systemInstruction": [
                "parts": [
                    ["text": Self.systemInstruction]
                ]
            ],
            "generationConfig": [
                "temperature": preferences.temperature,
                "maxOutputTokens": 8192
            ]
        ]

        let httpBody = try JSONSerialization.data(withJSONObject: promptPayload)
        request.httpBody = httpBody

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.emptyResponse
        }

        if httpResponse.statusCode != 200 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let err = json["error"] as? [String: Any],
               let msg = err["message"] as? String {
                throw GeminiError.apiError(msg)
            }
            throw GeminiError.apiError("HTTP status \(httpResponse.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let generatedText = firstPart["text"] as? String else {
            throw GeminiError.emptyResponse
        }

        return cleanGeneratedText(generatedText, action: action)
    }

    // MARK: - Post-processing Text Cleanup

    private func cleanGeneratedText(_ raw: String, action: GeminiAction) -> String {
        var trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // If the model wrapped the entire response in a markdown code fence like ```markdown ... ```
        // and action wasn't a code block or table, strip the outer fence
        if action != .table {
            if trimmed.hasPrefix("```markdown\n") && trimmed.hasSuffix("\n```") {
                trimmed = String(trimmed.dropFirst("```markdown\n".count).dropLast("\n```".count))
            } else if trimmed.hasPrefix("```\n") && trimmed.hasSuffix("\n```") {
                trimmed = String(trimmed.dropFirst("```\n".count).dropLast("\n```".count))
            }
        }

        return trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
