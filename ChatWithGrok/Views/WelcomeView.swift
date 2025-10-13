import SwiftUI

struct WelcomeView: View {
    @Binding var messages: [Message]
    @Binding var currentInput: String
    @Binding var showingModeSelector: Bool
    @AppStorage("userName") private var userName = ""
    @AppStorage("selectedAIMode") private var storedModeRaw: String = AIMode.general.rawValue
    
    private let quickActions: [QuickActionItem] = [
        QuickActionItem(
            icon: "sparkles",
            title: "Brainstorm with Grok",
            detail: "Generate ideas or plans in seconds",
            prompt: "Let's brainstorm three creative ideas for my next side project."
        ),
        QuickActionItem(
            icon: "checklist",
            title: "Summarize notes",
            detail: "Turn long text into bullet points",
            prompt: "Summarize the following notes into key takeaways:"
        ),
        QuickActionItem(
            icon: "figure.walk.motion",
            title: "Daily coach",
            detail: "Plan habits and focus areas",
            prompt: "Help me plan a productive schedule for today with three focus tasks."
        )
    ]
    
    private let promptSuggestions: [String] = [
        "Draft a friendly email to reconnect with an old colleague.",
        "Explain how large language models work so a teenager can understand.",
        "Review this code and suggest improvements:",
        "Outline a marketing plan for a new mobile app."
    ]
    
    private var activeMode: AIMode {
        AIMode(rawValue: storedModeRaw) ?? .general
    }
    
    var body: some View {
        ZStack {
            background
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    heroCard
                    Divider()
                        .background(AppTheme.outline.opacity(0.3))
                    quickActionsSection
                    suggestionsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 580)
            }
        }
    }
    
    private var background: some View {
        LinearGradient(
            colors: [
                AppTheme.background,
                AppTheme.secondaryBackground.opacity(0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.controlBackground.opacity(0.9))
                        .frame(width: 64, height: 64)
                        .overlay(Circle().stroke(AppTheme.outline.opacity(0.6)))
                        .shadow(color: AppTheme.accent.opacity(0.18), radius: 16, x: 0, y: 12)
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(userName.isEmpty ? "Welcome" : getGreeting(for: userName))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("A single, calm workspace for your ideas.")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("How can I help?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Type below or pick one of the shortcuts to jump straight in.")
                    .font(.system(size: 13.5))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            modeSummary
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.6, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            AppTheme.accent.opacity(0.22),
                            AppTheme.secondaryBackground.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.6, style: .continuous))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.6, style: .continuous)
                .stroke(AppTheme.outline.opacity(0.55))
        )
        .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 12)
    }
    
    private var modeSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Active profile")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            
            Button(action: {
                showingModeSelector = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                HStack(alignment: .center, spacing: 14) {
                    Image(systemName: activeMode.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activeMode.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text(activeMode.description)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(14)
                .background(AppTheme.controlBackground.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .stroke(AppTheme.outline.opacity(0.4))
                )
            }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick actions")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            
            VStack(spacing: 12) {
                ForEach(quickActions) { action in
                    QuickActionButton(action: action) {
                        handleQuickAction(action.prompt)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular prompts")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(promptSuggestions, id: \.self) { prompt in
                    PromptChip(text: prompt) {
                        handlePromptSuggestion(prompt)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    
    private func getGreeting(for name: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12:
            return "Good morning, \(name)!"
        case 12..<18:
            return "Good afternoon, \(name)!"
        case 18..<24:
            return "Good evening, \(name)!"
        default:
            return "Good night, \(name)!"
        }
    }
}

private struct QuickActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
    let prompt: String
}

private struct QuickActionButton: View {
    let action: QuickActionItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.controlBackground.opacity(0.92))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.outline.opacity(0.4))
                        )
                        .frame(width: 54, height: 54)
                    Image(systemName: action.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(action.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(action.detail)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.2, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.2, style: .continuous))
    }
}

private struct PromptChip: View {
    let text: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "text.badge.plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.controlBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .stroke(AppTheme.outline.opacity(0.5))
                )
        )
    }
}

#Preview {
    WelcomeView(messages: .constant([]), currentInput: .constant(""), showingModeSelector: .constant(false))
} 