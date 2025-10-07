import SwiftUI

struct LoadingView: View {
    @State private var dotCount = 0
    let selectedModel: String
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Text("\(getModelName(selectedModel)) is thinking")
                    .foregroundColor(.secondary)
                
                // Animasyonlu noktalar
                ForEach(0..<3) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 4, height: 4)
                        .scaleEffect(dotCount == index ? 1.5 : 1)
                        .animation(
                            .easeInOut(duration: 0.3)
                            .repeatForever()
                            .delay(0.15 * Double(index)),
                            value: dotCount
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
            .cornerRadius(16)
            
            Spacer()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { _ in
                dotCount = (dotCount + 1) % 3
            }
        }
    }
    
    private func getModelName(_ modelId: String) -> String {
        switch modelId {
        case "grok-beta":
            return "Grok Beta"
        case "gpt-4":
            return "GPT-4"
        case "gemini-1.5-flash":
            return "Gemini 1.5 Flash"
        case "gpt-4-mini":
            return "GPT-4-Mini"
        case "grok-alpha":
            return "Grok Alpha"
        case "grok-lite":
            return "Grok Lite"
        default:
            return modelId.capitalized
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
}

#Preview {
    LoadingView(selectedModel: "grok-beta")
} 