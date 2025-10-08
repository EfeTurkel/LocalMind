import SwiftUI

struct SettingsView: View {
    @AppStorage("preferredColorScheme") private var preferredColorScheme: Int = 0
    @AppStorage("isIncognitoMode") private var isIncognitoMode = false
    @Binding var apiKey: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("dailyMessageCount") private var dailyMessageCount = 0
    @AppStorage("isPremium") private var isPremium = true
    @State private var showingUpgradeView = false
    @AppStorage("lastMessageDate") private var lastMessageDate = Date()
    @State private var showingCreatorInfo = false
    @State private var showingPersonalizationView = false
    @AppStorage("selectedAIModel") private var selectedAIModel: String = "grok-beta"
    @State private var showingAIModelSelector = false
    @State private var showingAdvancedSettings = false
    @State private var showingProfileView = false
    @AppStorage("avatar") private var avatar = "xai2_logo"
    @AppStorage("userName") private var userName = ""
    @State private var showingProfileSettings = false
    let FREE_DAILY_LIMIT = 20
    let aiModels = ["grok-beta", "grok-alpha", "grok-lite", "gemini-1.5-flash", "gpt-4", "gpt-4-mini"]
    @AppStorage("minimalHome") private var minimalHome = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(action: { showingUpgradeView = true }) {
                        HStack {
                            Image(systemName: "hands.sparkles.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.tint)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Support")
                                    .font(.headline)
                                    .foregroundColor(systemColorScheme == .dark ? .white : .black)
                                
                                Text("Tap once a day to help keep the app free")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Section("Profile") {
                    Button(action: {
                        showingProfileSettings = true
                    }) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                            Text("Profile")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        showingProfileView = true
                    }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                            Text("User Statistics")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("API Keys") {
                    Button(action: {
                        showingAdvancedSettings = true
                    }) {
                        HStack {
                            Image(systemName: "key.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.tint)
                            Text("Manage API Keys")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("AI Model") {
                    Button(action: {
                        showingAIModelSelector = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Selected Model")
                                    .foregroundColor(systemColorScheme == .dark ? .white : .black)
                                Text(getModelDisplayName(selectedAIModel))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showingPersonalizationView = true
                    }) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.tint)
                            Text("Customize AI Model")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Daily limit UI kaldırıldı; tüm özellikler ücretsiz
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $preferredColorScheme) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                    
                    Toggle(isOn: $isIncognitoMode) {
                        Label {
                            Text("Incognito Mode")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                        } icon: {
                            Image(systemName: "eye.slash")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                        }
                    }
                    
                    if isIncognitoMode {
                        Text("Your messages will not be saved.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Toggle(isOn: $minimalHome) {
                        Label {
                            Text("Minimal Home")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                        } icon: {
                            Image(systemName: "rectangle.topthird.inset.filled")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                        }
                    }
                    Text("Show only the top and bottom bars on the home screen.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section("About") {
                    HStack {
                        Text("App Name")
                            .foregroundColor(systemColorScheme == .dark ? .white : .black)
                        Spacer()
                        Text("LockMind")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        showingCreatorInfo = true
                    }) {
                        HStack {
                            Text("Creator")
                                .foregroundColor(systemColorScheme == .dark ? .white : .black)
                            Spacer()
                            Text("Efe Türkel")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .tint(.blue)
            .listStyle(.insetGrouped)
            .sheet(isPresented: $showingPersonalizationView) {
                PersonalizationView(avatar: $avatar)
            }
            .sheet(isPresented: $showingAIModelSelector) {
                AIModelSelectorView()
            }
            .sheet(isPresented: $showingAdvancedSettings) {
                AdvancedSettingsView(apiKey: $apiKey)
            }
            .sheet(isPresented: $showingProfileView) {
                ProfileView()
            }
            .sheet(isPresented: $showingProfileSettings) {
                ProfileSettingsView()
            }
        }
        .preferredColorScheme(getPreferredColorScheme())
        .onChange(of: systemColorScheme) { oldValue, newValue in
            if preferredColorScheme == 0 {
                withAnimation {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("UpdateColorScheme"),
                        object: nil
                    )
                }
            }
        }
        .sheet(isPresented: $showingUpgradeView) { UpgradeView() }
        .sheet(isPresented: $showingCreatorInfo) {
            CreatorView()
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
        
        return "soon"
    }
    
    private func getPreferredColorScheme() -> ColorScheme? {
        switch preferredColorScheme {
        case 0:
            return nil // System
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }
    
    private func getModelDisplayName(_ modelId: String) -> String {
        switch modelId {
        // Grok Models
        case "grok-beta":
            return "Grok Beta"
        case "grok-2-1212":
            return "Grok 2"
        case "grok-vision-beta":
            return "Grok Vision"
        // OpenAI Models
        case "gpt-5-preview":
            return "GPT-5 Preview"
        case "o1-preview":
            return "o1 Preview"
        case "o1-mini":
            return "o1 Mini"
        case "gpt-4o":
            return "GPT-4o"
        case "gpt-4o-mini":
            return "GPT-4o Mini"
        case "gpt-4-turbo":
            return "GPT-4 Turbo"
        // Claude Models
        case "claude-3-5-sonnet-20241022":
            return "Claude 3.5 Sonnet"
        case "claude-3-opus-20240229":
            return "Claude 3 Opus"
        case "claude-3-sonnet-20240229":
            return "Claude 3 Sonnet"
        case "claude-3-haiku-20240307":
            return "Claude 3 Haiku"
        // Gemini Models
        case "gemini-2.0-flash-exp":
            return "Gemini 2.0 Flash"
        case "gemini-exp-1206":
            return "Gemini 2.0 Pro"
        case "gemini-1.5-pro":
            return "Gemini 1.5 Pro"
        case "gemini-1.5-flash":
            return "Gemini 1.5 Flash"
        default:
            return modelId
        }
    }
}

struct AIModelSelectorView: View {
    @AppStorage("selectedAIModel") private var selectedAIModel: String = "grok-beta"
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var openAIModels: [AIModelInfo] = []
    @State private var claudeModels: [AIModelInfo] = []
    @State private var geminiModels: [AIModelInfo] = []
    @State private var grokModels: [AIModelInfo] = []
    @State private var searchText = ""
    @State private var selectedProvider: String = "All"
    
    struct AIModelInfo: Identifiable {
        let id: String
        let name: String
        let description: String
        let provider: String
        let tier: String
    }
    
    private func loadAllProviders() async {
        await MainActor.run { isLoading = true }
        do {
            // OpenAI
            if let key = UserDefaults.standard.string(forKey: "openAIAPIKey"), !key.isEmpty {
                let models = try await ModelCatalogService.shared.fetchOpenAIModels(apiKey: key)
                await MainActor.run {
                    openAIModels = models.map { AIModelInfo(id: $0.id, name: $0.name, description: $0.description, provider: "OpenAI", tier: "") }
                }
            } else {
                await MainActor.run {
                    openAIModels = [
                        AIModelInfo(id: "gpt-4o", name: "GPT-4o", description: "Fast and multimodal", provider: "OpenAI", tier: ""),
                        AIModelInfo(id: "gpt-4o-mini", name: "GPT-4o Mini", description: "Affordable and efficient", provider: "OpenAI", tier: ""),
                        AIModelInfo(id: "o1-mini", name: "o1 Mini", description: "Reasoning-optimized", provider: "OpenAI", tier: "")
                    ]
                }
            }
            // Claude
            if let key = UserDefaults.standard.string(forKey: "claudeAPIKey"), !key.isEmpty {
                let models = try await ModelCatalogService.shared.fetchClaudeModels(apiKey: key)
                await MainActor.run {
                    claudeModels = models.map { AIModelInfo(id: $0.id, name: $0.name, description: $0.description, provider: "Claude", tier: "") }
                }
            } else {
                await MainActor.run {
                    claudeModels = [
                        AIModelInfo(id: "claude-3-5-sonnet-20241022", name: "Claude 3.5 Sonnet", description: "Most capable", provider: "Claude", tier: ""),
                        AIModelInfo(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku", description: "Fast and affordable", provider: "Claude", tier: "")
                    ]
                }
            }
            // Gemini
            if let key = UserDefaults.standard.string(forKey: "geminiAPIKey"), !key.isEmpty {
                let models = try await ModelCatalogService.shared.fetchGeminiModels(apiKey: key)
                // Separate main vs preview/exp
                let mains = models.filter { !$0.id.contains("preview") && !$0.id.contains("exp") }
                let previews = models.filter { $0.id.contains("preview") || $0.id.contains("exp") }
                // Select only the most recent preview by updatedAt (fallback to name sort)
                let mostRecentPreview = previews.sorted { (a, b) in
                    let ad = a.updatedAt ?? Date.distantPast
                    let bd = b.updatedAt ?? Date.distantPast
                    return ad > bd
                }.first
                let finalList = mains + (mostRecentPreview != nil ? [mostRecentPreview!] : [])
                await MainActor.run {
                    geminiModels = finalList.map { AIModelInfo(id: $0.id, name: $0.name, description: $0.description, provider: "Gemini", tier: "") }
                }
            } else {
                await MainActor.run {
                    geminiModels = [
                        AIModelInfo(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro", description: "Powerful and versatile", provider: "Gemini", tier: ""),
                        AIModelInfo(id: "gemini-1.5-flash", name: "Gemini 1.5 Flash", description: "Fast and efficient", provider: "Gemini", tier: ""),
                        AIModelInfo(id: "gemini-2.0-flash-exp", name: "Gemini 2.0 Flash (Preview)", description: "Latest experimental model", provider: "Gemini", tier: "")
                    ]
                }
            }
            // Grok fallback
            await MainActor.run {
                grokModels = [
                    AIModelInfo(id: "grok-beta", name: "Grok Beta", description: "Grok general model", provider: "Grok", tier: ""),
                    AIModelInfo(id: "grok-vision-beta", name: "Grok Vision", description: "Multimodal with vision", provider: "Grok", tier: "")
                ]
            }
        } catch {
            // Silent fail; sections will show empty with hint
        }
        await MainActor.run { isLoading = false }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Picker("Provider", selection: $selectedProvider) {
                            Text("All").tag("All")
                            Text("Grok").tag("Grok")
                            Text("OpenAI").tag("OpenAI")
                            Text("Claude").tag("Claude")
                            Text("Gemini").tag("Gemini")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)

                    if isLoading {
                        // Skeleton grid while loading
                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(0..<6) { _ in
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 88)
                                    .redacted(reason: .placeholder)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        let models = filteredModels()
                        if models.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.secondary)
                                Text("No models found")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Text("Try a different provider or search term")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 24)
                        } else {
                            LazyVGrid(columns: gridColumns, spacing: 12) {
                                ForEach(models, id: \.id) { model in
                                    DetailedModelCard(model: model, isSelected: selectedAIModel == model.id)
                                        .onTapGesture {
                                            selectedAIModel = model.id
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                        }
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel("\(model.provider) \(model.name)")
                                        .accessibilityHint("Double tap to select this model")
                                        .accessibilityAddTraits(selectedAIModel == model.id ? .isSelected : [])
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Button(action: { Task { await loadAllProviders() } }) {
                        Text("Refresh")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .navigationTitle("Select AI Model")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } } }
            .refreshable { await loadAllProviders() }
        }
        .task { await loadAllProviders() }
    }
    
    private func filteredModels() -> [AIModelInfo] {
        let all = grokModels + openAIModels + claudeModels + geminiModels
        return all.filter { model in
            let providerMatches = (selectedProvider == "All") || (model.provider == selectedProvider)
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let searchMatches = query.isEmpty || model.name.localizedCaseInsensitiveContains(query) || model.description.localizedCaseInsensitiveContains(query) || model.id.localizedCaseInsensitiveContains(query)
            return providerMatches && searchMatches
        }
    }

    private var gridColumns: [GridItem] {
        let minWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 260 : 220
        return [GridItem(.adaptive(minimum: minWidth, maximum: 400), spacing: 12)]
    }
}

// Model Section Component
struct ModelSection: View {
    let title: String
    let models: [AIModelSelectorView.AIModelInfo]
    @Binding var selectedModel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ForEach(models) { model in
                DetailedModelCard(model: model, isSelected: selectedModel == model.id)
                    .onTapGesture {
                        selectedModel = model.id
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
            }
        }
    }
}

// Detailed Model Card
struct DetailedModelCard: View {
    let model: AIModelSelectorView.AIModelInfo
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                Image(systemName: iconForProvider(model.provider))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tint)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(model.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 8)
                    
                    Text(model.tier)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(.secondarySystemBackground)))
                }
                
                Text(model.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.06), radius: isSelected ? 10 : 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Color.accentColor.opacity(0.6) : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
    
    private func tierColor(_ tier: String) -> Color {
        switch tier {
        case "Premium":
            return .orange
        case "Standard":
            return .blue
        case "Experimental":
            return .purple
        default:
            return .gray
        }
    }
    
    private func iconForProvider(_ provider: String) -> String {
        switch provider {
        case "OpenAI": return "brain.head.profile"
        case "Claude": return "sparkles"
        case "Gemini": return "star.circle"
        case "Grok": return "bolt"
        default: return "cpu"
        }
    }
}


struct AdvancedSettingsView: View {
    @Binding var apiKey: String
    @State private var grokAPIKey: String = ""
    @State private var openAIAPIKey: String = ""
    @State private var claudeAPIKey: String = ""
    @State private var geminiAPIKey: String = ""
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveNotification = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Keys")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Grok API Key")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        LockField("Enter Grok API Key", text: $grokAPIKey)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OpenAI API Key")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        LockField("Enter OpenAI API Key", text: $openAIAPIKey)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Claude (Anthropic) API Key")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        LockField("Enter Claude API Key", text: $claudeAPIKey)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Google Gemini API Key")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        LockField("Enter Gemini API Key", text: $geminiAPIKey)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Text("Your API keys are stored securely on your device and never sent to our servers.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Feedback") {
                    Toggle(isOn: $hapticFeedbackEnabled) {
                        Label {
                            Text("Haptic Feedback")
                        } icon: {
                            Image(systemName: hapticFeedbackEnabled ? "iphone.radiowaves.left.and.right" : "iphone")
                        }
                    }
                    
