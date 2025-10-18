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
            let rawContent = response?.text ?? "No response received"
            return cleanText(rawContent)
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
        let aiMemoryEnabled = UserDefaults.standard.bool(forKey: "aiMemoryEnabled")
        let aiMemory = UserDefaults.standard.string(forKey: "aiMemory") ?? ""
        let modeRaw = UserDefaults.standard.string(forKey: "selectedAIMode") ?? AIMode.general.rawValue
        let mode = AIMode(rawValue: modeRaw) ?? .general
        
        var instructions = ""
        if aiMemoryEnabled && !aiMemory.isEmpty {
            instructions = "AI Memory (learned from conversations): \(aiMemory)"
        } else {
            instructions = "Custom instructions: \(customInstructions)"
        }
        
        let base = "You are an AI assistant. Your avatar is \(avatar). Your personality is \(personality).\n\n\(instructions)\n\n\(mode.systemPrompt)"
        return base
    }
    
    private func cleanText(_ text: String) -> String {
        return text.replacingOccurrences(of: "**", with: "")
    }
    
    // MARK: - Chat Summary Functions
    
    /// Generates a title and description for a chat using Gemini 2.5 Flash Lite
    func generateChatSummary(messages: [Message]) async throws -> (title: String, description: String) {
        guard !apiKey.isEmpty else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // Ensure model exists with current API key
        if model == nil { rebuildModel() }
        guard model != nil else { throw URLError(.userAuthenticationRequired) }
        
        // Prepare messages for summary
        let conversationText = messages.map { message in
            let role = message.isUser ? "User" : "AI"
            return "\(role): \(message.content)"
        }.joined(separator: "\n")
        
        // Create summary prompt
        let summaryPrompt = """
        Please analyze this conversation and provide:
        1. A concise title (max 50 characters) that captures the main topic
        2. A brief description (max 100 characters) that summarizes what was discussed
        
        Conversation:
        \(conversationText)
        
        Format your response as:
        TITLE: [title here]
        DESCRIPTION: [description here]
        """
        
       // Use a temporary model for summary (without system instruction)
       let summaryModel = GenerativeModel(
           name: "gemini-2.0-flash-lite",
           apiKey: apiKey,
           generationConfig: GenerationConfig(
               temperature: 0.3,
               topP: 0.8,
               topK: 20,
               maxOutputTokens: 200,
               responseMIMEType: "text/plain"
           )
       )
        
        do {
            let response = try await summaryModel.generateContent(summaryPrompt)
            let content = response.text ?? ""
            
            // Parse the response
            let lines = content.components(separatedBy: .newlines)
            var title = "Chat Conversation"
            var description = "No description available"
            
            for line in lines {
                if line.hasPrefix("TITLE:") {
                    title = String(line.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
                } else if line.hasPrefix("DESCRIPTION:") {
                    description = String(line.dropFirst(12)).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
           return (title: title, description: description)
       } catch {
           print("Error generating chat summary: \(error)")
           throw error
       }
   }
   
   /// Generates AI memory from chat history
   func generateMemoryFromChats(_ chats: [[Message]]) async throws -> String {
       guard !apiKey.isEmpty else {
           throw URLError(.userAuthenticationRequired)
       }
       
       // Ensure model exists with current API key
       if model == nil { rebuildModel() }
       guard model != nil else { throw URLError(.userAuthenticationRequired) }
       
       // Prepare conversation data for memory generation
       let conversationData = chats.map { chat in
           let messages = chat.map { message in
               let role = message.isUser ? "User" : "AI"
               return "\(role): \(message.content)"
           }.joined(separator: "\n")
           return "Chat: \(messages)"
       }.joined(separator: "\n\n")
       
       // Create memory generation prompt
       let memoryPrompt = """
       Based on the following conversation history, create a personalized memory profile for this user. Extract key information about:
       1. User's interests and topics they frequently discuss
       2. User's preferences, likes, and dislikes
       3. User's communication style and personality traits
       4. Important personal details or context they've shared
       5. Recurring themes or patterns in their conversations
       
       Format the memory as a concise, personalized instruction that will help the AI understand and remember this user better.
       
       Conversation History:
       \(conversationData)
       
       Create a memory profile that captures the essence of this user's personality and preferences:
       """
       
       // Use a temporary model for memory generation
       let memoryModel = GenerativeModel(
           name: "gemini-2.0-flash-lite",
           apiKey: apiKey,
           generationConfig: GenerationConfig(
               temperature: 0.3,
               topP: 0.8,
               topK: 20,
               maxOutputTokens: 500,
               responseMIMEType: "text/plain"
           )
       )
       
       do {
           let response = try await memoryModel.generateContent(memoryPrompt)
           let memory = response.text ?? ""
           
           // Clean up the memory text
           let cleanedMemory = memory
               .replacingOccurrences(of: "Memory Profile:", with: "")
               .replacingOccurrences(of: "Based on our conversations:", with: "")
               .trimmingCharacters(in: .whitespacesAndNewlines)
           
           return cleanedMemory.isEmpty ? "No specific memory patterns identified yet." : cleanedMemory
       } catch {
           print("Error generating AI memory: \(error)")
           throw error
       }
   }
}
