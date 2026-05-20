import SwiftUI
import Charts

// MARK: - KPI delta card

struct KPICard: View {
    let label: String
    let value: String
    let kpi: DeltaKPI
    var tint: Color = Theme.brand
    var icon: String

    private var deltaText: String {
        guard kpi.hasPrev else { return "—" }
        let sign = kpi.delta > 0 ? "+" : ""
        return "\(sign)\(kpi.delta)"
    }
    private var deltaColor: Color {
        if !kpi.hasPrev { return Theme.textTertiary }
        return kpi.delta > 0 ? Theme.green : kpi.delta < 0 ? Theme.rose : Theme.textTertiary
    }
    private var deltaIcon: String {
        if !kpi.hasPrev { return "minus" }
        return kpi.delta > 0 ? "arrow.up.right" : kpi.delta < 0 ? "arrow.down.right" : "minus"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                Text(label.uppercased(with: Locale(identifier: "tr_TR")))
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(0.5)
            }
            .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 4) {
                Image(systemName: deltaIcon)
                    .font(.system(size: 10, weight: .heavy))
                Text(deltaText)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                Text("son 7g")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.textTertiary)
            }
            .foregroundStyle(deltaColor)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Class average line chart

struct ClassAverageChart: View {
    let points: [DailyPoint]
    var tint: Color = Theme.brand

    var body: some View {
        if points.allSatisfy({ $0.avg == 0 && $0.count == 0 }) {
            EmptyChartCard(title: "Yeterli veri yok",
                           message: "Bu aralıkta teslim henüz yapılmamış.",
                           icon: "chart.line.uptrend.xyaxis")
        } else {
            Chart(points) { p in
                if p.avg > 0 {
                    AreaMark(x: .value("Gün", p.day),
                             y: .value("Ortalama", p.avg))
                    .foregroundStyle(LinearGradient(colors: [tint.opacity(0.35), tint.opacity(0.0)],
                                                    startPoint: .top, endPoint: .bottom))
                    LineMark(x: .value("Gün", p.day),
                             y: .value("Ortalama", p.avg))
                    .foregroundStyle(tint)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .interpolationMethod(.monotone)
                    .symbol(.circle)
                    .symbolSize(36)
                }
            }
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 75, 100]) { v in
                    AxisGridLine().foregroundStyle(Theme.separator.opacity(0.5))
                    AxisTick().foregroundStyle(Theme.separator)
                    AxisValueLabel {
                        if let i = v.as(Int.self) { Text("%\(i)").font(.system(size: 10, weight: .medium)) }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: max(1, points.count / 5))) { v in
                    AxisGridLine().foregroundStyle(Theme.separator.opacity(0.3))
                    AxisValueLabel(format: .dateTime.day().month(.narrow).locale(Locale(identifier: "tr_TR")))
                        .font(.system(size: 10))
                }
            }
            .frame(height: 180)
        }
    }
}

// MARK: - Topic bar chart

struct TopicBarChart: View {
    let topics: [TopicAccuracy]
    var body: some View {
        Chart(topics) { row in
            BarMark(
                x: .value("Başarı", row.pct),
                y: .value("Konu", row.topic.name)
            )
            .foregroundStyle(row.topic.accent.gradient)
            .cornerRadius(6)
            .annotation(position: .trailing, alignment: .leading, spacing: 6) {
                Text("%\(row.pct)")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(row.topic.accent)
            }
        }
        .chartXScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: [0, 25, 50, 75, 100]) { v in
                AxisGridLine().foregroundStyle(Theme.separator.opacity(0.4))
                AxisValueLabel {
                    if let i = v.as(Int.self) { Text("%\(i)").font(.system(size: 9, weight: .medium)) }
                }
            }
        }
        .chartYAxis {
            AxisMarks { v in
                AxisValueLabel().font(.system(size: 11, weight: .semibold))
            }
        }
        .frame(height: CGFloat(topics.count) * 30 + 30)
    }
}

// MARK: - Confidence calibration

struct CalibrationChart: View {
    let points: [CalibrationPoint]
    let ece: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Chart {
                // Perfect calibration reference line
                ForEach([0, 100], id: \.self) { v in
                    RuleMark(yStart: .value("y", 0), yEnd: .value("y", 100))
                        .foregroundStyle(.clear)
                }
                // Diagonal "perfect" line: just use a line between (0,0) and (100,100)
                LineMark(x: .value("Beyan", 0), y: .value("Gerçek", 0), series: .value("seri", "ideal"))
                    .foregroundStyle(Theme.separator)
                    .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [4, 4]))
                LineMark(x: .value("Beyan", 100), y: .value("Gerçek", 100), series: .value("seri", "ideal"))
                    .foregroundStyle(Theme.separator)
                    .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [4, 4]))

                ForEach(points) { p in
                    PointMark(
                        x: .value("Beyan", p.stated),
                        y: .value("Gerçek", p.actual)
                    )
                    .foregroundStyle(p.bucket.tint)
                    .symbolSize(CGFloat(max(50, min(280, p.count * 14))))
                    .annotation(position: .top, alignment: .center, spacing: 2) {
                        Text(p.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(p.bucket.tint)
                    }
                }
            }
            .chartXScale(domain: 0...100)
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: [0, 50, 100]) { v in
                    AxisGridLine().foregroundStyle(Theme.separator.opacity(0.3))
                    AxisValueLabel {
                        if let i = v.as(Int.self) { Text("%\(i)").font(.system(size: 9)) }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 50, 100]) { v in
                    AxisGridLine().foregroundStyle(Theme.separator.opacity(0.3))
                    AxisValueLabel {
                        if let i = v.as(Int.self) { Text("%\(i)").font(.system(size: 9)) }
                    }
                }
            }
            .frame(height: 200)
            .padding(.top, 12)

            HStack {
                Image(systemName: ece < 12 ? "checkmark.seal.fill" : ece < 20 ? "exclamationmark.triangle.fill" : "xmark.octagon.fill")
                    .foregroundStyle(ece < 12 ? Theme.green : ece < 20 ? Theme.amber : Theme.rose)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sezgi Hatası (ECE): \(Int(round(ece)))%")
                        .font(.system(size: 12, weight: .semibold))
                    Text(ece < 12 ? "Mükemmel: öğrenciler güvenlerini iyi okuyor."
                         : ece < 20 ? "Orta: bazı öğrenciler aşırı güvenli."
                         : "Zayıf: emin olduğu sorularda yanılıyorlar.")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
            }
            .padding(10)
            .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Discrimination scatter (difficulty vs success)

