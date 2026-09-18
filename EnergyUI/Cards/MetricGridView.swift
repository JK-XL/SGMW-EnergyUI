import SwiftUI

// MARK: - 状态行 (status-headline 11px)
struct StatusHeadlineView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        HStack {
            Text(model.headlineDesc)
                .font(.system(size: 11))
                .foregroundColor(p.textMuted)
            Spacer()
            HStack(spacing: 4) {
                Circle().fill(p.accentGreen).frame(width: 6, height: 6)
                Text(model.headlineStatus)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(p.accentGreen)
            }
        }
        .padding(EdgeInsets(top: 2, leading: 2, bottom: 10, trailing: 2))
    }
}

// MARK: - 10 宫格能耗大盘 (metric-grid: 2列 gap10, 卡片 radius16 pad12 minH106, 彩条 3.5px)
struct MetricGridView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel

    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(0..<10, id: \.self) { idx in
                MetricCardCell(def: model.metricDefs[idx], value: model.metricValue(at: idx), palette: p)
            }
        }
        .padding(.bottom, 12)
    }
}

// 单张指标卡 (1:1 v32 metric-card: :active scale 0.98)
private struct MetricCardCell: View {
    @Environment(\.colorScheme) private var scheme
    let def: MetricCardDef
    let value: String
    let palette: V32Palette

    var body: some View {
        Button(action: {}) {
            cardContent
        }
        .buttonStyle(PressScaleStyle(scale: 0.98))
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // card-top (11px + 14px icon)
            HStack(spacing: 5) {
                Image(systemName: def.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(def.colorKey == "blue" ? palette.accentBlue : palette.textSecondary)
                    .frame(width: 14, height: 14)
                Text(def.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(palette.textSecondary)
            }
            .padding(.bottom, 4)

            Spacer(minLength: 0)

            // card-mid (24px/700 + 10px unit)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .kerning(-0.5)
                    .foregroundColor(palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                Text(def.unit)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(palette.textMuted)
            }

            // card-sub-stacked (9/10px + badge)
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(def.subT)
                        .font(.system(size: 9))
                        .foregroundColor(palette.textMuted)
                    Text(def.subV)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(palette.textSecondary)
                }
                Spacer(minLength: 0)
                Text(def.badge)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(palette.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(palette.badgeBG))
            }
            .padding(.top, 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 106, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.cardBG)
                .shadow(color: palette.cardShadow, radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        )
        // 3.5px 左侧纯色彩条 (1:1 ::before)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 3.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var accentColor: Color {
        switch def.colorKey {
        case "yellow": return palette.accentYellow
        case "green": return palette.accentGreen
        case "cyan": return palette.accentCyan
        case "purple": return palette.accentPurple
        case "blue": return palette.accentBlue
        case "orange": return palette.accentOrange
        case "red": return palette.accentRed
        default: return palette.accentCyan
        }
    }
}
