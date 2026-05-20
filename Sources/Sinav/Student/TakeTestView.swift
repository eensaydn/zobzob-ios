import SwiftUI

struct TakeTestView: View {
    let testId: String
    let studentId: String
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var index = 0
    @State private var choices: [String: Int] = [:]            // questionId -> choice
    @State private var confidences: [String: Confidence] = [:]
    @State private var timings: [String: Int] = [:]
    @State private var qStart: Date = Date()
    @State private var showCancelAlert = false
    @State private var submitted = false
    @State private var lastSubmissionId: String? = nil
    @State private var tapTrigger = 0
    @State private var submitTrigger = false

    private var test: MathTest? { store.test(byId: testId) }
    private var question: Question? {
        guard let t = test, t.questions.indices.contains(index) else { return nil }
        return t.questions[index]
    }
    private var isLast: Bool {
        guard let t = test else { return true }
        return index >= t.questions.count - 1
    }
    private var canAdvance: Bool {
        guard let q = question else { return false }
        return choices[q.id] != nil && confidences[q.id] != nil
    }
    private var allAnswered: Bool {
        guard let t = test else { return false }
        return t.questions.allSatisfy { q in choices[q.id] != nil && confidences[q.id] != nil }
    }
    private var progress: Double {
        guard let t = test, !t.questions.isEmpty else { return 0 }
        return Double(index) / Double(t.questions.count)
    }

    var body: some View {
        if submitted, let subId = lastSubmissionId {
            TestResultView(testId: testId, studentId: studentId, submissionId: subId)
        } else if let t = test, let q = question {
            content(t: t, q: q)
        } else {
            EmptyState(icon: "questionmark.circle", title: "Test yok", message: "Test bulunamadı.")
        }
    }

    // MARK: Content

    private func content(t: MathTest, q: Question) -> some View {
        VStack(spacing: 0) {
            header(t: t)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    questionCard(t: t, q: q)
                    optionsList(q: q)
                    confidencePicker(q: q)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 130)
                .id(q.id)
            }
            .background(Theme.canvas)
            .toolbar(.hidden, for: .tabBar)
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                navBar(t: t, q: q)
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .alert("Testten çıkmak istiyor musun?", isPresented: $showCancelAlert) {
            Button("Devam et", role: .cancel) { }
            Button("Çık", role: .destructive) { dismiss() }
        } message: {
            Text("İlerlemen kaybolur.")
        }
        .sensoryFeedback(.selection, trigger: tapTrigger)
        .sensoryFeedback(.success, trigger: submitTrigger)
        .onAppear { qStart = Date() }
    }

    private func header(t: MathTest) -> some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    Haptics.tap()
                    showCancelAlert = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Theme.surface, in: Circle())
                }
                Spacer()
                VStack(spacing: 0) {
                    Text(t.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text("Soru \(index + 1) / \(t.questions.count)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Progress bar
            GeometryReader { p in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(uiColor: .tertiarySystemFill))
                    Capsule().fill(Theme.brand)
                        .frame(width: max(6, p.size.width * progress))
                        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 6)
        .background(Theme.canvas)
    }

    private func questionCard(t: MathTest, q: Question) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                TopicChip(topic: t.topic)
                BadgePill(text: q.difficulty.label,
                          icon: q.difficulty == .veryHard ? "flame.fill" : "scope",
                          tint: q.difficulty.tint)
                if !q.subtopic.isEmpty {
                    BadgePill(text: q.subtopic, tint: Theme.textSecondary)
                }
            }
            Text(q.text)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private func optionsList(q: Question) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(q.options.enumerated()), id: \.offset) { (i, opt) in
                ChoiceButton(
                    label: letter(for: i),
                    text: opt,
                    isSelected: choices[q.id] == i,
                    isCorrect: nil,
                    isLocked: false
                ) {
                    tapTrigger &+= 1
                    choices[q.id] = i
                }
            }
        }
    }

    private func confidencePicker(q: Question) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CEVABINDAN NE KADAR EMİNSİN?")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 8) {
                ForEach(Confidence.allCases) { c in
                    Button {
                        Haptics.tap()
                        confidences[q.id] = c
                    } label: {
                        Text(c.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(confidences[q.id] == c ? .white : c.tint)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(confidences[q.id] == c ? c.tint : c.tint.opacity(0.12))
                            )
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    // MARK: Bottom nav bar

    private func navBar(t: MathTest, q: Question) -> some View {
        HStack(spacing: 10) {
            Button {
                Haptics.tap()
                commitTime(q: q)
                if index > 0 { index -= 1; qStart = Date() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(index == 0 ? Theme.textTertiary : Theme.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
            }
            .disabled(index == 0)

            if !isLast {
                Button {
                    Haptics.tap()
                    commitTime(q: q)
                    index += 1
                    qStart = Date()
                } label: {
                    HStack(spacing: 6) {
                        Text("Sonraki")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(canAdvance ? Theme.brand : Color(uiColor: .tertiarySystemFill),
                                in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canAdvance)
            } else {
                Button {
                    submit()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane.fill").font(.system(size: 13, weight: .bold))
                        Text("Bitir ve Gönder").font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(allAnswered ? Theme.green : Color(uiColor: .tertiarySystemFill),
                                in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!allAnswered)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: Helpers

    private func letter(for i: Int) -> String {
        ["A", "B", "C", "D", "E"][safe: i] ?? String(UnicodeScalar(65 + i)!)
    }

    private func commitTime(q: Question) {
        let elapsed = Int(Date().timeIntervalSince(qStart) * 1000)
        timings[q.id, default: 0] += elapsed
    }

    private func submit() {
        guard let t = test, let q = question else { return }
        commitTime(q: q)
        let answers: [Answer] = t.questions.map { qq in
            Answer(questionId: qq.id,
                   choiceIndex: choices[qq.id],
                   timeMs: timings[qq.id] ?? 0,
                   confidence: confidences[qq.id] ?? .unsure)
        }
        let newSub = Submission(id: UUID().uuidString,
                                testId: t.id, studentId: studentId,
                                submittedAt: Date(), answers: answers)
        store.data.submissions.append(newSub)
        store.persist()
        submitTrigger.toggle()
        lastSubmissionId = newSub.id
        submitted = true
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript(safe i: Index) -> Iterator.Element? {
        indices.contains(i) ? self[i] : nil
    }
}
