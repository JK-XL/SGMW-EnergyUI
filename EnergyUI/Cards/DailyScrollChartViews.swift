import SwiftUI

// MARK: - 七天单日明细横滑 (1:1 v32 daily-scroll: 卡宽138, radius12, pad8/10)
struct DailyScrollView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("📅 近期单日明细 (7天)")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(p.textSecondary)
                Spacer()
                Text("左右单手横划")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(p.accentCyan)
            }
            .padding(.bottom, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(model.dailyItems) { item in
                        DailyMiniCard(item: item)
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
    }
}

private struct DailyMiniCard: View {
    @Environment(\.colorScheme) private var scheme
    let item: DailyItem
    private var p: V32Palette { V32Palette(scheme) }

    private var tagColor: Color {
        switch item.tagColor {
        case "blue": return Color(hex: 0x0A84FF)
        case "green": return Color(hex: 0x30D158)
        default: return p.textMuted
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // dmc-date
            HStack {
                Text(item.date)
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(p.textPrimary)
                Spacer()
                Text(item.tag)
                    .font(.system(size: 10.5, weight: item.isToday ? .heavy : .bold))
                    .foregroundColor(tagColor)
            }
            .padding(.bottom, 3)
            .overlay(alignment: .bottom) { Divider().opacity(0.5) }

            ForEach(item.rows.indices, id: \.self) { idx in
                let row = item.rows[idx]
                HStack {
                    Text(row.0)
                        .font(.system(size: 9.5))
                        .foregroundColor(p.textMuted)
                    Spacer()
                    Text(row.1)
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(row.2 ? Color(hex: 0x30D158) : p.textSecondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(width: 138, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(p.subCardBG)
                .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 3)
                .shadow(color: Color.white.opacity(0.08), radius: 0.5, x: 0, y: 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(item.isToday ? Color(hex: 0x0A84FF).opacity(0.4) : p.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - 2026 出行次数月度分布柱状图 (1:1 v32 chart-card, bars h80, 柱宽16)
struct ChartCardView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("2026 出行次数月度分布")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(p.textPrimary)
                Spacer()
                Text(model.chartSubHint)
                    .font(.system(size: 10, weight: model.selectedChartMonth != nil ? .bold : .regular))
                    .foregroundColor(model.selectedChartMonth != nil ? p.accentBlue : p.textMuted)
            }
            .padding(.bottom, 12)

            // bars (h80 + border-bottom)
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(model.barMonths) { bar in
                    barColumn(bar)
                }
            }
            .frame(height: 80)
            .overlay(alignment: .bottom) { Divider().opacity(0.6) }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(p.cardBG)
                .shadow(color: p.cardShadow, radius: 8, x: 0, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(p.cardBorder, lineWidth: 1))
        .padding(.vertical, 12)
    }

    private func barColumn(_ bar: BarMonth) -> some View {
        let active = model.selectedChartMonth == bar.month
        let barH: CGFloat = bar.heightPercent == 0 ? 3 : max(3, 80 * bar.heightPercent / 100 - 20)
        return Button {
            model.quickMonth(bar.month)
        } label: {
            VStack(spacing: 0) {
                // bar-val (9px, 激活放大1.18)
                Text("\(bar.starts)")
                    .font(.system(size: 9, weight: active ? .heavy : .bold))
                    .foregroundColor(active ? p.accentBlue : (bar.isCurrent ? p.accentGreen : p.accentCyan))
                    .scaleEffect(active ? 1.18 : 1.0)
                    .padding(.bottom, 3)

                Spacer(minLength: 0)

                // bar-fill (w16, 激活蓝紫渐变+发光)
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(barFillColor(bar: bar, active: active))
                    .frame(width: 16, height: barH)
                    .shadow(color: active ? p.accentBlue.opacity(0.7) : .clear, radius: 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .contentShape(Rectangle())
            // bar-lbl
            .overlay(alignment: .bottom) {
                Text(bar.isCurrent ? "9月*" : "\(bar.month)月")
                    .font(.system(size: 9, weight: active ? .bold : .regular))
                    .foregroundColor(active ? p.accentBlue : (bar.isCurrent ? p.textPrimary : p.textMuted))
                    .offset(y: 13)
            }
        }
        .buttonStyle(PressScaleStyle(scale: 0.95))
        .padding(.bottom, 8)
    }

    private func barFillColor(bar: BarMonth, active: Bool) -> AnyShapeStyle {
        if active {
            return AnyShapeStyle(LinearGradient(colors: [p.accentBlue, Color(hex: 0x5856D6)], startPoint: .top, endPoint: .bottom))
        }
        if bar.heightPercent == 0 {
            return AnyShapeStyle(p.trackBG)
        }
        if bar.isCurrent {
            return AnyShapeStyle(p.accentGreen)
        }
        return AnyShapeStyle(LinearGradient(colors: [p.accentCyan, p.accentCyan.opacity(0.25)], startPoint: .top, endPoint: .bottom))
    }
}

// 按压缩放反馈 (1:1 :active scale)
struct PressScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.98
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

