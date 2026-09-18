import SwiftUI

// MARK: - 顶部极简导航：左实时日期+呼吸绿点，右纯图标三档外观 (1:1 v32 top-nav)
struct TopNavView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel

    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        HStack {
            HStack(spacing: 7) {
                Circle()
                    .fill(Color(hex: 0x30D158))
                    .frame(width: 7, height: 7)
                    .shadow(color: Color(hex: 0x30D158).opacity(0.7), radius: 4)
                    .modifier(PulseDotEffect())
                Text(model.navDateText)
                    .font(.system(size: 13.5, weight: .bold))
                    .kerning(-0.2)
                    .foregroundColor(p.textPrimary)
            }
            Spacer()
            HStack(spacing: 2) {
                themeButton(.light, icon: "sun.max.fill")
                themeButton(.dark, icon: "moon.fill")
                themeButton(.auto, icon: "circle.lefthalf.filled")
            }
            .padding(2)
            .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(p.cardBG))
            .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).strokeBorder(p.cardBorder, lineWidth: 1))
            .shadow(color: p.cardShadow, radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 8)
    }

    private func themeButton(_ mode: V32ThemeMode, icon: String) -> some View {
        let active = model.themeMode == mode
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { model.themeMode = mode }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(active ? p.accentCyan : p.textMuted)
                .frame(width: 28, height: 25)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(active ? p.badgeBG : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 呼吸圆点动画 (v32 pulseDot 2.2s 1:1)
struct PulseDotEffect: ViewModifier {
    @State private var pulsing = false
    func body(content: Content) -> some View {
        content
            .scaleEffect(pulsing ? 1.18 : 0.92)
            .opacity(pulsing ? 1.0 : 0.75)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
    }
}
