import Foundation

struct Suggestion: Identifiable {
    let id = UUID()
    let text: String
    let category: SuggestionCategory
    
    enum SuggestionCategory {
        case command
        case completion
        case popular
        case code
        case explain
        case translate
        case generate
        case debug
        case help
        
        var icon: String {
            switch self {
            case .command: return "terminal"
            case .completion: return "text.bubble"
            case .popular: return "star"
            case .code: return "function"
            case .explain: return "questionmark.circle"
            case .translate: return "globe"
            case .generate: return "plus.circle"
            case .debug: return "ant"
            case .help: return "lightbulb"
            }
        }
    }
    
    /// Returns appropriate icon based on suggestion text content
    var smartIcon: String {
        let lowercasedText = text.lowercased()
        
        if lowercasedText.contains("write") || lowercasedText.contains("code") || lowercasedText.contains("function") {
            return "function"
        } else if lowercasedText.contains("explain") || lowercasedText.contains("how") || lowercasedText.contains("what") {
            return "questionmark.circle"
        } else if lowercasedText.contains("translate") || lowercasedText.contains("language") {
            return "globe"
        } else if lowercasedText.contains("generate") || lowercasedText.contains("create") || lowercasedText.contains("make") {
            return "plus.circle"
        } else if lowercasedText.contains("debug") || lowercasedText.contains("fix") || lowercasedText.contains("error") {
            return "ant"
        } else if lowercasedText.contains("help") || lowercasedText.contains("understand") {
            return "lightbulb"
        } else if lowercasedText.contains("summarize") || lowercasedText.contains("summary") {
            return "doc.text"
        } else if lowercasedText.contains("analyze") || lowercasedText.contains("analysis") {
            return "chart.bar"
        } else if lowercasedText.contains("optimize") || lowercasedText.contains("improve") {
            return "arrow.up.circle"
        } else {
            return category.icon
        }
    }
} 