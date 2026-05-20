import SwiftUI

struct TestDetailView: View {
    let test: MathTest
    @Environment(AppStore.self) private var store

    private var subs: [Submission] { store.submissions(forTest: test.id) }

    private var rankedRows: [(student: Student, sub: Submission, score: (correct: Int, total: Int, pct: Int, time: Int))] {
        subs.compactMap { sub in
            guard let s = store.student(byId: sub.studentId) else { return nil }
            return (s, sub, store.score(test: test, submission: sub))
        }
        .sorted { $0.score.pct > $1.score.pct }
    }

    private var classAvg: Int {
        rankedRows.isEmpty ? 0 : Int(round(Double(rankedRows.map { $0.score.pct }.reduce(0, +)) / Double(rankedRows.count)))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statsCard
                rankedSection
                perQuestionSection
            }
            .padding(16)
        }
        .background(Theme.canvas)
        .navigationTitle(test.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statsCard: some View {
        HStack(spacing: 10) {
            StatCard(label: "Teslim", value: "\(subs.count)", tint: Theme.brandSecondary, icon: "tray.fill")
            StatCard(label: "Sınıf Ort.", value: "%\(classAvg)", tint: Theme.brand, icon: "chart.bar.fill")
            StatCard(label: "Soru", value: "\(test.questions.count)", tint: Theme.amber, icon: "list.number")
        }
    }

    private var rankedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SIRALAMA").font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6).foregroundStyle(Theme.textSecondary)
            if rankedRows.isEmpty {
                EmptyChartCard(title: "Henüz teslim yok",
                               message: "Bu testi çözen öğrenci olunca burada görünecek.",
                               icon: "tray")
            } else {
                VStack(spacing: 6) {
                    ForEach(Array(rankedRows.enumerated()), id: \.offset) { (i, row) in
                        NavigationLink {
                            TeacherStudentDetailView(student: row.student)
                        } label: {
                            HStack(spacing: 12) {
                                Text("\(i + 1)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(i < 3 ? Theme.amber : Theme.textTertiary)
                                    .frame(width: 24)
                                AvatarView(name: row.student.name, size: 32)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(row.student.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Theme.textPrimary)
                                        .lineLimit(1)
                                    Text("⏱ \(formatDuration(row.score.time))")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                Spacer()
                                Text("%\(row.score.pct)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(row.score.pct >= 70 ? Theme.green : row.score.pct >= 40 ? Theme.amber : Theme.rose)
                            }
                            .padding(10)
                            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
            }
        }
    }

    private var perQuestionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SORU SORU ANALİZ")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6).foregroundStyle(Theme.textSecondary)
            VStack(spacing: 8) {
                ForEach(Array(test.questions.enumerated()), id: \.offset) { (i, q) in
                    questionAnalysisRow(index: i+1, q: q)
                }
            }
        }
    }

    private func questionAnalysisRow(index: Int, q: Question) -> some View {
        let allAns = subs.flatMap { $0.answers.filter { $0.questionId == q.id } }
        let correct = allAns.filter { $0.choiceIndex == q.correctIndex }.count
        let total = allAns.count
        let pct = total > 0 ? Int(round(Double(correct) / Double(total) * 100)) : 0
        let avgTime = total > 0 ? allAns.map { $0.timeMs }.reduce(0, +) / total : 0
        let sureCount = allAns.filter { $0.confidence == .sure }.count
        let unsureCount = allAns.filter { $0.confidence == .unsure }.count
        let guessCount = allAns.filter { $0.confidence == .guess }.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text("\(index)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.brand)
                    .frame(width: 28, height: 28)
                    .background(Theme.brand.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                VStack(alignment: .leading, spacing: 6) {
                    Text(q.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    HStack(spacing: 6) {
                        BadgePill(text: "%\(pct) doğru",
                                  tint: pct >= 70 ? Theme.green : pct >= 40 ? Theme.amber : Theme.rose)
                        BadgePill(text: formatDuration(avgTime), icon: "clock", tint: Theme.textSecondary)
                        BadgePill(text: q.difficulty.label, tint: q.difficulty.tint)
                    }
                }
            }

            if total > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("GÜVEN DAĞILIMI").font(.system(size: 9, weight: .heavy, design: .rounded))
                        .tracking(0.5).foregroundStyle(Theme.textTertiary)
                    HStack(spacing: 2) {
                        Capsule().fill(Theme.green)
                            .frame(width: barWidth(sureCount, total: total), height: 6)
                        Capsule().fill(Theme.amber)
                            .frame(width: barWidth(unsureCount, total: total), height: 6)
                        Capsule().fill(Theme.rose)
                            .frame(width: barWidth(guessCount, total: total), height: 6)
                    }
                    HStack(spacing: 10) {
                        confLegend(color: Theme.green, label: "Emin", count: sureCount)
                        confLegend(color: Theme.amber, label: "Kararsız", count: unsureCount)
                        confLegend(color: Theme.rose, label: "Tahmin", count: guessCount)
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func barWidth(_ count: Int, total: Int) -> CGFloat {
        let containerWidth: CGFloat = UIScreen.main.bounds.width - 64
        return total > 0 ? containerWidth * CGFloat(count) / CGFloat(total) : 0
    }

    private func confLegend(color: Color, label: String, count: Int) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text("\(label) (\(count))")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
