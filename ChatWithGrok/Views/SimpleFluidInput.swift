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
            // Suggestions Panel (Liquid Glass) — paged, 2 per view, total up to 5
            if keyboardHeight == 0 && messages.isEmpty && currentInput.isEmpty {
                let items = Array(displayedSuggestions.prefix(5))
                let pages: [[String]] = stride(from: 0, to: items.count, by: 2).map { idx in
                    Array(items[idx..<min(idx+2, items.count)])
                }
                VStack(spacing: 8) {
                    TabView {
                        ForEach(0..<pages.count, id: \.self) { pageIndex in
                            HStack(spacing: 10) {
                                ForEach(pages[pageIndex], id: \.self) { suggestion in
                                    Button(action: {
                                        currentInput = suggestion
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }) {
                                        HStack(alignment: .center, spacing: 10) {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.accent)
                                            Text(suggestion)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                                .minimumScaleFactor(0.9)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(Color.clear)
                                        .liquidGlass(.chip, tint: AppTheme.accent, tintOpacity: AppPerformance.preferLightweightGlass ? 0.06 : 0.08)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                                // If only one item on the last page, keep layout balance with a spacer
                                if pages[pageIndex].count == 1 { Spacer(minLength: 10) }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 86)
                }
                .padding(.top, 6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Input Area
            HStack(alignment: .bottom, spacing: 12) {
                // Input Container
                ZStack(alignment: .trailing) {
                // Unified bar: rely on outer Liquid Glass; no inner background
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
                    
                    Spacer(minLength: 8)
                }
                
                // Send button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onSend()
                }) {
                    ZStack {
                        // Minimal icon inside unified bar
                        Image(systemName: isLoading ? "hourglass" : "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
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
                .padding(.trailing, 4)
                .scaleEffect(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.9 : 1.0)
                .animation(AppTheme.springMedium, value: currentInput.isEmpty)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.clear)
                    .liquidGlass(.toolbar, tint: AppTheme.accent, tintOpacity: AppPerformance.preferLightweightGlass ? 0.06 : 0.08)
            )
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
