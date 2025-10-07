import Foundation

enum ChatCategory: String, Codable, CaseIterable {
    case general = "General"
    case coding = "Coding"
    case research = "Research"
    case writing = "Writing"
    case math = "Math & Science"
    case translation = "Translation"
    
    var icon: String {
        switch self {
        case .general: return "bubble.left.and.bubble.right"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .research: return "magnifyingglass"
        case .writing: return "pencil"
        case .math: return "function"
        case .translation: return "globe"
        }
    }
    
    var color: String {
        switch self {
        case .general: return "blue"
        case .coding: return "purple"
        case .research: return "green"
        case .writing: return "orange"
        case .math: return "red"
        case .translation: return "indigo"
        }
    }
} 