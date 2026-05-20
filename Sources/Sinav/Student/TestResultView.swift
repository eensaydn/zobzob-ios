import SwiftUI

struct TestResultView: View {
    let testId: String
    let studentId: String
    let submissionId: String

    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var confettiTrigger = 0
    private var test: MathTest? { store.test(byId: testId) }
    private var submission: Submission? { store.data.submissions.first { $0.id == submissionId } }

    var body: some View {
        ZStack {
            Group {
                if let t = test, let s = submission {
                    content(t: t, s: s)
                } else {
                    EmptyState(icon: "questionmark.folder", title: "Sonuç bulunamadı", message: "Bu görev için cevap görünmüyor 🤔")
                }
            }
            // Confetti overlay on celebration
            Confetti(trigger: confettiTrigger)
                .allowsHitTesting(false)
        }
        .background(Theme.canvas)
        .navigationTitle("Sonuç")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let t = test, let s = submission {
                let sc = store.score(test: t, submission: s)
                if sc.pct >= 70 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        confettiTrigger &+= 1
                    }
                }
            }
        }
    }

    private func content(t: MathTest, s: Submission) -> some View {
        let sc = store.score(test: t, submission: s)
        let xp = store.xp(for: s, in: t)
        let avgTime = s.answers.isEmpty ? 0 : sc.time / s.answers.count
        let details = t.questions.map { q -> (Question, Answer?, Bool) in
            let a = s.answers.first(where: { $0.questionId == q.id })
            let correct = (a?.choiceIndex == q.correctIndex)
            return (q, a, correct)
        }
        let overConfWrong = details.filter { !$0.2 && $0.1?.confidence == .sure }.count
        let stuckCorrect = details.filter { $0.2 && ($0.1?.timeMs ?? 0) > 60_000 }.count

        return ScrollView {
            VStack(spacing: 18) {
                summaryCard(test: t, sc: sc, xp: xp, avgTime: avgTime)
                insightsCard(overConfWrong: overConfWrong, stuckCorrect: stuckCorrect, pct: sc.pct)
                detailsSection(details: details)
            }
            .padding(16)
        }
    }

    private func summaryCard(test: MathTest, sc: (correct: Int, total: Int, pct: Int, time: Int), xp: Int, avgTime: Int) -> some View {
        VStack(spacing: 14) {
            Text(test.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
            Text("%\(sc.pct)")
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .foregroundStyle(scoreColor(sc.pct))
                .contentTransition(.numericText())
            Text("\(sc.correct)/\(sc.total) doğru")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            HStack(spacing: 8) {
                BadgePill(text: "+\(xp) puan", icon: "sparkles", tint: Theme.brand, prominent: true)
                BadgePill(text: "Ort. \(formatDuration(avgTime))", icon: "clock.fill", tint: Theme.textSecondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22))
    }

    private func insightsCard(overConfWrong: Int, stuckCorrect: Int, pct: Int) -> some View {
        var insights: [(String, String, Color)] = []
        if pct == 100 { insights.append(("checkmark.seal.fill", "Kusursuz! Tüm soruları doğru bildin.", Theme.green)) }
        if overConfWrong > 0 { insights.append(("exclamationmark.triangle.fill", "\(overConfWrong) soruda emindin ama yanıldın. Bu konuyu tekrar et.", Theme.rose)) }
        if stuckCorrect > 0 { insights.append(("clock.fill", "\(stuckCorrect) soruda 1 dakikadan uzun harcadın — pratikle hızlanırsın.", Theme.amber)) }
        if insights.isEmpty { insights.append(("hand.thumbsup.fill", "Tutarlı bir performans. Devam et.", Theme.brand)) }
        return VStack(alignment: .leading, spacing: 8) {
            Text("İÇGÖRÜLER")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.textSecondary)
            VStack(spacing: 8) {
                ForEach(insights.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: insights[i].0)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(insights[i].2)
                            .frame(width: 32, height: 32)
                            .background(insights[i].2.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        Text(insights[i].1)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(10)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private func detailsSection(details: [(Question, Answer?, Bool)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SORU SORU")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.textSecondary)
            VStack(spacing: 8) {
                ForEach(Array(details.enumerated()), id: \.offset) { (i, item) in
                    detailRow(index: i+1, q: item.0, answer: item.1, correct: item.2)
                }
            }
        }
    }

    private func detailRow(index: Int, q: Question, answer: Answer?, correct: Bool) -> some View {
        let tint = correct ? Theme.green : Theme.rose
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 32, height: 32)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(index). \(q.text)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    HStack(spacing: 6) {
                        BadgePill(text: q.difficulty.label, tint: q.difficulty.tint)
                        if let a = answer {
                            BadgePill(text: a.confidence.label, tint: a.confidence.tint)
                            BadgePill(text: formatDuration(a.timeMs), icon: "clock", tint: Theme.textSecondary)
                        }
                    }
                    if !correct {
                        VStack(alignment: .leading, spacing: 4) {
                            if let a = answer, let c = a.choiceIndex {
                                Text("Senin cevabın: \(letter(c)). \(q.options[c])")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Theme.rose)
                            }
                            Text("Doğru cevap: \(letter(q.correctIndex)). \(q.options[q.correctIndex])")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.green)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func letter(_ i: Int) -> String { ["A","B","C","D","E"][safe: i] ?? "?" }
    private func scoreColor(_ pct: Int) -> Color {
        pct >= 70 ? Theme.green : pct >= 40 ? Theme.amber : Theme.rose
    }
}
