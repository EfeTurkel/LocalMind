import Foundation

class AIMemoryService {
    static let shared = AIMemoryService()
    
    private init() {}
    
    /// Generates AI memory from chat history
    func generateMemoryFromChats(_ chats: [[Message]]) async -> String {
        let geminiAPIKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        guard !geminiAPIKey.isEmpty else {
            return generateLocalMemory(chats)
        }
        
        do {
            let memory = try await GeminiService.shared.generateMemoryFromChats(chats)
            return memory
        } catch {
            print("Error generating AI memory: \(error)")
            return generateLocalMemory(chats)
        }
    }
    
    /// Generates local memory when AI is not available
    private func generateLocalMemory(_ chats: [[Message]]) -> String {
        var memory = "Based on our conversations, I remember:\n\n"
        
        // Extract key topics and patterns
        let allMessages = chats.flatMap { $0 }
        let userMessages = allMessages.filter { $0.isUser }
        
        // Find frequently mentioned topics
        let topics = extractTopics(from: userMessages)
        if !topics.isEmpty {
            memory += "Key topics you're interested in: \(topics.joined(separator: ", "))\n\n"
        }
        
        // Find preferences and patterns
        let preferences = extractPreferences(from: userMessages)
        if !preferences.isEmpty {
            memory += "Your preferences: \(preferences.joined(separator: ", "))\n\n"
        }
        
        // Find communication style
        let communicationStyle = extractCommunicationStyle(from: userMessages)
        if !communicationStyle.isEmpty {
            memory += "Your communication style: \(communicationStyle)\n\n"
        }
        
        return memory
    }
    
    private func extractTopics(from messages: [Message]) -> [String] {
        let allText = messages.map { $0.content }.joined(separator: " ")
        let words = allText.lowercased()
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { $0.count > 3 }
        
        let wordCounts = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        let commonWords = Set(["this", "that", "with", "from", "they", "have", "been", "were", "said", "each", "which", "their", "time", "will", "about", "there", "could", "other", "after", "first", "well", "also", "where", "much", "some", "very", "when", "here", "just", "into", "over", "think", "more", "your", "work", "know", "good", "make", "take", "come", "want", "need", "help", "like", "love", "hate", "feel", "seem", "look", "find", "give", "tell", "ask", "show", "try", "use", "get", "go", "see", "can", "may", "must", "should", "would", "could", "might"])
        
        return wordCounts
            .filter { !commonWords.contains($0.key) && $0.value > 2 }
            .prefix(5)
            .map { $0.key.capitalized }
    }
    
    private func extractPreferences(from messages: [Message]) -> [String] {
        var preferences: [String] = []
        
        for message in messages {
            let content = message.content.lowercased()
            
            if content.contains("i like") || content.contains("i love") || content.contains("i prefer") {
                preferences.append("Has specific likes and preferences")
            }
            
            if content.contains("i don't like") || content.contains("i hate") || content.contains("i dislike") {
                preferences.append("Has specific dislikes")
            }
            
            if content.contains("i always") || content.contains("i usually") || content.contains("i typically") {
                preferences.append("Has consistent habits and patterns")
            }
        }
        
        return Array(Set(preferences))
    }
    
    private func extractCommunicationStyle(from messages: [Message]) -> String {
        var styles: [String] = []
        
        for message in messages {
            let content = message.content
            
            if content.contains("!") {
                styles.append("enthusiastic")
            }
            
            if content.contains("?") {
                styles.append("inquisitive")
            }
            
            if content.count > 100 {
                styles.append("detailed")
            }
            
            if content.count < 20 {
                styles.append("concise")
            }
        }
        
        let styleCounts = Dictionary(grouping: styles, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return styleCounts.prefix(3).map { $0.key }.joined(separator: ", ")
    }
    
    /// Gets the current AI memory
    func getCurrentMemory() -> String {
        return UserDefaults.standard.string(forKey: "aiMemory") ?? ""
    }
    
    /// Saves AI memory
    func saveMemory(_ memory: String) {
        UserDefaults.standard.set(memory, forKey: "aiMemory")
    }
    
    /// Clears AI memory
    func clearMemory() {
        UserDefaults.standard.removeObject(forKey: "aiMemory")
    }
}
