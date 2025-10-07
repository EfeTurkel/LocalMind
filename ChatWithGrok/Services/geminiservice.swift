import Foundation
import GoogleGenerativeAI

class GeminiService {
    static let shared = GeminiService()
    private var model: GenerativeModel?
    private var chat: Chat?
    private var apiKey: String
    private var currentModelName: String = "gemini-1.5-flash"
    
    private init() {
        apiKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        rebuildModel()
    }
    
    func updateAPIKey(_ newKey: String) {
        apiKey = newKey
        UserDefaults.standard.set(apiKey, forKey: "geminiAPIKey")
        rebuildModel()
    }
    
    func sendMessage(_ message: String) async throws -> String {
        do {
            // Ensure model exists with current API key
            if model == nil { rebuildModel() }
            guard let model = model else { throw URLError(.userAuthenticationRequired) }
            
            if chat == nil {
                chat = model.startChat()
            }
            
            let response = try await chat?.sendMessage(message)
            return response?.text ?? "No response received"
        } catch {
            print("Error: \(error)")
            throw error
        }
    }

    func updateModel(_ modelName: String) {
        currentModelName = modelName
        rebuildModel()
    }

    private func rebuildModel() {
        chat = nil
        let config = GenerationConfig(
            temperature: 1,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 8192,
            responseMIMEType: "text/plain"
        )
        guard !apiKey.isEmpty else {
            model = nil
            return
        }
        model = GenerativeModel(
            name: currentModelName,
            apiKey: apiKey,
            generationConfig: config
        )
    }
}
