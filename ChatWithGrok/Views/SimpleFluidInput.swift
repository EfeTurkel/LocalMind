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
    
    @State private var displayedSuggestions: [(text: String, icon: String)] = []
    
    private let suggestionsByMode: [AIMode: [(text: String, icon: String)]] = [
        .general: [
            ("Explain complex topics simply", "questionmark.circle"),
            ("Summarize this article", "doc.text"),
            ("Translate to another language", "globe"),
            ("Fix grammar mistakes", "textformat.abc"),
            ("Suggest gift ideas", "gift"),
            ("Create a workout plan", "figure.strengthtraining.traditional"),
            ("Plan a healthy meal", "fork.knife"),
            ("Suggest productivity tips", "lightbulb"),
            ("Write motivational quote", "quote.bubble"),
            ("Create checklist template", "checklist")
        ],
        .coding: [
            ("Review and improve code", "arrow.up.circle"),
            ("Debug this code snippet", "ant"),
            ("Explain algorithm complexity", "questionmark.circle"),
            ("Refactor legacy code", "arrow.triangle.2.circlepath"),
            ("Write unit tests", "checkmark.circle"),
            ("Optimize database query", "chart.bar"),
            ("Design API endpoints", "network"),
            ("Fix security vulnerabilities", "shield"),
            ("Create code documentation", "doc.text"),
            ("Suggest best practices", "star"),
            ("Design system architecture", "building.2"),
            ("Implement design pattern", "puzzlepiece")
        ],
        .creative: [
            ("Generate creative names", "sparkles"),
            ("Write social media captions", "bubble.left.and.bubble.right"),
            ("Generate story ideas", "book"),
            ("Write video script", "video"),
            ("Design logo concept", "paintbrush"),
            ("Create presentation outline", "presentation"),
            ("Design color palette", "paintpalette"),
            ("Generate slogan options", "quote.bubble"),
            ("Write blog post ideas", "doc.text"),
            ("Design brand strategy", "building.2"),
            ("Create character backstory", "person"),
            ("Write catchy headlines", "textformat")
        ],
        .academic: [
            ("Create a study schedule", "calendar"),
            ("Suggest book recommendations", "book"),
            ("Create quiz questions", "questionmark.circle"),
            ("Create learning roadmap", "map"),
            ("Create mind map", "brain"),
            ("Write essay outline", "doc.text"),
            ("Explain scientific concepts", "atom"),
            ("Create bibliography", "list.bullet"),
            ("Summarize research paper", "doc.text"),
            ("Create flashcards", "rectangle.stack"),
            ("Write thesis statement", "textformat"),
            ("Analyze historical events", "chart.bar")
        ],
        .math: [
            ("Solve complex equations", "function"),
            ("Explain mathematical proofs", "questionmark.circle"),
            ("Create practice problems", "plus.circle"),
            ("Visualize data patterns", "chart.bar"),
            ("Calculate statistics", "chart.line.uptrend.xyaxis"),
            ("Explain calculus concepts", "infinity"),
            ("Solve physics problems", "atom"),
            ("Create formula sheet", "doc.text"),
            ("Analyze probability", "percent"),
            ("Design experiment", "flask"),
            ("Interpret scientific data", "chart.bar"),
            ("Model mathematical systems", "building.2")
        ],
        .business: [
            ("Plan marketing strategy", "chart.bar"),
            ("Draft business proposal", "doc.text"),
            ("Write a professional email", "envelope"),
            ("Write a cover letter", "doc.text"),
            ("Create presentation outline", "presentation"),
            ("Write resume bullet points", "list.bullet"),
            ("Write meeting agenda", "calendar"),
            ("Suggest career advice", "lightbulb"),
            ("Create budget plan", "dollarsign.circle"),
            ("Plan event timeline", "calendar"),
            ("Write interview questions", "questionmark.circle"),
            ("Suggest SEO keywords", "magnifyingglass"),
            ("Design workflow process", "arrow.triangle.branch"),
            ("Write sales pitch", "megaphone"),
            ("Analyze market trends", "chart.line.uptrend.xyaxis"),
            ("Create business plan", "building.2")
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
                let pages: [[(text: String, icon: String)]] = stride(from: 0, to: items.count, by: 2).map { idx in
                    Array(items[idx..<min(idx+2, items.count)])
                }
                VStack(spacing: 8) {
                    TabView {
                        ForEach(0..<pages.count, id: \.self) { pageIndex in
                            HStack(spacing: 10) {
                                ForEach(pages[pageIndex], id: \.text) { suggestion in
                                    Button(action: {
                                        currentInput = suggestion.text
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }) {
                                        HStack(alignment: .center, spacing: 10) {
                                            Image(systemName: suggestion.icon)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.accent)
                                            Text(suggestion.text)
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
