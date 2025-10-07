import SwiftUI

struct MessageLimitPopupView: View {
    let usedMessages: Int
    let remainingMessages: Int
    let totalLimit: Int
    @Binding var showingUpgradeView: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .symbolEffect(.bounce)
                    
                    Text("Message Usage")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                // Usage Stats
                VStack(spacing: 20) {
                    UsageStatRow(
                        icon: "message.fill",
                        title: "Used Messages",
                        value: "\(usedMessages)",
                        color: .blue
                    )
                    
                    UsageStatRow(
                        icon: "message.badge.circle.fill",
                        title: "Remaining Messages",
                        value: "\(remainingMessages)",
                        color: remainingMessages < 5 ? .red : .green
                    )
                    
                    UsageStatRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Daily Limit",
                        value: "\(totalLimit)",
                        color: .gray
                    )
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(16)
                
                // Bilgilendirme
                VStack(spacing: 8) {
                    Text("Günlük mesaj kullanımını buradan takip edebilirsin.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct UsageStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .padding(.horizontal)
    }
} 