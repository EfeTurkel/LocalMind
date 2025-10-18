import SwiftUI

struct SidebarContainer: View {
    @Binding var isOpen: Bool
    @Binding var selectedAIMode: AIMode
    @Binding var showingModeSelector: Bool
    @Binding var showingUpgradeView: Bool
    @Binding var showingChatHistory: Bool
    @Binding var showingSettings: Bool
    @Binding var showingProfile: Bool
    @Binding var searchText: String
    @Binding var savedChats: [[Message]]
    @Binding var pinnedIdentifiers: Set<Double>

    let isIncognitoMode: Bool
    let dailyMessageCount: Int
    let FREE_DAILY_LIMIT: Int
    let onSelectChat: ([Message]) -> Void
    let onDeleteChat: ([Message]) -> Void
    let onReturnHome: () -> Void
    let onToggleIncognito: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var summaryManager = ChatSummaryManager()
    
    // Helper functions for chat titles and descriptions
    private func getChatTitle(for chat: [Message]) -> String {
        let chatId = getChatId(chat)
        return summaryManager.getSummary(for: chatId)?.title ?? chat.chatTitle
    }
    
    private func getChatDescription(for chat: [Message]) -> String {
        let chatId = getChatId(chat)
        return summaryManager.getSummary(for: chatId)?.description ?? chat.chatDescription
    }
    
    private func getChatId(_ chat: [Message]) -> String {
        // Create a unique ID for the chat based on first message timestamp
        guard let firstMessage = chat.first else { return UUID().uuidString }
        return "\(firstMessage.timestamp.timeIntervalSince1970)"
    }
    
