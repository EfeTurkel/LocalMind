import Foundation

struct Message: Identifiable, Codable {
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