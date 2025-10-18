import Foundation

struct Message: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    let content: String
    let isUser: Bool
    var timestamp: Date
    var category: ChatCategory = .general
    var isLoading: Bool = false
    var aiModel: String = ""
    
    init(content: String, isUser: Bool, timestamp: Date = Date(), category: ChatCategory = .general, isLoading: Bool = false, aiModel: String = "") {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.category = category
        self.isLoading = isLoading
        self.aiModel = aiModel
    }
    
    enum CodingKeys: String, CodingKey {
        case id, content, isUser, timestamp, category, isLoading, aiModel
    }
} 

extension Message {
    // Stable hash usable for ForEach id to reduce diff churn
    var _idHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(isUser)
        hasher.combine(aiModel)
        return hasher.finalize()
    }
}

// MARK: - Chat Summary Extension
extension Array where Element == Message {
    /// Generates a meaningful title for a chat based on all messages
    var chatTitle: String {
        // If no messages, return default
        guard !isEmpty else { return "Untitled Chat" }
        
        // Check if we have saved AI summary first
        let chatId = getChatId()
        if let savedSummary = getSavedAISummary(chatId: chatId) {
            return savedSummary.title
        }
        
        // Check if Gemini API key is available
        let geminiAPIKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        if !geminiAPIKey.isEmpty {
            // Use Gemini for AI-powered summary
            return generateAISummary()
        } else {
            // Fallback to local summary
            return generateLocalSummary()
        }
    }
    
    /// Generates a description for the chat
    var chatDescription: String {
        // If no messages, return default
        guard !isEmpty else { return "No messages yet" }
        
        // Check if we have saved AI summary first
        let chatId = getChatId()
        if let savedSummary = getSavedAISummary(chatId: chatId) {
            return savedSummary.description
        }
        
        // Check if Gemini API key is available
        let geminiAPIKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        if !geminiAPIKey.isEmpty {
            // Use Gemini for AI-powered description
            return generateAIDescription()
        } else {
            // Fallback to local description
            return generateLocalDescription()
        }
    }
    
    private func generateAISummary() -> String {
        // Use local summary for now, AI summary will be handled asynchronously
        // when the view loads and calls generateAISummaryAsync()
        return generateLocalSummary()
    }
    
    private func generateAIDescription() -> String {
        // Use local description for now, AI description will be handled asynchronously
        // when the view loads and calls generateAISummaryAsync()
        return generateLocalDescription()
    }
    
    /// Generates AI-powered title and description asynchronously
    func generateAISummaryAsync() async -> (title: String, description: String) {
        let geminiAPIKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        guard !geminiAPIKey.isEmpty else {
            return (title: generateLocalSummary(), description: generateLocalDescription())
        }
        
        // Check if we already have saved AI summary for this chat
        let chatId = getChatId()
        if let savedSummary = getSavedAISummary(chatId: chatId) {
            return savedSummary
        }
        
        do {
            let summary = try await GeminiService.shared.generateChatSummary(messages: self)
            
            // Save the AI summary permanently
            saveAISummary(chatId: chatId, title: summary.title, description: summary.description)
            
            return (title: summary.title, description: summary.description)
        } catch {
            print("Error generating AI summary: \(error)")
            return (title: generateLocalSummary(), description: generateLocalDescription())
        }
    }
    
    /// Gets a unique ID for this chat
    private func getChatId() -> String {
        guard let firstMessage = first else { return UUID().uuidString }
        return "\(firstMessage.timestamp.timeIntervalSince1970)"
    }
    
    /// Saves AI summary to UserDefaults
    private func saveAISummary(chatId: String, title: String, description: String) {
        let key = "aiSummary_\(chatId)"
        let summaryData = [
            "title": title,
            "description": description
        ]
        UserDefaults.standard.set(summaryData, forKey: key)
    }
    
    /// Gets saved AI summary from UserDefaults
    private func getSavedAISummary(chatId: String) -> (title: String, description: String)? {
        let key = "aiSummary_\(chatId)"
        guard let summaryData = UserDefaults.standard.dictionary(forKey: key),
              let title = summaryData["title"] as? String,
              let description = summaryData["description"] as? String else {
            return nil
        }
        return (title: title, description: description)
    }
    
    private func generateLocalSummary() -> String {
        // Combine all messages into one text
        let allText = map { $0.content }.joined(separator: " ")
        
        // If only one message, use its content (truncated)
        if count == 1 {
            return allText.count > 50 ? String(allText.prefix(50)) + "..." : allText
        }
        
        // For multiple messages, create a comprehensive summary
        return createComprehensiveSummary(from: allText)
    }
    
    private func generateLocalDescription() -> String {
        // Create a simple description based on message count and content
        let messageCount = count
        
        if messageCount == 1 {
            return "Single message conversation"
        } else if messageCount <= 5 {
            return "Short conversation (\(messageCount) messages)"
        } else if messageCount <= 20 {
            return "Medium conversation (\(messageCount) messages)"
        } else {
            return "Long conversation (\(messageCount) messages)"
        }
    }
    
    private func createComprehensiveSummary(from allText: String) -> String {
        // Extract key topics and concepts
        let words = allText.lowercased()
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { $0.count > 2 } // Filter out short words
        
        // Count word frequency
        let wordCounts = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        // Get most frequent meaningful words (excluding common words)
        let commonWords = Set(["the", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "is", "are", "was", "were", "be", "been", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "may", "might", "can", "this", "that", "these", "those", "i", "you", "he", "she", "it", "we", "they", "me", "him", "her", "us", "them", "my", "your", "his", "her", "its", "our", "their"])
        
        let meaningfulWords = wordCounts
            .filter { !commonWords.contains($0.key) }
            .prefix(5) // Top 5 meaningful words
            .map { $0.key }
        
        // If we have meaningful words, create a summary
        if !meaningfulWords.isEmpty {
            let summary = meaningfulWords.joined(separator: " ")
            return summary.count > 50 ? String(summary.prefix(50)) + "..." : summary
        }
        
        // Fallback: Use first part of the conversation
        let firstPart = allText.components(separatedBy: ".").first ?? allText
        let cleaned = firstPart
            .replacingOccurrences(of: "Can you ", with: "")
            .replacingOccurrences(of: "Could you ", with: "")
            .replacingOccurrences(of: "Please ", with: "")
            .replacingOccurrences(of: "I want to ", with: "")
            .replacingOccurrences(of: "I need to ", with: "")
            .replacingOccurrences(of: "Help me ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it's still too long, truncate intelligently
        if cleaned.count > 50 {
            let words = cleaned.components(separatedBy: .whitespaces)
            var result = ""
            for word in words {
                if (result + " " + word).count > 50 {
                    break
                }
                result += (result.isEmpty ? "" : " ") + word
            }
            return result + "..."
        }
        
        return cleaned.isEmpty ? "Chat Conversation" : cleaned
    }
}