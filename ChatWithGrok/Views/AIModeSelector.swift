import SwiftUI

struct AIModeSelector: View {
    @Binding var selectedMode: AIMode
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedAIMode") private var storedModeRaw: String = AIMode.general.rawValue
    @Namespace private var selectionNamespace
    @State private var previewSelection: AIMode
    
    init(selectedMode: Binding<AIMode>) {
        self._selectedMode = selectedMode
        _previewSelection = State(initialValue: selectedMode.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                background
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        header
                        VStack(spacing: 18) {
                            ForEach(AIMode.allCases, id: \.self) { mode in
                                ModeCard(
                                    mode: mode,
                                    isSelected: previewSelection == mode,
                                    namespace: selectionNamespace
                                ) {
                                    previewSelection = mode
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, 32)
                    .padding(.bottom, 140)
                }
            }
            .navigationTitle("AI Profiles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppTheme.textSecondary)
                    .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use") {
                        applySelectionAndDismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            .tint(AppTheme.accent)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Text(previewSelection.description)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: applySelectionAndDismiss) {
                        Text("Use \(previewSelection.rawValue)")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.clear)
                            .background(AppTheme.controlBackground.opacity(0.3))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 16)
                .padding(.bottom, 20)
                .background(Color.clear)
                .background(AppTheme.controlBackground.opacity(0.3))
                .cornerRadius(12)
            }
        }
        .interactiveDismissDisabled(false)
    }
    
    private var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [
                GridItem(.flexible(), spacing: 18),
                GridItem(.flexible(), spacing: 18)
            ]
        } else {
            return [GridItem(.flexible(), spacing: 18)]
        }
    }
    
    private var horizontalPadding: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20
    }
    
    private var background: some View {
        LinearGradient(
            colors: [
                AppTheme.background.opacity(0.98),
                AppTheme.secondaryBackground.opacity(0.94)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose the vibe")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
                .transition(.opacity)
            Text("Pick a profile tailored for your current task. You can switch anytime.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func applySelectionAndDismiss() {
        selectedMode = previewSelection
        storedModeRaw = previewSelection.rawValue
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

private struct ModeCard: View {
    let mode: AIMode
    let isSelected: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(modeBadgeTitle)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .kerning(0.5)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(accentColor)
                        .clipShape(Capsule())
                        .matchedGeometryEffect(id: "badge-\(mode.rawValue)", in: namespace)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white, accentColor)
                            .symbolRenderingMode(.palette)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 14) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 58, height: 58)
                            .background(
                                LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(mode.rawValue)
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: 0x1a1a1a))
                            Text(mode.description)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.75) : Color(hex: 0x666666))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                        }
                    }
                    
                    Text(examplePrompt)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? accentColor.opacity(0.9) : accentColor)
                        .lineLimit(2)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(accentColor.opacity(colorScheme == .dark ? 0.15 : 0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clear)
            .background(AppTheme.controlBackground.opacity(isSelected ? 0.4 : 0.3))
            .cornerRadius(12)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
    
    private var accentColor: Color {
        switch mode {
        case .general: return Color(hex: 0x6C5CE7)
        case .coding: return Color(hex: 0x00C9A7)
        case .creative: return Color(hex: 0xF65A83)
        case .academic: return Color(hex: 0x54A0FF)
        case .math: return Color(hex: 0x10AC84)
        case .business: return Color(hex: 0xFDCB6E)
        }
    }
    
    private var modeBadgeTitle: String {
        switch mode {
        case .general: return "Balanced"
        case .coding: return "Developer"
        case .creative: return "Imaginative"
        case .academic: return "Scholar"
        case .math: return "Analytical"
        case .business: return "Strategist"
        }
    }
    
    private var examplePrompt: String {
        switch mode {
        case .general: return "“Help me plan my week with focus areas.”"
        case .coding: return "“Review this Swift function for edge cases.”"
        case .creative: return "“Draft a short story set on Mars.”"
        case .academic: return "“Summarize this research article objectively.”"
        case .math: return "“Solve and explain this calculus problem.”"
        case .business: return "“Outline a go-to-market checklist.”"
        }
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
} 