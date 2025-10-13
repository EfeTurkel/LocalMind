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
                        LazyVGrid(columns: columns, spacing: 18) {
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
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.accent.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: AppTheme.accent.opacity(0.3), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 16)
                .padding(.bottom, 20)
                .background(.regularMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: -2)
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
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(modeBadgeTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(accentColor.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(accentColor.opacity(0.16))
                        .clipShape(Capsule())
                        .matchedGeometryEffect(id: "badge-\(mode.rawValue)", in: namespace)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white, accentColor)
                            .symbolRenderingMode(.palette)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(accentColor.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: accentColor.opacity(0.35), radius: 12, x: 0, y: 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mode.rawValue)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                            Text(mode.description)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Text(examplePrompt)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(accentColor)
                        .lineLimit(2)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.65),
                                Color.white.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(accentColor.opacity(isSelected ? 0.12 : 0.06))
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(isSelected ? accentColor.opacity(0.6) : AppTheme.outline.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.36, dampingFraction: 0.82), value: isSelected)
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