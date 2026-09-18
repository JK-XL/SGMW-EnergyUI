import SwiftUI

// MARK: - 顶部极简导航：左实时日期+呼吸绿点，右单个 SF 图标点击切换 (1:1 v32 top-nav 规范)
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
                    .shadow(color: Color(hex: 0x30D158).opacity(0.6), radius: 3)
                    .modifier(PulseDotEffect())
                Text(model.navDateText)
                    .font(.system(size: 13.5, weight: .bold))
                    .kerning(-0.2)
                    .foregroundColor(p.textPrimary)
            }
            Spacer()
            // 右上角单图标切换：点一次切换一次 (iOS 15 官方原生 SF Symbols: moon.stars.fill / sun.max.fill)
            Button {
                model.toggleTheme()
            } label: {
                ZStack {
                    Circle()
                        .fill(p.cardBG)
                        .frame(width: 32, height: 32)
                        .shadow(color: p.cardShadow, radius: 4, x: 0, y: 2)
                        .overlay(Circle().strokeBorder(p.cardBorder, lineWidth: 1))

                    Image(systemName: model.themeMode == .dark ? "sun.max.fill" : "moon.stars.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(model.themeMode == .dark ? p.accentYellow : p.accentCyan)
                }
            }
            .buttonStyle(PressScaleStyle(scale: 0.92))
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 8)
    }
}

// MARK: - 呼吸圆点动画 (纯透明度变化，严禁 scaleEffect 形变，杜绝 ScrollView 任何微晃)
struct PulseDotEffect: ViewModifier {
    @State private var breathing = false
    func body(content: Content) -> some View {
        content
            .opacity(breathing ? 0.35 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    breathing = true
                }
            }
    }
}
