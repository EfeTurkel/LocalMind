import SwiftUI

struct SimpleFluidInput: View {
    @Binding var currentInput: String
    let onSend: () -> Void
    let isLoading: Bool
    @FocusState private var isFocused: Bool
    @State private var inputHeight: CGFloat = 44
    
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
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
                
                // Text Input
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
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
                        
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
                                    : .spring(response: 0.3, dampingFraction: 0.7),
                                value: isLoading
                            )
                            .scaleEffect(isLoading ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
                    }
                }
                .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .padding(.trailing, 6)
                .scaleEffect(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentInput.isEmpty)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(AppTheme.background)
    }
    
    private func updateInputHeight() {
        let textHeight = calculateTextHeight(for: currentInput)
        let newHeight = max(minHeight, min(textHeight + 24, maxHeight))
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
        isLoading: false
    )
    .padding()
    .background(AppTheme.background)
}
