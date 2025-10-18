import SwiftUI

struct CreatorView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Profil fotoğrafı
                Image("creator_photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 160)
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
                
                VStack(spacing: 12) {
                    Text("Created by")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Efe Türkel")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                // Sosyal medya butonlarını güncelleyelim
                VStack(spacing: 16) {
                    SocialMediaButton(
                        platform: "X (Twitter)", 
                        icon: "bird", 
                        username: "@efetu0x", 
                        url: "https://x.com/efetu0x"
                    )
                    
                    SocialMediaButton(
                        platform: "LinkedIn", 
                        icon: "linkedin_logo",
                        username: "Efe Türkel", 
                        url: "https://www.linkedin.com/in/efetu/",
                        useCustomImage: true
                    )
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .navigationTitle("About Creator")
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
}

struct SocialMediaButton: View {
    let platform: String
    let icon: String
    let username: String
    let url: String
    var useCustomImage: Bool = false
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 12) {
                if useCustomImage {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(platform)
                        .font(.headline)
                    Text(username)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.clear)
            .background(AppTheme.controlBackground.opacity(0.3))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 