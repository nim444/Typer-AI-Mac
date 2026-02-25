import Foundation
import Security

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var geminiApiKey: String = ""
    @Published var grokApiKey: String = ""
    @Published var geminiModel: String = "gemini-2.5-flash"
    @Published var grokModel: String = "grok-4-1-fast-non-reasoning"
    @Published var defaultProvider: String = "grok"
    @Published var customPrompt: String = "Rewrite to fix grammar and improve clarity. Please only return the fixed text and nothing else:"
    @Published var theme: String = "system"

    let geminiModels = ["gemini-2.5-flash", "gemini-2.0-flash", "gemini-2.5-flash-lite"]
    let grokModels = ["grok-4-1-fast-non-reasoning", "grok-3-mini"]

    private init() {
        load()
    }

    func load() {
        geminiApiKey = loadKeychain(key: "gemini_api_key") ?? ""
        grokApiKey = loadKeychain(key: "grok_api_key") ?? ""
        geminiModel = UserDefaults.standard.string(forKey: "gemini_model") ?? "gemini-2.5-flash"
        grokModel = UserDefaults.standard.string(forKey: "grok_model") ?? "grok-4-1-fast-non-reasoning"
        defaultProvider = UserDefaults.standard.string(forKey: "default_provider") ?? "grok"
        customPrompt = UserDefaults.standard.string(forKey: "custom_prompt") ?? "Rewrite to fix grammar and improve clarity. Please only return the fixed text and nothing else:"
        theme = UserDefaults.standard.string(forKey: "theme") ?? "system"
    }

    func save() {
        saveKeychain(key: "gemini_api_key", value: geminiApiKey)
        saveKeychain(key: "grok_api_key", value: grokApiKey)
        UserDefaults.standard.set(geminiModel, forKey: "gemini_model")
        UserDefaults.standard.set(grokModel, forKey: "grok_model")
        UserDefaults.standard.set(defaultProvider, forKey: "default_provider")
        UserDefaults.standard.set(customPrompt, forKey: "custom_prompt")
        UserDefaults.standard.set(theme, forKey: "theme")
    }

    private func saveKeychain(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.typer.mac",
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        if !value.isEmpty {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            SecItemAdd(addQuery as CFDictionary, nil)
        }
    }

    private func loadKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.typer.mac",
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
