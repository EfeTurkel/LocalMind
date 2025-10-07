import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var profileImage: String = ""
    var totalPrompts: Int = 0
    var dailyPrompts: [String: Int] = [:] // [Date string: count]
    var favoriteAIMode: AIMode = .general
    var averageResponseTime: Double = 0.0
    var totalCharactersSent: Int = 0
    var totalCharactersReceived: Int = 0
    var lastActive: Date = Date()
    var mostUsedAIModels: [String: Int] = [:] // Yeni özellik
    
    // Analiz metodları
    var averagePromptsPerDay: Double {
        guard !dailyPrompts.isEmpty else { return 0 }
        return Double(totalPrompts) / Double(dailyPrompts.count)
    }
    
    var mostActiveDay: (date: String, count: Int)? {
        guard let maxEntry = dailyPrompts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        return (date: maxEntry.key, count: maxEntry.value)
    }
    
    var weeklyActivity: [String: Int] {
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return dailyPrompts.filter { dateStr, _ in
            guard let date = DateFormatter.yyyyMMdd.date(from: dateStr) else { return false }
            return date >= lastWeek
        }
    }
}

// Date formatter extension
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
} 