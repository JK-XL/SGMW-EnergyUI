import SwiftUI

// MARK: - 动力电池与低压电网工况 (1:1 v32 battery-panel: 60px SOC 环 + 紧凑两列零换行)
struct BatteryPanelView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            // panel-title
            HStack {
                Text(model.batteryTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(p.textPrimary)
                Spacer()
                Text(model.batteryBus)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(p.accentGreen)
            }
            .padding(.bottom, 12)

            HStack(spacing: 14) {
                // battery-ring (60px 紧凑光环)
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(p.trackBG, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    Circle()
                        .trim(from: 0, to: Double(model.batterySOC) / 100.0)
                        .stroke(Color(hex: 0x28CD41), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color(hex: 0x28CD41).opacity(0.5), radius: 3)
                        .modifier(BreathEffect())
                    Text("\(model.batterySOC)%")
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundColor(p.textPrimary)
                }
                .frame(width: 60, height: 60)

                // battery-details (2x2, 标签与数值紧凑对齐，绝不折行截断)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    detailCell(label: "电池健康度 (SOH)", val: "99 % (极佳)", colorKey: "green")
                    detailCell(label: "12V 小电瓶", val: "12.38 V (安全)", colorKey: "green")
                    detailCell(label: "电池平均温度", val: "29 ℃ (正常)", colorKey: "plain")
                    detailCell(label: "温差 (高/低)", val: "29℃/28℃ (1℃)", colorKey: "cyan")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .v32Card(radius: 18)
        .padding(.bottom, 12)
    }

    private func detailCell(label: String, val: String, colorKey: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(p.textMuted)
                .lineLimit(1)
            Text(val)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(detailColor(colorKey))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func detailColor(_ key: String) -> Color {
        switch key {
        case "green": return p.accentGreen
        case "cyan": return p.accentCyan
        case "orange": return p.accentOrange
        default: return p.textPrimary
        }
    }
}

// SOC 呼吸光环 (1:1 呼吸绿环)
struct BreathEffect: ViewModifier {
    @State private var breathing = false
    func body(content: Content) -> some View {
        content
            .opacity(breathing ? 0.75 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    breathing = true
                }
            }
    }
}

// MARK: - 机电踏板与工况卡 (1:1 v32: 油门/刹车条 + 5 小格)
struct PedalGearCardView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            // energy-bars (gap8, track h6 radius3)
            VStack(spacing: 8) {
                pedalRow(label: "油门深度", pct: model.throttlePct, color: p.accentGreen)
                pedalRow(label: "刹车力度", pct: model.brakePct, color: p.accentRed)
            }
            .padding(.bottom, 12)

            // gear-chips (5 格, gap6, border-top)
            HStack(spacing: 6) {
                ForEach(0..<model.gearItems.count, id: \.self) { idx in
                    let g = model.gearItems[idx]
                    VStack(spacing: 2) {
                        Text(g.0)
                            .font(.system(size: 9))
                            .foregroundColor(p.textMuted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(g.1)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(gearColor(g.2))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(p.subCardBG))
                }
            }
            .padding(.top, 10)
            .overlay(alignment: .top) { Divider().opacity(0.6) }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .v32Card(radius: 18)
        .padding(.bottom, 12)
    }

    private func pedalRow(label: String, pct: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(p.textSecondary)
                .frame(width: 65, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(p.trackBG)
                    Capsule().fill(color).frame(width: geo.size.width * CGFloat(pct) / 100.0)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 10)
            Text("\(pct)%")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)
                .frame(width: 35, alignment: .trailing)
        }
    }

    private func gearColor(_ key: String) -> Color {
        switch key {
        case "green": return p.accentGreen
        case "cyan": return p.accentCyan
        default: return p.textPrimary
        }
    }
}

// MARK: - 温控 4 模块 (1:1 v32 thermal-matrix: 2x2, th-box radius14 pad10/12)
struct ThermalMatrixView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
            ForEach(0..<model.thermalBoxes.count, id: \.self) { idx in
                let box = model.thermalBoxes[idx]
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(box.0)
                            .font(.system(size: 10))
                            .foregroundColor(p.textMuted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(box.1)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(boxColor(box.2))
                    }
                    Spacer(minLength: 2)
                    // th-badge-icon (24px 圆)
                    ZStack {
                        Circle().fill(boxColor(box.2).opacity(0.1)).frame(width: 24, height: 24)
                        Image(systemName: sfIcon(box.3))
                            .font(.system(size: 11))
                            .foregroundColor(boxColor(box.2))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(p.cardBG))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(p.cardBorder, lineWidth: 1))
                .shadow(color: p.cardShadow, radius: 5, x: 0, y: 2)
            }
        }
    }

    private func boxColor(_ key: String) -> Color {
        switch key {
        case "cyan": return p.accentCyan
        case "orange": return p.accentOrange
        default: return p.textPrimary
        }
    }

    private func sfIcon(_ name: String) -> String {
        switch name {
        case "thermometer": return "thermometer"          // iOS 15 兼容
        case "fanblades": return "wind"                   // iOS 15 兼容 (fanblades 为 iOS 16+)
        case "circle.hexagongrid.fill": return "circle.hexagongrid.fill"
        case "cpu": return "cpu"
        default: return "circle.fill"
        }
    }
}

// MARK: - 充电与 OBC / 照明信号 双拼卡 (1:1 v32 pair-grid + sub-fusion-card)
struct PairGridView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            fusionCard(title: "充电与OBC", icon: "bolt.fill", color: p.accentYellow, rows: model.obcRows)
            fusionCard(title: "照明信号", icon: "lightbulb.fill", color: p.accentCyan, rows: model.lightRows)
        }
        .padding(.top, 10)
    }

    private func fusionCard(title: String, icon: String, color: Color, rows: [(String, String, Bool)]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(.bottom, 8)

            ForEach(rows.indices, id: \.self) { idx in
                let row = rows[idx]
                HStack {
                    Text(row.0)
                        .font(.system(size: 11))
                        .foregroundColor(p.textSecondary)
                    Spacer()
                    Text(row.1)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(row.2 ? p.accentGreen : p.textPrimary)
                }
                .padding(.bottom, 6)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(p.cardBG))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(p.cardBorder, lineWidth: 1))
        .shadow(color: p.cardShadow, radius: 6, x: 0, y: 3)
    }
}
