import Foundation

enum AIMode: String, CaseIterable, Codable {
    case general = "General Assistant"
    case coding = "Code Expert"
    case creative = "Creative Writer"
    case academic = "Academic Assistant"
    case math = "Math & Science Expert"
    case business = "Business Analyst"
    
    var icon: String {
        switch self {
        case .general: return "brain"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .creative: return "paintbrush.fill"
        case .academic: return "book.fill"
        case .math: return "function"
        case .business: return "chart.bar.fill"
        }
    }
    
    var systemPrompt: String {
        switch self {
        case .general:
            return "You are a helpful assistant."
        case .coding:
            return """
            You are an expert programmer. Provide clean, efficient, and well-documented code.
            Always explain your code and include best practices. If there are potential improvements
            or alternative approaches, mention them.
            """
        case .creative:
            return """
            You are a creative writing assistant. Help with storytelling, poetry, and creative
            content. Provide imaginative and engaging responses while maintaining good writing
            structure and style.
            """
        case .academic:
            return """
            You are an academic assistant. Provide well-researched, scholarly responses with
            proper citations when possible. Use academic language and maintain a formal tone.
            Help with research, papers, and academic analysis.
            """
        case .math:
            return """
            You are a math and science expert. Show step-by-step solutions, explain concepts
            clearly, and use proper notation. Help with calculations, proofs, and scientific
            explanations.
            """
        case .business:
            return """
            You are a business analyst. Provide insights on business strategy, market analysis,
            and professional communication. Help with reports, presentations, and business
            planning.
            """
        }
    }
    
    var description: String {
        switch self {
        case .general: return "General purpose assistance for any topic"
        case .coding: return "Expert programming help and code review"
        case .creative: return "Creative writing and artistic expression"
        case .academic: return "Academic research and scholarly writing"
        case .math: return "Mathematical and scientific problem solving"
        case .business: return "Business analysis and professional writing"
        }
    }
} 