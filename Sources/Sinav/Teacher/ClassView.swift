import SwiftUI

struct ClassView: View {
    @Environment(AppStore.self) private var store
    @State private var query = ""

    private var rows: [AppStore.LeaderboardRow] {
        let all = store.leaderboard()
        if query.isEmpty { return all }
        return all.filter { $0.student.name.localizedCaseInsensitiveContains(query) ||
            $0.student.classroom.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        Group {
            if rows.isEmpty {
                EmptyState(icon: "person.3",
                           title: "Öğrenci bulunamadı",
                           message: "Arama kriterine uygun öğrenci yok.")
            } else {
                List {
                    ForEach(rows) { r in
                        NavigationLink(value: r.student) {
                            HStack(spacing: 12) {
                                Text("\(r.rank)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(r.rank <= 3 ? Theme.amber : Theme.textTertiary)
                                    .frame(width: 22)
                                AvatarView(name: r.student.name, size: 38)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(r.student.name)
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("\(r.student.classroom) • L\(r.metrics.level) • \(r.metrics.totalSubmissions) test")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                Spacer()
                                Text("\(r.metrics.totalXP)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.brand)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { idxs in
                        for i in idxs {
                            store.deleteStudent(id: rows[i].student.id)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Theme.canvas)
            }
        }
        .navigationTitle("Sınıf")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $query, prompt: "Öğrenci ara")
        .navigationDestination(for: Student.self) { s in
            TeacherStudentDetailView(student: s)
        }
    }
}

// MARK: - Student detail (teacher view)

struct TeacherStudentDetailView: View {
    let student: Student
    @Environment(AppStore.self) private var store

    private var metrics: StudentMetrics { store.metrics(forStudent: student.id) }
    private var subs: [Submission] {
        store.submissions(forStudent: student.id).sorted { $0.submittedAt > $1.submittedAt }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                statsRow
                if !metrics.scoreTrend.isEmpty { trendCard }
                topicProfileCard
                submissionsCard
            }
            .padding(16)
        }
        .background(Theme.canvas)
        .navigationTitle(student.firstName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 14) {
            AvatarView(name: student.name, size: 62, showRing: true)
            VStack(alignment: .leading, spacing: 4) {
                Text(student.name)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                Text("\(student.classroom) • \(subs.count) test")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                HStack(spacing: 6) {
                    BadgePill(text: "L\(metrics.level)", icon: "star.fill", tint: Theme.brand)
                    BadgePill(text: "\(metrics.totalXP) puan", tint: Theme.brandSecondary)
                    if metrics.streak > 0 {
                        BadgePill(text: "\(metrics.streak)", icon: "flame.fill", tint: Theme.amber)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatCard(label: "Ortalama", value: "%\(metrics.averageScore)", tint: Theme.brand, icon: "chart.bar.fill")
            StatCard(label: "Sezgi", value: "%\(metrics.calibration)",
                     caption: "öz-değer.", tint: Theme.brandAccent, icon: "brain.head.profile")
            StatCard(label: "Test", value: "\(metrics.totalSubmissions)",
                     caption: "çözüldü", tint: Theme.brandSecondary, icon: "doc.text.fill")
        }
    }

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İLERLEME").font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6).foregroundStyle(Theme.textSecondary)
            SparklineView(values: metrics.scoreTrend, tint: Theme.brand)
                .padding(.vertical, 4)
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    private var topicProfileCard: some View {
        let rows = metrics.topicAccuracy.map { (t, v) -> (TopicID, Int, Int) in
            let pct = v.total > 0 ? Int(round(Double(v.correct) / Double(v.total) * 100)) : 0
            return (t, pct, v.total)
        }.sorted { $0.1 < $1.1 }
        return VStack(alignment: .leading, spacing: 10) {
            Text("KONU PROFİLİ").font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6).foregroundStyle(Theme.textSecondary)
            if rows.isEmpty {
                EmptyChartCard(title: "Veri yok",
                               message: "Öğrenci test çözmeye başlayınca burada görünecek.",
                               icon: "chart.pie")
            } else {
                VStack(spacing: 10) {
                    ForEach(rows, id: \.0) { (topic, pct, count) in
                        ProgressRow(label: "\(topic.name) (\(count))", value: pct,
                                    tint: pct >= 70 ? Theme.green : pct >= 40 ? Theme.amber : Theme.rose)
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    private var submissionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TESLİMLER").font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6).foregroundStyle(Theme.textSecondary)
            if subs.isEmpty {
                EmptyChartCard(title: "Henüz teslim yok",
                               message: "İlk testi çözünce burada görünecek.",
                               icon: "tray")
            } else {
                VStack(spacing: 6) {
                    ForEach(subs) { sub in
                        if let t = store.test(byId: sub.testId) {
                            NavigationLink {
                                TestDetailView(test: t)
                            } label: {
                                submissionRow(sub: sub, test: t)
                            }
                            .buttonStyle(PressableStyle())
                        }
                    }
                }
            }
        }
    }

    private func submissionRow(sub: Submission, test: MathTest) -> some View {
        let sc = store.score(test: test, submission: sub)
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(test.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                Text(sub.submittedAt.formattedShortTime())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Text("%\(sc.pct)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(sc.pct >= 70 ? Theme.green : sc.pct >= 40 ? Theme.amber : Theme.rose)
        }
        .padding(10)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
    }
}
