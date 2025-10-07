import Foundation

class GrokService {
    static let shared = GrokService()
    private let baseURL = "https://api.x.ai/v1/chat/completions"
    private init() {}
    
    func sendMessage(_ message: String, mode: AIMode, apiKey: String, previousMessages: [Message] = []) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let selectedAIModel = UserDefaults.standard.string(forKey: "selectedAIModel") ?? "grok-beta"
        let apiKeyToUse = apiKey
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKeyToUse)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var chatMessages: [ChatMessage] = [
            ChatMessage(role: "system", content: getSystemPrompt(mode: mode))
        ]
        
        for msg in previousMessages {
            chatMessages.append(ChatMessage(
                role: msg.isUser ? "user" : "assistant",
                content: msg.content
            ))
        }
        
        chatMessages.append(ChatMessage(role: "user", content: message))
        
        let messageBody = ChatRequest(
            model: selectedAIModel,
            messages: chatMessages,
            stream: false,
            temperature: 0.7
        )
        
        request.httpBody = try JSONEncoder().encode(messageBody)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // 30 saniye zaman aşımı
        let session = URLSession(configuration: configuration)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error.message)
                }
                throw URLError(.badServerResponse)
            }
            
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            return chatResponse.choices.first?.message.content ?? "No response"
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getSystemPrompt(mode: AIMode) -> String {
        let avatar = UserDefaults.standard.string(forKey: "avatar") ?? "xai2_logo"
        let personality = UserDefaults.standard.string(forKey: "personality") ?? "default"
        let customInstructions = UserDefaults.standard.string(forKey: "customInstructions") ?? ""
        
        return """
        You are an AI assistant. Your avatar is \(avatar). Your personality is \(personality).
        
        Custom instructions: \(customInstructions)
        
        \(mode.systemPrompt)
        """
    }
    
    private func getAIModelName(_ modelId: String) -> String {
        switch modelId {
        case "grok-beta":
            return "Grok Beta (Premium)"
        case "gpt-4":
            return "GPT-4 (Premium)"
        case "gemini-1.5-flash":
            return "Gemini 1.5 Flash (Basic)"
        case "gpt-4-mini":
            return "GPT-4-Mini (Basic)"
        case "grok-alpha":
            return "Grok Alpha"
        case "grok-lite":
            return "Grok Lite"
        default:
            return "Unknown"
        }
    }
}

// Request ve Response modelleri
struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
    let temperature: Double
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: ChatMessage
}

struct ErrorResponse: Codable {
    let error: APIErrorDetail
}

struct APIErrorDetail: Codable {
    let message: String
}

enum APIError: Error {
    case serverError(String)
} 