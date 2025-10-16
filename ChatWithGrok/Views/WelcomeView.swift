import SwiftUI

struct WelcomeView: View {
    @Binding var messages: [Message]
    @Binding var currentInput: String
    @Binding var showingModeSelector: Bool
    @AppStorage("userName") private var userName = ""
    @AppStorage("selectedAIMode") private var storedModeRaw: String = AIMode.general.rawValue
    @State private var animateCards = false
    @State private var animateHeader = false
    private let uiScale: CGFloat = 0.92
    
    private let quickActions: [QuickActionItem] = [
        QuickActionItem(
            icon: "sparkles",
            title: "Creative Ideas",
            detail: "Brainstorm and innovate",
            gradient: [Color(red: 0.45, green: 0.4, blue: 1.0), Color(red: 0.6, green: 0.35, blue: 0.95)],
            prompt: "Let's brainstorm three creative ideas for my next side project."
        ),
        QuickActionItem(
            icon: "doc.text.fill",
            title: "Summarize",
            detail: "Quick insights from text",
            gradient: [Color(red: 0.2, green: 0.7, blue: 0.9), Color(red: 0.1, green: 0.6, blue: 0.95)],
            prompt: "Summarize the following notes into key takeaways:"
        ),
        QuickActionItem(
            icon: "brain.head.profile",
            title: "Coach",
            detail: "Personal productivity guide",
            gradient: [Color(red: 0.95, green: 0.4, blue: 0.5), Color(red: 0.9, green: 0.3, blue: 0.6)],
            prompt: "Help me plan a productive schedule for today with three focus tasks."
        ),
        QuickActionItem(
            icon: "wand.and.stars",
            title: "Write",
            detail: "Draft emails and content",
            gradient: [Color(red: 0.3, green: 0.8, blue: 0.6), Color(red: 0.2, green: 0.7, blue: 0.5)],
            prompt: "Draft a friendly email to reconnect with an old colleague."
        )
    ]
    
    private let promptSuggestions: [PromptSuggestion] = [
        PromptSuggestion(text: "Explain complex topics simply", icon: "lightbulb.fill"),
        PromptSuggestion(text: "Review and improve code", icon: "chevron.left.forwardslash.chevron.right"),
        PromptSuggestion(text: "Plan marketing strategy", icon: "chart.line.uptrend.xyaxis"),
        PromptSuggestion(text: "Generate creative names", icon: "sparkle.magnifyingglass")
    ]
    
    private var activeMode: AIMode {
        AIMode(rawValue: storedModeRaw) ?? .general
    }
    
    var body: some View {
        ZStack {
            modernBackground
            VStack(spacing: 24) {
                Spacer(minLength: 0)
                modernHeroSection
                minimalPinnedChats
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 620,
                   maxHeight: .infinity,
                   alignment: .center)
            .scaleEffect(uiScale)
        }
        .onAppear {
            withAnimation(AppTheme.springSlow.delay(0.1)) {
                animateHeader = true
            }
            withAnimation(AppTheme.springSlow.delay(0.2)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Modern Background
    private var modernBackground: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            // Animated gradient orbs
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.accent.opacity(0.15), AppTheme.accent.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -100, y: -150)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.12), Color.blue.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: geo.size.width - 100, y: geo.size.height - 200)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Modern Hero Section
    private var modernHeroSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Greeting
            VStack(alignment: .leading, spacing: 10) {
                Text(getGreeting())
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.textPrimary, AppTheme.textPrimary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(animateHeader ? 1 : 0)
                    .offset(y: animateHeader ? 0 : 20)
                
                Text("What would you like to explore today?")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .opacity(animateHeader ? 1 : 0)
                    .offset(y: animateHeader ? 0 : 20)
            }
            