    private func generateAISummariesForAllChats() async {
        let geminiAPIKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        guard !geminiAPIKey.isEmpty else { return }
        
        for chat in savedChats {
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

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                header
                    .padding(.top, 0)
                
                ScrollView(.vertical, showsIndicators: false) {
                    scrollContent
                        .padding(.trailing, 4)
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 12)
                }
            }
            .padding(.top, 0)
            .padding(.bottom, 0)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clear)
            .background(AppTheme.elevatedBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(AppTheme.outline.opacity(0.1), lineWidth: 1)
            )
            .onAppear {
                // Ensure keyboard is dismissed when sidebar is presented
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
                // Generate AI summaries for all chats
                Task {
                    await generateAISummariesForAllChats()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("LockMind")
                    .font(AppTypography.largeTitle)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isOpen = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(10)
                        .background(AppTheme.controlBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 16)

            HStack(spacing: 16) {
                ModeChip(title: selectedAIMode.rawValue, icon: selectedAIMode.icon) {
                    showingModeSelector = true
                }

            }

            if (FREE_DAILY_LIMIT - dailyMessageCount) < 5 {
                DailyLimitChip(remaining: FREE_DAILY_LIMIT - dailyMessageCount)
            }

            QuickActionsRow(
                onUpgrade: { showingUpgradeView = true },
                onHistory: { showingChatHistory = true },
                onSettings: { showingSettings = true },
                onProfile: { showingProfile = true },
                onHome: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isOpen = false
                    }
                    onReturnHome()
                }
            )

            SearchField(text: $searchText)
        }
    }

    private var scrollContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isIncognitoMode {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onToggleIncognito()
                    }
                }) {
                    BannerView(
                        icon: "eye.slash.fill",
                        title: "Incognito mode",
                        subtitle: "Chats won't be saved while active",
                        tint: Color.orange.opacity(0.85)
                    )
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Recent Chats")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)

                if filteredChats().isEmpty {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("No saved chats yet")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(AppTheme.controlBackground.opacity(0.3))
                    .cornerRadius(8)
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredChats().indices, id: \.self) { index in
                            let chat = filteredChats()[index]
                            chatRow(chat)
                        }
                    }
                }
            }
        }
    }

    private var incognitoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? AppTheme.textPrimary : .white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Incognito mode")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? AppTheme.textPrimary : .white)
                Text("Chats won't be saved while active")
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .dark ? AppTheme.textSecondary : Color.white.opacity(0.7))
            }
        }
        .padding(12)
        .background(colorScheme == .dark ? AppTheme.controlBackground : Color.orange.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(colorScheme == .dark ? AppTheme.outline : Color.orange.opacity(0.9))
        )
    }

    private func chatRow(_ chat: [Message]) -> some View {
        let isPinned = isChatPinned(chat)

        return Button(action: {
            onSelectChat(chat)
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    if isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(getChatTitle(for: chat))
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(getChatDescription(for: chat))
                            .font(.system(size: 12, weight: .regular))
                            .lineLimit(1)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                HStack(spacing: 8) {
                    if let last = chat.last {
                        Text(formatDate(last.timestamp))
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.subtleText)
                    }
                    Text("\(chat.count) messages")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.subtleText)
                }
            }
            .padding(14)
            .background(AppTheme.controlBackground.opacity(0.3))
            .cornerRadius(8)
            .contextMenu {
                Button(role: .destructive) {
                    onDeleteChat(chat)
                    savedChats = StorageManager.shared.loadAllChats()
                    pinnedIdentifiers = StorageManager.shared.loadPinnedIdentifiers()
                } label: {
                    Label("Delete", systemImage: "trash")
                }

                Button(isPinned ? "Unpin" : "Pin") {
                    togglePin(chat)
                    pinnedIdentifiers = StorageManager.shared.loadPinnedIdentifiers()
                }
            }
        }
    }

    private func filteredChats() -> [[Message]] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return sortedChats(savedChats)
        }

        let filtered = savedChats.filter { chat in
            // Search in message content
            let contentMatch = chat.contains { $0.content.localizedCaseInsensitiveContains(query) }
            
            // Search in AI-generated title and description
            let titleMatch = getChatTitle(for: chat).localizedCaseInsensitiveContains(query)
            let descriptionMatch = getChatDescription(for: chat).localizedCaseInsensitiveContains(query)
            
            return contentMatch || titleMatch || descriptionMatch
        }
        return sortedChats(filtered)
    }

    private func sortedChats(_ chats: [[Message]]) -> [[Message]] {
        let pinned = chats.filter { isChatPinned($0) }
        let others = chats.filter { !isChatPinned($0) }
        return pinned + others
    }

    private func isChatPinned(_ chat: [Message]) -> Bool {
        guard let identifier = StorageManager.shared.identifier(for: chat) else { return false }
        return pinnedIdentifiers.contains(identifier)
    }

    private func togglePin(_ chat: [Message]) {
        guard let identifier = StorageManager.shared.identifier(for: chat) else { return }
        let willPin = !pinnedIdentifiers.contains(identifier)
        StorageManager.shared.setPinned(willPin, for: chat)
        if willPin {
            pinnedIdentifiers.insert(identifier)
        } else {
            pinnedIdentifiers.remove(identifier)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

}

struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)
            TextField("Search chats", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(AppTheme.textPrimary)
                .autocapitalization(.none)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.clear)
        .liquidGlass(.chip, tint: AppTheme.accent, tintOpacity: 0.07)
    }
}

struct QuickActionsRow: View {
    let onUpgrade: () -> Void
    let onHistory: () -> Void
    let onSettings: () -> Void
    let onProfile: () -> Void
    let onHome: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            quickIcon("house.fill", action: onHome)
            quickIcon("person.crop.circle", action: onProfile)
            quickIcon("sparkles", action: onUpgrade)
            quickIcon("clock", action: onHistory)
            quickIcon("gearshape", action: onSettings)
        }
        .padding(.horizontal, 4)
    }

    private func quickIcon(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 42, height: 42)
        .background(Color.clear)
        .liquidGlass(.chip, tint: AppTheme.accent, tintOpacity: 0.07)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
    }
}

private struct ModeChip: View {
    let title: String
    let icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.clear)
            .liquidGlass(.chip, tint: AppTheme.accent, tintOpacity: 0.07)
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        }
    }
}

private struct DailyLimitChip: View {
    let remaining: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "message.badge.filled.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(remaining <= 0 ? AppTheme.destructive : AppTheme.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Daily limit")
                    .font(.system(size: 13, weight: .semibold))
                Text("\(max(remaining, 0)) messages left")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.outline)
        )
    }
}

