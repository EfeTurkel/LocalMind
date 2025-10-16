//
//  APIKeySetupView.swift
//  LockMind
//
//  Created for LockMind
//

import SwiftUI

struct APIKeySetupView: View {
    @Binding var hasAPIKey: Bool
    @Binding var apiKey: String
    @Binding var openAIAPIKey: String
    @State private var claudeAPIKey: String = UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
    @State private var selectedProvider: APIProvider = .grok
    @State private var selectedModel: String = "grok-beta"
    @State private var tempAPIKey: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedAIModel") private var selectedAIModel: String = "grok-beta"
    @State private var isLoadingModels = false
    @State private var fetchedModels: [AIModel] = []
    
    enum APIProvider: String, CaseIterable {
        case grok = "Grok (X.AI)"
        case openai = "OpenAI"
        case claude = "Claude (Anthropic)"
        case gemini = "Google Gemini"
        
        var models: [AIModel] {
            switch self {
            case .grok:
                return [
                    AIModel(id: "grok-beta", name: "Grok Beta", description: "Latest and most capable Grok model", tier: "Premium"),
                    AIModel(id: "grok-2-1212", name: "Grok 2", description: "Advanced reasoning and analysis", tier: "Premium"),
                    AIModel(id: "grok-vision-beta", name: "Grok Vision", description: "Multimodal with vision capabilities", tier: "Premium")
                ]
            case .openai:
                return [
                    AIModel(id: "gpt-5-preview", name: "GPT-5 Preview", description: "Next-generation AI model", tier: "Premium"),
                    AIModel(id: "o1-preview", name: "o1 Preview", description: "Advanced reasoning model", tier: "Premium"),
                    AIModel(id: "o1-mini", name: "o1 Mini", description: "Faster reasoning model", tier: "Premium"),
                    AIModel(id: "gpt-4o", name: "GPT-4o", description: "Fast and multimodal", tier: "Premium"),
                    AIModel(id: "gpt-4o-mini", name: "GPT-4o Mini", description: "Affordable and efficient", tier: "Standard")
                ]
            case .claude:
                return [
                    AIModel(id: "claude-3-5-sonnet-20241022", name: "Claude 3.5 Sonnet", description: "Most intelligent Claude model", tier: "Premium"),
                    AIModel(id: "claude-3-opus-20240229", name: "Claude 3 Opus", description: "Powerful for complex tasks", tier: "Premium"),
                    AIModel(id: "claude-3-sonnet-20240229", name: "Claude 3 Sonnet", description: "Balanced performance", tier: "Standard"),
                    AIModel(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku", description: "Fast and affordable", tier: "Standard")
                ]
            case .gemini:
                return [
                    AIModel(id: "gemini-2.0-flash-exp", name: "Gemini 2.0 Flash", description: "Latest experimental model", tier: "Experimental"),
                    AIModel(id: "gemini-exp-1206", name: "Gemini 2.0 Pro", description: "Most capable Gemini 2.0", tier: "Premium"),
                    AIModel(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro", description: "Powerful and versatile", tier: "Premium"),
                    AIModel(id: "gemini-1.5-flash", name: "Gemini 1.5 Flash", description: "Fast and efficient", tier: "Standard")
                ]
            }
        }
    }
    
    struct AIModel: Identifiable {
        let id: String
        let name: String
        let description: String
        let tier: String
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Welcome to LockMind")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Select your AI provider, model, and enter your API key")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                
                    // API Provider Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Select AI Provider")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Picker("Provider", selection: $selectedProvider) {
                            ForEach(APIProvider.allCases, id: \.self) { provider in
                                Text(provider.rawValue).tag(provider)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .onChange(of: selectedProvider) { oldValue, newValue in
                            Task { await loadModelsForCurrentSelection() }
                        }
                    }
                    
                    // Model Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. Select AI Model")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if isLoadingModels {
                            ProgressView()
                                .padding(.horizontal)
                        }
                        ForEach(fetchedModels) { model in
                            ModelCard(
                                model: model,
                                isSelected: selectedModel == model.id,
                                onTap: {
                                    selectedModel = model.id
                                }
                            )
                        }
                        if fetchedModels.isEmpty && !isLoadingModels {
                            Text("Add your API key to load models for \(selectedProvider.rawValue).")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    }
                    
