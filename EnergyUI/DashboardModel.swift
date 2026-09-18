import SwiftUI

// MARK: - 周期档位
enum PeriodType: String, CaseIterable, Identifiable {
    case today, yesterday, thisMonth, lastMonth
    case thisYear, lastYear, lifetime, custom
    var id: String { rawValue }

    var isPrimary: Bool { [.today, .yesterday, .thisMonth, .lastMonth].contains(self) }
    var isArchive: Bool { !isPrimary }
}

// MARK: - 10 宫格卡片静态定义 (文案/徽章 1:1 v32)
struct MetricCardDef {
    let colorKey: String     // c-yellow / c-green / c-cyan / c-purple / c-blue
    let icon: String         // SF Symbol
    let title: String
    let unit: String
    let subT: String
    let subV: String
    let badge: String
}

// MARK: - 单日明细
struct DailyItem: Identifiable {
    let id = UUID()
    let date: String
    let tag: String
    let tagColor: String   // "blue" / "green" / "muted"
    let isToday: Bool
    let rows: [(String, String, Bool)]  // (label, value, highlight)
}

// MARK: - 月度柱条
struct BarMonth: Identifiable {
    let id = UUID()
    let month: Int
    let starts: Int
    let heightPercent: Double   // 0~100；0 值 → 3px 灰条
    let isCurrent: Bool         // 9月* 绿色特殊
}

// MARK: - 数据底座与全局状态机
final class DashboardModel: ObservableObject {
    // ===== 交互状态 =====
    @Published var themeMode: V32ThemeMode = .light
    @Published var selectedPeriod: PeriodType = .today
    @Published var isTrayOpen: Bool = false
    @Published var selectedChartMonth: Int? = nil
    @Published var chartSubHint: String = "点击柱条即刻切换对应月份"
    @Published var showDatePicker: Bool = false
    @Published var customStartDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var customEndDate: Date = Date()

    // ===== Hero 头部 (实车快照 1:1) =====
    let carName = "宝骏云海"
    let carVIN = "VIN: LK6ADAH92RB765125"
    let carTag = "LV1 灵眸智驾"
    let statMileage = "9,537"
    let statHybrid = "4,645"
    let statFuelNum = "41.4"
    let statFuelPct = "(69%)"
    let statElecNum = "19.0"
    let statElecPct = "(94%)"

    // ===== 智驾 (v32 pilot-section-card 1:1) =====
    let pilotChip = "DJI"
    let pilotTitle = "灵眸智驾 · 卓驭车载高阶"
    let pilotScore = "智驾安全分 98 · 极佳"
    let pilotCells: [(String, String, String)] = [
        ("1,862.5", "km", "智驾总里程 (19.5%)"),
        ("1,240", "km", "高快领航 NOA"),
        ("328", "次", "自主变道超车"),
        ("42", "次", "全场景智能泊车"),
        ("12", "次", "跨层记忆泊车"),
        ("6", "次", "循迹倒车"),
    ]

    // ===== 城市足迹 (v32 city-footprint-card 1:1) =====
    let cityBadge = "已点亮 8 座城市 · 纵横华南"
    let cityCurrent = "当前城市：广西·柳州"
    let cityCross = "跨城足迹：1,898 km"
    let cityTags: [(String, Bool)] = [
        ("柳州 (当前)", true), ("南宁 (足迹 482km)", true), ("桂林 (足迹 326km)", true),
        ("广州 (足迹 680km)", true), ("深圳 (足迹 410km)", true), ("佛山", true),
        ("珠海", true), ("东莞", true),
    ]

