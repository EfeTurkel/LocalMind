import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var showConfetti = false
    @State private var now = Date()
    private let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.colorScheme) private var colorScheme
    @State private var userName = ""
    @AppStorage("userProfile") private var userProfileData: Data = Data()
    @State private var currentPage = 0
    @AppStorage("userName") private var savedUserName = ""
    
    var body: some View {
        TabView(selection: $currentPage) {
            // İlk sayfa - xAI ve Grok tanıtımı
            VStack(spacing: 0) {
                // Üst boşluk
                Spacer()
                    .frame(height: 200)
                
                // xAI logosu ve marka
                VStack(spacing: 24) {
                    // xAI logosu
                    Image("xai_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.8), .blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 12) {
                        Text("Powered by")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Most Successful AI Models")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                .padding(.bottom, 60)
                
                Spacer()
                
                // Alt kısım
                VStack(spacing: 20) {
                    Text("Experience the Future of AI")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Chat with the most advanced AI models")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding()
            .frame(maxWidth: 520)
            .tag(0)
            
            // İkinci sayfa - Özellikler
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Custom AI Models")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose from different AI models\nfor specialized conversations")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    Image(systemName: "message.and.waveform")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Natural Conversations")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Chat naturally and get\nhuman-like responses")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Secure Access")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Use your API key for\nsecure communication")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: 520)
            .tag(1)
            
            // Günlük destek sayfası (Premium yerine)
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 40)
                
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue)
                    .symbolEffect(.bounce)
                
                Text("Keep the App Free")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Support the app once per day to help keep it free")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                Text("Today's status: \(isTipAvailable() ? "Ready" : "Completed ✅")")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                        Text("Your support helps keep the app free")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 5)
                
                HStack(spacing: 12) {
                    Button(action: {
                        currentPage = 3 // İsim girişi sayfasına geç
                    }) {
                        Text("Later")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        if TipStorage.shared.isTipAvailable(now: now) {
                            showConfetti = true
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            TipStorage.shared.setLastTipDate(Date())
                            TipStorage.shared.incrementTipCount()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                showConfetti = false
                                currentPage = 3
                            }
                        } else {
                            let warning = UINotificationFeedbackGenerator()
                            warning.notificationOccurred(.warning)
                        }
                    }) {
                        Text(TipStorage.shared.isTipAvailable(now: now) ? "Support Today" : "Completed")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(TipStorage.shared.isTipAvailable(now: now) ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!TipStorage.shared.isTipAvailable(now: now))
                    
                    if !TipStorage.shared.isTipAvailable(now: now) {
                        Text("You can support again in \(TipStorage.shared.timeRemainingString(now: now)).")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 15)
                
                if showConfetti {
                    ConfettiView(duration: 1.2)
                        .transition(.opacity)
                }
            }
            .padding()
            .frame(maxWidth: 520)
            .tag(2)
            
            // İsim girişi sayfası
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("What's your name?")
                    .font(.title)
                    .fontWeight(.bold)
                
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    savedUserName = userName
                    hasSeenOnboarding = true
                }) {
                    Text("Get Started")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(userName.isEmpty)
                
                Spacer()
            }
            .frame(maxWidth: 520)
            .tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
}

extension OnboardingView {
    private func isTipAvailable() -> Bool {
        return TipStorage.shared.isTipAvailable(now: now)
    }
    
    private func timeRemainingString() -> String {
        return TipStorage.shared.timeRemainingString(now: now)
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let imageName: String
    var isLastPage: Bool = false
    var hasSeenOnboarding: Binding<Bool>? = nil
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .symbolEffect(.bounce)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.bottom, 50)
    }
}

struct ModelFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SocialMediaLink: View {
    let platform: String
    let username: String
    let url: String
    var icon: String? = nil // Özel ikon için opsiyonel parametre
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon ?? (platform == "twitter" ? "bird" : "link"))
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(username)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
} 