import SwiftUI

// MARK: - Hero 头部卡 (1:1 v32 header-card: radius 20, padding 16/18, 四指标)
struct HeaderCardView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel

    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            // title-row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.carName)
                        .font(.system(size: 21, weight: .bold))
                        .kerning(-0.5)
                        .foregroundColor(p.textPrimary)
                    Text(model.carVIN)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(p.textMuted)
                }
                Spacer()
                Text(model.carTag)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(p.accentCyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(p.accentCyan.opacity(0.12)))
                    .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(p.accentCyan.opacity(0.25), lineWidth: 1))
            }
            .padding(.bottom, 10)

            // header-stats (border-top 分隔)
            HStack(spacing: 0) {
                statItem(value: model.statMileage, badge: nil, valueColor: p.textPrimary, label: "总里程 (km)")
                statItem(value: model.statHybrid, badge: nil, valueColor: p.accentCyan, label: "混动里程 (km)")
                statItem(value: model.statFuelNum, badge: model.statFuelPct, valueColor: p.accentYellow, label: "油量 (L)")
                statItem(value: model.statElecNum, badge: model.statElecPct, valueColor: p.accentGreen, label: "电量 (kWh)")
            }
            .padding(.top, 12)
            .overlay(Divider().opacity(0.6), alignment: .top)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [p.heroTop, p.heroBottom], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: p.cardShadow, radius: 9, x: 0, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(p.heroBorder, lineWidth: 1))
        .padding(.bottom, 14)
    }

    private func statItem(value: String, badge: String?, valueColor: Color, label: String) -> some View {
        VStack(spacing: 3) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(valueColor.opacity(0.85))
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(p.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
