import SwiftUI

// MARK: - 根视图 (彻底拔除 NavigationView，焊死安全区上下晃动，主盘通透自适应)
struct ContentView: View {
    @EnvironmentObject private var model: DashboardModel

    var body: some View {
        ZStack {
            PaletteBG()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TopNavView()                    // 顶部导航 + 单SF图标主题切换
                    HeaderCardView()                // Hero 头部卡
                    TimeCapsuleView()               // 时间舱 + 更多抽屉 + 就地悬浮自选日期
                    MetricGridView()                // 10 宫格能耗大盘 (全周期动态响应)
                    PilotCardView()                 // 灵眸智驾卡
                    CityFootprintView()             // 城市足迹卡 (内容自适应全显示)
                    DailyScrollView()               // 七天横滑明细
                    ChartCardView()                 // 月度柱状图 (带标准月度分割基准线)
                    TirePressureCardView()          // 四轮胎压 + 车模
                    LockSecurityCardView()          // 全车车锁与防盗
                    BatteryPanelView()              // 动力电池与低压电网 (两端拉齐分散排布)
                    PedalGearCardView()             // 机电踏板与工况
                    ThermalMatrixView()             // 温控 4 模块
                    PairGridView()                  // 充电OBC + 照明信号
                }
                .padding(14)
                .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch model.themeMode {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
}

// 背景色跟随主题 (静态平铺，绝无全局动画抖动)
private struct PaletteBG: View {
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        V32Palette(scheme).bgColor
            .ignoresSafeArea()
    }
}