    // ===== 七天单日明细 (v32 daily-scroll 1:1) =====
    let dailyItems: [DailyItem] = [
        DailyItem(date: "09月17日", tag: "今天", tagColor: "blue", isToday: true, rows: [
            ("今日行驶", "18.5 km", false), ("今日电耗", "2.4 kWh", false),
            ("百公里耗电", "12.4 kWh", true), ("消耗燃油", "0.0 L", false),
            ("今日出行", "2 次", false), ("充入电量", "0.0 kWh", false),
        ]),
        DailyItem(date: "09月16日", tag: "昨天", tagColor: "green", isToday: false, rows: [
            ("当日里程", "65.0 km", false), ("当日耗电", "8.3 kWh", false),
            ("百公里电耗", "12.8 kWh", true), ("消耗燃油", "0.2 L", false),
            ("出行次数", "4 次", false),
        ]),
        DailyItem(date: "09月15日", tag: "前天", tagColor: "muted", isToday: false, rows: [
            ("当日里程", "40.2 km", false), ("当日耗电", "4.9 kWh", false),
            ("百公里电耗", "12.2 kWh", true), ("消耗燃油", "0.7 L", false),
            ("出行次数", "2 次", false),
        ]),
        DailyItem(date: "09月14日", tag: "周一", tagColor: "muted", isToday: false, rows: [
            ("当日里程", "32.0 km", false), ("当日耗电", "3.9 kWh", false),
            ("百公里电耗", "12.1 kWh", true), ("出行次数", "2 次", false),
        ]),
        DailyItem(date: "09月13日", tag: "周日", tagColor: "muted", isToday: false, rows: [
            ("当日里程", "78.5 km", false), ("当日耗电", "10.1 kWh", false),
            ("百公里电耗", "12.9 kWh", true), ("智驾领航", "26.4 km", false),
        ]),
        DailyItem(date: "09月12日", tag: "周六", tagColor: "muted", isToday: false, rows: [
            ("当日里程", "15.0 km", false), ("当日耗电", "1.8 kWh", false),
            ("百公里电耗", "12.0 kWh", true), ("智能泊车", "2 次", false),
        ]),
        DailyItem(date: "09月11日", tag: "周五", tagColor: "muted", isToday: false, rows: [
            ("当日里程", "52.0 km", false), ("当日耗电", "6.5 kWh", false),
            ("百公里电耗", "12.5 kWh", true), ("高快NOA", "35.0 km", false),
        ]),
    ]

    // ===== 2026 出行次数月度分布 (v32 bars 1:1，仅 2~9 月) =====
    let barMonths: [BarMonth] = [
        BarMonth(month: 2, starts: 62, heightPercent: 75, isCurrent: false),
        BarMonth(month: 3, starts: 27, heightPercent: 35, isCurrent: false),
        BarMonth(month: 4, starts: 0,  heightPercent: 0,  isCurrent: false),
        BarMonth(month: 5, starts: 50, heightPercent: 60, isCurrent: false),
        BarMonth(month: 6, starts: 0,  heightPercent: 0,  isCurrent: false),
        BarMonth(month: 7, starts: 0,  heightPercent: 0,  isCurrent: false),
        BarMonth(month: 8, starts: 16, heightPercent: 22, isCurrent: false),
        BarMonth(month: 9, starts: 7,  heightPercent: 12, isCurrent: true),
    ]

    // ===== 四轮胎压 (实车 1:1) =====
    let tireChip = "胎温 29°C (正常)"
    let tireLF = 235, tireRF = 234, tireLR = 236, tireRR = 235

    // ===== 车锁防盗 =====
    let lockChip = "全车已锁 · 尾门已关"
    let doorPods: [(String, String)] = [
        ("主驾门", "已关"), ("左前窗", "已关"), ("副驾门", "已关"), ("右前窗", "已关"),
        ("左后门", "已关"), ("左后窗", "已关"), ("右后门", "已关"), ("右后窗", "已关"),
    ]

    // ===== 动力电池 (实车 1:1) =====
    let batteryTitle = "动力电池与低压电网工况"
    let batteryBus = "母线 99.4V · 正常"
    let batterySOC = 94
    var batterySOCReal: Double { 93.8 }           // 官方 soc: 93.8 (环填充比例)
    // 官方 batteryHealth 真值绑定 (sgmw_official_client.py --action summary, 2026-09-18)
    var batterySOCText: String { "93.8%" }        // 官方 soc: 93.8
    var batterySOHText: String { "99.0 % (极佳)" } // 官方 soh: 99.0
    var lowBatVoltageText: String { "12.38 V (安全)" } // 官方 lowBatVoltage: 12.38
    var coolingTempText: String { "24°C (正常)" }  // 官方 coolingTemp: 24°C (正常)
    var tireTempDiffText: String { "29℃/28℃ (1℃)" } // 官方 tpms 温差真值
    let batteryDetails: [(String, String, String)] = [
        ("电池健康度 (SOH)", "99 % (几无衰减)", "green"),
        ("12V 小电瓶电压", "12.38 V (安全)", "green"),
        ("电池平均温度", "29 ℃ (正常)", "plain"),
        ("温差 (最高/最低)", "29℃ / 28℃ (1℃)", "cyan"),
    ]

