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


// MARK: - Typography & Spacing Tokens (iOS 26)
enum AppTypography {
    static let largeTitle: Font = .system(size: 28, weight: .bold)
    static let title: Font = .system(size: 20, weight: .semibold)
    static let body: Font = .system(size: 16, weight: .regular)
    static let subheadline: Font = .system(size: 14, weight: .medium)
    static let caption: Font = .system(size: 12, weight: .medium)
}

enum AppSpacing {
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
}


// MARK: - Performance & Accessibility Heuristics
enum AppPerformance {
    static var isLowPowerMode: Bool { ProcessInfo.processInfo.isLowPowerModeEnabled }
    static var reduceTransparency: Bool { UIAccessibility.isReduceTransparencyEnabled }
    static var reduceMotion: Bool { UIAccessibility.isReduceMotionEnabled }
    static var preferLightweightGlass: Bool { isLowPowerMode || reduceTransparency }
}


// MARK: - iOS 26 Liquid Glass Tokens & Components

/// Visual style presets for Liquid Glass containers.
enum LiquidGlassStyle {
    case surface
    case toolbar
    case chip
    case card

    var cornerRadius: CGFloat {
        switch self {
        case .surface: return 20
        case .toolbar: return 16
        case .chip: return 14
        case .card: return 18
        }
    }

    var strokeOpacity: Double {
        switch self {
        case .surface: return 0.10
        case .toolbar: return 0.12
        case .chip: return 0.14
        case .card: return 0.10
        }
    }

    var shadow: (color: Color, radius: CGFloat, y: CGFloat) {
        // Slightly stronger for surface/card, lighter for toolbar/chip
        switch self {
        case .surface: return (.black.opacity(0.14), 16, 8)
        case .toolbar: return (.black.opacity(0.10), 12, 6)
        case .chip: return (.black.opacity(0.08), 8, 4)
        case .card: return (.black.opacity(0.12), 14, 7)
        }
    }
}

/// A modifier that applies a Liquid Glass appearance consistent with iOS 26.
struct LiquidGlassModifier: ViewModifier {
    let style: LiquidGlassStyle
    let tint: Color
    let tintOpacity: Double
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    init(style: LiquidGlassStyle = .surface, tint: Color = AppTheme.accent, tintOpacity: Double = 0.06) {
        self.style = style
        self.tint = tint
        self.tintOpacity = tintOpacity
    }

    func body(content: Content) -> some View {
        let isHighContrast = UIAccessibility.isDarkerSystemColorsEnabled
        let effectiveTintOpacity = isHighContrast ? min(tintOpacity + 0.04, 0.14) : tintOpacity
        let baseStroke = style.strokeOpacity
        let strokeBoost = isHighContrast ? 0.05 : 0.0
        let schemeAdjust = (colorScheme == .dark) ? 0.02 : 0.0
        let effectiveStroke = min(baseStroke + strokeBoost + schemeAdjust, 0.2)
        let shadow = style.shadow

        // Lightweight path for performance/battery/accessibility
        if AppPerformance.preferLightweightGlass {
            return AnyView(
                content
                    .padding(0)
                    .background(
                        // Use thinner, cheaper material
                        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                            .fill(.thinMaterial)
                    )
                    // No gradient tint or shadow in lightweight mode
            )
        }

        return AnyView(
            content
                .padding(0)
                .background(
                    // Base material (thinner is cheaper and closer to iOS bar surfaces)
                    RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                        .fill(.thinMaterial)
                )
                .background(
                    Group {
                        if effectiveTintOpacity > 0.05 {
                            RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [tint.opacity(effectiveTintOpacity), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .compositingGroup() // hint GPU
                        }
                    }
                )
                .overlay(
                    // Edge highlight to suggest refraction/lensing
                    RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(effectiveStroke), lineWidth: 1)
                )
                .shadow(color: AppPerformance.reduceMotion ? .clear : (isHighContrast ? shadow.color.opacity(1.0) : shadow.color),
                        radius: AppPerformance.reduceMotion ? 0 : (isHighContrast ? shadow.radius + 2 : shadow.radius),
                        y: AppPerformance.reduceMotion ? 0 : (isHighContrast ? shadow.y + 1 : shadow.y))
                .transaction { txn in
                    if AppPerformance.reduceMotion { txn.animation = nil }
                }
        )
    }
}

extension View {
    /// Apply the Liquid Glass style.
    func liquidGlass(_ style: LiquidGlassStyle = .surface, tint: Color = AppTheme.accent, tintOpacity: Double = 0.06) -> some View {
        modifier(LiquidGlassModifier(style: style, tint: tint, tintOpacity: tintOpacity))
    }
}

/// Convenience container for wrapping content in a Liquid Glass surface.
struct LiquidGlassContainer<Content: View>: View {
    let style: LiquidGlassStyle
    let tint: Color
    let tintOpacity: Double
    let content: Content

    init(style: LiquidGlassStyle = .surface, tint: Color = AppTheme.accent, tintOpacity: Double = 0.06, @ViewBuilder content: () -> Content) {
        self.style = style
        self.tint = tint
        self.tintOpacity = tintOpacity
        self.content = content()
    }

    var body: some View {
        content
            .padding(0)
            .liquidGlass(style, tint: tint, tintOpacity: tintOpacity)
    }
}

