import Foundation
import GoogleGenerativeAI

class GeminiService {
    static let shared = GeminiService()
    private var model: GenerativeModel?
    private var chat: Chat?
    private var apiKey: String
    private var currentModelName: String = "gemini-1.5-flash"
    private var currentSystemInstruction: String = ""
    
    private init() {
        apiKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        rebuildModel()
    }
    
    func updateAPIKey(_ newKey: String) {
        apiKey = newKey
        UserDefaults.standard.set(apiKey, forKey: "geminiAPIKey")
        rebuildModel()
    }
    
    func sendMessage(_ message: String, previousMessages: [Message] = []) async throws -> String {
        do {
            // Ensure model exists with current API key
            if model == nil { rebuildModel() }
            guard let model = model else { throw URLError(.userAuthenticationRequired) }
            
            if chat == nil {
                // Build system instruction from user settings
                let system = getSystemPrompt()
                // Map previous messages into Gemini chat history; prepend system instruction if present
                var history: [ModelContent] = []
                if !system.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    history.append(ModelContent(role: "user", parts: system))
                }
                history += previousMessages.map { msg in
                    let role = msg.isUser ? "user" : "model"
                    // The SDK accepts String-convertible parts; pass text directly
                    return ModelContent(role: role, parts: msg.content)
                }
                if history.isEmpty {
                    chat = model.startChat()
                } else {
                    chat = model.startChat(history: history)
                }
            }
            
            let response = try await chat?.sendMessage(message)
            return response?.text ?? "No response received"
        } catch {
            print("Error: \(error)")
            throw error
        }
    }

    func updateModel(_ modelName: String) {
        // Only rebuild if model actually changed to preserve ongoing chat state
        guard modelName != currentModelName else { return }
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
        let system = getSystemPrompt()
        currentSystemInstruction = system
        model = GenerativeModel(
            name: currentModelName,
            apiKey: apiKey,
            generationConfig: config,
            systemInstruction: system
        )
    }

    private func getSystemPrompt() -> String {
        let avatar = UserDefaults.standard.string(forKey: "avatar") ?? "xai2_logo"
        let personality = UserDefaults.standard.string(forKey: "personality") ?? "default"
        let customInstructions = UserDefaults.standard.string(forKey: "customInstructions") ?? ""
        let modeRaw = UserDefaults.standard.string(forKey: "selectedAIMode") ?? AIMode.general.rawValue
        let mode = AIMode(rawValue: modeRaw) ?? .general
        let base = "You are an AI assistant. Your avatar is \(avatar). Your personality is \(personality).\n\nCustom instructions: \(customInstructions)\n\n\(mode.systemPrompt)"
        return base
    }
}
