import SwiftUI

struct WelcomeView: View {
    @Binding var messages: [Message]
    @Binding var currentInput: String
    @Binding var showingModeSelector: Bool
    @AppStorage("userName") private var userName = ""
    @AppStorage("selectedAIMode") private var storedModeRaw: String = AIMode.general.rawValue
    @AppStorage("aiMemoryEnabled") private var aiMemoryEnabled = false
    @State private var animateCards = false
    @State private var animateHeader = false
    @State private var animateAIMemory = false
    @State private var showAIMemoryFeature = false
    @StateObject private var summaryManager = ChatSummaryManager()
    @State private var pinnedChats: [[Message]] = []
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
                aiMemoryFeatureCard
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
            withAnimation(AppTheme.springSlow.delay(0.3)) {
                animateAIMemory = true
            }
            
            // Load pinned chats
            loadPinnedChats()
            
            // Generate AI summaries for pinned chats
            Task {
                await generateAISummariesForPinnedChats()
            }
            
            // Show AI Memory feature if not enabled
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if !aiMemoryEnabled {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showAIMemoryFeature = true
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PinnedChatsUpdated"))) { _ in
            // Reload pinned chats when they are updated
            loadPinnedChats()
            
            // Regenerate AI summaries for updated pinned chats
            Task {
                await generateAISummariesForPinnedChats()
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
    
    // MARK: - AI Memory Feature Card
    private var aiMemoryFeatureCard: some View {
        Group {
            if !aiMemoryEnabled && showAIMemoryFeature {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        // Animated Brain Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .scaleEffect(animateAIMemory ? 1.0 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true), value: animateAIMemory)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.purple)
                                .scaleEffect(animateAIMemory ? 1.0 : 0.9)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateAIMemory)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("AI Memory Automatic")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.purple)
                                    .scaleEffect(animateAIMemory ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateAIMemory)
                            }
                            
                            Text("AI learns from your conversations and creates personalized responses")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                aiMemoryEnabled = true
                                showAIMemoryFeature = false
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 80, height: 36)
                                
                                Text("Enable")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Feature Benefits
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureBenefitRow(
                            icon: "person.crop.circle.badge.checkmark",
                            title: "Personalized Responses",
                            description: "AI remembers your preferences and style"
                        )
                        
                        FeatureBenefitRow(
                            icon: "arrow.clockwise",
                            title: "Continuous Learning",
                            description: "Gets smarter with every conversation"
                        )
                        
                        FeatureBenefitRow(
                            icon: "lock.shield",
                            title: "Privacy First",
                            description: "All data stays on your device"
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.08),
                                    Color.blue.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .purple.opacity(0.15), radius: 20, x: 0, y: 10)
                .opacity(showAIMemoryFeature ? 1 : 0)
                .scaleEffect(showAIMemoryFeature ? 1 : 0.9)
                .offset(y: showAIMemoryFeature ? 0 : 20)
            }
        }
    }
    
    // MARK: - Minimal Pinned Chats (Liquid Glass)
    private var minimalPinnedChats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pinned Chats")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .textCase(.uppercase)
                .kerning(0.5)

            if pinnedChats.isEmpty {
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
                    ForEach(pinnedChats.prefix(3), id: \.[0].id) { chat in
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
                                    Text(getChatTitle(for: chat))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .lineLimit(1)
                                    Text(getChatDescription(for: chat))
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .lineLimit(1)
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
    
    // MARK: - Helper Functions for AI Summaries
    
    private func getChatTitle(for chat: [Message]) -> String {
        let chatId = getChatId(chat)
        return summaryManager.getSummary(for: chatId)?.title ?? chat.chatTitle
    }
    
    private func getChatDescription(for chat: [Message]) -> String {
        let chatId = getChatId(chat)
        return summaryManager.getSummary(for: chatId)?.description ?? chat.chatDescription
    }
    
    private func getChatId(_ chat: [Message]) -> String {
        guard let firstMessage = chat.first else { return UUID().uuidString }
        return "\(firstMessage.timestamp.timeIntervalSince1970)"
    }
    
    private func loadPinnedChats() {
        let pinnedIds = StorageManager.shared.loadPinnedIdentifiers()
        let allChats = StorageManager.shared.loadAllChats()
        pinnedChats = allChats.filter { chat in
            if let id = StorageManager.shared.identifier(for: chat) { 
                return pinnedIds.contains(id) 
            }
            return false
        }
    }
    
    private func generateAISummariesForPinnedChats() async {
        let geminiAPIKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        guard !geminiAPIKey.isEmpty else { return }
        
        for chat in pinnedChats {
            let chatId = getChatId(chat)
            
            // Skip if we already have a summary for this chat in memory
            if summaryManager.getSummary(for: chatId) != nil { continue }
            
            // Check if we have saved AI summary
            if let savedSummary = getSavedAISummary(chatId: chatId) {
                summaryManager.updateSummary(for: chatId, title: savedSummary.title, description: savedSummary.description)
                continue
            }
            
            let summary = await chat.generateAISummaryAsync()
            summaryManager.updateSummary(for: chatId, title: summary.title, description: summary.description)
        }
    }
    
    private func getSavedAISummary(chatId: String) -> (title: String, description: String)? {
        let key = "aiSummary_\(chatId)"
        guard let summaryData = UserDefaults.standard.dictionary(forKey: key),
              let title = summaryData["title"] as? String,
              let description = summaryData["description"] as? String else {
            return nil
        }
        return (title: title, description: description)
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

// MARK: - Feature Benefit Row

private struct FeatureBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.purple)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
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