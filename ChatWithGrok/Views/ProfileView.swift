import SwiftUI

struct ProfileView: View {
    @AppStorage("userProfile") private var userProfileData: Data = Data()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if let profile = try? JSONDecoder().decode(UserProfile.self, from: userProfileData) {
                    Form {
                        Section(header: Text("General")) {
                            HStack {
                                Text("Total Prompts:")
                                Spacer()
                                Text("\(profile.totalPrompts)")
                            }
                            
                            HStack {
                                Text("Average Prompts per Day:")
                                Spacer()
                                Text(String(format: "%.1f", profile.averagePromptsPerDay))
                            }
                            
                            if let mostActiveDay = profile.mostActiveDay {
                                HStack {
                                    Text("Most Active Day:")
                                    Spacer()
                                    Text("\(formatDate(dateString: mostActiveDay.date)) (\(mostActiveDay.count) prompts)")
                                }
                            }
                        }
                        
                        Section(header: Text("AI Interaction")) {
                            HStack {
                                Text("Favorite AI Mode:")
                                Spacer()
                                Text(profile.favoriteAIMode.rawValue)
                            }
                            
                            HStack {
                                Text("Average Response Time:")
                                Spacer()
                                Text(String(format: "%.2f seconds", profile.averageResponseTime))
                            }
                            
                            HStack {
                                Text("Characters Sent:")
                                Spacer()
                                Text("\(profile.totalCharactersSent)")
                            }
                            
                            HStack {
                                Text("Characters Received:")
                                Spacer()
                                Text("\(profile.totalCharactersReceived)")
                            }
                        }
                        
                        Section(header: Text("AI Models Usage")) {
                            ForEach(profile.mostUsedAIModels.sorted(by: { $0.value > $1.value }), id: \.key) { model, count in
                                HStack {
                                    Text(model)
                                    Spacer()
                                    Text("\(count) times")
                                }
                            }
                        }
                        
                        Section(header: Text("Activity")) {
                            HStack {
                                Text("Last Active:")
                                Spacer()
                                Text(formatDate(date: profile.lastActive))
                            }
                        }
                    }
                } else {
                    Text("No profile data available.")
                }
            }
            .navigationTitle("User Statistics")
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