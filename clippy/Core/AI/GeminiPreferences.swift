import Foundation
import Combine

// MARK: - Gemini Model Definition

public struct GeminiModel: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let badge: String
    public let description: String
    public let isRecommended: Bool

    public init(id: String, name: String, badge: String, description: String, isRecommended: Bool = false) {
        self.id = id
        self.name = name
        self.badge = badge
        self.description = description
        self.isRecommended = isRecommended
    }
}

// MARK: - Gemini Preferences (BYOK)

final class GeminiPreferences: ObservableObject, @unchecked Sendable {
    static let shared = GeminiPreferences()

    private enum Keys {
        static let apiKey = "Gemini_apiKey"
        static let selectedModel = "Gemini_selectedModel"
        static let temperature = "Gemini_temperature"
    }

    static let availableModels: [GeminiModel] = [
        GeminiModel(
            id: "gemini-2.5-flash",
            name: "Gemini 2.5 Flash",
            badge: "Recommended",
            description: "Ultra-fast with frontier reasoning. Best for instant text rewrites.",
            isRecommended: true
        ),
        GeminiModel(
            id: "gemini-2.5-pro",
            name: "Gemini 2.5 Pro",
            badge: "Deep Reasoning",
            description: "Advanced intelligence for complex documents and nuanced editing."
        ),
        GeminiModel(
            id: "gemini-2.0-flash",
            name: "Gemini 2.0 Flash",
            badge: "Next-Gen Speed",
            description: "Low-latency generation with high accuracy."
        ),
        GeminiModel(
            id: "gemini-1.5-flash",
            name: "Gemini 1.5 Flash",
            badge: "Fast & Light",
            description: "Standard fast model for everyday summaries and formatting."
        ),
        GeminiModel(
            id: "gemini-1.5-pro",
            name: "Gemini 1.5 Pro",
            badge: "Long Context",
            description: "High capacity model suited for extensive text content."
        )
    ]

    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Keys.apiKey)
        }
    }

    @Published var selectedModel: String {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: Keys.selectedModel)
        }
    }

    @Published var temperature: Double {
        didSet {
            UserDefaults.standard.set(temperature, forKey: Keys.temperature)
        }
    }

    var isConfigured: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var activeModel: GeminiModel {
        Self.availableModels.first(where: { $0.id == selectedModel }) ?? Self.availableModels[0]
    }

    private init() {
        self.apiKey = UserDefaults.standard.string(forKey: Keys.apiKey) ?? ""
        self.selectedModel = UserDefaults.standard.string(forKey: Keys.selectedModel) ?? "gemini-2.5-flash"
        if UserDefaults.standard.object(forKey: Keys.temperature) != nil {
            self.temperature = UserDefaults.standard.double(forKey: Keys.temperature)
        } else {
            self.temperature = 0.3
        }
    }
}
