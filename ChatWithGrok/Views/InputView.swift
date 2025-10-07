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
        VStack(spacing: 0) {
            // Öneriler
            if showSuggestions && !currentInput.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filteredSuggestions) { suggestion in
                            SuggestionButton(suggestion: suggestion) {
                                currentInput = suggestion.text + " "
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 40)
                .background(Color(.systemGray6).opacity(0.5))
            }
            
            // Mesaj girişi
            HStack(spacing: 8) {
                if isFocused {
                    Button(action: {
                        currentInput = ""
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                TextField("Ask anything...", text: $currentInput, axis: .vertical)
                    .focused($isFocused)
                    .padding(12)
                    .background(colorScheme == .light ? Color(.systemGray5) : Color(.systemGray6))
                    .cornerRadius(24)
                    .lineLimit(5) // Maksimum 5 satır göster
                    .onChange(of: currentInput) { oldValue, newValue in
                        withAnimation {
                            showSuggestions = !newValue.isEmpty
                        }
                    }
                
                Button(action: onSend) {
                    Image(systemName: isLoading ? "clock.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(dailyMessageCount >= FREE_DAILY_LIMIT ? .orange : .blue)
                        .symbolEffect(.bounce, value: shouldBounce)
                }
                .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
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
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.systemGray5))
            )
        }
        .foregroundColor(.primary)
    }
} 