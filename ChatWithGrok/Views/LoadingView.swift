import SwiftUI

struct LoadingView: View {
    @State private var dotCount = 0
    let selectedModel: String
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppTheme.controlBackground)
                        .frame(width: 44, height: 44)
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                        .symbolEffect(.pulse, options: .repeat(1))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(getModelName(selectedModel))")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    HStack(spacing: 4) {
                        Text("is thinking")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(AppTheme.accent)
                                .frame(width: 4, height: 4)
                                .opacity(dotCount == index ? 1 : 0.3)
                                .animation(
                                    .easeInOut(duration: 0.45)
                                        .repeatForever()
                                        .delay(0.15 * Double(index)),
                                    value: dotCount
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(AppTheme.elevatedBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(AppTheme.outline)
            )
            .cornerRadius(AppTheme.cornerRadius)
            
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