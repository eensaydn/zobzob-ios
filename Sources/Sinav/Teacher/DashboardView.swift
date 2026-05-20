import SwiftUI
import Charts

struct DashboardView: View {
    @Binding var role: AppRole?
    var switchTab: (TeacherTabView.Tab) -> Void

    @Environment(AppStore.self) private var store
    @State private var showNewTest = false
    @State private var range: DateRange = .last30

    private var analytics: Analytics { Analytics(store) }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                kpiGrid
                trajectoryCard
                alertsCard
                outliersCard
                topicSnapshotCard
                recentActivityCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            .padding(.top, 4)
        }
        .background(Theme.canvas)
        .navigationTitle("Panel")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("Rol Değiştir", systemImage: "arrow.left.arrow.right") {
                        role = nil
                    }
                    Divider()
                    Button("Verileri sıfırla", systemImage: "arrow.counterclockwise", role: .destructive) {
                        store.resetToSample()
                    }
                } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.tap()
                    showNewTest = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .symbolEffect(.bounce, value: showNewTest)
                }
            }
        }
        .refreshable {
            // Trigger re-render
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        .sheet(isPresented: $showNewTest) {
            NavigationStack { TestEditorView() }
        }
    }

    // MARK: KPI grid (4 cards with deltas)

    private var kpiGrid: some View {
        let k = analytics.kpis()
        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                KPICard(label: "Sınıf ortalaması", value: "%\(k.avg.value)", kpi: k.avg,
                        tint: Theme.brand, icon: "chart.bar.fill")
                KPICard(label: "Teslim", value: "\(k.submissions.value)", kpi: k.submissions,
                        tint: Theme.brandSecondary, icon: "tray.fill")
            }
            HStack(spacing: 10) {
                KPICard(label: "Sezgi", value: "\(k.calibration.value)/100", kpi: k.calibration,
                        tint: Theme.amber, icon: "brain.head.profile")
                KPICard(label: "Katılım", value: "%\(k.completion.value)", kpi: k.completion,
                        tint: Theme.green, icon: "checkmark.circle.fill")
            }
        }
    }

    // MARK: Trajectory + range picker

    private var trajectoryCard: some View {
        let points = analytics.dailyClassAverage(in: range)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SINIF YÖRÜNGESİ")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(Theme.textSecondary)
                    Text("Günlük sınıf ortalaması")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                Picker("", selection: $range) {
                    ForEach(DateRange.allCases) { r in Text(r.label).tag(r) }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }

            ClassAverageChart(points: points)

            HStack(spacing: 16) {
                if let last = points.last(where: { $0.avg > 0 })?.avg,
                   let first = points.first(where: { $0.avg > 0 })?.avg {
                    statPill(icon: "arrow.up.right", text: "Δ \(last - first) puan",
                             tint: (last - first) >= 0 ? Theme.green : Theme.rose)
                }
                let total = points.map { $0.count }.reduce(0, +)
                statPill(icon: "tray.fill", text: "\(total) teslim", tint: Theme.brandSecondary)
                Spacer()
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Action alerts

    private var alertsCard: some View {
        let alerts = analytics.alerts()
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.bubble.fill")
                    .foregroundStyle(Theme.amber)
                    .symbolEffect(.pulse, options: .repeating)
                Text("DİKKAT EDİLMESİ GEREKENLER")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(alerts.count)")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(alerts.isEmpty ? Theme.green : Theme.amber, in: Capsule())
            }
            if alerts.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.green)
                    Text("Şu an aksiyon gereken bir durum yok. Tüm öğrenciler iyi gidiyor.")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                }
                .padding(12)
                .background(Theme.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 8) {
                    ForEach(alerts.prefix(4), id: \.id) { alert in
                        alertRow(alert)
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private func alertRow(_ a: Analytics.Alert) -> some View {
        switch a {
        case .overdueTest(let t, let missing):
            NavigationLink {
                TestDetailView(test: t)
            } label: {
                alertContent(
                    icon: "clock.badge.exclamationmark.fill",
                    tint: Theme.amber,
                    title: "“\(t.title)” süresi geçti",
                    sub: "\(missing) öğrenci teslim etmedi"
                )
            }
            .buttonStyle(PressableStyle())

        case .weakTopic(let topic, let pct, let attempts):
            Button {
                switchTab(.insights)
            } label: {
                alertContent(
                    icon: topic.symbol,
                    tint: topic.accent,
                    title: "Sınıf “\(topic.name)” konusunda zayıf",
                    sub: "Son 30 günde %\(pct) başarı · \(attempts) cevap"
                )
            }
            .buttonStyle(PressableStyle())

        case .strugglingStudent(let student, let pct):
            NavigationLink {
                TeacherStudentDetailView(student: student)
            } label: {
                alertContent(
                    icon: "person.fill.questionmark",
                    tint: Theme.rose,
                    title: "\(student.name) zorlanıyor",
                    sub: "Son 7 gün ortalaması %\(pct)"
                )
            }
            .buttonStyle(PressableStyle())

        case .hardestQuestion(let q):
            if let t = store.test(byId: q.testId) {
                NavigationLink {
                    TestDetailView(test: t)
                } label: {
                    alertContent(
                        icon: "questionmark.circle.fill",
                        tint: Theme.rose,
                        title: "Çok zorlu bir soru var",
                        sub: "“\(q.testTitle)” · sınıfın %\(Int(q.accuracy * 100)) başarısı"
                    )
                }
                .buttonStyle(PressableStyle())
            }
        }
    }

    private func alertContent(icon: String, tint: Color, title: String, sub: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(tint.opacity(0.14))
                Image(systemName: icon).foregroundStyle(tint).font(.system(size: 17, weight: .semibold))
            }
            .frame(width: 38, height: 38)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(sub)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(10)
        .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Outliers (struggling / rising)

    private var outliersCard: some View {
        let (struggling, rising) = analytics.outliers()
        return VStack(spacing: 10) {
            outlierGroup(title: "DESTEK GEREKEN", icon: "arrow.down.right", tint: Theme.rose, rows: struggling)
            outlierGroup(title: "YÜKSELİYOR", icon: "arrow.up.right", tint: Theme.green, rows: rising)
        }
    }

    private func outlierGroup(title: String, icon: String, tint: Color, rows: [OutlierStudent]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
            if rows.isEmpty {
                HStack {
                    Text("Bu kategoride öğrenci yok.")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                    Spacer()
                }
                .padding(.vertical, 6)
            } else {
                VStack(spacing: 6) {
                    ForEach(rows.prefix(3)) { o in
                        NavigationLink {
                            TeacherStudentDetailView(student: o.student)
                        } label: {
                            outlierRow(o, tint: tint)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func outlierRow(_ o: OutlierStudent, tint: Color) -> some View {
        HStack(spacing: 12) {
            AvatarView(name: o.student.name, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(o.student.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 4) {
                    Text("%\(o.recentAvg)").font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(o.recentAvg >= 70 ? Theme.green : o.recentAvg >= 40 ? Theme.amber : Theme.rose)
                    if o.prevAvg > 0 {
                        Image(systemName: "arrow.right").font(.system(size: 8)).foregroundStyle(Theme.textTertiary)
                        Text("önceki %\(o.prevAvg)").font(.system(size: 11)).foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: o.delta >= 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 9, weight: .heavy))
                Text("\(o.delta >= 0 ? "+" : "")\(o.delta)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(tint.opacity(0.12), in: Capsule())
        }
    }

    // MARK: Topic snapshot

    private var topicSnapshotCard: some View {
        let topics = analytics.topicAccuracy(in: range)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("KONU BAZLI DURUM")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Button {
                    switchTab(.insights)
                } label: {
                    Text("Detay")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.brand)
                }
            }
            if topics.isEmpty {
                EmptyChartCard(title: "Veri yok",
                               message: "Bu aralıkta cevap toplanmamış.",
                               icon: "chart.pie")
            } else {
                TopicBarChart(topics: topics)
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Recent activity (kept but compact)

    private var recentActivityCard: some View {
        let recent = store.data.submissions.sorted { $0.submittedAt > $1.submittedAt }.prefix(5)
        return VStack(alignment: .leading, spacing: 10) {
            Text("SON AKTİVİTE")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(Theme.textSecondary)
            if recent.isEmpty {
                EmptyChartCard(title: "Henüz teslim yok", message: "Öğrenciler test çözünce burada görünür.", icon: "tray")
            } else {
                VStack(spacing: 6) {
                    ForEach(Array(recent), id: \.id) { sub in
                        if let s = store.student(byId: sub.studentId),
                           let t = store.test(byId: sub.testId) {
                            NavigationLink {
                                TestDetailView(test: t)
                            } label: {
                                recentRow(s: s, t: t, sub: sub)
                            }
                            .buttonStyle(PressableStyle())
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    private func recentRow(s: Student, t: MathTest, sub: Submission) -> some View {
        let sc = store.score(test: t, submission: sub)
        return HStack(spacing: 12) {
            AvatarView(name: s.name, size: 32)
            VStack(alignment: .leading, spacing: 1) {
                Text(s.name).font(.system(size: 13, weight: .semibold))
                Text(t.title).font(.system(size: 11)).foregroundStyle(Theme.textSecondary).lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text("%\(sc.pct)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(sc.pct >= 70 ? Theme.green : sc.pct >= 40 ? Theme.amber : Theme.rose)
                Text(sub.submittedAt.formattedRelative())
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: Helpers

    private func statPill(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10, weight: .heavy))
            Text(text).font(.system(size: 11, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(tint.opacity(0.12), in: Capsule())
    }
}
