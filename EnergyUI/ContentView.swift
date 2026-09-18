import SwiftUI

// MARK: - 根视图 (v32 container max-width 480 + body padding 14, 主题三档环境注入)
struct ContentView: View {
    @EnvironmentObject private var model: DashboardModel

    var body: some View {
        NavigationView {
            ZStack {
                PaletteBG()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        TopNavView()                    // 顶部导航 + 三档主题切换
                        HeaderCardView()                // Hero 头部卡
                        TimeCapsuleView()               // 时间舱 + 更多抽屉
                        StatusHeadlineView()            // 状态行
                        MetricGridView()                // 10 宫格能耗大盘
                        PilotCardView()                 // 灵眸智驾卡
                        CityFootprintView()             // 城市足迹卡
                        DailyScrollView()               // 七天横滑明细
                        ChartCardView()                 // 月度柱状图
                        TirePressureCardView()          // 四轮胎压 + 车模
                        LockSecurityCardView()          // 全车车锁与防盗
                        BatteryPanelView()              // 动力电池与低压电网
                        PedalGearCardView()             // 机电踏板与工况
                        ThermalMatrixView()             // 温控 4 模块
                        PairGridView()                  // 充电OBC + 照明信号
                        Text("SGMW-EnergyUI · v32 1:1 原生重写预览")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(hex: 0x9CA3AF))
                            .padding(.top, 14)
                            .padding(.bottom, 30)
                    }
                    .padding(14)
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(colorScheme)
        }
        .navigationViewStyle(.stack)
    }

    private var colorScheme: ColorScheme? {
        switch model.themeMode {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
}

// 背景色跟随主题
private struct PaletteBG: View {
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        V32Palette(scheme).bgColor
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.25), value: scheme)
    }
}
