import SwiftUI

struct InputView: View {
    @Binding var currentInput: String
    let onSend: () -> Void
    let isLoading: Bool
    @State private var bounceTimer: Timer?
    @State private var shouldBounce = false
    @AppStorage("dailyMessageCount") private var dailyMessageCount = 0
    @State private var suggestions: [Suggestion] = []
    @State private var showSuggestions = false
    @FocusState private var isFocused: Bool
    let FREE_DAILY_LIMIT = 20
    @Environment(\.colorScheme) private var colorScheme
    
    // Örnek öneriler
    private let defaultSuggestions = [
        Suggestion(text: "Write code for", category: .command),
        Suggestion(text: "Explain how to", category: .command),
        Suggestion(text: "Help me understand", category: .command),
        Suggestion(text: "Generate a", category: .command),
        Suggestion(text: "Debug this code", category: .popular),
        Suggestion(text: "Translate to", category: .popular)
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            // Öneriler
            if showSuggestions && !currentInput.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filteredSuggestions) { suggestion in
                            SuggestionButton(suggestion: suggestion) {
                                currentInput = suggestion.text + " "
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 44)
                .background(AppTheme.secondaryBackground)
                .clipShape(Capsule())
                .padding(.horizontal)
            }
            
            // Mesaj girişi
            HStack(spacing: 12) {
                if isFocused {
                    Button(action: {
                        currentInput = ""
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.destructive)
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(AppTheme.destructive.opacity(0.12))
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                TextField("Ask anything...", text: $currentInput, axis: .vertical)
                    .focused($isFocused)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(AppTheme.elevatedBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                            .stroke(AppTheme.outline)
                    )
                    .lineLimit(5) // Maksimum 5 satır göster
                    .onChange(of: currentInput) { oldValue, newValue in
                        withAnimation {
                            showSuggestions = !newValue.isEmpty
                        }
                    }
                
                Button(action: onSend) {
                    Image(systemName: isLoading ? "hourglass" : "paperplane.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(dailyMessageCount >= FREE_DAILY_LIMIT ? AppTheme.destructive : AppTheme.accent)
                        .symbolEffect(.bounce, value: shouldBounce)
                }
                .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.1, style: .continuous)
                    .fill(AppTheme.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.1, style: .continuous)
                            .stroke(AppTheme.outline)
                    )
            )
            .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 18)
            .animation(.easeInOut, value: isFocused)
        }
        .onAppear {
            bounceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                shouldBounce.toggle()
            }
            suggestions = defaultSuggestions
        }
        .onDisappear {
            bounceTimer?.invalidate()
            bounceTimer = nil
        }
    }
    
    private var filteredSuggestions: [Suggestion] {
        if currentInput.isEmpty {
            return suggestions
        }
        return suggestions.filter { $0.text.lowercased().contains(currentInput.lowercased()) }
    }
}

struct SuggestionButton: View {
    let suggestion: Suggestion
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: suggestion.category.icon)
                    .font(.system(size: 12))
                Text(suggestion.text)
                    .font(.subheadline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(AppTheme.chipBackground)
            .overlay(
                Capsule()
                    .stroke(AppTheme.chipBorder, lineWidth: 1)
            )
        }
        .foregroundColor(AppTheme.textPrimary)
    }
} 