    // ===== 机电踏板与工况 =====
    let throttlePct = 0, brakePct = 0
    let gearItems: [(String, String, String)] = [
        ("实时车速", "0 km/h", "plain"),
        ("挡位", "P档", "green"),
        ("方向盘转角", "0°", "cyan"),
        ("高压电源", "未上电", "plain"),
        ("车钥匙", "车外", "plain"),
    ]

    // ===== 温控 4 模块 =====
    let thermalBoxes: [(String, String, String, String)] = [
        ("车内座舱温度 (实测)", "25 ℃", "cyan", "thermometer"),
        ("空调设定与风量", "17℃ · 已关", "plain", "fanblades"),
        ("驱动电机温度 (tmActTemp)", "29 ℃", "orange", "circle.hexagongrid.fill"),
        ("电机逆变器温 (invActTemp)", "30 ℃", "orange", "cpu"),
    ]

    // ===== 充电 OBC 与照明信号 =====
    // 当前工况 4 行 + 8月充电历史 2 行 (官方 rechargePm 3617 / chargeTimeMin 47 / cdl 13.65)
    let obcRows: [(String, String, Bool)] = [
        ("状态", "未充电", false), ("功率", "0 kW", false),
        ("OBC电流", "0 A", false), ("OBC温度", "未充电", false),
        ("8月充入", "13.65 kWh", true), ("8月时长", "47 分钟", true),
    ]
    let lightRows: [(String, String, Bool)] = [
        ("近光灯", "关闭", true), ("远光灯", "关闭", true),
        ("左右转向", "全关", true), ("示宽/雾灯", "全关", true),
        ("日行灯", "自动", true), ("伴我回家", "关闭", true),
    ]

    // ===== 10 宫格静态定义 (颜色顺序/文案 1:1 v32) =====
    // MARK: - 周期称谓 (标题/副标题/数值三者语义一致)
    /// 标题前缀词: 点昨日全说"昨日", 点8月全说"8月"
    var periodWord: String {
        if let m = selectedChartMonth { return "\(m)月" }
        switch selectedPeriod {
        case .today:     return "今日"
        case .yesterday: return "昨日"
        case .thisMonth: return "9月"
        case .lastMonth: return "8月"
        case .thisYear:  return "今年"
        case .lastYear:  return "去年"
        case .lifetime:  return "累计"
        case .custom:    return "自选"
        }
    }
    /// 副标题用词 (更口语/更完整)
    var periodSubWord: String {
        if let m = selectedChartMonth { return "\(m)月" }
        switch selectedPeriod {
        case .today:     return "今日"
        case .yesterday: return "昨日"
        case .thisMonth: return "9月"
        case .lastMonth: return "8月"
        case .thisYear:  return "今年"
        case .lastYear:  return "去年"
        case .lifetime:  return "提车至今"
        case .custom:    return "自选区间"
        }
    }
    /// 官方是否已结算该周期 (里程/电耗/燃油有真值)
    var periodSettled: Bool {
        if let m = selectedChartMonth { return m == 8 }
        switch selectedPeriod {
        case .today, .yesterday, .lastMonth, .lifetime: return true
        default: return false
        }
    }

    // MARK: - 10 宫格卡片定义 (标题+副标题 随周期派生, 与数值语义一致)
    var metricDefs: [MetricCardDef] {
        let w = periodWord, s = periodSubWord
        return [
            MetricCardDef(colorKey: "yellow", icon: "speedometer", title: "百公里油耗", unit: "L/100km",
                          subT: "插混能耗折算", subV: "燃油续航 673km", badge: "插混"),
            MetricCardDef(colorKey: "green", icon: "info.circle", title: "百公里耗电", unit: "kWh/100km",
                          subT: "能耗水平", subV: "同级领先", badge: "极省"),
            MetricCardDef(colorKey: "yellow", icon: "drop.fill", title: "\(w)消耗燃油", unit: "L",
                          subT: periodSettled ? "\(s)油耗累计" : "官方次月结算",
                          subV: periodSettled ? "纯电优先模式" : "尚未结算", badge: "省油"),
            MetricCardDef(colorKey: "cyan", icon: "bolt.fill", title: "\(w)电耗", unit: "kWh",
                          subT: periodSettled ? "\(s)耗电累计" : "官方次月结算",
                          subV: periodSettled ? "动态累计" : "尚未结算", badge: "实时"),
            MetricCardDef(colorKey: "green", icon: "car.fill", title: "\(w)里程", unit: "km",
                          subT: periodSettled ? "\(s)里程累计" : "官方次月结算",
                          subV: periodSettled ? "实时记录" : "尚未结算", badge: "里程"),
            MetricCardDef(colorKey: "cyan", icon: "battery.100", title: "\(w)充入电量", unit: "kWh",
                          subT: chargingSubT, subV: chargingSubV, badge: "电量"),
            MetricCardDef(colorKey: "green", icon: "figure.walk", title: "\(w)出行次数", unit: "次",
                          subT: "\(s)出行记录", subV: "官方实时可算", badge: "行程"),
            MetricCardDef(colorKey: "purple", icon: "bolt.circle.fill", title: "\(w)充电次数", unit: "次",
                          subT: "\(s)充电记录", subV: "官方实时可算", badge: "充电"),
            MetricCardDef(colorKey: "blue", icon: "chart.line.uptrend.xyaxis", title: "累计出行次数", unit: "次",
                          subT: "全生命周期", subV: "出行总和", badge: "总计"),
            MetricCardDef(colorKey: "purple", icon: "calendar", title: "相伴天数", unit: "天",
                          subT: "提车至今", subV: "风雨同行", badge: "陪伴")
        ]
    }

