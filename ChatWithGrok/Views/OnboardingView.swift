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
    private let totalPages = 4
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
                        .frame(width: 160, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 12) {
                        Text("Powered by")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Most Successful AI Models")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 90, height: 90)
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 38))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                    }
                    
                    Text("Custom AI Models")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("Choose from different AI models\nfor specialized conversations")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 90, height: 90)
                        Image(systemName: "message.and.waveform")
                            .font(.system(size: 38))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                    }
                    
                    Text("Natural Conversations")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("Chat naturally and get\nhuman-like responses")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 90, height: 90)
                        Image(systemName: "key.fill")
                            .font(.system(size: 38))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                    }
                    
                    Text("Secure Access")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
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

        // Bottom progress bar & controls
        VStack(spacing: 10) {
            ProgressView(value: Double(currentPage + 1), total: Double(totalPages))
                .progressViewStyle(.linear)
            HStack {
                Button(action: { withAnimation { currentPage = max(0, currentPage - 1) } }) {
                    Label("Back", systemImage: "chevron.left")
                }
                .disabled(currentPage == 0)
                Spacer()
                Button(action: {
                    withAnimation {
                        if currentPage < totalPages - 1 {
                            currentPage += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                    }
                }) {
                    Label(currentPage < totalPages - 1 ? "Next" : "Finish", systemImage: currentPage < totalPages - 1 ? "chevron.right" : "checkmark.circle.fill")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
        .padding(.bottom, 12)
        }
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