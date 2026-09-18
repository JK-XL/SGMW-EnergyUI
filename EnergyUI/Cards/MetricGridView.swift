import SwiftUI

// MARK: - 10 宫格能耗大盘 (动态周期响应引擎：点今日显今日/点本月显本月 + 3.5px 纯色彩条 + 纯净胶囊)
struct MetricGridView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel

    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            // 响应式 10 宫格：根据当前选区动态派生标题与数值
            let cards = model.currentActivePeriodInfo.cards
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(0..<cards.count, id: \.self) { idx in
                    let card = cards[idx]
                    metricCard(card: card)
                }
            }
            .padding(.bottom, 10)

            // 原厂精致科技胶囊 (彻底拔除生硬星号与轮询解释)
            HStack(spacing: 5) {
                Circle()
                    .fill(Color(hex: 0x30D158))
                    .frame(width: 5, height: 5)
                Text("五菱云端已同步 · 15分钟级动态刷新")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(p.textMuted)
                Spacer()
                Text(model.currentActivePeriodInfo.subHint)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(p.accentCyan)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 12)
    }

    private func metricCard(card: MetricCardData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部小标题 (动态前缀，如：9月行驶里程、8月充入电量、2026出行次数)
            Text(card.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(p.textMuted)
                .lineLimit(1)
                .padding(.bottom, 6)

            Spacer(minLength: 0)

            // 主数值与单位 (大字 22pt + 右下基线对齐单位)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(card.value)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundColor(p.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(card.unit)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(barColor(card.accent))
                    .lineLimit(1)
            }
            .padding(.bottom, 4)

            // 辅助说明行 (无生硬星号，纯净展示)
            HStack(spacing: 4) {
                if let sub = card.subUnit, !sub.isEmpty {
                    Text(sub)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(p.textMuted)
                        .lineLimit(1)
                }
                Spacer()
                if let delta = card.delta, !delta.isEmpty {
                    Text(delta)
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(p.accentGreen)
                        .lineLimit(1)
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 10))
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(p.cardBG)
                .shadow(color: p.cardShadow, radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(p.cardBorder, lineWidth: 1)
        )
        // 左侧 3.5px 纯色彩条
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(barColor(card.accent))
                .frame(width: 3.5)
                .padding(.vertical, 8)
                .padding(.leading, 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func barColor(_ key: String) -> Color {
        switch key {
        case "cyan": return p.accentCyan
        case "green": return p.accentGreen
        case "blue": return p.accentBlue
        case "yellow": return p.accentYellow
        case "red": return p.accentRed
        case "purple": return p.accentPurple
        default: return p.accentCyan
        }
    }
}
