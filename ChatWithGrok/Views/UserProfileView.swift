import SwiftUI
import Charts

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userProfile") private var userProfileData: Data = Data()
    
    var body: some View {
        NavigationView {
            if let profile = try? JSONDecoder().decode(UserProfile.self, from: userProfileData) {
                Form {
                    Section("Statistics") {
                        HStack {
                            Text("Total Prompts:")
                            Spacer()
                            Text("\(profile.totalPrompts)")
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
                        
                        HStack {
                            Text("Average Response Time:")
                            Spacer()
                            Text(String(format: "%.2f seconds", profile.averageResponseTime))
                        }
                    }
                    
                    Section("Preferences") {
                        HStack {
                            Text("Favorite AI Mode:")
                            Spacer()
                            Text(profile.favoriteAIMode.rawValue.capitalized)
                        }
                        
                        Section("Most Used AI Models") {
                            ForEach(profile.mostUsedAIModels.sorted(by: >), id: \.key) { model, count in
                                HStack {
                                    Text(model.capitalized)
                                    Spacer()
                                    Text("\(count)")
                                }
                            }
                        }
                    }
                    
                    Section("Activity") {
                        HStack {
                            Text("Last Active:")
                            Spacer()
                            Text(profile.lastActive, style: .date)
                        }
                        
                        HStack {
                            Text("Daily Prompts:")
                            Spacer()
                            Text("\(profile.dailyPrompts.values.reduce(0, +))")
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
                                Text("\(mostActiveDay.date) (\(mostActiveDay.count))")
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weekly Activity")
                                .font(.headline)
                            
                            Chart(profile.weeklyActivity.sorted(by: <), id: \.key) { entry in
                                BarMark(
                                    x: .value("Day", entry.key),
                                    y: .value("Prompts", entry.value)
                                )
                                .foregroundStyle(Color.blue)
                            }
                            .frame(height: 200)
                        }
                    }
                }
                .navigationTitle("User Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            } else {
                Text("No user profile data found.")
                    .padding()
            }
        }
    }
} 