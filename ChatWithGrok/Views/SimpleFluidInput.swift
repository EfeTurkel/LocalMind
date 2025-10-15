import SwiftUI

struct SimpleFluidInput: View {
    @Binding var currentInput: String
    let onSend: () -> Void
    let isLoading: Bool
    @Binding var keyboardHeight: CGFloat
    @Binding var messages: [Message]
    @Binding var selectedAIMode: AIMode
    @FocusState private var isFocused: Bool
    @State private var inputHeight: CGFloat = 44
    
    private let minHeight: CGFloat = 44
    private let maxHeight: CGFloat = 120
    private let cornerRadius: CGFloat = 22
    
    @State private var displayedSuggestions: [String] = []
    
    private let suggestionsByMode: [AIMode: [String]] = [
        .general: [
            "Explain complex topics simply",
            "Summarize this article",
            "Translate to another language",
            "Fix grammar mistakes",
            "Suggest gift ideas",
            "Create a workout plan",
            "Plan a healthy meal",
            "Suggest productivity tips",
            "Write motivational quote",
            "Create checklist template"
        ],
        .coding: [
            "Review and improve code",
            "Debug this code snippet",
            "Explain algorithm complexity",
            "Refactor legacy code",
            "Write unit tests",
            "Optimize database query",
            "Design API endpoints",
            "Fix security vulnerabilities",
            "Create code documentation",
            "Suggest best practices",
            "Design system architecture",
            "Implement design pattern"
        ],
        .creative: [
            "Generate creative names",
            "Write social media captions",
            "Generate story ideas",
            "Write video script",
            "Design logo concept",
            "Create presentation outline",
            "Design color palette",
            "Generate slogan options",
            "Write blog post ideas",
            "Design brand strategy",
            "Create character backstory",
            "Write catchy headlines"
        ],
        .academic: [
            "Create a study schedule",
            "Suggest book recommendations",
            "Create quiz questions",
            "Create learning roadmap",
            "Create mind map",
            "Write essay outline",
            "Explain scientific concepts",
            "Create bibliography",
            "Summarize research paper",
            "Create flashcards",
            "Write thesis statement",
            "Analyze historical events"
        ],
        .math: [
            "Solve complex equations",
            "Explain mathematical proofs",
            "Create practice problems",
            "Visualize data patterns",
            "Calculate statistics",
            "Explain calculus concepts",
            "Solve physics problems",
            "Create formula sheet",
            "Analyze probability",
            "Design experiment",
            "Interpret scientific data",
            "Model mathematical systems"
        ],
        .business: [
            "Plan marketing strategy",
            "Draft business proposal",
            "Write a professional email",
            "Write a cover letter",
            "Create presentation outline",
            "Write resume bullet points",
            "Write meeting agenda",
            "Suggest career advice",
            "Create budget plan",
            "Plan event timeline",
            "Write interview questions",
            "Suggest SEO keywords",
            "Design workflow process",
            "Write sales pitch",
            "Analyze market trends",
            "Create business plan"
        ]
    ]
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Suggestion Chips - Only show when no keyboard and no messages
            if keyboardHeight == 0 && messages.isEmpty && currentInput.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(displayedSuggestions, id: \.self) { suggestion in
                            Button(action: {
                                currentInput = suggestion
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }) {
                                Text(suggestion)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(AppTheme.controlBackground.opacity(0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .stroke(AppTheme.outline.opacity(0.8), lineWidth: 1.5)
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Input Area
            HStack(alignment: .bottom, spacing: 12) {
                // Input Container
                ZStack(alignment: .trailing) {
                // Background
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.elevatedBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                isFocused ? AppTheme.accent : AppTheme.outline.opacity(0.6),
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
                    .frame(height: inputHeight)
                    .scaleEffect(isFocused ? 1.02 : 1.0)
                    .animation(AppTheme.springMedium, value: isFocused)
                
                // Text Input
                HStack(spacing: 12) {
                    // Clear button (only when focused and has text)
                    if isFocused && !currentInput.isEmpty {
                        Button(action: {
                            withAnimation(AppTheme.springMedium) {
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
                    
                    TextField(placeholderText, text: $currentInput, axis: .vertical)
                        .focused($isFocused)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppTheme.textPrimary)
                        .tint(AppTheme.accent)
                        .lineLimit(5)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.clear)
                        .onChange(of: currentInput) { _, newValue in
                            updateInputHeight()
                        }
                    
                    // Character count
                    if !currentInput.isEmpty {
                        Text("\(currentInput.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.6))
                            .padding(.trailing, 18)
                            .transition(.opacity)
                    }
                }
                
                // Send button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onSend()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
                                    ? AppTheme.controlBackground
                                    : AppTheme.accent
                            )
                            .frame(width: 36, height: 36)
                            .scaleEffect(isLoading ? 1.1 : 1.0)
                            .animation(AppTheme.springFast, value: isLoading)
                        
                        Image(systemName: isLoading ? "hourglass" : "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(
                                currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
                                    ? AppTheme.textSecondary
                                    : .white
                            )
                            .rotationEffect(.degrees(isLoading ? 360 : 0))
                            .animation(
                                isLoading 
                                    ? .linear(duration: 1.0).repeatForever(autoreverses: false)
                                    : AppTheme.springMedium,
                                value: isLoading
                            )
                            .scaleEffect(isLoading ? 1.2 : 1.0)
                            .animation(AppTheme.springFast, value: isLoading)
                    }
                }
                .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .padding(.trailing, 6)
                .scaleEffect(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.9 : 1.0)
                .animation(AppTheme.springMedium, value: currentInput.isEmpty)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(AppTheme.background)
        }
        .onAppear {
            refreshSuggestions()
        }
        .onChange(of: selectedAIMode) { _, _ in
            refreshSuggestions()
        }
    }
    
    private func refreshSuggestions() {
        // Seçili AI mode'a göre 4 rastgele öneri seç
        if let modeSuggestions = suggestionsByMode[selectedAIMode] {
            displayedSuggestions = Array(modeSuggestions.shuffled().prefix(4))
        } else {
            // Fallback: general suggestions
            displayedSuggestions = Array(suggestionsByMode[.general]!.shuffled().prefix(4))
        }
    }
    
    private func updateInputHeight() {
        let textHeight = calculateTextHeight(for: currentInput)
        let newHeight = max(minHeight, min(textHeight + 24, maxHeight))
        
        withAnimation(AppTheme.springMedium) {
            inputHeight = newHeight
        }
    }
    
    private func calculateTextHeight(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 16, weight: .regular)
        let maxWidth = UIScreen.main.bounds.width - 120
        let size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingRect = text.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingRect.height)
    }
}

#Preview {
    SimpleFluidInput(
        currentInput: .constant(""),
        onSend: {},
        isLoading: false,
        keyboardHeight: .constant(0),
        messages: .constant([]),
        selectedAIMode: .constant(.general)
    )
    .padding()
    .background(AppTheme.background)
}
