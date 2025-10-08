import SwiftUI

struct ChatHistoryView: View {
    @Binding var currentMessages: [Message]
    @State private var savedChats: [[Message]] = []
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
                            
                            Button(action: {
                                loadChat(chat)
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive, action: {
                                    withAnimation {
                                        if let originalIndex = indexOfChat(chat) {
                                            StorageManager.shared.deleteChat(at: originalIndex)
                                            savedChats.remove(at: originalIndex)
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
        .onAppear {
            // Sıralı şekilde yükle
            savedChats = StorageManager.shared.loadAllChats()
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
        guard !query.isEmpty else { return savedChats }
        return savedChats.filter { chat in
            chat.contains { $0.content.localizedCaseInsensitiveContains(query) }
        }
    }
    
    private func indexOfChat(_ chat: [Message]) -> Int? {
        // Find original index by identity of first and last messages if available
        guard let first = chat.first, let last = chat.last else { return nil }
        return savedChats.firstIndex(where: { original in
            guard let ofirst = original.first, let olast = original.last else { return false }
            return ofirst.id == first.id && olast.id == last.id && original.count == chat.count
        })
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