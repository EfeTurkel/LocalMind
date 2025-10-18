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
    
    private var placeholderText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good morning, how can I help?"
        case 12..<17:
            return "Good afternoon, what's on your mind?"
        case 17..<22:
            return "Good evening, how can I assist?"
        default:
            return "Good night, what can I help with?"
        }
    }
    
    // Örnek öneriler
    private let defaultSuggestions = [
        Suggestion(text: "Write code for", category: .code),
        Suggestion(text: "Explain how to", category: .explain),
        Suggestion(text: "Help me understand", category: .help),
        Suggestion(text: "Generate a", category: .generate),
        Suggestion(text: "Debug this code", category: .debug),
        Suggestion(text: "Translate to", category: .translate),
        Suggestion(text: "Summarize this", category: .popular),
        Suggestion(text: "Analyze the", category: .popular),
        Suggestion(text: "Optimize this", category: .popular),
        Suggestion(text: "Create a", category: .generate)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern Suggestions Bar
            if showSuggestions && !currentInput.isEmpty && !filteredSuggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filteredSuggestions) { suggestion in
                            ModernSuggestionChip(suggestion: suggestion) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    currentInput = suggestion.text + " "
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .background(
                    ZStack {
                        AppTheme.background.opacity(0.9)
                        
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.6)
                    }
                    .overlay(
                        Rectangle()
                            .fill(AppTheme.outline.opacity(0.2))
                            .frame(height: 1),
                        alignment: .top
                    )
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Modern Input Bar
            HStack(spacing: 12) {
                // Clear button (only when focused and has text)
                if isFocused && !currentInput.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            currentInput = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 36, height: 36)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Text Input with Modern Design
                HStack(spacing: 12) {
                    TextField(placeholderText, text: $currentInput, axis: .vertical)
                        .focused($isFocused)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppTheme.textPrimary)
                        .tint(AppTheme.accent)
                        .lineLimit(5)
                        .onChange(of: currentInput) { oldValue, newValue in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showSuggestions = !newValue.isEmpty
                            }
                        }
                    
                    // Character count or loading indicator
                    if !currentInput.isEmpty {
                        Text("\(currentInput.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.6))
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.elevatedBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(
                                    isFocused ? AppTheme.accent.opacity(0.5) : AppTheme.outline.opacity(0.6),
                                    lineWidth: isFocused ? 1.5 : 1
                                )
                        )
                )
                
                // Modern Send Button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onSend()
                }) {
                    ZStack {
                        if currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading {
                            Circle()
                                .fill(AppTheme.controlBackground)
                                .frame(width: 48, height: 48)
                        } else {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.accent, AppTheme.accent.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                        }
                        
                        Image(systemName: isLoading ? "hourglass" : "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(
                                currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
                                    ? AppTheme.textSecondary
                                    : .white
                            )
                            .symbolEffect(.bounce, value: shouldBounce)
                    }
                }
                .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .shadow(
                    color: currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? .clear
                        : AppTheme.accent.opacity(0.3),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    AppTheme.background
                    
                    // Subtle gradient overlay
                    LinearGradient(
                        colors: [
                            AppTheme.background.opacity(0.8),
                            AppTheme.secondaryBackground.opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .background(.ultraThinMaterial.opacity(0.5))
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFocused)
        }
        .onAppear {
            bounceTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                if currentInput.isEmpty {
                    shouldBounce.toggle()
                }
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

// MARK: - Modern Suggestion Chip

struct ModernSuggestionChip: View {
    let suggestion: Suggestion
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: suggestion.smartIcon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.accent)
                
                Text(suggestion.text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(AppTheme.controlBackground.opacity(0.8))
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.outline.opacity(0.6), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(SuggestionButtonStyle())
    }
}

struct SuggestionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
} 