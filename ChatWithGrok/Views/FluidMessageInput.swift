import SwiftUI

struct FluidMessageInput: View {
    @Binding var currentInput: String
    let onSend: () -> Void
    let isLoading: Bool
    @FocusState private var isFocused: Bool
    @State private var inputHeight: CGFloat = 44
    @State private var isExpanded: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var animationPhase: CGFloat = 0
    @State private var waveOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = 0
    @State private var typingIndicator: Bool = false
    @State private var showSuggestions: Bool = false
    @State private var animationTimer: Timer?
    @State private var pulseTimer: Timer?
    @Environment(\.colorScheme) private var colorScheme
    
    private let minHeight: CGFloat = 44
    private let maxHeight: CGFloat = 120
    private let cornerRadius: CGFloat = 22
    
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
            // Quick suggestions when focused
            if showSuggestions && isFocused {
                FluidSuggestionsView(
                    onSuggestionTap: { suggestion in
                        currentInput = suggestion
                        showSuggestions = false
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                // Fluid Input Container
                ZStack(alignment: .trailing) {
                // Background with fluid animation
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppTheme.elevatedBackground)
                    
                    fluidBackground
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(fluidBorder, lineWidth: isFocused ? 2 : 1)
                )
                    .frame(height: inputHeight)
                    .scaleEffect(fluidScale)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFocused)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: inputHeight)
                
                // Text Input
                HStack(spacing: 12) {
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
                        .onChange(of: isFocused) { _, focused in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isExpanded = focused
                                showSuggestions = focused
                            }
                            // Restart animation when focus changes
                            if focused {
                                startFluidAnimation()
                            } else {
                                stopFluidAnimation()
                            }
                        }
                    
                    // Character count with fluid animation
                    if !currentInput.isEmpty {
                        Text("\(currentInput.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.6))
                            .padding(.trailing, 18)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                
                // Fluid send button
                fluidSendButton
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(fluidContainerBackground)
            .onAppear {
                startFluidAnimation()
            }
            .onDisappear {
                stopFluidAnimation()
            }
        }
    }
    
    // MARK: - Fluid Background
    private var fluidBackground: some View {
        LinearGradient(
            colors: [
                AppTheme.elevatedBackground,
                AppTheme.elevatedBackground.opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Simple shimmer effect only when focused
            isFocused ? 
            LinearGradient(
                colors: [
                    Color.clear,
                    AppTheme.accent.opacity(0.1),
                    Color.clear
                ],
                startPoint: .init(x: shimmerOffset - 0.3, y: 0),
                endPoint: .init(x: shimmerOffset + 0.3, y: 0)
            )
            .opacity(0.3)
            : nil
        )
    }
    
    // MARK: - Fluid Border
    private var fluidBorder: some ShapeStyle {
        LinearGradient(
            colors: isFocused ? [
                AppTheme.accent.opacity(0.8),
                AppTheme.accent.opacity(0.4)
            ] : [
                AppTheme.outline.opacity(0.6),
                AppTheme.outline.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Fluid Scale Effect
    private var fluidScale: CGFloat {
        let baseScale: CGFloat = 1.0
        let focusScale: CGFloat = isFocused ? 1.02 : 1.0
        let waveScale: CGFloat = 1.0 + (sin(animationPhase * 2) * 0.005)
        let pulseScale: CGFloat = self.pulseScale
        return baseScale * focusScale * waveScale * pulseScale
    }
    
    // MARK: - Fluid Send Button
    private var fluidSendButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            onSend()
        }) {
            ZStack {
                // Fluid button background
                Circle()
                    .fill(fluidButtonBackground)
                    .frame(width: 36, height: 36)
                    .scaleEffect(fluidButtonScale)
                    .shadow(
                        color: fluidButtonShadow,
                        radius: fluidButtonShadowRadius,
                        x: 0,
                        y: fluidButtonShadowOffset
                    )
                
                // Send icon with fluid animation
                Image(systemName: isLoading ? "hourglass" : "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(fluidButtonIconColor)
                    .rotationEffect(.degrees(fluidButtonRotation))
                    .scaleEffect(fluidButtonIconScale)
            }
        }
        .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        .padding(.trailing, 6)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFocused)
    }
    
    // MARK: - Fluid Button Properties
    private var fluidButtonBackground: some ShapeStyle {
        if currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading {
            return LinearGradient(
                colors: [AppTheme.controlBackground, AppTheme.controlBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    AppTheme.accent,
                    AppTheme.accent.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var fluidButtonScale: CGFloat {
        let baseScale: CGFloat = 1.0
        let pressScale: CGFloat = 0.95
        let waveScale: CGFloat = 1.0 + (sin(animationPhase * 3) * 0.01)
        return baseScale * pressScale * waveScale
    }
    
    private var fluidButtonShadow: Color {
        if currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .clear
        } else {
            return AppTheme.accent.opacity(0.3)
        }
    }
    
    private var fluidButtonShadowRadius: CGFloat {
        return isFocused ? 12 : 8
    }
    
    private var fluidButtonShadowOffset: CGFloat {
        return isFocused ? 6 : 4
    }
    
    private var fluidButtonIconColor: Color {
        if currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading {
            return AppTheme.textSecondary
        } else {
            return .white
        }
    }
    
    private var fluidButtonRotation: Double {
        return isLoading ? 360 : 0
    }
    
    private var fluidButtonIconScale: CGFloat {
        return isLoading ? 1.1 : 1.0
    }
    
    // MARK: - Fluid Container Background
    private var fluidContainerBackground: some View {
        ZStack {
            AppTheme.background
            
            // Subtle fluid gradient overlay
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
    }
    
    // MARK: - Helper Functions
    private func updateInputHeight() {
        let textHeight = calculateTextHeight(for: currentInput)
        let newHeight = max(minHeight, min(textHeight + 24, maxHeight))
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            inputHeight = newHeight
        }
    }
    
    private func calculateTextHeight(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 16, weight: .regular)
        let maxWidth = UIScreen.main.bounds.width - 120 // Account for padding and button
        let size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingRect = text.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingRect.height)
    }
    
    private func startFluidAnimation() {
        // Clean up existing timers
        stopFluidAnimation()
        
        // Simplified animation - only when focused
        if isFocused {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    animationPhase += 0.2
                    waveOffset += 0.1
                    shimmerOffset += 0.05
                }
            }
        }
    }
    
