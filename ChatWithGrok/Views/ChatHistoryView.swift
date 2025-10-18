import SwiftUI

struct ChatHistoryView: View {
    @Binding var currentMessages: [Message]
    @State private var savedChats: [[Message]] = []
    @State private var pinnedIdentifiers: Set<Double> = []
    @State private var pendingPinChat: [Message]? = nil
    @State private var showingPinAction = false
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isIncognitoMode") private var isIncognitoMode = false
    @State private var searchText: String = ""
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
        NavigationView {
            VStack(spacing: 0) {
                if savedChats.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.accent)
                        
                        Text("No Chat History")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Start chatting with the AI to see your chat history here.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 12)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Start Chatting")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.clear)
                                .background(AppTheme.controlBackground.opacity(0.3))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 100)
                } else {
                    VStack(spacing: 0) {
                        List {
                            ForEach(filteredChats().indices, id: \.self) { index in
                                let chat = filteredChats()[index]
                                let isPinned = self.isChatPinned(chat)
                                
                                Button(action: {
                                    loadChat(chat)
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            if isPinned {
                                                Label("Pinned", systemImage: "pin.fill")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(AppTheme.chipBackground)
                                                    .foregroundColor(AppTheme.accent)
                                                    .clipShape(Capsule())
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(getChatTitle(for: chat))
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                
                                                Text(getChatDescription(for: chat))
                                                    .lineLimit(2)
                                                    .truncationMode(.tail)
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                            
                                            if let lastMessage = chat.last {
                                                HStack {
                                                    Text(formatDate(lastMessage.timestamp))
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(AppTheme.subtleText)
                                                    
                                                    Text(formatTime(lastMessage.timestamp))
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(AppTheme.subtleText)
                                                }
                                            }
                                            
                                            Text("\(chat.count) messages")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowBackground(EmptyView())
                                .listRowSeparator(.hidden)
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    pendingPinChat = chat
                                    showingPinAction = true
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive, action: {
                                        withAnimation {
                                            if let originalIndex = indexOfChat(chat) {
                                                StorageManager.shared.deleteChat(at: originalIndex)
                                                savedChats.remove(at: originalIndex)
                                                refreshPinnedIdentifiers()
                                            }
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                    }
                    .background(Color.clear)
                    .liquidGlass(.surface, tint: AppTheme.accent, tintOpacity: 0.05)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    colors: [
                        AppTheme.background,
                        AppTheme.secondaryBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Chat History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.controlBackground)
                    .foregroundColor(AppTheme.accent)
                    .clipShape(Capsule())
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
        }
        .tint(AppTheme.accent)
        .confirmationDialog("Chat Actions", isPresented: $showingPinAction, presenting: pendingPinChat) { chat in
            let isPinned = isChatPinned(chat)
            Button(isPinned ? "Unpin" : "Pin") {
                withAnimation {
                    togglePin(for: chat)
                }
                pendingPinChat = nil
            }
            Button("Cancel", role: .cancel) {
                pendingPinChat = nil
            }
        } message: { chat in
            Text(isChatPinned(chat) ? "Remove this chat from pinned list?" : "Keep this chat at the top?")
        }
        .onAppear {
            // Pin bilgilerini ve sohbetleri yükle
            pinnedIdentifiers = StorageManager.shared.loadPinnedIdentifiers()
            savedChats = sortedChats(StorageManager.shared.loadAllChats())
            
            // Generate AI summaries for all chats
            Task {
                await generateAISummariesForAllChats()
            }
        }
    }
    
    private func loadChat(_ chat: [Message]) {
        withAnimation {
            currentMessages = chat
        }
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func filteredChats() -> [[Message]] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = sortedChats(savedChats)
        guard !query.isEmpty else { return base }
        let filtered = base.filter { chat in
            // Search in message content
            let contentMatch = chat.contains { $0.content.localizedCaseInsensitiveContains(query) }
            
            // Search in AI-generated title and description
            let titleMatch = getChatTitle(for: chat).localizedCaseInsensitiveContains(query)
            let descriptionMatch = getChatDescription(for: chat).localizedCaseInsensitiveContains(query)
            
            return contentMatch || titleMatch || descriptionMatch
        }
        return sortedChats(filtered)
    }
    
    private func indexOfChat(_ chat: [Message]) -> Int? {
        // Find original index by identity of first and last messages if available
        guard let first = chat.first, let last = chat.last else { return nil }
        return savedChats.firstIndex(where: { original in
            guard let ofirst = original.first, let olast = original.last else { return false }
            return ofirst.id == first.id && olast.id == last.id && original.count == chat.count
        })
    }

    private func togglePin(for chat: [Message]) {
        guard let identifier = StorageManager.shared.identifier(for: chat) else { return }
        let currentlyPinned = pinnedIdentifiers.contains(identifier)
        StorageManager.shared.setPinned(!currentlyPinned, for: chat)
        if currentlyPinned {
            pinnedIdentifiers.remove(identifier)
        } else {
            pinnedIdentifiers.insert(identifier)
        }
        savedChats = sortedChats(savedChats)
        
        // Notify WelcomeView that pinned chats have been updated
        NotificationCenter.default.post(name: Notification.Name("PinnedChatsUpdated"), object: nil)
    }

    private func isChatPinned(_ chat: [Message]) -> Bool {
        guard let identifier = StorageManager.shared.identifier(for: chat) else { return false }
        return pinnedIdentifiers.contains(identifier)
    }

    private func sortedChats(_ chats: [[Message]]) -> [[Message]] {
        let pinned = chats.filter { isChatPinned($0) }
        let others = chats.filter { !isChatPinned($0) }
        return sortByLatestTimestamp(pinned) + sortByLatestTimestamp(others)
    }

    private func refreshPinnedIdentifiers() {
        pinnedIdentifiers = StorageManager.shared.loadPinnedIdentifiers()
    }

    private func sortByLatestTimestamp(_ chats: [[Message]]) -> [[Message]] {
        chats.sorted { first, second in
            guard let firstDate = first.first?.timestamp,
                  let secondDate = second.first?.timestamp else {
                return false
            }
            return firstDate > secondDate
        }
    }
}

// Kaydetme başarılı görünümü
struct SaveSuccessView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Chat Saved")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(radius: 2)
        )
    }
} 