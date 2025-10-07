import SwiftUI

struct WelcomeView: View {
    @AppStorage("isIncognitoMode") private var isIncognitoMode = false
    @Binding var messages: [Message]
    @Binding var currentInput: String
    @AppStorage("userProfile") private var userProfileData: Data = Data()
    @AppStorage("userName") private var userName = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Logo ve başlık
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: isIncognitoMode ? 40 : 50))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                        .symbolEffect(.bounce)
                    
                    if !userName.isEmpty {
                        VStack(spacing: 4) {
                            Text(getGreeting(for: userName))
                                .font(.system(size: isIncognitoMode ? 20 : 22, weight: .bold, design: .rounded))
                                .fontWeight(.bold)
                            
                            Spacer()
                                .frame(height: 20)
                        }
                    } else {
                        Text("Welcome to ChatAI")
                            .font(.system(size: isIncognitoMode ? 20 : 22, weight: .bold, design: .rounded))
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, isIncognitoMode ? 12 : 16)
                
                // Özellikler listesi
                VStack(alignment: .leading, spacing: isIncognitoMode ? 8 : 12) {
                    FeatureRow(
                        icon: "brain.head.profile",
                        title: "Powered by",
                        description: "Enhanced AI Models"
                    )
                    
                    FeatureRow(
                        icon: "wand.and.stars",
                        title: "Custom AI Assistants",
                        description: "Choose from different AI models\nfor specialized conversations"
                    )
                    
                    FeatureRow(
                        icon: "message.and.waveform",
                        title: "Natural Conversations",
                        description: "Chat naturally and get\nhuman-like responses"
                    )
                    
                    FeatureRow(
                        icon: "key.fill",
                        title: "Secure Access",
                        description: "Use your API key for\nsecure communication"
                    )
                }
                .padding(.horizontal)
                .padding(.top, isIncognitoMode ? 6 : 8)
                
                // AI Model İpuçları
                VStack(alignment: .leading, spacing: isIncognitoMode ? 6 : 8) {
                    Text("Try asking AI Models:")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .padding(.bottom, isIncognitoMode ? 1 : 2)
                    
                    TipRow(text: "Write code or debug your existing code", messages: $messages, currentInput: $currentInput)
                    TipRow(text: "Explain complex topics in simple terms", messages: $messages, currentInput: $currentInput)
                    TipRow(text: "Help with creative writing", messages: $messages, currentInput: $currentInput)
                    TipRow(text: "Analyze data or solve math problems", messages: $messages, currentInput: $currentInput)
                    TipRow(text: "Get help with research", messages: $messages, currentInput: $currentInput)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, isIncognitoMode ? 12 : 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.25), value: messages.count)
                
                Spacer(minLength: isIncognitoMode ? 12 : 16)
                
                // Başlangıç talimatı
                VStack(spacing: isIncognitoMode ? 2 : 4) {
                    Text("Ready to start?")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    
                    Text("Type your message below to begin chatting")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, isIncognitoMode ? 8 : 12)
            }
            .padding(.horizontal)
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
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingUpgradeView) { UpgradeView() }
    }
}

#Preview {
    WelcomeView(messages: .constant([]), currentInput: .constant(""))
} 