            // Active Mode Card - Ultra Modern Design
            Button(action: {
                showingModeSelector = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                HStack(spacing: 14) {
                    // Gradient Icon Container
                    ZStack {
                        LinearGradient(
                            colors: [
                                AppTheme.accent,
                                AppTheme.accent.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .frame(width: 56, height: 56)
                        .shadow(color: AppTheme.accent.opacity(0.25), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: activeMode.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 7) {
                            Text(activeMode.rawValue)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.accent)
                        }
                        
                        Text(activeMode.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Modern Arrow with Background
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                    }
                }
                .padding(12)
                .background(Color.clear)
                .liquidGlass(.chip, tint: AppTheme.accent, tintOpacity: 0.06)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .opacity(animateHeader ? 1 : 0)
            .offset(y: animateHeader ? 0 : 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Minimal Pinned Chats (Liquid Glass)
    private var minimalPinnedChats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pinned Chats")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .textCase(.uppercase)
                .kerning(0.5)

            let pinnedIds = StorageManager.shared.loadPinnedIdentifiers()
            let allChats = StorageManager.shared.loadAllChats()
            let pinned = allChats.filter { chat in
                if let id = StorageManager.shared.identifier(for: chat) { return pinnedIds.contains(id) }
                return false
            }

            if pinned.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "pin.slash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                    Text("No pinned chats yet")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.clear)
                .liquidGlass(.chip, tint: AppTheme.accent, tintOpacity: 0.06)
            } else {
                VStack(spacing: 8) {
                    ForEach(pinned.prefix(3), id: \.[0].id) { chat in
                        Button(action: {
                            // Load selected pinned chat into current session via Notification
                            NotificationCenter.default.post(name: Notification.Name("LoadPinnedChat"), object: chat)
                        }) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "pin.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.accent)
                                    .padding(.top, 2)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chat.first?.content ?? "Untitled Chat")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .lineLimit(1)
                                    if let last = chat.last {
                                        Text(last.content)
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.textSecondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer(minLength: 8)
                                if let last = chat.last {
                                    Text(DateFormatter.yyyyMMdd.string(from: last.timestamp))
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.subtleText)
                                }
                            }
                            .padding(12)
                            .background(Color.clear)
                            .liquidGlass(.card, tint: AppTheme.accent, tintOpacity: 0.05)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Modern Suggestions Section
    private var modernSuggestionsSection: some View {
            VStack(alignment: .leading, spacing: 16) {
            Text("Try Asking")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .textCase(.uppercase)
                .kerning(0.5)
            
            VStack(spacing: 8) {
                ForEach(Array(promptSuggestions.enumerated()), id: \.element.id) { index, suggestion in
                        ModernPromptChip(suggestion: suggestion) {
                        handlePromptSuggestion(suggestion.text)
                    }
                    .opacity(animateCards ? 1 : 0)
                    .offset(x: animateCards ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.3 + Double(index) * 0.05), value: animateCards)
                }
            }
        }
    }
    
    private func handleQuickAction(_ prompt: String) {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else { return }
        
        let userMessage = Message(content: trimmedPrompt, isUser: true)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            messages.append(userMessage)
            messages.append(Message(content: "", isUser: false, isLoading: true))
        }
        
        currentInput = ""
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(
                name: Notification.Name("SendMessageFromTip"),
                object: trimmedPrompt
            )
        }
    }
    
    private func handlePromptSuggestion(_ prompt: String) {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else { return }
        
        currentInput = trimmedPrompt
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userName.isEmpty ? "" : ", \(userName)"
        
        switch hour {
        case 5..<12:
            return "Good morning\(name)"
        case 12..<17:
            return "Good afternoon\(name)"
        case 17..<22:
            return "Good evening\(name)"
        default:
            return "Good night\(name)"
        }
    }
}

// MARK: - Supporting Models

private struct PromptSuggestion: Identifiable {
    let id = UUID()
    let text: String
    let icon: String
}

private struct QuickActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
    let gradient: [Color]
    let prompt: String
}

// MARK: - Modern Components

private struct ModernQuickActionCard: View {
    let action: QuickActionItem
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 14) {
                // Compact Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: action.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: action.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: action.gradient[0].opacity(0.25), radius: 6, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text(action.detail)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.controlBackground.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppTheme.outline.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct ModernPromptChip: View {
    let suggestion: PromptSuggestion
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 12) {
                Image(systemName: suggestion.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 28, height: 28)
                
                Text(suggestion.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.controlBackground.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppTheme.outline.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Button Style

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    WelcomeView(messages: .constant([]), currentInput: .constant(""), showingModeSelector: .constant(false))
} 