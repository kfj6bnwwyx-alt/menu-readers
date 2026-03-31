import SwiftUI

extension Color {
    // Core backgrounds
    static let themeBg = Color(hex: 0x0B0B0E)
    static let cardBg = Color(hex: 0x16161A)
    static let surfaceBg = Color(hex: 0x222228)

    // Borders & dividers
    static let border = Color(hex: 0x2A2A2E)
    static let divider = Color(hex: 0x2A2A2E)
    static let subtleBorder = Color(hex: 0x3A3A40)

    // Text
    static let textPrimary = Color(hex: 0xFAFAF9)
    static let textSecondary = Color(hex: 0x6B6B70)
    static let textTertiary = Color(hex: 0x4A4A50)

    // Accent
    static let amber = Color(hex: 0xC8742E)

    // Destructive
    static let destructive = Color(hex: 0xE85A4F)

    // Red light mode
    static let deepRed = Color(hex: 0x8B0000)
    static let redPrimary = Color(hex: 0xCC0000)
    static let redSecondary = Color(hex: 0x770000)
    static let redTertiary = Color(hex: 0x550000)
    static let redBg = Color(hex: 0x0A0000)
    static let redCardBg = Color(hex: 0x1A0000)
    static let redBorder = Color(hex: 0x2A0000)
    static let redSubtle = Color(hex: 0x330000)
    static let redSurface = Color(hex: 0x440000)
    static let redGlow = Color(hex: 0xFF0000)

    // Legacy compat
    static let warmWhite = Color(red: 1.0, green: 0.96, blue: 0.9)
    static let softAmber = Color(red: 0.702, green: 0.447, blue: 0.0)
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension ShapeStyle where Self == Color {
    static var themeBackground: Color { Color(hex: 0x0B0B0E) }
    static var themeForeground: Color { Color(hex: 0xFAFAF9) }
}
