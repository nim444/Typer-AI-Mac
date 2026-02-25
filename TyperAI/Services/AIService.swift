import Foundation

enum AIError: LocalizedError {
    case noApiKey(String)
    case badResponse(String)

    var errorDescription: String? {
        switch self {
        case .noApiKey(let provider): return "No \(provider) API key set. Open Settings."
        case .badResponse(let msg): return msg
        }
    }
}

struct AIService {

    static func fix(text: String, settings: SettingsManager) async throws -> String {
        let provider = settings.defaultProvider
        let prompt = settings.customPrompt

        if provider == "gemini" {
            guard !settings.geminiApiKey.isEmpty else { throw AIError.noApiKey("Gemini") }
            return try await callGemini(text: text, prompt: prompt, apiKey: settings.geminiApiKey, model: settings.geminiModel)
        } else {
            guard !settings.grokApiKey.isEmpty else { throw AIError.noApiKey("Grok") }
            return try await callGrok(text: text, prompt: prompt, apiKey: settings.grokApiKey, model: settings.grokModel)
        }
    }

    private static func callGrok(text: String, prompt: String, apiKey: String, model: String) async throws -> String {
        let url = URL(string: "https://api.x.ai/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": prompt],
                ["role": "user", "content": text]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        guard let content = message?["content"] as? String else {
            throw AIError.badResponse("Unexpected response from Grok.")
        }
        return content
    }

    private static func callGemini(text: String, prompt: String, apiKey: String, model: String) async throws -> String {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": "\(prompt)\n\n\(text)"]]]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let candidates = json?["candidates"] as? [[String: Any]]
        let content = candidates?.first?["content"] as? [String: Any]
        let parts = content?["parts"] as? [[String: Any]]
        guard let text = parts?.first?["text"] as? String else {
            throw AIError.badResponse("Unexpected response from Gemini.")
        }
        return text
    }
}
