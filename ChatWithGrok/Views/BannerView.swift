import SwiftUI

struct BannerView: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? AppTheme.textPrimary : .white)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? AppTheme.textPrimary : .white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .dark ? AppTheme.textSecondary : Color.white.opacity(0.7))
            }
        }
        .padding(12)
        .background(Color.clear)
        .liquidGlass(.chip, tint: tint, tintOpacity: colorScheme == .dark ? 0.07 : 0.09)
    }
}
