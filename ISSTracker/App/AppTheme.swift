import SwiftUI

enum AppTheme {
    static let backgroundTop = Color(red: 0.02, green: 0.05, blue: 0.11)
    static let backgroundBottom = Color(red: 0.0, green: 0.0, blue: 0.03)
    static let card = Color.white.opacity(0.08)
    static let stroke = Color.white.opacity(0.12)
    static let strokeStrong = Color.white.opacity(0.22)
    static let glass = Color.black.opacity(0.28)
    static let glassHeavy = Color.black.opacity(0.42)
    static let accent = Color(red: 0.33, green: 0.86, blue: 1.0)
    static let accentSecondary = Color(red: 0.56, green: 0.62, blue: 1.0)
    static let accentWarm = Color(red: 1.0, green: 0.63, blue: 0.31)
    static let success = Color(red: 0.47, green: 0.93, blue: 0.72)
    static let caution = Color(red: 1.0, green: 0.77, blue: 0.44)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let textTertiary = Color.white.opacity(0.58)

    static let background = LinearGradient(
        colors: [backgroundTop, backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.12),
            Color.white.opacity(0.04)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

}
