import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    func sendMessage(_ message: String, model: String, apiKey: String, previousMessages: [Message] = []) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = getSystemPrompt()
        let messageBody = OpenAIChatRequest(
            model: model,
            messages: [OpenAIChatMessage(role: "system", content: systemPrompt)] + previousMessages.map { OpenAIChatMessage(role: $0.isUser ? "user" : "assistant", content: $0.content) } + [OpenAIChatMessage(role: "user", content: message)]
        )
        
        request.httpBody = try JSONEncoder().encode(messageBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let chatResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        return chatResponse.choices.first?.message.content ?? "No response"
    }
    
    private func getSystemPrompt() -> String {
        let avatar = UserDefaults.standard.string(forKey: "avatar") ?? "xai2_logo"
        let personality = UserDefaults.standard.string(forKey: "personality") ?? "default"
        let customInstructions = UserDefaults.standard.string(forKey: "customInstructions") ?? ""
        
        return """
        You are an AI assistant. Your avatar is \(avatar). Your personality is \(personality).
        
        Custom instructions: \(customInstructions)
        """
    }
}

struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
}

struct OpenAIChatMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIChatResponse: Codable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Codable {
    let message: OpenAIChatMessage
} 