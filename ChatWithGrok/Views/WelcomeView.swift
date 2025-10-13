import SwiftUI

struct WelcomeView: View {
    @Binding var messages: [Message]
    @Binding var currentInput: String
    @AppStorage("userProfile") private var userProfileData: Data = Data()
    @AppStorage("userName") private var userName = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.controlBackground)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Circle().stroke(AppTheme.outline)
                            )
                            .shadow(color: AppTheme.accent.opacity(0.25), radius: 20, x: 0, y: 12)
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                            .symbolEffect(.bounce, options: .repeat(2))
                    }
                    
                    VStack(spacing: 2) {
                        Text(userName.isEmpty ? "Welcome" : getGreeting(for: userName))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                Text("All-in-one workspace")
                    .font(.system(size: 12.5))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(.top, 12)
                
                HighlightSection()
                
                QuickStartGrid(messages: $messages, currentInput: $currentInput)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.25), value: messages.count)
                
                VStack(spacing: 6) {
                    Text("Ready to start?")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Type your message below to begin chatting")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 580)
        }
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

private struct HighlightSection: View {
    private let highlights: [(String, String, String)] = [
        ("bolt.fill", "Powered by", "Enhanced AI"),
        ("wand.and.stars", "Custom Assistants", "Tailor personalities"),
        ("message.and.waveform", "Natural Conversations", "Remembers your flow"),
        ("lock.shield", "Secure Access", "On-device encryption")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Highlights")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(highlights, id: \.0) { item in
                    HighlightCard(icon: item.0, title: item.1, subtitle: item.2)
                }
            }
        }
    }
}

private struct HighlightCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.accent)
                .frame(width: 40, height: 40)
                .background(AppTheme.controlBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12.5))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(AppTheme.secondaryBackground.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.outline)
        )
    }
}

private struct QuickStartGrid: View {
    @Binding var messages: [Message]
    @Binding var currentInput: String

    private let items: [String] = [
        "Write code or debug existing code",
        "Explain complex topics simply",
        "Help with creative writing",
        "Analyze data or solve math",
        "Assist with research"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Jump back in")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(items, id: \.self) { item in
                    QuickStartCard(text: item, messages: $messages, currentInput: $currentInput)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: messages.count)
    }
}

private struct QuickStartCard: View {
    let text: String
    @Binding var messages: [Message]
    @Binding var currentInput: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "arrow.up.right.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.accent)

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.85)

            Button(action: triggerTip) {
                Text("Start")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(AppTheme.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.outline)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func triggerTip() {
        let userMessage = Message(content: text, isUser: true)
        messages.append(userMessage)

        messages.append(Message(
            content: "",
            isUser: false,
            isLoading: true
        ))

        currentInput = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(
                name: Notification.Name("SendMessageFromTip"),
                object: text
            )
        }
    }
}

struct TipRow: View {
    let text: String
    @Binding var messages: [Message]
    @Binding var currentInput: String
    @AppStorage("dailyMessageCount") private var dailyMessageCount = 0
    let FREE_DAILY_LIMIT = 20
    @State private var showingUpgradeView = false
    
    var body: some View {
        Button(action: {
            // Limit kaldırıldı: doğrudan gönder
            
            // Normal akış
            withAnimation {
                // Kullanıcı mesajını ekle
                let userMessage = Message(content: text, isUser: true)
                messages.append(userMessage)
                
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                // Grok düşünüyor mesajı
                messages.append(Message(
                    content: "",
                    isUser: false,
                    isLoading: true
                ))
                
                currentInput = ""
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(
                        name: Notification.Name("SendMessageFromTip"),
                        object: text
                    )
                }
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .sheet(isPresented: $showingUpgradeView) { UpgradeView() }
    }
}

#Preview {
    WelcomeView(messages: .constant([]), currentInput: .constant(""))
} 