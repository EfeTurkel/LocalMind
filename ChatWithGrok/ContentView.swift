//
//  ContentView.swift
//  LockMind
//
//  Created by Efe Türkel on 3.11.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var currentInput: String = ""
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "grokApiKey") ?? ""
    @State private var showingSettings = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasAPIKey") private var hasAPIKey = false
    @AppStorage("isIncognitoMode") private var isIncognitoMode = false
    @AppStorage("isPremium") private var isPremium = true
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("preferredColorScheme") private var preferredColorScheme: Int = 0
    @AppStorage("dailyMessageCount") private var dailyMessageCount = 0
    @AppStorage("lastMessageDate") private var lastMessageDate = Date()
    @State private var showingUpgradeView = false
    @State private var selectedAIMode: AIMode = .general
    @AppStorage("selectedAIMode") private var storedAIModeRaw: String = AIMode.general.rawValue
    @State private var showingModeSelector = false
    @State private var showingLimitPopup = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @State private var showingProfile = false
    @AppStorage("userProfile") private var userProfileData: Data = Data()
    @State private var keyboardHeight: CGFloat = 0
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingChatHistory = false
    @AppStorage("selectedAIModel") private var selectedAIModel: String = "grok-beta"
    @State private var openAIAPIKey: String = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
    @State private var claudeAPIKey: String = UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
    @AppStorage("avatar") private var avatar = "xai2_logo"
    @AppStorage("userName") private var userName = ""
    @AppStorage("minimalHome") private var minimalHome = false
    
    let FREE_DAILY_LIMIT = Int.max
    
    let darkOrange = Color(red: 255/255, green: 140/255, blue: 0/255)
    
    private enum MessageSource {
        case user
        case tip
    }
    
    private enum ModelProviderContext {
        case grok(apiKey: String)
        case openAI(apiKey: String)
        case claude(apiKey: String)
        case gemini
        case demo
    }
    
    private var activeColorScheme: ColorScheme? {
        switch preferredColorScheme {
        case 0:
            return systemColorScheme
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return systemColorScheme
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan rengi
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Toolbar içeriği
                    ToolbarContent(
                        messages: $messages,
                        isIncognitoMode: isIncognitoMode,
                        showingModeSelector: $showingModeSelector,
                        dailyMessageCount: dailyMessageCount,
                        FREE_DAILY_LIMIT: FREE_DAILY_LIMIT,
                        showingLimitPopup: $showingLimitPopup,
                        showingUpgradeView: $showingUpgradeView,
                        showingChatHistory: $showingChatHistory,
                        showingSettings: $showingSettings
                    )
                    
                    // Incognito mod göstergesi
                    if isIncognitoMode {
                        IncognitoModeIndicator(isIncognitoMode: $isIncognitoMode)
                    }
                    
                    // Mesajlar kısmı (Minimal Home: yalnızca mesaj yokken gizle)
                    if !(minimalHome && messages.isEmpty) {
                        MessagesView(
                            messages: $messages,
                            currentInput: $currentInput,
                            isLoading: $isLoading,
                            keyboardHeight: $keyboardHeight,
                            selectedAIModel: $selectedAIModel
                        )
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 580)
                    } else {
                        Spacer()
                    }
                    // InputView en altta sabit
                    InputView(
                        currentInput: $currentInput,
                        onSend: sendMessage,
                        isLoading: isLoading
                    )
                    .background(Color(.systemGroupedBackground))
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 580)
                }
            }
            .navigationBarTitle("LockMind")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LockMind")
                        .font(.headline)
                }
            }
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 8) { // Üst boşluk ekledik
                Color.clear.frame(height: 4)
            }
            .toolbar {
                // ... toolbar içeriği aynı ...
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(apiKey: $apiKey)
            }
            .sheet(isPresented: .constant(!hasSeenOnboarding)) {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
            .sheet(isPresented: .constant(!hasAPIKey && hasSeenOnboarding)) {
                APIKeySetupView(hasAPIKey: $hasAPIKey, apiKey: $apiKey, openAIAPIKey: $openAIAPIKey)
            }
            .sheet(isPresented: $showingUpgradeView) {
                UpgradeView()
            }
            .sheet(isPresented: $showingModeSelector) {
                AIModeSelector(selectedMode: $selectedAIMode)
            }
            .sheet(isPresented: $showingLimitPopup) {
                MessageLimitPopupView(
                    usedMessages: dailyMessageCount,
                    remainingMessages: FREE_DAILY_LIMIT - dailyMessageCount,
                    totalLimit: FREE_DAILY_LIMIT,
                    showingUpgradeView: $showingUpgradeView
                )
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showingChatHistory) {
                ChatHistoryView(currentMessages: $messages)
            }
            .preferredColorScheme(activeColorScheme)
        }
        .onChange(of: systemColorScheme) { oldValue, newValue in
            if preferredColorScheme == 0 {
                withAnimation {
                    // Tüm pencereler için güncelle
                    for window in UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows }) {
                        window.overrideUserInterfaceStyle = .unspecified
                    }
                }
            }
        }
        .onAppear {
            checkAndResetDailyLimit()
            // Sync stored AI mode
            if let restored = AIMode(rawValue: storedAIModeRaw) {
                selectedAIMode = restored
            }
            
            // Load API keys
            apiKey = UserDefaults.standard.string(forKey: "grokApiKey") ?? ""
            openAIAPIKey = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
            claudeAPIKey = UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
            
            // Check if user has set up API key
            hasAPIKey = !apiKey.isEmpty || !openAIAPIKey.isEmpty || !claudeAPIKey.isEmpty || !(UserDefaults.standard.string(forKey: "geminiAPIKey") ?? "").isEmpty
            
            // Klavye bildirimlerini dinle
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                keyboardHeight = keyboardFrame?.height ?? 0
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }
            
            // Tip'ten gelen mesajları dinle
            NotificationCenter.default.addObserver(
                forName: Notification.Name("SendMessageFromTip"),
                object: nil,
                queue: .main
            ) { notification in
                if let messageText = notification.object as? String {
                    handleSend(for: messageText, source: .tip)
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                checkAndResetDailyLimit()
            }
        }
    }
    
    private func checkAndResetDailyLimit() {
        let now = Date()
        
        // Limit dolduktan sonraki ilk mesajın tarihinden itibaren 24 saat geçip geçmediğini kontrol et
        if dailyMessageCount >= FREE_DAILY_LIMIT {
            if let timeSinceLimit = Calendar.current.dateComponents(
                [.hour, .minute],
                from: lastMessageDate,
                to: now
            ).hour {
                if timeSinceLimit >= 24 {
                    dailyMessageCount = 0
                    lastMessageDate = now
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmedInput = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        let originalInput = currentInput
        if handleSend(for: trimmedInput, source: .user) {
            currentInput = ""
        } else {
            currentInput = originalInput
        }
    }
    
    @discardableResult
    private func handleSend(for text: String, source: MessageSource) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return false }
        
        // Enforce daily support before sending any message
        // If support is available, user has NOT supported yet today → block send
        if TipStorage.shared.isTipAvailable(now: Date()) {
            let notice = "ℹ️ Please support today to continue. Tap the Daily Support button and try again."
            messages.append(Message(content: notice, isUser: false))
            if hapticFeedbackEnabled {
                let warning = UINotificationFeedbackGenerator()
                warning.notificationOccurred(.warning)
            }
            showingUpgradeView = true
            return false
        }

        guard let modelContext = resolveModelContext(for: trimmedText, source: source) else {
            cleanupAfterFailedSend(for: source)
            return false
        }
        
        if shouldEnforceLimit() {
            handleLimitReached(userText: trimmedText, source: source)
            return false
        }
        
        appendUserMessageIfNeeded(text: trimmedText, source: source)
        sendToSelectedModel(userText: trimmedText, context: modelContext)
        return true
    }
    
    private func resolveModelContext(for message: String, source: MessageSource) -> ModelProviderContext? {
        // Check if model is Claude
        if selectedAIModel.starts(with: "claude-") {
            let claudeKey = resolveClaudeAPIKey()
            guard !claudeKey.isEmpty else {
                presentMissingAPIKeyAlert(for: source)
                return nil
            }
            return .claude(apiKey: claudeKey)
        }
        
        // Check if model is OpenAI
        if selectedAIModel.starts(with: "gpt-") || selectedAIModel.starts(with: "o1-") {
            let openAIKey = resolveOpenAIAPIKey()
            guard !openAIKey.isEmpty else {
                presentMissingAPIKeyAlert(for: source)
                return nil
            }
            return .openAI(apiKey: openAIKey)
        }
        
        // Check if model is Gemini
        if selectedAIModel.starts(with: "gemini-") {
            ensureGeminiAPIKeyIsSynced()
            // If missing key, use demo
            let hasKey = !(UserDefaults.standard.string(forKey: "geminiAPIKey") ?? "").isEmpty
            return hasKey ? .gemini : .demo
        }
        
        // Default to Grok
        let grokKey = resolveGrokAPIKey()
        if grokKey.isEmpty { return .demo }
        return .grok(apiKey: grokKey)
    }
    
    private func resolveGrokAPIKey() -> String {
        if apiKey.isEmpty {
            apiKey = UserDefaults.standard.string(forKey: "grokApiKey") ?? ""
        }
        return apiKey
    }
    
    private func resolveOpenAIAPIKey() -> String {
        if openAIAPIKey.isEmpty {
            openAIAPIKey = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
        }
        return openAIAPIKey
    }
    
    private func resolveClaudeAPIKey() -> String {
        if claudeAPIKey.isEmpty {
            claudeAPIKey = UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
        }
        return claudeAPIKey
    }
    
    private func ensureGeminiAPIKeyIsSynced() {
        let customGeminiAPIKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
        if !customGeminiAPIKey.isEmpty {
            GeminiService.shared.updateAPIKey(customGeminiAPIKey)
        }
    }
    
    private func presentMissingAPIKeyAlert(for source: MessageSource) {
        // Don't automatically open settings, just show error message
        if hapticFeedbackEnabled {
            let warning = UINotificationFeedbackGenerator()
            warning.notificationOccurred(.warning)
        }
        
        // Show error message to user
        let errorMsg = "⚠️ API key not found. Please add your API key in Settings → API Keys."
        messages.append(Message(content: errorMsg, isUser: false))
    }
    
    private func shouldEnforceLimit() -> Bool {
        return false
    }
    
    private func handleLimitReached(userText: String, source: MessageSource) {
        // Limit kullanılmıyor; hiçbir şey yapma
        return
    }
    
    private func appendUserMessageIfNeeded(text: String, source: MessageSource) {
        switch source {
        case .user:
            let userMessage = Message(content: text, isUser: true)
            messages.append(userMessage)
        case .tip:
            break
        }
        if !messages.contains(where: { $0.isLoading }) {
            messages.append(Message(
                content: "",
                isUser: false,
                isLoading: true,
                aiModel: selectedAIModel
            ))
        }
        isLoading = true
    }
    
    private func sendToSelectedModel(userText: String, context: ModelProviderContext) {
        let history = messages.filter { !$0.isLoading }
        Task {
            let startTime = Date()
            do {
                let response: String
                switch context {
                case .grok(let apiKey):
                    response = try await GrokService.shared.sendMessage(
                        userText,
                        mode: selectedAIMode,
                        apiKey: apiKey,
                        previousMessages: history
                    )
                case .openAI(let apiKey):
                    response = try await OpenAIService.shared.sendMessage(
                        userText,
                        model: selectedAIModel,
                        apiKey: apiKey,
                        previousMessages: history
                    )
                case .claude(let apiKey):
                    response = try await ClaudeService.shared.sendMessage(
                        userText,
                        model: selectedAIModel,
                        apiKey: apiKey,
                        previousMessages: history
                    )
                case .gemini:
                    // Ensure SDK uses the currently selected Gemini model
                    GeminiService.shared.updateModel(selectedAIModel)
                    response = try await GeminiService.shared.sendMessage(userText)
                case .demo:
                    response = try await MockAIService.shared.sendMessage(userText, model: selectedAIModel, previousMessages: history)
                }
                await MainActor.run {
                    if let index = messages.firstIndex(where: { $0.isLoading }) {
                        messages.remove(at: index)
                    }
                    let botMessage = Message(content: response, isUser: false, aiModel: selectedAIModel)
                    messages.append(botMessage)
                    isLoading = false
                    if !isIncognitoMode {
                        StorageManager.shared.saveChat(messages)
                    }
                    if hapticFeedbackEnabled {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                    let responseTime = Date().timeIntervalSince(startTime)
                    updateUserProfile(
                        userMessage: userText,
                        botMessage: response,
                        responseTime: responseTime
                    )
                    // Persist chosen mode for future sessions
                    storedAIModeRaw = selectedAIMode.rawValue
                    // Günlük sayaç artık kullanılmıyor
                    lastMessageDate = Date()
                }
            } catch {
                await MainActor.run {
                    removeLoadingPlaceholder()
                    let errorMessage = Message(
                        content: "Error: \(error.localizedDescription)",
                        isUser: false
                    )
                    messages.append(errorMessage)
                    isLoading = false
                    if hapticFeedbackEnabled {
                        let generator = UINotificationFeedbackGenerator()
                        generator.prepare()
                        generator.notificationOccurred(.error)
                    }
                }
            }
        }
    }
    
    private func removeLoadingPlaceholder() {
        if let index = messages.firstIndex(where: { $0.isLoading }) {
            messages.remove(at: index)
        }
    }
    
    private func cleanupAfterFailedSend(for source: MessageSource) {
        if source == .tip {
            removeLoadingPlaceholder()
        }
        isLoading = false
    }
    
    private func updateUserProfile(userMessage: String, botMessage: String, responseTime: TimeInterval) {
        if var profile = try? JSONDecoder().decode(UserProfile.self, from: userProfileData) {
            // Toplam prompt sayısını güncelle
            profile.totalPrompts += 1
            
            // Günlük prompt sayısını güncelle
            let today = DateFormatter.yyyyMMdd.string(from: Date())
            profile.dailyPrompts[today, default: 0] += 1
            
            // Karakter sayılarını güncelle
            profile.totalCharactersSent += userMessage.count
            profile.totalCharactersReceived += botMessage.count
            
            // Ortalama yanıt süresini güncelle
            let oldTotal = profile.averageResponseTime * Double(profile.totalPrompts - 1)
            profile.averageResponseTime = (oldTotal + responseTime) / Double(profile.totalPrompts)
            
            // Favori AI modunu güncelle
            // Bu kısım daha karmaşık bir mantık gerektirebilir
            profile.favoriteAIMode = selectedAIMode
            
            // Son aktif zaman güncelle
            profile.lastActive = Date()
            
            // En çok kullanılan AI modellerini güncelle
            profile.mostUsedAIModels[selectedAIModel, default: 0] += 1
            
            // Profili kaydet
            if let encoded = try? JSONEncoder().encode(profile) {
                userProfileData = encoded
            }
        } else {
            // İlk kullanım için yeni profil oluştur
            var profile = UserProfile()
            profile.totalPrompts = 1
            profile.dailyPrompts[DateFormatter.yyyyMMdd.string(from: Date())] = 1
            profile.totalCharactersSent = userMessage.count
            profile.totalCharactersReceived = botMessage.count
            profile.averageResponseTime = responseTime
            profile.favoriteAIMode = selectedAIMode
            profile.mostUsedAIModels[selectedAIModel] = 1
            
            if let encoded = try? JSONEncoder().encode(profile) {
                userProfileData = encoded
            }
        }
    }
    
    private func getTimeUntilReset() -> String {
        let now = Date()
        let resetTime = lastMessageDate.addingTimeInterval(24 * 60 * 60) // 24 saat ekle
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: now, to: resetTime)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        }
        
        return "0m"
    }
}

