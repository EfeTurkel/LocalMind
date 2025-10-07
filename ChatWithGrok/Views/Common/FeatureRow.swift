import SwiftUI

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String?
    
    init(icon: String, title: String, description: String? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                if let description = description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
} 