                    // API Key Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("3. Enter API Key")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LockField("Enter your API key", text: $tempAPIKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to get an API key:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        switch selectedProvider {
                        case .grok:
                            instructionText("1. Visit console.x.ai")
                            instructionText("2. Sign in to your account")
                            instructionText("3. Go to API Keys section")
                            instructionText("4. Create a new API key")
                        case .openai:
                            instructionText("1. Visit platform.openai.com")
                            instructionText("2. Sign in to your account")
                            instructionText("3. Go to API Keys section")
                            instructionText("4. Create a new API key")
                        case .claude:
                            instructionText("1. Visit console.anthropic.com")
                            instructionText("2. Sign in to your account")
                            instructionText("3. Go to API Keys section")
                            instructionText("4. Create a new API key")
                        case .gemini:
                            instructionText("1. Visit makersuite.google.com/app/apikey")
                            instructionText("2. Sign in with Google")
                            instructionText("3. Click 'Create API Key'")
                            instructionText("4. Copy your key")
                        }
                    }
                    .padding(18)
                    .background(Color.clear)
                    .liquidGlass(.card, tint: AppTheme.accent, tintOpacity: 0.05)
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveAPIKey) {
                        Text("Save & Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .fill(tempAPIKey.isEmpty ? AppTheme.outline : AppTheme.accent)
                            )
                            .shadow(color: AppTheme.accent.opacity(tempAPIKey.isEmpty ? 0 : 0.25), radius: tempAPIKey.isEmpty ? 0 : 18, x: 0, y: 12)
                    }
                    .disabled(tempAPIKey.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                    // Continue without API key (Demo Mode)
                    Button(action: {
                        hasAPIKey = true // allow app to proceed in demo mode
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }) {
                        Text("Continue without API key (Demo Mode)")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                            .underline()
                    }
                    .padding(.bottom, 8)
                }
                .padding(.vertical)
            }
            .navigationBarTitle("API Setup", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .interactiveDismissDisabled(true)
        .task {
            await loadModelsForCurrentSelection()
        }
    }
    
    private func instructionText(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.success)
                .font(.system(size: 15, weight: .semibold))
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private func saveAPIKey() {
        guard !tempAPIKey.isEmpty else {
            alertMessage = "Please enter an API key"
            showingAlert = true
            return
        }
        
        // Save selected model
        selectedAIModel = selectedModel
        UserDefaults.standard.set(selectedModel, forKey: "selectedAIModel")
        
        // Save to UserDefaults based on provider
        switch selectedProvider {
        case .grok:
            UserDefaults.standard.set(tempAPIKey, forKey: "grokApiKey")
            apiKey = tempAPIKey
        case .openai:
            UserDefaults.standard.set(tempAPIKey, forKey: "openAIAPIKey")
            openAIAPIKey = tempAPIKey
        case .claude:
            UserDefaults.standard.set(tempAPIKey, forKey: "claudeAPIKey")
            claudeAPIKey = tempAPIKey
        case .gemini:
            UserDefaults.standard.set(tempAPIKey, forKey: "geminiAPIKey")
            GeminiService.shared.updateAPIKey(tempAPIKey)
        }
        
        hasAPIKey = true
        
        // Show success feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func loadModelsForCurrentSelection() async {
        await MainActor.run { isLoadingModels = true; fetchedModels = [] }
        do {
            switch selectedProvider {
            case .openai:
                let key = tempAPIKey.isEmpty ? (UserDefaults.standard.string(forKey: "openAIAPIKey") ?? "") : tempAPIKey
                if key.isEmpty {
                    await MainActor.run {
                        fetchedModels = [
                            AIModel(id: "gpt-4o", name: "GPT-4o", description: "Fast and multimodal", tier: ""),
                            AIModel(id: "gpt-4o-mini", name: "GPT-4o Mini", description: "Affordable and efficient", tier: ""),
                            AIModel(id: "o1-mini", name: "o1 Mini", description: "Reasoning-optimized", tier: "")
                        ]
                        if let first = fetchedModels.first { selectedModel = first.id }
                    }
                } else {
                    let models = try await ModelCatalogService.shared.fetchOpenAIModels(apiKey: key)
                    await MainActor.run {
                        fetchedModels = models.map { AIModel(id: $0.id, name: $0.name, description: $0.description, tier: "") }
                        if let first = fetchedModels.first { selectedModel = first.id }
                    }
                }
            case .claude:
                let key = tempAPIKey.isEmpty ? (UserDefaults.standard.string(forKey: "claudeAPIKey") ?? "") : tempAPIKey
                if key.isEmpty {
                    await MainActor.run {
                        fetchedModels = [
                            AIModel(id: "claude-3-5-sonnet-20241022", name: "Claude 3.5 Sonnet", description: "Most capable", tier: ""),
                            AIModel(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku", description: "Fast and affordable", tier: "")
                        ]
                        if let first = fetchedModels.first { selectedModel = first.id }
                    }
                } else {
                    let models = try await ModelCatalogService.shared.fetchClaudeModels(apiKey: key)
                    await MainActor.run {
                        fetchedModels = models.map { AIModel(id: $0.id, name: $0.name, description: $0.description, tier: "") }
                        if let first = fetchedModels.first { selectedModel = first.id }
                    }
                }
            case .gemini:
                let key = tempAPIKey.isEmpty ? (UserDefaults.standard.string(forKey: "geminiAPIKey") ?? "") : tempAPIKey
                if key.isEmpty {
                    await MainActor.run {
                        fetchedModels = [
                            AIModel(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro", description: "Powerful and versatile", tier: ""),
                            AIModel(id: "gemini-1.5-flash", name: "Gemini 1.5 Flash", description: "Fast and efficient", tier: ""),
                            AIModel(id: "gemini-2.0-flash-exp", name: "Gemini 2.0 Flash (Preview)", description: "Latest experimental model", tier: "")
                        ]
                        if let first = fetchedModels.first { selectedModel = first.id }
                    }
                } else {
                    let models = try await ModelCatalogService.shared.fetchGeminiModels(apiKey: key)
                    await MainActor.run {
                        fetchedModels = models.map { AIModel(id: $0.id, name: $0.name, description: $0.description, tier: "") }
                        if let first = fetchedModels.first { selectedModel = first.id }
                    }
                }
            case .grok:
                // Fallback: xAI public model list yok
                let defaults = [
                    AIModel(id: "grok-beta", name: "Grok Beta", description: "Grok general model", tier: ""),
                    AIModel(id: "grok-vision-beta", name: "Grok Vision", description: "Multimodal with vision", tier: "")
                ]
                await MainActor.run {
                    fetchedModels = defaults
                    if let first = fetchedModels.first { selectedModel = first.id }
                }
            }
        } catch {
            await MainActor.run { fetchedModels = [] }
        }
        await MainActor.run { isLoadingModels = false }
    }
}

// Model Card Component
struct ModelCard: View {
    let model: APIKeySetupView.AIModel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(model.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        // Premium/Standard etiketlerini kaldır
                    }
                    
                    Text(model.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.accent)
                        .font(.system(size: 20, weight: .semibold))
                }
            }
            .padding()
            .background(Color.clear)
            .liquidGlass(.card, tint: AppTheme.accent, tintOpacity: 0.05)
            .shadow(color: Color.black.opacity(isSelected ? 0.25 : 0.12), radius: isSelected ? 18 : 10, x: 0, y: 12)
        }
        .buttonStyle(PlainButtonStyle())
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
}

#Preview {
    struct PreviewWrapper: View {
        @State private var hasAPIKey = false
        @State private var apiKey = ""
        @State private var openAIAPIKey = ""
        
        var body: some View {
            APIKeySetupView(
                hasAPIKey: $hasAPIKey,
                apiKey: $apiKey,
                openAIAPIKey: $openAIAPIKey
            )
        }
    }
    return PreviewWrapper()
}

