import Foundation

class MockAIService {
    static let shared = MockAIService()
    private init() {}
    
    func sendMessage(_ message: String, model: String, previousMessages: [Message]) async throws -> String {
        let canned: [String] = [
            "This is a demo response showcasing the app without API keys.",
            "Thanks for trying SecureAI! Add your API key in Settings to use real models.",
            "You can switch models and features even in Demo Mode."
        ]
        let suffix = [
            "\n\nModel: \(model)",
            "\n\nTip: Go to Settings → API Keys to enable real responses.",
            "\n\nNote: Messages are generated locally in demo mode."
        ].randomElement() ?? ""
        return (canned.randomElement() ?? "Hello from demo mode!") + suffix
    }
}