    private func stopFluidAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        pulseTimer?.invalidate()
        pulseTimer = nil
    }
}

// MARK: - Fluid Wave Overlay
struct FluidWaveOverlay: View {
    let phase: CGFloat
    let waveOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Create fluid wave path with reduced complexity
                let step = max(1, Int(width / 50)) // Reduce number of points
                
                for x in stride(from: 0, through: Int(width), by: step) {
                    let xFloat = CGFloat(x)
                    let wave1 = sin((xFloat / width) * .pi * 2 + phase + waveOffset) * 2
                    let wave2 = sin((xFloat / width) * .pi * 4 + phase * 1.5 + waveOffset) * 1
                    
                    let y = height * 0.5 + wave1 + wave2
                    
                    if x == 0 {
                        path.move(to: CGPoint(x: xFloat, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: xFloat, y: y))
                    }
                }
                
                // Fill the wave area
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(AppTheme.accent.opacity(0.1))
        }
    }
}

// MARK: - Shimmer Overlay
struct ShimmerOverlay: View {
    let offset: CGFloat
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.clear,
                AppTheme.accent.opacity(0.3),
                Color.clear
            ],
            startPoint: .init(x: offset - 0.3, y: 0),
            endPoint: .init(x: offset + 0.3, y: 0)
        )
        .mask(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

// MARK: - Fluid Suggestions View
struct FluidSuggestionsView: View {
    let onSuggestionTap: (String) -> Void
    @State private var animationOffset: CGFloat = 0
    @State private var animationTimer: Timer?
    
    private let suggestions = [
        "Write code for",
        "Explain how to",
        "Help me understand",
        "Generate a",
        "Debug this code",
        "Translate to"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                    FluidSuggestionChip(
                        text: suggestion,
                        animationOffset: animationOffset + CGFloat(index) * 0.1
                    ) {
                        onSuggestionTap(suggestion)
                    }
                }
            }
            .padding(.horizontal, 18)
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
        .onAppear {
            startSuggestionAnimation()
        }
        .onDisappear {
            stopSuggestionAnimation()
        }
    }
    
    private func startSuggestionAnimation() {
        // Simplified - no timer needed
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            animationOffset += 1.0
        }
    }
    
    private func stopSuggestionAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

// MARK: - Fluid Suggestion Chip
struct FluidSuggestionChip: View {
    let text: String
    let animationOffset: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(AppTheme.controlBackground.opacity(0.8))
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.outline.opacity(0.6), lineWidth: 1)
                        )
                        .scaleEffect(1.0 + sin(animationOffset) * 0.02)
                )
        }
        .buttonStyle(FluidButtonStyle())
    }
}

// MARK: - Fluid Button Style
struct FluidButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    FluidMessageInput(
        currentInput: .constant(""),
        onSend: {},
        isLoading: false
    )
    .padding()
    .background(AppTheme.background)
}
