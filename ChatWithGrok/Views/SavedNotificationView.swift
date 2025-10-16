import SwiftUI

struct SavedNotificationView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.success)
                .font(.system(size: 16, weight: .semibold))
            
            Text("Chat Saved")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.clear)
        .liquidGlass(.chip, tint: AppTheme.accent, tintOpacity: 0.08)
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
        .transition(.scale.combined(with: .opacity))
    }
} 