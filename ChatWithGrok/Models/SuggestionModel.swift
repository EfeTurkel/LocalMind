import Foundation

struct Suggestion: Identifiable {
    let id = UUID()
    let text: String
    let category: SuggestionCategory
    
    enum SuggestionCategory {
        case command
        case completion
        case popular
        
        var icon: String {
            switch self {
            case .command: return "terminal"
            case .completion: return "text.bubble"
            case .popular: return "star"
            }
        }
    }
} 