    /// #6 充入电量 副标题: 按周期显示官方真值, 消除"恒定 0.0 却讲 8月"的困惑
    private var chargingSubT: String {
        if let m = selectedChartMonth {
            return m == 8 ? "8月充入 13.65 kWh" : "\(m)月尚未结算"
        }
        switch selectedPeriod {
        case .today:     return "今日未充电"
        case .yesterday: return "昨日未充电"
        case .thisMonth: return "9月充电 1 次"
        case .lastMonth: return "8月充入 13.65 kWh"
        case .thisYear:  return "官方无年度汇总"
        case .lastYear:  return "账本未收录"
        case .lifetime:  return "累计充入待统计"
        case .custom:    return "自选区间"
        }
    }
    private var chargingSubV: String {
        if let m = selectedChartMonth {
            return m == 8 ? "已结算" : "—"
        }
        switch selectedPeriod {
        case .today, .yesterday: return "8月充入 13.65 kWh"
        case .thisMonth:         return "充入待结算"
        case .lastMonth:         return "充电 1 次"
        case .thisYear, .lastYear, .lifetime: return "—"
        case .custom:            return "—"
        }
    }

    // MARK: - 联动派生 (1:1 对齐 v32 selectPrimary / selectArchive / quickMonth)

    // 10 宫格 5 个动态值: mil / km / energy / fuelBurn / starts
    // 官方实测真值 (sgmw_official_client.py --action summary / mixmessage, 2026-09-18)
    // 里程/电耗/fuel: 官方仅 T+1 结算上一完整月, 未结算周期显 "—"
    // 出行/充电次数: 官方任意窗口实时可算, 全部为真值 → 永不显 "—"
    // 顺序: (里程, 里程, 电耗, 燃油, 出行次数, 充电次数)
    func metricValues() -> (mil: String, km: String, energy: String, fuel: String, starts: String, charges: String) {
        switch selectedPeriod {
        case .today:     return ("18.5", "18.5", "2.4", "0.0", "2", "0")
        case .yesterday: return ("65.0", "65.0", "8.3", "0.2", "4", "0")
        case .thisMonth: return ("—", "—", "—", "—", "7", "1")          // 9月: 里程/电耗官方未结算
        case .lastMonth: return ("225.7", "225.7", "13.65", "0.0", "16", "1") // 8月: 官方已结算
        case .thisYear:  return ("—", "—", "—", "—", "162", "14")       // 2026: 无年度汇总, 次数为累加真值
        case .lastYear:  return ("—", "—", "—", "—", "—", "—")         // 2025: 账本未收录
        case .lifetime:  return ("9,537", "9,537", "—", "—", "162", "14") // 提车至今: 仪表总里程为真值
        case .custom:    return ("—", "—", "—", "—", "—", "—")
        }
    }

    // 柱图月份覆盖 (quickMonth): 里程/电耗官方仅 8月 已结算, 其余月份官方返回 0.0 → 显 "—"
    // 出行/充电次数为官方真值, 任意窗口实时可算
    func chartOverride(month: Int) -> (mil: String, km: String, energy: String, fuel: String, starts: String, charges: String)? {
        guard let m = selectedChartMonth, m == month else { return nil }
        let bm = barMonths.first { $0.month == m }
        let starts = bm?.starts ?? 0
        switch m {
        case 8: return ("225.7", "225.7", "13.65", "0.0", "\(starts)", "1")
        case 9: return ("—", "—", "—", "—", "\(starts)", "1")
        default: return ("—", "—", "—", "—", "\(starts)", "0")
        }
    }

