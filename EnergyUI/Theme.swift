import SwiftUI

// MARK: - V32 调色板 (1:1 还原 energy_dashboard_v32.html CSS 变量)
struct V32Palette {
    let isDark: Bool

    init(_ scheme: ColorScheme) {
        self.isDark = scheme == .dark
    }

    // --bg-color
    var bgColor: Color { isDark ? Color(hex: 0x06090E) : Color(hex: 0xF2F3F7) }
    // --card-bg  浅: rgba(255,255,255,0.72) 深: rgba(255,255,255,0.04)
    var cardBG: Color { isDark ? Color.white.opacity(0.04) : Color.white.opacity(0.72) }
    // --card-border  浅: rgba(0,0,0,0.06) 深: rgba(255,255,255,0.08)
    var cardBorder: Color { isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.06) }
    // --card-shadow
    var cardShadow: Color { isDark ? Color.black.opacity(0.4) : Color.black.opacity(0.03) }
    // --sub-card-bg / --sub-card-border
    var subCardBG: Color { isDark ? Color.black.opacity(0.3) : Color.black.opacity(0.03) }
    var subCardBorder: Color { isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.04) }
    // --text-primary
    var textPrimary: Color { isDark ? .white : Color(hex: 0x111827) }
    // --text-secondary
    var textSecondary: Color { isDark ? Color.white.opacity(0.65) : Color(hex: 0x4B5563) }
    // --text-muted
    var textMuted: Color { isDark ? Color.white.opacity(0.4) : Color(hex: 0x9CA3AF) }
    // --hero-bg  浅: linear-gradient(145deg,#ffffff,#edf2f7) 深: linear-gradient(145deg,rgba(20,36,58,.8),rgba(8,16,28,.95))
    var heroTop: Color { isDark ? Color(hex: 0x14243A).opacity(0.8) : .white }
    var heroBottom: Color { isDark ? Color(hex: 0x08101C).opacity(0.95) : Color(hex: 0xEDF2F7) }
    // --hero-border  浅: rgba(0,122,255,0.2) 深: rgba(0,210,255,0.25)
    var heroBorder: Color { isDark ? Color(hex: 0x00D2FF).opacity(0.25) : Color(hex: 0x007AFF).opacity(0.2) }
    // --tray-bg / --tray-border
    var trayTop: Color { isDark ? Color(hex: 0x00D2FF).opacity(0.08) : Color(hex: 0x007AFF).opacity(0.06) }
    var trayBottom: Color { isDark ? Color.white.opacity(0.02) : Color.white.opacity(0.6) }
    var trayBorder: Color { isDark ? Color(hex: 0x00D2FF).opacity(0.2) : Color(hex: 0x007AFF).opacity(0.2) }

    // accent 六彩 (浅/深两套)
    var accentGreen: Color { isDark ? Color(hex: 0x30D158) : Color(hex: 0x28CD41) }
    var accentCyan: Color { isDark ? Color(hex: 0x00D2FF) : Color(hex: 0x007AFF) }
    var accentYellow: Color { isDark ? Color(hex: 0xFFD60A) : Color(hex: 0xFF9500) }
    var accentOrange: Color { isDark ? Color(hex: 0xFF9F0A) : Color(hex: 0xFF5E3A) }
    var accentPurple: Color { isDark ? Color(hex: 0xBF5AF2) : Color(hex: 0xAF52DE) }
    var accentRed: Color { isDark ? Color(hex: 0xFF453A) : Color(hex: 0xFF3B30) }
    var accentBlue: Color { Color(hex: 0x0A84FF) } // metric c-blue / bar 高光固定 #0A84FF

    // badge-pill
    var badgeBG: Color { isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.05) }
    // eb-track
    var trackBG: Color { isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.08) }
    // 车模涂装
    var carPaintTop: Color { isDark ? Color(hex: 0x152436) : .white }
    var carPaintMid: Color { isDark ? Color(hex: 0x0C1420) : Color(hex: 0xF0F4F8) }
    var carPaintBottom: Color { isDark ? Color(hex: 0x060A10) : Color(hex: 0xE2E8F0) }
    var carStroke: Color { isDark ? Color(hex: 0x00D2FF).opacity(0.75) : Color(hex: 0x007AFF).opacity(0.8) }
    var carGlass: Color { isDark ? Color(hex: 0x00D2FF).opacity(0.25) : Color(hex: 0x007AFF).opacity(0.18) }
}

// MARK: - Hex Color
extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - 主题三档
enum V32ThemeMode: String, CaseIterable {
    case light, dark, auto
}

// MARK: - 通用 1:1 卡片底座 (card-bg + 1px border + radius + shadow)
struct V32CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var radius: CGFloat
    var paddingLR: CGFloat = 0
    var paddingTB: CGFloat = 0

    func body(content: Content) -> some View {
        let p = V32Palette(scheme)
        content
            .padding(EdgeInsets(top: paddingTB, leading: paddingLR, bottom: paddingTB, trailing: paddingLR))
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(p.cardBG)
                .shadow(color: p.cardShadow, radius: 9, x: 0, y: 4))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(p.cardBorder, lineWidth: 1))
    }
}

extension View {
    func v32Card(radius: CGFloat, hpad: CGFloat = 0, vpad: CGFloat = 0) -> some View {
        modifier(V32CardStyle(radius: radius, paddingLR: hpad, paddingTB: vpad))
    }
}
