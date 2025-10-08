import SwiftUI

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType = .monthly
    @State private var showConfetti = false
    @State private var now = Date()
    private let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var showInfoAlert = false
    
    enum PlanType {
        case weekly
        case monthly
        
        var price: String {
            switch self {
            case .weekly: return "$2.99"
            case .monthly: return "$3.99"
            }
        }
        
        var period: String {
            switch self {
            case .weekly: return "week"
            case .monthly: return "month"
            }
        }
        
        var savings: String? {
            switch self {
            case .weekly: return nil
            case .monthly: return "Save 66% - Limited Time!"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 60))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                        .symbolEffect(.bounce)
                    
                    Text("Daily Support")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    
                    Text("Help keep the app free by supporting once per day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Günlük buton
                Text("You can tap once per day")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                Button(action: {
                    if TipStorage.shared.isTipAvailable(now: now) {
                        showConfetti = true
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        TipStorage.shared.setLastTipDate(Date())
                        TipStorage.shared.incrementTipCount()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            showConfetti = false
                            dismiss()
                        }
                    } else {
                        let warning = UINotificationFeedbackGenerator()
                        warning.notificationOccurred(.warning)
                        showInfoAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "hands.sparkles.fill")
                        Text(TipStorage.shared.isTipAvailable(now: now) ? "Support Today" : "Completed")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(TipStorage.shared.isTipAvailable(now: now) ? Color.accentColor : Color.gray)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .alert("Daily Support", isPresented: $showInfoAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("You already supported today. You can support again in \(TipStorage.shared.timeRemainingString(now: now)).")
                }
                
                if !TipStorage.shared.isTipAvailable(now: now) {
                    Text("You can support again in \(TipStorage.shared.timeRemainingString(now: now)).")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                // Information
                VStack(alignment: .leading, spacing: 14) {
                    Text("Thank You")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Label {
                            Text("This app is created by a student as a personal project.")
                        } icon: {
                            Image(systemName: "graduationcap.fill").foregroundStyle(.tint)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Label {
                            Text("There is no commercial goal; your daily support simply helps keep the app free and running.")
                        } icon: {
                            Image(systemName: "hand.thumbsup.fill").foregroundStyle(.tint)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Label {
                            Text("Support taps are not payments. They are a small gesture that encourages development and covers basic costs.")
                        } icon: {
                            Image(systemName: "sparkles").foregroundStyle(.tint)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                    
                    Divider()
                        .opacity(0.25)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What your support helps with")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                            Text("Server and API usage for testing and demos")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                            Text("UI/UX improvements and accessibility work")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                            Text("Maintenance and bug fixes to keep the app reliable")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer(minLength: 8)
                
                if showConfetti {
                    ConfettiView(duration: 1.2)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 520)
            .padding(.top)
            .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
        .onReceive(countdownTimer) { _ in now = Date() }
    }
}

extension UpgradeView {
    // Logic delegated to TipStorage
}

struct PlanCard: View {
    let type: UpgradeView.PlanType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(type == .weekly ? "Weekly" : "Monthly")
                            .font(.headline)
                        
                        if let savings = type.savings {
                            Text(savings)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                    
                    Text("\(type.price)/\(type.period)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}