struct ToolbarContent: View {
    @Binding var messages: [Message]
    let isIncognitoMode: Bool
    @Binding var showingModeSelector: Bool
    let dailyMessageCount: Int
    let FREE_DAILY_LIMIT: Int
    @Binding var showingLimitPopup: Bool
    @Binding var showingUpgradeView: Bool
    @Binding var showingChatHistory: Bool
    @Binding var showingSettings: Bool
    @AppStorage("lastMessageDate") private var lastMessageDate = Date()
    @AppStorage("isPremium") private var isPremium = false
    
    let darkOrange = Color(red: 255/255, green: 140/255, blue: 0/255)
    
    var body: some View {
        HStack(spacing: 12) {
            // Geri butonu en solda
            if !messages.isEmpty {
                Button(action: {
                    if !messages.isEmpty && !isIncognitoMode {
                        // Mevcut sohbeti kaydet
                        StorageManager.shared.saveChat(messages)
                    }
                    withAnimation {
                        messages.removeAll()
                    }
                }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 36, height: 36)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .frame(width: 44, height: 44)
            }
            
            // AI Mode Selector butonu
            Button(action: {
                showingModeSelector = true
            }) {
                Image(systemName: "brain")
                    .font(.system(size: 16))
                    .frame(width: 36, height: 36)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.3),
                                        Color.blue.opacity(0.3)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .frame(width: 44, height: 44)
            
            // Mesaj limiti göstergesi - 5'ten az kaldığında göster
            if (FREE_DAILY_LIMIT - dailyMessageCount) < 5 {
                Button(action: {
                    showingLimitPopup = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "message.badge.filled.fill")
                            .foregroundColor(dailyMessageCount >= FREE_DAILY_LIMIT ? .red : darkOrange)
                            .symbolEffect(.pulse)
                            .font(.system(size: 14))
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(FREE_DAILY_LIMIT - dailyMessageCount) left")
                                .font(.system(size: 12, weight: .medium))
                            
                            if dailyMessageCount >= FREE_DAILY_LIMIT {
                                let timeUntilReset = getTimeUntilReset()
                                Text("Resets in \(timeUntilReset)")
                                    .font(.system(size: 10))
                            }
                        }
                        .foregroundColor(dailyMessageCount >= FREE_DAILY_LIMIT ? .red : darkOrange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(height: 36)
                    .background(
                        Capsule()
                            .fill(dailyMessageCount >= FREE_DAILY_LIMIT ? Color.red.opacity(0.15) : darkOrange.opacity(0.15))
                    )
                }
                .frame(height: 44)
            }
            
            // Günlük destek butonu her zaman görünür
            Button(action: {
                showingUpgradeView = true
            }) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 16))
                    .foregroundColor(darkOrange)
                    .frame(width: 36, height: 36)
                    .background(
                        Capsule()
                            .fill(darkOrange.opacity(0.15))
                    )
            }
            .frame(width: 44, height: 44)
            
            // Chat History butonu (Settings'den önce)
            if !isIncognitoMode {
                Button(action: {
                    showingChatHistory = true
                }) {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 36, height: 36)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .frame(width: 44, height: 44)
                .transition(.opacity) // Animasyonlu geçiş ekledik
            }
            
            // Settings butonu en sağda
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    private func getTimeUntilReset() -> String {
        let now = Date()
        let resetTime = lastMessageDate.addingTimeInterval(24 * 60 * 60) // 24 saat ekle
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: now, to: resetTime)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        }
        
        return "0m"
    }
}

