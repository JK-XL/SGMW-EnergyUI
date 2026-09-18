import SwiftUI

// MARK: - 四轮胎压监测卡 (1:1 v32 v5-status-card + tire-wire-box + 纯净卡宴剪影)
struct TirePressureCardView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            // v5-sc-head
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 13))
                        .foregroundColor(p.accentCyan)
                    Text("四轮胎压监测")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(p.textPrimary)
                }
                Spacer()
                Text(model.tireChip)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(p.accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(p.accentGreen.opacity(0.12)))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(p.accentGreen.opacity(0.25), lineWidth: 1))
            }
            .padding(.bottom, 12)

            // tire-wire-box (pad12/14, radius14, sub底)
            HStack(spacing: 0) {
                // 左列 (左前/左后, border-left 3px 绿)
                VStack(spacing: 18) {
                    tireUnit(label: "左前 (tireLF)", val: model.tireLF, alignRight: false)
                    tireUnit(label: "左后 (tireLR)", val: model.tireLR, alignRight: false)
                }
                .frame(width: 62, alignment: .leading)

                Spacer()

                // 中央车模 (viewBox 100x220)
                CarSilhouetteView()
                    .frame(maxHeight: 156)
                    .padding(.horizontal, 2)

                Spacer()

                // 右列 (右前/右后, border-right 3px 绿, 右对齐)
                VStack(spacing: 18) {
                    tireUnit(label: "右前 (tireRF)", val: model.tireRF, alignRight: true)
                    tireUnit(label: "右后 (tireRR)", val: model.tireRR, alignRight: true)
                }
                .frame(width: 62, alignment: .trailing)
            }
            .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(p.subCardBG))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(p.subCardBorder, lineWidth: 1))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .v32Card(radius: 18)
        .padding(.bottom, 12)
    }

    private func tireUnit(label: String, val: Int, alignRight: Bool) -> some View {
        VStack(alignment: alignRight ? .trailing : .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(p.textMuted)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(val)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(p.textPrimary)
                Text("kPa")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(p.accentGreen)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: alignRight ? .trailing : .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(p.cardBG)
                .shadow(color: p.cardShadow, radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(p.cardBorder, lineWidth: 1)
        )
        .overlay(alignment: alignRight ? .trailing : .leading) {
            // 3px 绿色边条 (1:1 border-left/right)
            Rectangle().fill(p.accentGreen).frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - 卡宴剪影 (SVG viewBox 0 0 100 220 全部贝塞尔 1:1 重绘)
struct CarSilhouetteView: View {
    @Environment(\.colorScheme) private var scheme
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 4 只内收车轮 (rect + 绿色反光条)
                Group {
                    wheel(x: 13, y: 36, w: 8, h: 26, rx: 3.5)
                    wheel(x: 79, y: 36, w: 8, h: 26, rx: 3.5)
                    wheel(x: 12, y: 148, w: 9.5, h: 30, rx: 4)
                    wheel(x: 78.5, y: 148, w: 9.5, h: 30, rx: 4)
                }
                // 车身主轮廓
                bodyOutline
                    .fill(LinearGradient(colors: [p.carPaintTop, p.carPaintMid, p.carPaintBottom],
                                         startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 1, y: 1)))
                    .overlay(bodyOutline.stroke(p.carStroke, lineWidth: 1.8))
                // 机盖双脊线
                Path { $0.move(to: CGPoint(x: 36, y: 20)); $0.addCurve(to: CGPoint(x: 37, y: 62), control1: CGPoint(x: 39, y: 34), control2: CGPoint(x: 38, y: 52)) }
                    .stroke(p.carStroke.opacity(0.5), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                Path { $0.move(to: CGPoint(x: 64, y: 20)); $0.addCurve(to: CGPoint(x: 63, y: 62), control1: CGPoint(x: 61, y: 34), control2: CGPoint(x: 62, y: 52)) }
                    .stroke(p.carStroke.opacity(0.5), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                // 大灯 (glass + 4 蓝钻点)
                headlightLeft.fill(p.carGlass).overlay(headlightLeft.stroke(p.carStroke, lineWidth: 1.1))
                headlightRight.fill(p.carGlass).overlay(headlightRight.stroke(p.carStroke, lineWidth: 1.1))
                ForEach(gemPoints, id: \.self) { pt in
                    Circle().fill(Color(hex: 0x007AFF)).frame(width: 2, height: 2).position(pt)
                }
                // 后视镜
                mirrorLeft.fill(p.carGlass).overlay(mirrorLeft.stroke(p.carStroke, lineWidth: 1))
                mirrorRight.fill(p.carGlass).overlay(mirrorRight.stroke(p.carStroke, lineWidth: 1))
                // 前后风挡
                windshieldFront.fill(p.carGlass).overlay(windshieldFront.stroke(p.carStroke, lineWidth: 1.2))
                windshieldRear.fill(p.carGlass).overlay(windshieldRear.stroke(p.carStroke, lineWidth: 1.2))
                // 后翼子板微光肩线
                Path { $0.move(to: CGPoint(x: 16, y: 126)); $0.addCurve(to: CGPoint(x: 15, y: 176), control1: CGPoint(x: 12, y: 138), control2: CGPoint(x: 11, y: 158)) }
                    .stroke(p.carStroke.opacity(0.4), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                Path { $0.move(to: CGPoint(x: 84, y: 126)); $0.addCurve(to: CGPoint(x: 85, y: 176), control1: CGPoint(x: 88, y: 138), control2: CGPoint(x: 89, y: 158)) }
                    .stroke(p.carStroke.opacity(0.4), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                // 贯穿式 3D 红色 LED 尾灯带
                Path { $0.move(to: CGPoint(x: 16, y: 193)); $0.addCurve(to: CGPoint(x: 84, y: 193), control1: CGPoint(x: 32, y: 197), control2: CGPoint(x: 68, y: 197)) }
                    .stroke(Color(hex: 0xFF3B30), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
                    .shadow(color: Color(hex: 0xFF3B30), radius: 2)
            }
            .aspectRatio(100.0 / 220.0, contentMode: .fit)
        }
    }

    private func wheel(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, rx: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: rx, style: .continuous)
                .fill(Color(hex: 0x1C2128))
                .overlay(RoundedRectangle(cornerRadius: rx, style: .continuous).stroke(Color.black.opacity(0.15), lineWidth: 0.7))
                .frame(width: w, height: h)
                .position(CGPoint(x: x + w / 2, y: y + h / 2))
            RoundedRectangle(cornerRadius: 0.8)
                .fill(Color(hex: 0x28CD41))
                .frame(width: 1.6, height: h * 0.5)
                .position(CGPoint(x: x + w - 1.2, y: y + h / 2))
        }
    }

    private var gemPoints: [CGPoint] {
        [CGPoint(x: 23, y: 32), CGPoint(x: 27, y: 33), CGPoint(x: 23, y: 38), CGPoint(x: 27, y: 39),
         CGPoint(x: 73, y: 33), CGPoint(x: 77, y: 32), CGPoint(x: 73, y: 39), CGPoint(x: 77, y: 38)]
    }

    // 修长卡宴外轮廓 (原 SVG path 逐段转换)
    private var bodyOutline: Path {
        var path = Path()
        path.move(to: CGPoint(x: 30, y: 18))
        path.addCurve(to: CGPoint(x: 70, y: 18), control1: CGPoint(x: 38, y: 15), control2: CGPoint(x: 62, y: 15))
        path.addCurve(to: CGPoint(x: 88, y: 38), control1: CGPoint(x: 80, y: 21), control2: CGPoint(x: 86, y: 28))
        path.addCurve(to: CGPoint(x: 88, y: 70), control1: CGPoint(x: 90, y: 48), control2: CGPoint(x: 89, y: 62))
        path.addCurve(to: CGPoint(x: 84, y: 116), control1: CGPoint(x: 85, y: 82), control2: CGPoint(x: 84, y: 100))
        path.addCurve(to: CGPoint(x: 89, y: 148), control1: CGPoint(x: 84, y: 128), control2: CGPoint(x: 86, y: 140))
        path.addCurve(to: CGPoint(x: 88, y: 184), control1: CGPoint(x: 92, y: 158), control2: CGPoint(x: 91, y: 172))
        path.addCurve(to: CGPoint(x: 50, y: 203), control1: CGPoint(x: 83, y: 196), control2: CGPoint(x: 73, y: 203))
        path.addCurve(to: CGPoint(x: 12, y: 184), control1: CGPoint(x: 27, y: 203), control2: CGPoint(x: 17, y: 196))
        path.addCurve(to: CGPoint(x: 11, y: 148), control1: CGPoint(x: 9, y: 172), control2: CGPoint(x: 8, y: 158))
        path.addCurve(to: CGPoint(x: 16, y: 116), control1: CGPoint(x: 14, y: 140), control2: CGPoint(x: 16, y: 128))
        path.addCurve(to: CGPoint(x: 12, y: 70), control1: CGPoint(x: 16, y: 100), control2: CGPoint(x: 15, y: 82))
        path.addCurve(to: CGPoint(x: 12, y: 38), control1: CGPoint(x: 11, y: 62), control2: CGPoint(x: 10, y: 48))
        path.addCurve(to: CGPoint(x: 30, y: 18), control1: CGPoint(x: 14, y: 28), control2: CGPoint(x: 20, y: 21))
        path.closeSubpath()
        return path
    }

    private var headlightLeft: Path {
        var path = Path()
        path.move(to: CGPoint(x: 19, y: 28))
        path.addCurve(to: CGPoint(x: 30, y: 33), control1: CGPoint(x: 22, y: 25), control2: CGPoint(x: 28, y: 27))
        path.addCurve(to: CGPoint(x: 22, y: 43), control1: CGPoint(x: 31, y: 40), control2: CGPoint(x: 26, y: 45))
        path.addCurve(to: CGPoint(x: 19, y: 28), control1: CGPoint(x: 19, y: 41), control2: CGPoint(x: 17, y: 34))
        path.closeSubpath()
        return path
    }

    private var headlightRight: Path {
        var path = Path()
        path.move(to: CGPoint(x: 81, y: 28))
        path.addCurve(to: CGPoint(x: 70, y: 33), control1: CGPoint(x: 78, y: 25), control2: CGPoint(x: 72, y: 27))
        path.addCurve(to: CGPoint(x: 78, y: 43), control1: CGPoint(x: 69, y: 40), control2: CGPoint(x: 74, y: 45))
        path.addCurve(to: CGPoint(x: 81, y: 28), control1: CGPoint(x: 81, y: 41), control2: CGPoint(x: 83, y: 34))
        path.closeSubpath()
        return path
    }

    private var mirrorLeft: Path {
        var path = Path()
        path.move(to: CGPoint(x: 14, y: 68))
        path.addLine(to: CGPoint(x: 4, y: 64))
        path.addCurve(to: CGPoint(x: 5, y: 73), control1: CGPoint(x: 2, y: 64), control2: CGPoint(x: 2, y: 69))
        path.addLine(to: CGPoint(x: 13, y: 71))
        path.closeSubpath()
        return path
    }

    private var mirrorRight: Path {
        var path = Path()
        path.move(to: CGPoint(x: 86, y: 68))
        path.addLine(to: CGPoint(x: 96, y: 64))
        path.addCurve(to: CGPoint(x: 95, y: 73), control1: CGPoint(x: 98, y: 64), control2: CGPoint(x: 98, y: 69))
        path.addLine(to: CGPoint(x: 87, y: 71))
        path.closeSubpath()
        return path
    }

    private var windshieldFront: Path {
        var path = Path()
        path.move(to: CGPoint(x: 19, y: 68))
        path.addCurve(to: CGPoint(x: 81, y: 68), control1: CGPoint(x: 31, y: 62), control2: CGPoint(x: 69, y: 62))
        path.addLine(to: CGPoint(x: 76, y: 96))
        path.addCurve(to: CGPoint(x: 24, y: 96), control1: CGPoint(x: 65, y: 92), control2: CGPoint(x: 35, y: 92))
        path.closeSubpath()
        return path
    }

    private var windshieldRear: Path {
        var path = Path()
        path.move(to: CGPoint(x: 28, y: 156))
        path.addCurve(to: CGPoint(x: 72, y: 156), control1: CGPoint(x: 38, y: 153), control2: CGPoint(x: 62, y: 153))
        path.addLine(to: CGPoint(x: 69, y: 180))
        path.addCurve(to: CGPoint(x: 31, y: 180), control1: CGPoint(x: 62, y: 183), control2: CGPoint(x: 38, y: 183))
        path.closeSubpath()
        return path
    }
}

// MARK: - 全车车锁与防盗 (1:1 v32 doors-grid 2列8格)
struct LockSecurityCardView: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var model: DashboardModel
    private var p: V32Palette { V32Palette(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(p.accentCyan)
                    Text("全车车锁与防盗")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(p.textPrimary)
                }
                Spacer()
                Text(model.lockChip)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(p.accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(p.accentGreen.opacity(0.12)))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(p.accentGreen.opacity(0.25), lineWidth: 1))
            }
            .padding(.bottom, 12)

            // doors-grid (2列 gap8 pad10 radius14)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(0..<model.doorPods.count, id: \.self) { idx in
                    let pod = model.doorPods[idx]
                    HStack {
                        Text(pod.0)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(p.textSecondary)
                        Spacer()
                        Text(pod.1)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(p.accentGreen)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(p.cardBG))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(p.cardBorder, lineWidth: 1))
                    .shadow(color: p.cardShadow, radius: 3, x: 0, y: 1)
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(p.subCardBG))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(p.subCardBorder, lineWidth: 1))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .v32Card(radius: 18)
        .padding(.bottom, 12)
    }
}
