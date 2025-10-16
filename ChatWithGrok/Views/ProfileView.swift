import SwiftUI

struct ProfileView: View {
    @AppStorage("userProfile") private var userProfileData: Data = Data()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if let profile = try? JSONDecoder().decode(UserProfile.self, from: userProfileData) {
                    ScrollView {
                        VStack(spacing: 20) {
                            statsCard(title: "Overview", items: [
                                .metric(label: "Total Prompts", value: "\(profile.totalPrompts)"),
                                .metric(label: "Avg Prompts / Day", value: String(format: "%.1f", profile.averagePromptsPerDay))
                            ])
                            
                            if let mostActiveDay = profile.mostActiveDay {
                                statsCard(
                                    title: "Most Active Day",
                                    items: [.detail(label: formatDate(dateString: mostActiveDay.date), value: "\(mostActiveDay.count) prompts")]
                                )
                            }
                            
                            statsCard(title: "AI Interaction", items: [
                                .metric(label: "Favorite Mode", value: profile.favoriteAIMode.rawValue),
                                .metric(label: "Avg Response", value: String(format: "%.2f s", profile.averageResponseTime)),
                                .metric(label: "Chars Sent", value: "\(profile.totalCharactersSent)"),
                                .metric(label: "Chars Received", value: "\(profile.totalCharactersReceived)")
                            ])
                            
                            statsCard(title: "Model Usage", items:
                                profile.mostUsedAIModels
                                    .sorted { $0.value > $1.value }
                                    .map { .detail(label: $0.key, value: "\($0.value) sessions") }
                            )
                            
                            statsCard(title: "Activity", items: [
                                .detail(label: "Last Active", value: formatDate(date: profile.lastActive))
                            ])
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.exclam")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("No profile data available")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Start chatting to see your stats appear here.")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(32)
                }
            }
            .background(
                LinearGradient(
                    colors: [AppTheme.background, AppTheme.secondaryBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("User Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.controlBackground)
                    .foregroundColor(AppTheme.accent)
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    private func statsCard(title: String, items: [StatItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    switch item {
                    case .metric(let label, let value):
                        HStack {
                            Text(label)
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(value)
                                .foregroundColor(AppTheme.textPrimary)
                                .fontWeight(.semibold)
                        }
                    case .detail(let label, let value):
                        VStack(alignment: .leading, spacing: 4) {
                            Text(label)
                                .foregroundColor(AppTheme.textPrimary)
                                .fontWeight(.semibold)
                            Text(value)
                                .foregroundColor(AppTheme.textSecondary)
                                .font(.system(size: 13))
                        }
                    }
                    if index != items.count - 1 {
                        Divider().background(AppTheme.outline)
                    }
                }
            }
            .padding(18)
            .background(Color.clear)
            .liquidGlass(.card, tint: AppTheme.accent, tintOpacity: 0.05)
        }
    }
    
    private enum StatItem {
        case metric(label: String, value: String)
        case detail(label: String, value: String)
    }

    private func formatDate(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "d MMM yyyy"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
} 