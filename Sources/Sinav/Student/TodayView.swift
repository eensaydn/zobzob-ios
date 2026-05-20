import SwiftUI

struct TodayView: View {
    let studentId: String
    var onOpenPill: (Pill) -> Void
    var onOpenTopic: (TopicID) -> Void
    var onGoToTests: () -> Void
    var onGoToLibrary: () -> Void = {}
    var onGoToMotivation: () -> Void = {}

    @Environment(AppStore.self) private var store

    private var student: Student? { store.student(byId: studentId) }
    private var metrics: StudentMetrics { store.metrics(forStudent: studentId) }
    private var todayPill: Pill { PillBank.todayPill() }
    private var todayWeekday: Int { Calendar.current.component(.weekday, from: Date()) - 1 }
    private var todayProgram: ProgramDay? { store.data.programByDay[todayWeekday] }
    private var upcoming: [MathTest] {
        store.data.tests
            .filter { !store.hasCompleted(student: studentId, test: $0.id) }
            .sorted { ($0.dueAt ?? .distantFuture) < ($1.dueAt ?? .distantFuture) }
            .prefix(3)
            .map { $0 }
    }
    private var completedToday: Int {
        let key = Date().dayKey
        return store.submissions(forStudent: studentId)
            .filter { $0.submittedAt.dayKey == key }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                heroCard
                motivationPeek

                if let prog = todayProgram {
                    todayConceptCard(prog)
                }

                Button {
                    Haptics.tap()
                    onOpenPill(todayPill)
                } label: {
                    PillFeatureCard(pill: todayPill)
                }
                .buttonStyle(PressableStyle())

                if !upcoming.isEmpty {
                    upcomingTestsSection
                }

                quickLinks
                statsRow
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Theme.canvas)
        .navigationTitle("Bugün")
        .navigationBarTitleDisplayMode(.large)
    }

    // Daily motivation preview card linking to Motivasyon tab
    private var motivationPeek: some View {
        let m = MotivationBank.today()
        return Button {
            Haptics.tap()
            onGoToMotivation()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.brand.opacity(0.14))
                        .frame(width: 42, height: 42)
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.brand)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Günün İlhamı")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.brand)
                        SparkleDecoration(tint: Theme.brand, size: 11)
                    }
                    Text("\u{201C}\(m.quote)\u{201D}")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text("— \(m.author)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.textTertiary)
            }
            .padding(12)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PressableStyle())
    }

    // Quick links row to library + motivation
    private var quickLinks: some View {
        HStack(spacing: 10) {
            quickLink(title: "Konular", icon: "books.vertical.fill", tint: Theme.brandSecondary) { onGoToLibrary() }
            quickLink(title: "Motivasyon", icon: "sparkles", tint: Theme.brand) { onGoToMotivation() }
        }
    }

    private func quickLink(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.tap(); action() }) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 13, weight: .semibold))
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Hero greeting

    private var heroCard: some View {
        HStack(spacing: 14) {
            ProgressRing(progress: metrics.levelProgress,
                         size: 78, lineWidth: 8,
                         tint: Theme.brand,
                         label: "L\(metrics.level)",
                         caption: "\(metrics.totalXP) puan")

            VStack(alignment: .leading, spacing: 6) {
                Text("Selam \(student?.firstName ?? "") 👋")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text(todayDateString)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                HStack(spacing: 6) {
                    if metrics.streak > 0 {
                        BadgePill(text: "\(metrics.streak) gün 🔥", tint: Theme.amber)
                    }
                    BadgePill(text: "%\(metrics.averageScore) ortalama", icon: "chart.line.uptrend.xyaxis", tint: Theme.green)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var todayDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "EEEE • d MMMM"
        return f.string(from: Date()).capitalizedTR
    }

    // MARK: Today concept

    private func todayConceptCard(_ p: ProgramDay) -> some View {
        Button {
            Haptics.tap()
            onOpenTopic(p.topic)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(p.topic.accent.opacity(0.14))
                        .frame(width: 50, height: 50)
                    Image(systemName: p.topic.symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(p.topic.accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Bugün öğreneceğin 📚")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(p.topic.accent)
                    }
                    Text(p.topic.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    if !p.note.isEmpty {
                        Text(p.note)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.textTertiary)
            }
            .padding(14)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: Upcoming tests

    private var upcomingTestsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Yapılacak görevler ✏️")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Button {
                    onGoToTests()
                } label: {
                    Text("Tümünü gör")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.brand)
                }
            }
            VStack(spacing: 8) {
                ForEach(upcoming) { t in
                    NavigationLink {
                        TakeTestView(testId: t.id, studentId: studentId)
                            .navigationBarBackButtonHidden()
                    } label: {
                        upcomingRow(t)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    private func upcomingRow(_ t: MathTest) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(t.topic.accent.opacity(0.13))
                Image(systemName: t.topic.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(t.topic.accent)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(t.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 6) {
                    TopicChip(topic: t.topic)
                    BadgePill(text: "\(t.questions.count) soru", tint: Theme.textSecondary)
                    if let due = t.dueAt {
                        let overdue = due < Date()
                        BadgePill(text: overdue ? "Geçti" : "Son: \(due.formattedShort())",
                                  icon: "clock.fill", tint: overdue ? Theme.rose : Theme.amber)
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: Stats

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatCard(label: "Bugün", value: "\(completedToday)",
                     caption: "test çözüldü", tint: Theme.brand,
                     icon: "calendar")
            StatCard(label: "Doğru", value: "\(metrics.totalCorrect)",
                     caption: "toplam", tint: Theme.green,
                     icon: "checkmark.circle.fill")
            StatCard(label: "Sezgi", value: "%\(metrics.calibration)",
                     caption: "öz-değer.", tint: Theme.brandSecondary,
                     icon: "brain.head.profile")
        }
    }
}

// MARK: - Turkish capitalize helper

extension String {
    var capitalizedTR: String {
        let trLocale = Locale(identifier: "tr_TR")
        return self.split(separator: " ").map { word -> String in
            let w = String(word)
            guard let first = w.first else { return w }
            let capFirst = String(first).uppercased(with: trLocale)
            return capFirst + String(w.dropFirst()).lowercased(with: trLocale)
        }.joined(separator: " ")
    }
}