                    if hapticFeedbackEnabled {
                        Text("Feel a gentle vibration when receiving messages")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Manage API Keys")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAPIKeys()
                    }
                }
            }
            .overlay(
                Group {
                    if showingSaveNotification {
                        SavedNotificationView()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            )
        }
        .onAppear {
            loadAPIKeys()
        }
    }
    
    private func loadAPIKeys() {
        grokAPIKey = UserDefaults.standard.string(forKey: "grokApiKey") ?? ""
        openAIAPIKey = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
        claudeAPIKey = UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
        geminiAPIKey = UserDefaults.standard.string(forKey: "geminiAPIKey") ?? ""
    }
    
    private func saveAPIKeys() {
        // Save to UserDefaults
        UserDefaults.standard.set(grokAPIKey, forKey: "grokApiKey")
        UserDefaults.standard.set(openAIAPIKey, forKey: "openAIAPIKey")
        UserDefaults.standard.set(claudeAPIKey, forKey: "claudeAPIKey")
        UserDefaults.standard.set(geminiAPIKey, forKey: "geminiAPIKey")
        
        // Update binding
        apiKey = grokAPIKey
        
        // Update Gemini service
        if !geminiAPIKey.isEmpty {
            GeminiService.shared.updateAPIKey(geminiAPIKey)
        }
        
        // Show notification
        withAnimation {
            showingSaveNotification = true
        }
        
        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingSaveNotification = false
            }
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Dismiss after saving
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            dismiss()
        }
    }
}

