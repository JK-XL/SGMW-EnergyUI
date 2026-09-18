import SwiftUI

// MARK: - 灵眸智驾卡 (1:1 v32 pilot-section-card: 紫蓝渐变底+边框, 3列6格)
struct PilotCardView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            // pilot-header
            HStack {
                HStack(spacing: 6) {
                    Text(model.pilotChip)
                        .font(.system(size: 11, weight: .heavy))
                        .kerning(-0.2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(LinearGradient(colors: [Color(hex: 0x5E5CE6), p.accentBlue], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    Text(model.pilotTitle)
                        .font(.system(size: 13, weight: .bold))
                        .kerning(-0.2)
                        .foregroundColor(p.textPrimary)
                }
                Spacer()
                Text(model.pilotScore)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(p.isDark ? Color(hex: 0xA5B4FC) : Color(hex: 0x5E5CE6))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color(hex: 0x5E5CE6).opacity(p.isDark ? 0.25 : 0.12)))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Color(hex: 0x5E5CE6).opacity(p.isDark ? 0.5 : 0.3), lineWidth: 1))
            }
            .padding(.bottom, 8)

            // pilot-grid (3列 gap5, cell minH44 radius9)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5) {
                ForEach(0..<model.pilotCells.count, id: \.self) { idx in
                    let cell = model.pilotCells[idx]
                    VStack(spacing: 1) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(cell.0)
                                .font(.system(size: 13, weight: .heavy))
                                .kerning(-0.3)
                                .foregroundColor(p.isDark ? Color(hex: 0x93C5FD) : Color(hex: 0x5E5CE6))
                            Text(cell.1)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(p.textMuted)
                        }
                        Text(cell.2)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(p.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(p.isDark ? Color.white.opacity(0.04) : Color.white.opacity(0.5))
                    )
                    .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).strokeBorder(p.cardBorder, lineWidth: 1))
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: p.isDark
                            ? [Color(hex: 0x5856D6).opacity(0.18), Color(hex: 0x0A84FF).opacity(0.10), Color(hex: 0x141418).opacity(0.85)]
                            : [Color(hex: 0x5856D6).opacity(0.08), Color(hex: 0x0A84FF).opacity(0.05), p.cardBG],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: 0x5856D6).opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color(hex: 0x5856D6).opacity(p.isDark ? 0.4 : 0.28), lineWidth: 1))
        .padding(.bottom, 9)
    }
}

// MARK: - 城市足迹卡 (1:1 v32 city-footprint-card)
struct CityFootprintView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            // city-header
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(p.accentBlue)
                        .frame(width: 6, height: 6)
                        .shadow(color: p.accentBlue.opacity(0.8), radius: 3.5)
                        .modifier(PulseDotEffect())
                    Text("点亮城市 · 足迹勋章")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(p.textPrimary)
                }
                Spacer()
                Text(model.cityBadge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(p.accentBlue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(p.accentBlue.opacity(0.1)))
                    .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(p.accentBlue.opacity(0.25), lineWidth: 1))
            }
            .padding(.bottom, 7)

            // 当前城市行
            HStack {
                Text(model.cityCurrent)
                    .font(.system(size: 11))
                    .foregroundColor(p.textSecondary)
                Spacer()
                Text(model.cityCross)
                    .font(.system(size: 11))
                    .foregroundColor(p.textSecondary)
            }
            .padding(.bottom, 7)

            // city-tags-flow (9.5px 标签, flex-wrap 4+4 两行 1:1)
            VStack(spacing: 4) {
                ForEach(0..<2, id: \.self) { rowIdx in
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { colIdx in
                            let idx = rowIdx * 4 + colIdx
                            if idx < model.cityTags.count {
                                let tag = model.cityTags[idx]
                                HStack(spacing: 3) {
                                    Circle().fill(p.accentBlue).frame(width: 4, height: 4)
                                    Text(tag.0)
                                        .font(.system(size: 9.5, weight: .semibold))
                                        .foregroundColor(tag.1 ? p.accentCyan : p.textSecondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(tag.1 ? AnyShapeStyle(p.accentBlue.opacity(0.08)) : AnyShapeStyle(LinearGradient(colors: [p.trayTop, p.trayBottom], startPoint: .top, endPoint: .bottom)))
                                )
                                .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(tag.1 ? p.accentBlue.opacity(0.35) : p.cardBorder, lineWidth: 1))
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(p.cardBG)
                .shadow(color: p.cardShadow, radius: 8, x: 0, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(p.cardBorder, lineWidth: 1))
        .overlay(alignment: .top) {
            // 顶部青蓝微光线 (::before)
            LinearGradient(colors: [.clear, p.accentCyan.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(height: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.bottom, 11)
    }
}
