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
    @State private var isSidebarOpen = false
    @State private var sidebarSearchText: String = ""
    @State private var sidebarSavedChats: [[Message]] = []
    @State private var sidebarPinnedIdentifiers: Set<Double> = []
    // Banner state for replies arriving while on home
    @State private var homeNewMessageAvailable: Bool = false
    @State private var pendingChatForHome: [Message] = []
    
    let FREE_DAILY_LIMIT = Int.max

    private var bottomSafeAreaInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first?
            .safeAreaInsets.bottom ?? 0
    }

    private var keyboardPadding: CGFloat {
        guard !isSidebarOpen else { return 0 }
        let extra = max(keyboardHeight - bottomSafeAreaInset, 0)
        return extra > 0 ? extra + 24 : 0
    }
    
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
            ZStack(alignment: .leading) {
                // Status bar background
                VStack(spacing: 0) {
                    Color.clear.frame(height: 0) // remove extra top filler entirely
                    Spacer()
                }
                .zIndex(0)
                
                mainBackground
                chatLayer
                sidebarLayer
            }
            .contentShape(Rectangle())
            // Global top-left sidebar toggle button (pinned to true safe area)
            .overlay(alignment: .topLeading) {
                if !isSidebarOpen {
                    GeometryReader { geometry in
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isSidebarOpen = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.controlBackground.opacity(0.7))
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                
                                Image(systemName: "sidebar.leading")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .frame(width: 46, height: 46)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.outline.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                        }
                        .position(
                            x: 18 + 23,
                            y: geometry.safeAreaInsets.top + 23
                        )
                        .transition(.opacity.combined(with: .scale))
                    }
                }
            }
            .overlay(alignment: .leading) {
                if isSidebarOpen {
                    HStack(spacing: 0) {
                        Color.clear.frame(width: 300)
                        Color.black.opacity(0.001)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isSidebarOpen = false
                                }
                            }
                    }
                    .ignoresSafeArea()
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
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
        .statusBarStyle(activeColorScheme == .dark ? .lightContent : .darkContent)
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
            
            // Configure status bar appearance
            configureStatusBar()
            
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

            refreshSidebarChats()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkAndResetDailyLimit()
                configureStatusBar()
            }
        }
        .onChange(of: activeColorScheme) { _, _ in
            configureStatusBar()
        }
        .onChange(of: messages.count) { _, _ in
            refreshSidebarChats()
            if !messages.isEmpty && homeNewMessageAvailable {
                homeNewMessageAvailable = false
                pendingChatForHome.removeAll()
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
    
    private func configureStatusBar() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
            // Set status bar appearance based on color scheme
            let isDark = activeColorScheme == .dark
            
            windowScene.windows.forEach { window in
                // Update window appearance to match our color scheme
                if preferredColorScheme == 0 {
                    window.overrideUserInterfaceStyle = .unspecified
                } else {
                    window.overrideUserInterfaceStyle = isDark ? .dark : .light
                }
            }
        }
    }

    private func refreshSidebarChats() {
        sidebarPinnedIdentifiers = StorageManager.shared.loadPinnedIdentifiers()
        sidebarSavedChats = StorageManager.shared.loadAllChats()
    }

    private var mainBackground: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            if activeColorScheme == .dark || preferredColorScheme == 2 {
                RadialGradient(
                    colors: [
                        AppTheme.accent.opacity(0.12),
                        AppTheme.background
                    ],
                    center: .topLeading,
                    startRadius: 120,
                    endRadius: 600
                )
                .ignoresSafeArea()
            }
        }
    }

    private var sidebarLayer: some View {
        return SidebarContainer(
            isOpen: $isSidebarOpen,
            selectedAIMode: $selectedAIMode,
            showingModeSelector: $showingModeSelector,
            showingUpgradeView: $showingUpgradeView,
            showingChatHistory: $showingChatHistory,
            showingSettings: $showingSettings,
            showingProfile: $showingProfile,
            searchText: $sidebarSearchText,
            savedChats: $sidebarSavedChats,
            pinnedIdentifiers: $sidebarPinnedIdentifiers,
            isIncognitoMode: isIncognitoMode,
            dailyMessageCount: dailyMessageCount,
            FREE_DAILY_LIMIT: FREE_DAILY_LIMIT,
            onSelectChat: { chat in
                let restoredMessages: [Message] = chat.map { message in
                    Message(
                        content: message.content,
                        isUser: message.isUser,
                        timestamp: message.timestamp,
                        category: message.category,
                        isLoading: false,
                        aiModel: message.aiModel
                    )
                }

                messages = restoredMessages
                isLoading = false
                currentInput = ""

                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isSidebarOpen = false
                }
            },
            onDeleteChat: { chat in
                if let index = sidebarSavedChats.firstIndex(where: { $0.first?.id == chat.first?.id && $0.last?.id == chat.last?.id }) {
                    StorageManager.shared.deleteChat(at: index)
                    refreshSidebarChats()
                }
            },
            onReturnHome: {
                messages.removeAll()
                currentInput = ""
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isSidebarOpen = false
                }
            },
            onToggleIncognito: {
                isIncognitoMode.toggle()
            }
        )
        .frame(width: 300)
        .offset(x: isSidebarOpen ? 0 : -300)
        .opacity(isSidebarOpen ? 1 : 0)
        .allowsHitTesting(isSidebarOpen)
        .zIndex(isSidebarOpen ? 2 : 0)
        .accessibilityHidden(false)
        .background(AppTheme.background)
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .trailing) {
            if isSidebarOpen {
                Rectangle()
                    .fill(AppTheme.outline.opacity(0.35))
                    .frame(width: 1)
                    .padding(.vertical, 16)
                    .transition(.opacity)
            }
        }
    }

    private var chatLayer: some View {
        return VStack(spacing: 0) {
            Group {
                if minimalHome && messages.isEmpty {
                    Spacer(minLength: 0)
                } else {
                    MessagesView(
                        messages: $messages,
                        currentInput: $currentInput,
                        isLoading: $isLoading,
                        keyboardHeight: $keyboardHeight,
                        selectedAIModel: $selectedAIModel,
                        showingModeSelector: $showingModeSelector
                    )
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 580, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            SimpleFluidInput(
                currentInput: $currentInput,
                onSend: sendMessage,
                isLoading: isLoading,
                keyboardHeight: $keyboardHeight,
                messages: $messages,
                selectedAIMode: $selectedAIMode
            )
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 580)
        }
        .background(AppTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
        .shadow(color: Color.clear, radius: 0)
        .overlay(alignment: .top) {
            if messages.isEmpty && homeNewMessageAvailable {
                HStack(spacing: 10) {
                    Image(systemName: "bolt.horizontal.circle.fill")
                        .foregroundColor(AppTheme.accent)
                        .font(.system(size: 16, weight: .semibold))
                    Text("New message arrived. Tap to view")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.controlBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppTheme.outline))
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                .padding(.top, 18)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        messages = pendingChatForHome
                        pendingChatForHome.removeAll()
                        homeNewMessageAvailable = false
                    }
                }
            }
        }
        .overlay(
            Group {
                if isSidebarOpen {
                    VisualEffectBlur(style: .systemUltraThinMaterialDark)
                        .ignoresSafeArea()
                        .opacity(0.2)
                        .transition(.opacity)
                }
            }
        )
        // Button moved to global overlay above; remove local overlay
        .padding(.bottom, keyboardPadding)
        .ignoresSafeArea(edges: .bottom)
        .zIndex(isSidebarOpen ? 1 : 2)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onChanged { value in
                    // Soldan sağa kaydırma hareketi - sadece ana sayfada ve sidebar kapalıyken
                    if messages.isEmpty && !isSidebarOpen && value.translation.width > 0 && value.startLocation.x < 50 {
                        // Gesture başlangıcı ekranın sol kenarından 50pt içindeyse
                        if value.translation.width > 100 {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isSidebarOpen = true
                            }
                        }
                    }
                }
                .onEnded { value in
                    // Hareket tamamlandığında sidebar'ı aç
                    if messages.isEmpty && !isSidebarOpen && value.translation.width > 80 && value.startLocation.x < 50 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isSidebarOpen = true
                        }
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
                }
        )
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
        // Build clean history: only real chat turns (user or assistant with model), no system/notice entries
        let nonLoading = messages.filter { !$0.isLoading && ($0.isUser || !$0.aiModel.isEmpty) }
        // Keep last 30 turns to avoid overflowing context
        let trimmed = nonLoading.suffix(30)
        let history: [Message]
        if let last = trimmed.last, last.isUser {
            history = Array(trimmed.dropLast())
        } else {
            history = Array(trimmed)
        }
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
                    response = try await GeminiService.shared.sendMessage(userText, previousMessages: history)
                case .demo:
                    response = try await MockAIService.shared.sendMessage(userText, model: selectedAIModel, previousMessages: history)
                }
                await MainActor.run {
                    // If user returned home during generation, don't force open chat; show banner instead
                    if messages.isEmpty {
                        var transcript: [Message] = Array(history)
                        transcript.append(Message(content: userText, isUser: true))
                        transcript.append(Message(content: response, isUser: false, aiModel: selectedAIModel))
                        pendingChatForHome = transcript
                        homeNewMessageAvailable = true
                        isLoading = false
                        if !isIncognitoMode {
                            StorageManager.shared.saveChat(transcript)
                        }
                    } else {
                        if let index = messages.firstIndex(where: { $0.isLoading }) {
                            messages.remove(at: index)
                        }
                        let botMessage = Message(content: response, isUser: false, aiModel: selectedAIModel)
                        messages.append(botMessage)
                        isLoading = false
                        if !isIncognitoMode {
                            StorageManager.shared.saveChat(messages)
                        }
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
}

struct ToolbarContent: View {
    @Binding var messages: [Message]
    let isIncognitoMode: Bool
    let selectedAIMode: AIMode
    @Binding var showingModeSelector: Bool
    let dailyMessageCount: Int
    let FREE_DAILY_LIMIT: Int
    @Binding var showingLimitPopup: Bool
    @Binding var showingUpgradeView: Bool
    @Binding var showingChatHistory: Bool
    @Binding var showingSettings: Bool
    @AppStorage("lastMessageDate") private var lastMessageDate = Date()
    @AppStorage("isPremium") private var isPremium = false
    var onSaveChat: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 14) {
            if !messages.isEmpty {
                Button(action: {
                    if !messages.isEmpty && !isIncognitoMode {
                        // Mevcut sohbeti kaydet
                        StorageManager.shared.saveChat(messages)
                        onSaveChat?()
                    }
                    withAnimation {
                        messages.removeAll()
                    }
                }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }

            Button(action: {
                showingModeSelector = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: selectedAIMode.icon)
                        .font(.system(size: 16, weight: .semibold))
                    Text(selectedAIMode.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(AppTheme.controlBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppTheme.outline))
            }

            if (FREE_DAILY_LIMIT - dailyMessageCount) < 5 {
                Button(action: { showingLimitPopup = true }) {
                    limitIndicator
                }
            }

            Button(action: {
                showingUpgradeView = true
            }) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.controlBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if !isIncognitoMode {
                Button(action: {
                    showingChatHistory = true
                }) {
                    Image(systemName: "clock")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .transition(.opacity)
            }

            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.controlBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.2, style: .continuous)
                .fill(AppTheme.secondaryBackground.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.2, style: .continuous)
                        .stroke(AppTheme.outline)
                )
        )
        .shadow(color: Color.black.opacity(0.26), radius: 24, x: 0, y: 18)
    }

    private var limitIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: "message.badge.filled.fill")
                .foregroundColor(dailyMessageCount >= FREE_DAILY_LIMIT ? AppTheme.destructive : AppTheme.accent)
                .symbolEffect(.pulse)
                .font(.system(size: 14))

            VStack(alignment: .leading, spacing: 1) {
                Text("\(FREE_DAILY_LIMIT - dailyMessageCount) left")
                    .font(.system(size: 12, weight: .medium))

                if dailyMessageCount >= FREE_DAILY_LIMIT {
                    Text("Resets in \(timeUntilResetText())")
                        .font(.system(size: 10))
                }
            }
            .foregroundColor(dailyMessageCount >= FREE_DAILY_LIMIT ? AppTheme.destructive : AppTheme.accent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(AppTheme.controlBackground)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppTheme.outline))
    }

    private func timeUntilResetText() -> String {
        let now = Date()
        let resetTime = lastMessageDate.addingTimeInterval(24 * 60 * 60)
        let components = Calendar.current.dateComponents([.hour, .minute], from: now, to: resetTime)

        guard let hours = components.hour, let minutes = components.minute else {
            return "0m"
        }

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct MessagesView: View {
    @Binding var messages: [Message]
    @Binding var currentInput: String
    @Binding var isLoading: Bool
    @Binding var keyboardHeight: CGFloat
    @Binding var selectedAIModel: String
    @Binding var showingModeSelector: Bool
    
    var body: some View {
        Group {
            if messages.isEmpty {
                WelcomeView(messages: $messages, currentInput: $currentInput, showingModeSelector: $showingModeSelector)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
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
                                .frame(height: keyboardHeight > 0 ? 8 : 0)
                                .id("keyboard")
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 24)
                        .padding(.bottom, 12)
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
                    .background(Color.clear)
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Ensure status bar follows system appearance
        return true
    }
}

// Status Bar Style Controller
class StatusBarStyleController: ObservableObject {
    @Published var style: UIStatusBarStyle = .default
    
    static let shared = StatusBarStyleController()
}

extension View {
    func statusBarStyle(_ style: UIStatusBarStyle) -> some View {
        StatusBarStyleController.shared.style = style
        return self
    }
}