    // 10 宫格逐卡取值 (1:1 对齐 v32 DOM id 联动)
    func metricValue(at index: Int) -> String {
        // 柱图月份选中时优先覆盖 (quickMonth 联动)
        if let m = selectedChartMonth, let ov = chartOverride(month: m) {
            switch index {
            case 2: return ov.fuel
            case 3: return ov.energy
            case 4: return ov.mil
            case 6: return ov.starts     // {周期}出行次数
            case 7: return ov.charges    // {周期}充电次数
            case 8: return ov.starts
            default: break
            }
        }
        let base = metricValues()
        switch index {
        case 0: return "1.2"        // card-val-avg-fuel (恒定, 官方窗口均值)
        case 1: return "12.4"       // card-val-per-hundred (恒定)
        case 2: return base.fuel    // {周期}消耗燃油
        case 3: return base.energy  // {周期}电耗
        case 4: return base.mil     // {周期}里程
        case 5: return base.energy  // {周期}充入电量 (与官方 cdl 同源)
        case 6: return base.starts  // {周期}出行次数
        case 7: return base.charges // {周期}充电次数
        case 8: return base.starts  // 累计出行次数
        case 9: return "644"        // card-val-days (恒定)
        default: return "--"
        }
    }

    var headlineDesc: String {
        if let m = selectedChartMonth {
            let starts = barMonths.first { $0.month == m }?.starts ?? 0
            return "2026年\(m)月历史月报 · 当月出行 \(starts) 次"
        }
        switch selectedPeriod {
        case .today:     return "今日实时 · 今日出行采集中"
        case .yesterday: return "昨日完整归档 · 09月16日"
        case .thisMonth: return "9月动态月度累计 · 进行中"
        case .lastMonth: return "8月完整月报 · 充入 13.65 kWh / 行驶 139 分"
        case .thisYear:  return "2026 年度出行档案 · 累计出行 162 次"
        case .lastYear:  return "2025 年度出行档案 · 稳健陪伴"
        case .lifetime:  return "提车至今 (644天) · 全生命周期相伴"
        case .custom:    return "自选日期范围 · 自定义行程检索"
        }
    }

    var headlineStatus: String {
        if let m = selectedChartMonth {
            return m == 8 ? "8月已结算归档" : "2026年\(m)月"
        }
        switch selectedPeriod {
        case .today:     return "8月能耗月报已结算"
        case .yesterday: return "行程已完整同步"
        case .thisMonth: return "月度数据持续累加"
        case .lastMonth: return "8月官方已结算"
        default:         return "档案已归档"
        }
    }

    // 胶囊主副标题 (动态日期)
    var todayDayNum: String { "\(Calendar.current.component(.day, from: Date()))号" }
    var yesterdayDayNum: String {
        let d = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return "\(Calendar.current.component(.day, from: d))号"
    }
    var thisMonthName: String { "\(Calendar.current.component(.month, from: Date()))月" }
    var lastMonthName: String {
        let d = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return "\(Calendar.current.component(.month, from: d))月"
    }
    var navDateText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy年M月d日"
        return f.string(from: Date())
    }

    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.25)) {
            themeMode = (themeMode == .light) ? .dark : .light
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func applyCustomDateRange() {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy年M月d日"
        let startStr = f.string(from: customStartDate)
        let endStr = f.string(from: customEndDate)
        selectedPeriod = .custom
        selectedChartMonth = nil
        chartSubHint = "已检索：\(startStr) ~ \(endStr)"
        showDatePicker = false
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // ===== 交互动作 =====
    func selectPrimary(_ p: PeriodType) {
        selectedPeriod = p
        selectedChartMonth = nil
        withAnimation(.easeInOut(duration: 0.22)) { isTrayOpen = false }
        chartSubHint = "点击柱条即刻切换对应月份"
    }

    func selectArchive(_ p: PeriodType) {
        selectedPeriod = p
        selectedChartMonth = nil
        chartSubHint = "点击柱条即刻切换对应月份"
    }

    func toggleTray() {
        withAnimation(.easeInOut(duration: 0.25)) { isTrayOpen.toggle() }
    }

    func quickMonth(_ m: Int) {
        selectedChartMonth = m
        withAnimation(.easeInOut(duration: 0.25)) { isTrayOpen = false }
        let starts = barMonths.first { $0.month == m }?.starts ?? 0
        chartSubHint = "🟢 已切换至 \(m)月 · 当月出行 \(starts) 次"
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