struct IncognitoModeIndicator: View {
    @Binding var isIncognitoMode: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .symbolEffect(.pulse.byLayer, options: .repeating)
                
                Text("Incognito Mode Active")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Kapatma butonu
                Button(action: {
                    withAnimation {
                        isIncognitoMode = false
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    // Arkaplan gradyanı
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.9),
                            Color.blue.opacity(0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // Üst ksımdaki parlak çizgi
                    LinearGradient(
                        colors: [
                            .white.opacity(0.3),
                            .white.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(
                color: .black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 2
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct MessagesView: View {
    @Binding var messages: [Message]
    @Binding var currentInput: String
    @Binding var isLoading: Bool
    @Binding var keyboardHeight: CGFloat
    @Binding var selectedAIModel: String
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messages.isEmpty {
                        WelcomeView(messages: $messages, currentInput: $currentInput)
                    } else {
                        ForEach(messages) { message in
                            if message.isLoading {
                                LoadingView(selectedModel: message.aiModel)
                            } else {
                                MessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        
                        if isLoading && !messages.contains(where: { $0.isLoading }) {
                            LoadingView(selectedModel: selectedAIModel)
                                .id("loading")
                        }
                        
                        Color.clear
                            .frame(height: keyboardHeight > 0 ? keyboardHeight - 20 : 0)
                            .id("keyboard")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .onChange(of: messages.count) { oldCount, newCount in
                    withAnimation {
                        if let lastMessage = messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { wasLoading, isNowLoading in
                    if isNowLoading {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
                .onChange(of: keyboardHeight) { oldValue, newValue in
                    if newValue > 0 {
                        withAnimation {
                            proxy.scrollTo("keyboard", anchor: .bottom)
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if let lastMessage = messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .scrollDismissesKeyboard(.interactively)
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                             to: nil, from: nil, for: nil)
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 30 {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                         to: nil, from: nil, for: nil)
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.width > 100 && !messages.isEmpty { // Sağa kaydırma - Ana ekrana dön
                            withAnimation {
                                messages.removeAll()
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                            }
                        } else if gesture.translation.width < -100 && messages.isEmpty { // Sola kaydırma - Chat ekranına geç
                            withAnimation {
                                messages = []
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                            }
                        }
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        if abs(gesture.translation.height) > 50 {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                         to: nil, from: nil, for: nil)
                        }
                    }
            )
        }
    }
}

#Preview {
    ContentView()
}

// AppDelegate'i ekleyelim
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
