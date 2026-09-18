import SwiftUI

// MARK: - 时间舱：今日/昨日/本月/上月/更多▼ + 二级抽屉 + 就地悬浮自选日期浮层 (1:1 原版规范)
struct TimeCapsuleView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel

    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            // primary-track (padding 2, gap 3, radius 14)
            HStack(spacing: 3) {
                capsule(.today, main: "今日", sub: "(\(model.todayDayNum))")
                capsule(.yesterday, main: "昨日", sub: "(\(model.yesterdayDayNum))")
                capsule(.thisMonth, main: "本月", sub: "(\(model.thisMonthName))")
                capsule(.lastMonth, main: "上月", sub: "(\(model.lastMonthName))")
                expanderCapsule
            }
            .padding(2)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(p.cardBG))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(p.cardBorder, lineWidth: 1))
            .shadow(color: p.cardShadow, radius: 5, x: 0, y: 2)

            // archive-tray (padding 4, gap 4, margin-top 5)
            if model.isTrayOpen {
                HStack(spacing: 4) {
                    archivePill(.thisYear, main: "今年", sub: "(2026)", isIcon: false)
                    archivePill(.lastYear, main: "去年", sub: "(2025)", isIcon: false)
                    archivePill(.lifetime, main: "提车至今", sub: "(644天)", isIcon: false)
                    archivePill(.custom, main: "自选日期", sub: "calendar", isIcon: true)
                }
                .padding(4)
                .margin(top: 5)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: [p.trayTop, p.trayBottom], startPoint: .top, endPoint: .bottom))
                )
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(p.trayBorder, lineWidth: 1))
                .transition(.opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.97, anchor: .top)))
            }

            // C2 就地悬浮自选日期浮层 (非整页弹窗，轻巧悬浮就地选择)
            if model.showDatePicker {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Text("自选出行周期")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(p.accentCyan)
                            Spacer()
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { model.showDatePicker = false }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(p.textMuted)
                            }
                        }

                        HStack(spacing: 6) {
                            DatePicker("", selection: $model.customStartDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "zh_CN"))

                            Text("至")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(p.textSecondary)

                            DatePicker("", selection: $model.customEndDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "zh_CN"))

                            Spacer()

                            Button {
                                model.applyCustomDateRange()
                            } label: {
                                Text("确定")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(p.accentCyan))
                            }
                        }
                    }
                }
                .padding(10)
                .margin(top: 6)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(p.cardBG)
                        .shadow(color: p.cardShadow, radius: 8, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(p.accentCyan.opacity(0.4), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.96, anchor: .top)))
            }
        }
        .padding(.bottom, 8)
    }

    // 主胶囊 (min-height 35, radius 10, main 11px, sub 9px)
    private func capsule(_ period: PeriodType, main: String, sub: String) -> some View {
        let active = model.selectedPeriod == period && model.selectedChartMonth == nil
        return Button {
            model.selectPrimary(period)
            withAnimation(.easeInOut(duration: 0.2)) { model.showDatePicker = false }
        } label: {
            VStack(spacing: 1) {
                Text(main)
                    .font(.system(size: 11, weight: active ? .bold : .semibold))
                    .foregroundColor(active ? p.accentCyan : p.textSecondary)
                Text(sub)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(active ? p.accentCyan.opacity(0.9) : p.textMuted)
            }
            .frame(maxWidth: .infinity, minHeight: 35)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(active ? p.accentCyan.opacity(0.12) : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(active ? p.accentCyan.opacity(0.35) : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // 更多 ▼ 胶囊
    private var expanderCapsule: some View {
        Button {
            model.toggleTray()
            if !model.isTrayOpen {
                withAnimation(.easeInOut(duration: 0.2)) { model.showDatePicker = false }
            }
        } label: {
            VStack(spacing: 1) {
                Text("更多")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(p.accentCyan)
                HStack(spacing: 2) {
                    Text("▼")
                        .font(.system(size: 8))
                        .rotationEffect(.degrees(model.isTrayOpen ? 180 : 0))
                        .animation(.easeInOut(duration: 0.25), value: model.isTrayOpen)
                }
                .foregroundColor(p.textMuted)
            }
            .frame(maxWidth: .infinity, minHeight: 35)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(model.isTrayOpen ? p.accentCyan.opacity(0.15) : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(model.isTrayOpen ? p.accentCyan.opacity(0.4) : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // 抽屉药丸 (min-height 34, radius 8, 自选日期点击原地展开浮动浮层)
    private func archivePill(_ period: PeriodType, main: String, sub: String, isIcon: Bool) -> some View {
        let active = model.selectedPeriod == period
        return Button {
            if period == .custom {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    model.showDatePicker.toggle()
                }
            } else {
                model.selectArchive(period)
                withAnimation(.easeInOut(duration: 0.2)) { model.showDatePicker = false }
            }
        } label: {
            VStack(spacing: 1) {
                Text(main)
                    .font(.system(size: 10.5, weight: active ? .bold : .semibold))
                    .foregroundColor(active ? p.accentCyan : p.textSecondary)
                if isIcon {
                    Image(systemName: sub)
                        .font(.system(size: 8.5))
                        .foregroundColor(active ? p.accentCyan : p.textMuted)
                } else {
                    Text(sub)
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundColor(active ? p.accentCyan.opacity(0.9) : p.textMuted)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(active ? p.accentCyan.opacity(0.15) : p.cardBG))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(active ? p.accentCyan.opacity(0.45) : p.cardBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// 简易 top margin helper (iOS 15 兼容)
extension View {
    func margin(top: CGFloat) -> some View { padding(.top, top) }
}
