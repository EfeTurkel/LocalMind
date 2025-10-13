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
    
    var body: some View {
        NavigationView {
            VStack {
                if savedChats.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("No Chat History")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("Start chatting with the AI to see your chat history here.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Start Chatting")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 100)
                } else {
                    List {
                        ForEach(filteredChats().indices, id: \.self) { index in
                            let chat = filteredChats()[index]
                            let isPinned = self.isChatPinned(chat)
                            
                            Button(action: {
                                loadChat(chat)
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    if isPinned {
                                        Label("Pinned", systemImage: "pin.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    
                                    // İlk mesajı göster
                                    if let firstMessage = chat.first {
                                        Text(firstMessage.content)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .font(.headline)
                                    }
                                    
                                    // Son mesajı göster
                                    if let lastMessage = chat.last {
                                        Text(lastMessage.content)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Tarih ve saat bilgisini göster
                                    if let lastMessage = chat.last {
                                        HStack {
                                            Text(formatDate(lastMessage.timestamp))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text(formatTime(lastMessage.timestamp))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    // Mesaj sayısını göster
                                    Text("\(chat.count) messages")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
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
                }
            }
            .navigationTitle("Chat History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
        }
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
        }
    }
    
    private func loadChat(_ chat: [Message]) {
        if !isIncognitoMode {
            withAnimation {
                currentMessages = chat
            }
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
            chat.contains { $0.content.localizedCaseInsensitiveContains(query) }
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