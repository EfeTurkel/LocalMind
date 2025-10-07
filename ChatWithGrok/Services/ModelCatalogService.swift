import Foundation

struct ProviderModel: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let provider: String
    let updatedAt: Date?
}

class ModelCatalogService {
    static let shared = ModelCatalogService()
    private init() {}
    
    // OpenAI: GET /v1/models
    func fetchOpenAIModels(apiKey: String) async throws -> [ProviderModel] {
        guard let url = URL(string: "https://api.openai.com/v1/models") else { return [] }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return [] }
        if let decoded = try? JSONDecoder().decode(OpenAIModelList.self, from: data) {
            // Keep chat-capable and recent families: gpt-*, o1-*. Exclude embeddings/audio/realtime/fine-tunes
            let filtered = decoded.data.compactMap { m -> ProviderModel? in
                let id = m.id
                let lower = id.lowercased()
                let isChatFamily = lower.hasPrefix("gpt-") || lower.hasPrefix("o1-")
                let isExcluded = lower.contains("embedding") || lower.contains("realtime") || lower.contains("audio") || lower.contains("whisper") || lower.contains("tts")
                guard isChatFamily && !isExcluded else { return nil }
                return ProviderModel(id: id, name: id, description: "OpenAI model", provider: "OpenAI", updatedAt: nil)
            }
            if filtered.isEmpty {
                return [
                    ProviderModel(id: "gpt-4o", name: "GPT-4o", description: "Fast and multimodal", provider: "OpenAI", updatedAt: nil),
                    ProviderModel(id: "gpt-4o-mini", name: "GPT-4o Mini", description: "Affordable and efficient", provider: "OpenAI", updatedAt: nil),
                    ProviderModel(id: "o1-mini", name: "o1 Mini", description: "Reasoning-optimized", provider: "OpenAI", updatedAt: nil)
                ]
            }
            return filtered
        }
        return []
    }
    
    // Anthropic (Claude): GET /v1/models
    func fetchClaudeModels(apiKey: String) async throws -> [ProviderModel] {
        guard let url = URL(string: "https://api.anthropic.com/v1/models") else { return [] }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return [] }
        if let decoded = try? JSONDecoder().decode(AnthropicModelList.self, from: data) {
            // Only Claude chat families
            let filtered = decoded.data.compactMap { m -> ProviderModel? in
                let id = m.id
                guard id.hasPrefix("claude-") else { return nil }
                return ProviderModel(id: id, name: id, description: "Claude model", provider: "Claude", updatedAt: nil)
            }
            if filtered.isEmpty {
                return [
                    ProviderModel(id: "claude-3-5-sonnet-20241022", name: "Claude 3.5 Sonnet", description: "Most capable", provider: "Claude", updatedAt: nil),
                    ProviderModel(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku", description: "Fast and affordable", provider: "Claude", updatedAt: nil)
                ]
            }
            return filtered
        }
        return []
    }
    
    // Google Gemini: GET /v1beta/models (requires key)
    func fetchGeminiModels(apiKey: String) async throws -> [ProviderModel] {
        guard !apiKey.isEmpty else { return [] }
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models?key=\(apiKey)") else { return [] }
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return [] }
        if let decoded = try? JSONDecoder().decode(GeminiModelList.self, from: data) {
            // Filter by family and recency (last 60 days based on updateTime or createTime)
            let now = Date()
            let cutoff = now.addingTimeInterval(-60 * 24 * 60 * 60) // ~60 days
            let isoParser = ISO8601DateFormatter()
            isoParser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let isoFallback = ISO8601DateFormatter() // without fractional seconds
            let filtered = decoded.models.compactMap { m -> ProviderModel? in
                guard m.name.contains("gemini") else { return nil }
                let id = m.name.replacingOccurrences(of: "models/", with: "")
                let timeStr = m.updateTime ?? m.createTime
                // Include if timestamp is within last 60 days; if timestamp missing/unparseable, keep (some APIs omit these)
                if let ts = timeStr {
                    let dt = isoParser.date(from: ts) ?? isoFallback.date(from: ts)
                    if let dt = dt, dt < cutoff { return nil }
                    return ProviderModel(id: id, name: m.displayName ?? id, description: m.description ?? "Gemini model", provider: "Gemini", updatedAt: dt)
                }
                return ProviderModel(id: id, name: m.displayName ?? id, description: m.description ?? "Gemini model", provider: "Gemini", updatedAt: nil)
            }
            // If everything filtered out (e.g. timestamps missing), provide a minimal recent default set
            if filtered.isEmpty {
                return [
                    ProviderModel(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro", description: "Powerful and versatile", provider: "Gemini", updatedAt: nil),
                    ProviderModel(id: "gemini-1.5-flash", name: "Gemini 1.5 Flash", description: "Fast and efficient", provider: "Gemini", updatedAt: nil)
                ]
            }
            return filtered
        }
        return []
    }
}

// MARK: - OpenAI Types
private struct OpenAIModelList: Codable { let data: [OpenAIModel] }
private struct OpenAIModel: Codable { let id: String }

// MARK: - Anthropic Types
private struct AnthropicModelList: Codable { let data: [AnthropicModel] }
private struct AnthropicModel: Codable { let id: String }

// MARK: - Gemini Types
private struct GeminiModelList: Codable { let models: [GeminiModel] }
private struct GeminiModel: Codable {
    let name: String
    let displayName: String?
    let description: String?
    let createTime: String?
    let updateTime: String?
}


