//
//  ClaudeService.swift
//  LockMind
//
//  Claude (Anthropic) API Service
//

import Foundation

class ClaudeService {
    static let shared = ClaudeService()
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private init() {}
    
    func sendMessage(_ message: String, model: String, apiKey: String, previousMessages: [Message] = []) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build messages array for Claude
        var claudeMessages: [ClaudeMessage] = []
        
        // Add previous messages
        for msg in previousMessages {
            claudeMessages.append(ClaudeMessage(
                role: msg.isUser ? "user" : "assistant",
                content: msg.content
            ))
        }
        
        // Add current message
        claudeMessages.append(ClaudeMessage(role: "user", content: message))
        
        let systemPrompt = getSystemPrompt()
        let messageBody = ClaudeRequest(
            model: model,
            max_tokens: 4096,
            system: systemPrompt,
            messages: claudeMessages
        )
        
        request.httpBody = try JSONEncoder().encode(messageBody)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: configuration)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorResponse = try? JSONDecoder().decode(ClaudeErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error.message)
                }
                throw URLError(.badServerResponse)
            }
            
            let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
            
            // Extract text from content array
            if let firstContent = claudeResponse.content.first {
                return cleanText(firstContent.text)
            }
            
            return "No response"
        } catch {
            print("Claude Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getSystemPrompt() -> String {
        let avatar = UserDefaults.standard.string(forKey: "avatar") ?? "xai2_logo"
        let personality = UserDefaults.standard.string(forKey: "personality") ?? "default"
        let customInstructions = UserDefaults.standard.string(forKey: "customInstructions") ?? ""
        let modeRaw = UserDefaults.standard.string(forKey: "selectedAIMode") ?? AIMode.general.rawValue
        let mode = AIMode(rawValue: modeRaw) ?? .general
        
        return """
        You are an AI assistant. Your avatar is \(avatar). Your personality is \(personality).
        
        Custom instructions: \(customInstructions)
        
        \(mode.systemPrompt)
        """
    }
    
    private func cleanText(_ text: String) -> String {
        return text.replacingOccurrences(of: "**", with: "")
    }
}

// Claude API Models
struct ClaudeRequest: Codable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [ClaudeMessage]
}

struct ClaudeMessage: Codable {
    let role: String
    let content: String
}

struct ClaudeResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ClaudeContent]
    let model: String
    let stop_reason: String?
}

struct ClaudeContent: Codable {
    let type: String
    let text: String
}

struct ClaudeErrorResponse: Codable {
    let error: ClaudeErrorDetail
}

struct ClaudeErrorDetail: Codable {
    let type: String
    let message: String
}

