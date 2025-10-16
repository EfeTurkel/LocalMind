import SwiftUI

struct ChatCategoryView: View {
    @Binding var messages: [Message]
    @State private var selectedCategory: ChatCategory? = nil
    @Environment(\.dismiss) private var dismiss
    
    var categorizedMessages: [ChatCategory: [Message]] {
        Dictionary(grouping: messages) { $0.category }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ChatCategory.allCases, id: \.self) { category in
                    if let categoryMessages = categorizedMessages[category] {
                        Section {
                            ForEach(categoryMessages) { message in
                                MessageRow(message: message) {
                                    editCategory(for: message)
                                }
                            }
                        } header: {
                            CategoryHeader(category: category, count: categoryMessages.count)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func editCategory(for message: Message) {
        if messages.contains(where: { $0.id == message.id }) {
            // Kategori seçim menüsü göster
        }
    }
}

struct CategoryHeader: View {
    let category: ChatCategory
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(Color(category.color))
            Text(category.rawValue)
            Spacer()
            Text("\(count)")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(8)
        .background(Color.clear)
        .liquidGlass(.chip, tint: AppTheme.accent, tintOpacity: 0.06)
    }
}

struct MessageRow: View {
    let message: Message
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(message.isUser ? "You:" : "Grok:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: message.category.icon)
                    .foregroundColor(Color(message.category.color))
                    .font(.caption)
            }
            
            Text(message.content)
                .lineLimit(2)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.clear)
        .liquidGlass(.card, tint: AppTheme.accent, tintOpacity: 0.05)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
} 