struct DifficultyScatter: View {
    let stats: [QuestionStat]

    var body: some View {
        Chart(stats) { s in
            PointMark(
                x: .value("Zorluk (öğretmen)", s.difficultyRated),
                y: .value("Başarı %", Int(s.accuracy * 100))
            )
            .foregroundStyle(s.topic.accent.opacity(0.85))
            .symbolSize(CGFloat(max(40, min(240, s.attempts * 8))))
        }
        .chartXScale(domain: 0.5...5.5)
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { v in
                AxisGridLine().foregroundStyle(Theme.separator.opacity(0.3))
                AxisValueLabel {
                    if let i = v.as(Int.self) {
                        Text(Difficulty(rawValue: i)?.label.prefix(3) ?? "")
                            .font(.system(size: 9, weight: .medium))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 25, 50, 75, 100]) { v in
                AxisGridLine().foregroundStyle(Theme.separator.opacity(0.3))
                AxisValueLabel {
                    if let i = v.as(Int.self) { Text("%\(i)").font(.system(size: 9)) }
                }
            }
        }
        .frame(height: 200)
    }
}

// MARK: - Heatmap (students × topics)

struct Heatmap: View {
    let cells: [HeatCell]
    let students: [Student]
    let topics: [TopicID]

    private func cell(student: Student, topic: TopicID) -> HeatCell? {
        cells.first { $0.studentId == student.id && $0.topic == topic }
    }

    private func color(_ pct: Int) -> Color {
        if pct < 0 { return Color(uiColor: .tertiarySystemFill) }
        let p = Double(pct) / 100.0
        // 0 -> rose, 0.5 -> amber, 1.0 -> green
        if p < 0.5 {
            return Color.interpolate(Theme.rose, Theme.amber, t: p / 0.5)
        } else {
            return Color.interpolate(Theme.amber, Theme.green, t: (p - 0.5) / 0.5)
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 4) {
                // Header (topics)
                HStack(spacing: 4) {
                    Text("")
                        .frame(width: 86, alignment: .leading)
                    ForEach(topics) { t in
                        VStack(spacing: 2) {
                            Image(systemName: t.symbol)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(t.accent)
                        }
                        .frame(width: 36)
                    }
                }
                ForEach(students) { st in
                    HStack(spacing: 4) {
                        Text(st.firstName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)
                            .frame(width: 86, alignment: .leading)
                        ForEach(topics) { topic in
                            let c = cell(student: st, topic: topic)
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(color(c?.pct ?? -1))
                                Text(c?.pct ?? -1 >= 0 ? "\(c!.pct)" : "—")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .foregroundStyle(c?.pct ?? -1 >= 0 ? .white : Theme.textTertiary)
                            }
                            .frame(width: 36, height: 30)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
}

extension Color {
    static func interpolate(_ a: Color, _ b: Color, t: Double) -> Color {
        let tt = max(0, min(1, t))
        let ai = UIColor(a).rgba
        let bi = UIColor(b).rgba
        let r = ai.r + (bi.r - ai.r) * tt
        let g = ai.g + (bi.g - ai.g) * tt
        let bl = ai.b + (bi.b - ai.b) * tt
        return Color(red: r, green: g, blue: bl)
    }
}

private extension UIColor {
    var rgba: (r: Double, g: Double, b: Double, a: Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }
}

// MARK: - Submission velocity bars

struct SubmissionsBar: View {
    let points: [DailyPoint]
    var body: some View {
        Chart(points) { p in
            BarMark(x: .value("Gün", p.day),
                    y: .value("Teslim", p.count))
            .foregroundStyle(Theme.brand.opacity(0.75))
            .cornerRadius(3)
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Theme.separator.opacity(0.3))
                AxisValueLabel().font(.system(size: 9))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: max(1, points.count / 5))) { _ in
                AxisGridLine().foregroundStyle(Theme.separator.opacity(0.3))
                AxisValueLabel(format: .dateTime.day().month(.narrow).locale(Locale(identifier: "tr_TR")))
                    .font(.system(size: 9))
            }
        }
        .frame(height: 120)
    }
}
