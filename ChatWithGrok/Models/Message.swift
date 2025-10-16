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