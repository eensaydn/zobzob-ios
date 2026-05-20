import SwiftUI

struct StudentTestsView: View {
    let studentId: String
    @Environment(AppStore.self) private var store

    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable, Identifiable {
        case all, todo, done
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "Tümü"
            case .todo: return "Yapılacak"
            case .done: return "Tamamlanan"
            }
        }
    }

    private var allTests: [(MathTest, Submission?)] {
        store.data.tests
            .sorted { (a, b) in
                let ad = a.dueAt ?? .distantFuture
                let bd = b.dueAt ?? .distantFuture
                return ad < bd
            }
            .map { t in (t, store.latestSubmission(student: studentId, test: t.id)) }
    }

    private var filtered: [(MathTest, Submission?)] {
        switch filter {
        case .all: return allTests
        case .todo: return allTests.filter { $0.1 == nil }
        case .done: return allTests.filter { $0.1 != nil }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Filtre", selection: $filter) {
                ForEach(Filter.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            if filtered.isEmpty {
                EmptyState(icon: "doc.text.magnifyingglass",
                           title: "Henüz test yok",
                           message: "Bu kategoride sana atanmış test bulunmuyor.")
                .padding(.top, 40)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filtered, id: \.0.id) { (test, sub) in
                            row(test: test, sub: sub)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Theme.canvas)
        .navigationTitle("Ödevler")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func row(test: MathTest, sub: Submission?) -> some View {
        if let sub {
            NavigationLink {
                TestResultView(testId: test.id, studentId: studentId, submissionId: sub.id)
            } label: {
                doneRow(test: test, sub: sub)
            }
            .buttonStyle(PressableStyle())
        } else {
            NavigationLink {
                TakeTestView(testId: test.id, studentId: studentId)
                    .navigationBarBackButtonHidden()
            } label: {
                todoRow(test: test)
            }
            .buttonStyle(PressableStyle())
        }
    }

    private func doneRow(test: MathTest, sub: Submission) -> some View {
        let score = store.score(test: test, submission: sub)
        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.green.opacity(0.13))
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.green)
            }
            .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(test.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    TopicChip(topic: test.topic)
                    Text("\(score.correct)/\(score.total) doğru • \(sub.submittedAt.formattedShort())")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text("%\(score.pct)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(scoreColor(score.pct))
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func todoRow(test: MathTest) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(test.topic.accent.opacity(0.13))
                Image(systemName: test.topic.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(test.topic.accent)
            }
            .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(test.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    TopicChip(topic: test.topic)
                    BadgePill(text: "\(test.questions.count) soru", tint: Theme.textSecondary)
                    if let due = test.dueAt {
                        let overdue = due < Date()
                        BadgePill(text: overdue ? "Geçti" : "Son: \(due.formattedShort())",
                                  icon: "clock.fill", tint: overdue ? Theme.rose : Theme.amber)
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func scoreColor(_ pct: Int) -> Color {
        pct >= 70 ? Theme.green : pct >= 40 ? Theme.amber : Theme.rose
    }
}
