import Foundation
import SwiftUI

class ChatSummaryManager: ObservableObject {
    @Published var chatSummaries: [String: (title: String, description: String)] = [:]
    
    func updateSummary(for chatId: String, title: String, description: String) {
        DispatchQueue.main.async {
            self.chatSummaries[chatId] = (title: title, description: description)
        }
    }
    
    func getSummary(for chatId: String) -> (title: String, description: String)? {
        return chatSummaries[chatId]
    }
}
