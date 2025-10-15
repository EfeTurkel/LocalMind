import SwiftUI

enum AppTheme {
    static let background = Color(UIColor { trait in
        trait.userInterfaceStyle == .light
            ? UIColor.systemGroupedBackground
            : UIColor(red: 10/255, green: 11/255, blue: 13/255, alpha: 1)
    })

    static let secondaryBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .light
            ? UIColor.secondarySystemGroupedBackground
            : UIColor(red: 22/255, green: 24/255, blue: 29/255, alpha: 1)
    })

    static let elevatedBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .light
            ? UIColor.systemBackground
            : UIColor(red: 28/255, green: 31/255, blue: 36/255, alpha: 1)
    })

    static let outline = Color(UIColor { trait in
        trait.userInterfaceStyle == .light
            ? UIColor.black.withAlphaComponent(0.06)
            : UIColor.white.withAlphaComponent(0.08)
    })

    static let accent = Color(UIColor { _ in
        UIColor(red: 93/255, green: 134/255, blue: 255/255, alpha: 1)
    })

    static let destructive = Color(UIColor { _ in
        UIColor(red: 255/255, green: 92/255, blue: 103/255, alpha: 1)
    })

    static let success = Color(UIColor { trait in
        trait.userInterfaceStyle == .light
            ? UIColor.systemGreen
            : UIColor(red: 100/255, green: 223/255, blue: 173/255, alpha: 1)
    })

    static let textPrimary = Color(UIColor { trait in
        trait.userInterfaceStyle == .light ? UIColor.label : UIColor.white
    })

    static let textSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .light ? UIColor.secondaryLabel : UIColor.white.withAlphaComponent(0.6)
    })

    static let subtleText = Color(UIColor { trait in
        trait.userInterfaceStyle == .light ? UIColor.tertiaryLabel : UIColor.white.withAlphaComponent(0.35)
    })

    static let controlBackground = Color(UIColor { trait in
        if trait.userInterfaceStyle == .light {
            return UIColor.systemGray5.withAlphaComponent(0.9)
        } else {
            return UIColor.white.withAlphaComponent(0.08)
        }
    })

    static let controlActiveBackground = Color(UIColor { trait in
        if trait.userInterfaceStyle == .light {
            return UIColor.systemGray4.withAlphaComponent(0.9)
        } else {
            return UIColor.white.withAlphaComponent(0.14)
        }
    })

    static let chipBackground = Color(UIColor { trait in
        if trait.userInterfaceStyle == .light {
            return UIColor.systemGray5
        } else {
            return UIColor.white.withAlphaComponent(0.12)
        }
    })

    static let chipBorder = Color(UIColor { trait in
        if trait.userInterfaceStyle == .light {
            return UIColor.systemGray4
        } else {
            return UIColor.white.withAlphaComponent(0.18)
        }
    })

    static let cornerRadius: CGFloat = 18

    // Global animation styles inspired by iOS spring curves
    static let springFast: Animation = .interactiveSpring(response: 0.28, dampingFraction: 0.82, blendDuration: 0.12)
    static let springMedium: Animation = .interactiveSpring(response: 0.42, dampingFraction: 0.85, blendDuration: 0.18)
    static let springSlow: Animation = .interactiveSpring(response: 0.6, dampingFraction: 0.88, blendDuration: 0.22)
    static let easeEmphasized: Animation = .easeInOut(duration: 0.35)

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(UIColor { trait in
                    trait.userInterfaceStyle == .light
                        ? UIColor.systemBlue.withAlphaComponent(0.85)
                        : UIColor(red: 109/255, green: 151/255, blue: 255/255, alpha: 1)
                }),
                Color(UIColor { trait in
                    trait.userInterfaceStyle == .light
                        ? UIColor.systemBlue
                        : UIColor(red: 76/255, green: 112/255, blue: 255/255, alpha: 1)
                })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func glassBackground(cornerRadius: CGFloat = cornerRadius) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(outline, lineWidth: 1)
            )
    }
}

