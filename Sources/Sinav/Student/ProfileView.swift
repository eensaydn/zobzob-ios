import SwiftUI

struct ProfileView: View {
    let studentId: String
    var onOpenLibrary: () -> Void = {}
    var onLogout: () -> Void
    @Environment(AppStore.self) private var store

    @State private var showResetAlert = false

    private var student: Student? { store.student(byId: studentId) }
    private var board: [AppStore.LeaderboardRow] { store.leaderboard() }
    private var myRank: Int? { board.first(where: { $0.student.id == studentId })?.rank }
    private var metrics: StudentMetrics {
        var m = store.metrics(forStudent: studentId)
        m.isRankOne = myRank == 1
        return m
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard
                statsRow
                if !metrics.scoreTrend.isEmpty { trendCard }
                achievementsCard
                if !metrics.topicAccuracy.isEmpty { topicProfileCard }
                signOutButton
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .background(Theme.canvas)
        .navigationTitle("Profilim")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: Header

    private var headerCard: some View {
        HStack(spacing: 16) {
            AvatarView(name: student?.name ?? "", size: 72, showRing: true)
            VStack(alignment: .leading, spacing: 6) {
                Text(student?.name ?? "")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text("\(student?.classroom ?? "") • Sıralama #\(myRank ?? 0)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                HStack(spacing: 6) {
                    BadgePill(text: "Seviye \(metrics.level)", icon: "star.fill", tint: Theme.brand)
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

    // MARK: Stats row

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatCard(label: "Test", value: "\(metrics.totalSubmissions)", caption: "çözüldü",
                     tint: Theme.brandSecondary, icon: "doc.text.fill")
            StatCard(label: "Doğru", value: "\(metrics.totalCorrect)", caption: "toplam",
                     tint: Theme.green, icon: "checkmark.circle.fill")
            StatCard(label: "Sezgi", value: "%\(metrics.calibration)", caption: "öz-değer.",
                     tint: Theme.brandAccent, icon: "brain.head.profile")
        }
    }

    // MARK: Trend

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İLERLEME").font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.textSecondary)
            SparklineView(values: metrics.scoreTrend, tint: Theme.brand)
                .padding(.vertical, 4)
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Achievements

    private var achievementsCard: some View {
        let computed = AchievementBank.all.map { ach -> (Achievement, Bool) in
            (ach, ach.test(metrics))
        }
        let unlocked = computed.filter { $0.1 }.count
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ROZETLER")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(unlocked)/\(AchievementBank.all.count)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.brand)
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(computed, id: \.0.id) { (ach, unlocked) in
                    achievementBadge(ach, unlocked: unlocked)
                }
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    private func achievementBadge(_ a: Achievement, unlocked: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(unlocked ? Theme.amber.opacity(0.18) : Color(uiColor: .tertiarySystemFill))
                Image(systemName: unlocked ? a.icon : "lock.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(unlocked ? Theme.amber : Theme.textTertiary)
            }
            .frame(height: 56)
            Text(a.name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(unlocked ? Theme.textPrimary : Theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(a.description)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Theme.textTertiary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .opacity(unlocked ? 1 : 0.6)
    }

    // MARK: Topic profile

    private var topicProfileCard: some View {
        let rows = metrics.topicAccuracy.map { (t, v) -> (TopicID, Int, Int) in
            let pct = v.total > 0 ? Int(round(Double(v.correct) / Double(v.total) * 100)) : 0
            return (t, pct, v.total)
        }.sorted { $0.1 < $1.1 }

        return VStack(alignment: .leading, spacing: 10) {
            Text("KONU PROFİLİN")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.textSecondary)
            VStack(spacing: 10) {
                ForEach(rows, id: \.0) { (topic, pct, count) in
                    ProgressRow(label: "\(topic.name) (\(count))",
                                value: pct, max: 100,
                                tint: pct >= 70 ? Theme.green : pct >= 40 ? Theme.amber : Theme.rose)
                }
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Sign out

    private var signOutButton: some View {
        Button {
            onLogout()
        } label: {
            Label("Hesaptan çık", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.rose)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressableStyle())
    }
}
