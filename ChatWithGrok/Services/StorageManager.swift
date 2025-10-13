import Foundation

class StorageManager {
    static let shared = StorageManager()
    private let defaults = UserDefaults.standard
    private let allChatsKey = "allChats"
    private let pinnedChatsKey = "pinnedChatIdentifiers"
    
    private init() {}
    
    func saveChat(_ messages: [Message]) {
        if messages.isEmpty { return }
        
        var allChats = loadAllChats()
        
        if let firstMessageTime = messages.first?.timestamp {
            if let existingChatIndex = allChats.firstIndex(where: { chat in
                let chatFirstMessageTime = chat.first?.timestamp
                return chatFirstMessageTime?.timeIntervalSince1970 == firstMessageTime.timeIntervalSince1970
            }) {
                let updatedMessages = messages.enumerated().map { index, message in
                    if index < allChats[existingChatIndex].count {
                        var updatedMessage = message
                        updatedMessage.timestamp = allChats[existingChatIndex][index].timestamp
                        return updatedMessage
                    }
                    return message
                }
                allChats[existingChatIndex] = updatedMessages
            } else {
                allChats.insert(messages, at: 0)
            }
            
            if let encoded = try? JSONEncoder().encode(allChats) {
                defaults.set(encoded, forKey: allChatsKey)
            }
        }
    }
    
    func loadAllChats() -> [[Message]] {
        if let data = defaults.data(forKey: allChatsKey),
           let chats = try? JSONDecoder().decode([[Message]].self, from: data) {
            return chats.sorted { first, second in
                guard let firstDate = first.first?.timestamp,
                      let secondDate = second.first?.timestamp else {
                    return false
                }
                return firstDate > secondDate
            }
        }
        return []
    }
    
    func deleteChat(at index: Int) {
        var allChats = loadAllChats()
        if index < allChats.count {
            let removedChat = allChats[index]
            allChats.remove(at: index)
            removePinned(for: removedChat)
            if let encoded = try? JSONEncoder().encode(allChats) {
                defaults.set(encoded, forKey: allChatsKey)
            }
        }
    }
    
    func deleteAllChats() {
        defaults.removeObject(forKey: allChatsKey)
        defaults.removeObject(forKey: pinnedChatsKey)
    }

    func setPinned(_ pinned: Bool, for chat: [Message]) {
        guard let identifier = identifier(for: chat) else { return }
        var current = loadPinnedIdentifiers()
        if pinned {
            current.insert(identifier)
        } else {
            current.remove(identifier)
        }
        savePinnedIdentifiers(current)
    }

    func loadPinnedIdentifiers() -> Set<Double> {
        if let stored = defaults.array(forKey: pinnedChatsKey) as? [Double] {
            return Set(stored)
        }
        return []
    }

    func identifier(for chat: [Message]) -> Double? {
        guard let firstTimestamp = chat.first?.timestamp else { return nil }
        return firstTimestamp.timeIntervalSince1970
    }

    private func removePinned(for chat: [Message]) {
        guard let identifier = identifier(for: chat) else { return }
        var current = loadPinnedIdentifiers()
        if current.remove(identifier) != nil {
            savePinnedIdentifiers(current)
        }
    }

    private func savePinnedIdentifiers(_ identifiers: Set<Double>) {
        defaults.set(Array(identifiers), forKey: pinnedChatsKey)
    }
} 