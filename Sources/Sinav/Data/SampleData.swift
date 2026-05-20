import Foundation

enum SampleData {
    static func defaultAppData() -> AppData {
        let now = Date()
        let day: TimeInterval = 86400
        let cal = Calendar.current

        let students: [Student] = [
            .init(id: "s1", name: "Ayşe Yılmaz",   classroom: "12-A", joinedAt: now.addingTimeInterval(-60*day)),
            .init(id: "s2", name: "Mehmet Kaya",   classroom: "12-A", joinedAt: now.addingTimeInterval(-58*day)),
            .init(id: "s3", name: "Zeynep Demir",  classroom: "12-A", joinedAt: now.addingTimeInterval(-55*day)),
            .init(id: "s4", name: "Burak Şahin",   classroom: "12-A", joinedAt: now.addingTimeInterval(-50*day)),
            .init(id: "s5", name: "Ela Aydın",     classroom: "12-A", joinedAt: now.addingTimeInterval(-48*day)),
            .init(id: "s6", name: "Can Öztürk",    classroom: "12-B", joinedAt: now.addingTimeInterval(-45*day)),
            .init(id: "s7", name: "Defne Arslan",  classroom: "12-B", joinedAt: now.addingTimeInterval(-42*day)),
            .init(id: "s8", name: "Emir Doğan",    classroom: "12-B", joinedAt: now.addingTimeInterval(-40*day)),
            .init(id: "s9", name: "Selin Polat",   classroom: "12-B", joinedAt: now.addingTimeInterval(-38*day)),
            .init(id: "s10", name: "Kerem Çelik",  classroom: "12-B", joinedAt: now.addingTimeInterval(-35*day))
        ]

        // Build a richer test bank — 6 tests spanning topics + difficulty
        let tests = buildTests(now: now)

        // Generate 30 days of synthetic, realistic submissions
        let submissions = buildSubmissions(now: now, students: students, tests: tests, cal: cal)

        let program: [String: ProgramDay] = [
            "1": .init(topic: .turev, note: "Türev kuralları ve uygulamaları"),
            "2": .init(topic: .integral, note: "Belirsiz & belirli integral"),
            "3": .init(topic: .limit, note: "Standart limitler, L'Hôpital"),
            "4": .init(topic: .trigonometri, note: "Toplam-fark ve iki kat açı"),
            "5": .init(topic: .logaritma, note: "Logaritma ve üs özellikleri"),
            "6": .init(topic: .polinomlar, note: "Çarpanlara ayırma + test"),
            "0": .init(topic: .geometri, note: "Hafta tekrarı")
        ]

        return AppData(
            students: students,
            tests: tests,
            submissions: submissions,
            program: program,
            teacherPin: "1234",
            schemaVersion: 1
        )
    }

    // MARK: - Tests

    private static func buildTests(now: Date) -> [MathTest] {
        let day: TimeInterval = 86400
        return [
            MathTest(id: "t1", title: "Türev — Tarama Sınavı", topic: .turev,
                createdAt: now.addingTimeInterval(-28*day), dueAt: now.addingTimeInterval(-21*day),
                questions: [
                    .init(id: "q1", text: "f(x) = x³ − 3x ise f′(x) = ?",
                          options: ["3x² − 3", "x² − 3", "3x − 3", "3x²", "x³ − 3"], correctIndex: 0,
                          difficulty: .easy, subtopic: "Kuvvet kuralı"),
                    .init(id: "q2", text: "f(x) = sin(x) ise f′(π) = ?",
                          options: ["1", "0", "−1", "π", "−π"], correctIndex: 2,
                          difficulty: .medium, subtopic: "Trigonometrik türev"),
                    .init(id: "q3", text: "f(x) = eˣ · x ise f′(x) = ?",
                          options: ["eˣ", "eˣ(x+1)", "x·eˣ", "eˣ·x²", "eˣ − x"], correctIndex: 1,
                          difficulty: .hard, subtopic: "Çarpım kuralı"),
                    .init(id: "q4", text: "f(x) = ln(x²) ise f′(x) = ?",
                          options: ["1/x²", "2/x", "x", "2x", "ln x"], correctIndex: 1,
                          difficulty: .medium, subtopic: "Logaritma türevi"),
                    .init(id: "q5", text: "f(x) = (2x+1)⁵ ise f′(x) = ?",
                          options: ["5(2x+1)⁴", "10(2x+1)⁴", "(2x+1)⁴", "2(2x+1)⁵", "10x⁴"], correctIndex: 1,
                          difficulty: .hard, subtopic: "Zincir kuralı")
                ]),
            MathTest(id: "t2", title: "İntegral — Temel Kurallar", topic: .integral,
                createdAt: now.addingTimeInterval(-21*day), dueAt: now.addingTimeInterval(-14*day),
                questions: [
                    .init(id: "q1", text: "∫ 2x dx = ?",
                          options: ["x² + C", "2x² + C", "x²/2 + C", "2 + C", "x + C"], correctIndex: 0,
                          difficulty: .veryEasy, subtopic: "Kuvvet integrali"),
                    .init(id: "q2", text: "∫ (1/x) dx = ?",
                          options: ["x²/2 + C", "ln x²", "ln|x| + C", "−1/x² + C", "1 + C"], correctIndex: 2,
                          difficulty: .easy, subtopic: "1/x integrali"),
                    .init(id: "q3", text: "∫₀¹ x² dx = ?",
                          options: ["0", "1/3", "1/2", "1", "2/3"], correctIndex: 1,
                          difficulty: .easy, subtopic: "Belirli integral"),
                    .init(id: "q4", text: "∫ cos(2x) dx = ?",
                          options: ["sin(2x) + C", "−sin(2x)/2 + C", "sin(2x)/2 + C", "2·sin(2x) + C", "cos(2x)/2 + C"], correctIndex: 2,
                          difficulty: .medium, subtopic: "Trigonometrik integral"),
                    .init(id: "q5", text: "∫ eˣ·x dx = ?",
                          options: ["eˣ + C", "x·eˣ + C", "eˣ(x−1) + C", "eˣ·x² + C", "eˣ/x + C"], correctIndex: 2,
                          difficulty: .hard, subtopic: "Kısmi integral"),
                    .init(id: "q6", text: "y = x ve y = x² eğrileri arasındaki alan?",
                          options: ["1/2", "1/3", "1/6", "1", "2/3"], correctIndex: 2,
                          difficulty: .hard, subtopic: "Alan hesabı")
                ]),
            MathTest(id: "t3", title: "Limit & Süreklilik", topic: .limit,
                createdAt: now.addingTimeInterval(-14*day), dueAt: now.addingTimeInterval(-7*day),
                questions: [
                    .init(id: "q1", text: "lim_(x→2) (x²−4)/(x−2) = ?",
                          options: ["0", "2", "4", "Tanımsız", "−2"], correctIndex: 2,
                          difficulty: .easy, subtopic: "Belirsizlik 0/0"),
                    .init(id: "q2", text: "lim_(x→0) sin(x)/x = ?",
                          options: ["0", "1", "∞", "−1", "Tanımsız"], correctIndex: 1,
                          difficulty: .veryEasy, subtopic: "Standart limit"),
                    .init(id: "q3", text: "lim_(x→∞) (3x²+1)/(x²−x) = ?",
                          options: ["0", "1", "3", "∞", "−1"], correctIndex: 2,
                          difficulty: .medium, subtopic: "Sonsuzda"),
                    .init(id: "q4", text: "f(x) = |x−1| fonksiyonu x = 1'de?",
                          options: ["Sürekli ve türevlenebilir", "Sürekli ama türevsiz", "Süreksiz", "Tanımsız", "Hepsi"], correctIndex: 1,
                          difficulty: .hard, subtopic: "Süreklilik")
                ]),
            MathTest(id: "t4", title: "Trigonometri — Özdeşlikler", topic: .trigonometri,
                createdAt: now.addingTimeInterval(-10*day), dueAt: now.addingTimeInterval(-3*day),
                questions: [
                    .init(id: "q1", text: "sin²x + cos²x = ?",
                          options: ["0", "1", "−1", "2", "sinx·cosx"], correctIndex: 1,
                          difficulty: .veryEasy, subtopic: "Temel özdeşlik"),
                    .init(id: "q2", text: "sin(2x) = ?",
                          options: ["2sinx", "sin²x", "2sinx·cosx", "cos2x", "1 − cos2x"], correctIndex: 2,
                          difficulty: .easy, subtopic: "İki kat açı"),
                    .init(id: "q3", text: "cos(2x) = ?",
                          options: ["1 − 2cos²x", "2cos²x − 1", "1 − sin²x", "0", "1"], correctIndex: 1,
                          difficulty: .medium, subtopic: "İki kat açı"),
                    .init(id: "q4", text: "1 + tan²x = ?",
                          options: ["sec²x", "cot²x", "sin²x", "0", "csc²x"], correctIndex: 0,
                          difficulty: .medium, subtopic: "Tanjant özdeşliği"),
                    .init(id: "q5", text: "sin(75°) = ?",
                          options: ["(√6−√2)/4", "(√6+√2)/4", "1/2", "√3/2", "(√3−1)/2"], correctIndex: 1,
                          difficulty: .hard, subtopic: "Toplam formülü")
                ]),
            MathTest(id: "t5", title: "Logaritma & Üslü Sayılar", topic: .logaritma,
                createdAt: now.addingTimeInterval(-6*day), dueAt: now.addingTimeInterval(day),
                questions: [
                    .init(id: "q1", text: "log(ab) = ?",
                          options: ["log a · log b", "log a + log b", "log a − log b", "log(a+b)", "a·log b"], correctIndex: 1,
                          difficulty: .easy, subtopic: "Çarpım"),
                    .init(id: "q2", text: "log₂(8) = ?",
                          options: ["2", "3", "4", "1", "8"], correctIndex: 1,
                          difficulty: .veryEasy, subtopic: "Logaritma hesabı"),
                    .init(id: "q3", text: "2³·2² = ?",
                          options: ["2⁵", "2⁶", "4⁵", "4⁶", "16"], correctIndex: 0,
                          difficulty: .veryEasy, subtopic: "Üs çarpımı"),
                    .init(id: "q4", text: "log(a/b) − log a = ?",
                          options: ["log b", "−log b", "0", "log a", "log(1/b)"], correctIndex: 1,
                          difficulty: .medium, subtopic: "Bölüm"),
                    .init(id: "q5", text: "log_a(b) · log_b(c) = ?",
                          options: ["log_a(c)", "log_c(a)", "1", "log(a+c)", "0"], correctIndex: 0,
                          difficulty: .hard, subtopic: "Taban değiştirme")
                ]),
            MathTest(id: "t6", title: "Karma Final Provası", topic: .polinomlar,
                createdAt: now.addingTimeInterval(-2*day), dueAt: now.addingTimeInterval(5*day),
                questions: [
                    .init(id: "q1", text: "(a+b)² − (a−b)² = ?",
                          options: ["2ab", "4ab", "0", "a² − b²", "2a²"], correctIndex: 1,
                          difficulty: .medium, subtopic: "Açılım"),
                    .init(id: "q2", text: "x² − 5x + 6 = 0 denkleminin kökleri?",
                          options: ["1, 6", "2, 3", "−2, −3", "−1, −6", "Yok"], correctIndex: 1,
                          difficulty: .medium, subtopic: "İkinci derece"),
                    .init(id: "q3", text: "f(x) = 2x + 1 ise f(f(x)) = ?",
                          options: ["4x + 3", "4x + 1", "2x + 3", "4x + 2", "2x² + 1"], correctIndex: 0,
                          difficulty: .medium, subtopic: "Birleşik fonksiyon"),
                    .init(id: "q4", text: "Bir zarda 5'ten büyük gelme olasılığı?",
                          options: ["1/6", "1/3", "1/2", "2/3", "5/6"], correctIndex: 0,
                          difficulty: .easy, subtopic: "Olasılık"),
                    .init(id: "q5", text: "C(5,2) = ?",
                          options: ["5", "10", "20", "25", "120"], correctIndex: 1,
                          difficulty: .medium, subtopic: "Kombinasyon"),
                    .init(id: "q6", text: "3 kişi 5 koltuğa kaç farklı şekilde oturur?",
                          options: ["15", "60", "120", "243", "125"], correctIndex: 1,
                          difficulty: .hard, subtopic: "Permütasyon")
                ])
        ]
    }

    // MARK: - Realistic submissions

    /// Generates submissions over the last 30 days with per-student "ability" + per-topic strength,
    /// improving trend, and confidence calibration noise.
    private static func buildSubmissions(now: Date, students: [Student], tests: [MathTest], cal: Calendar) -> [Submission] {
        var subs: [Submission] = []
        let day: TimeInterval = 86400

        // Per-student ability + trend + topic affinity
        struct Profile {
            var baseAbility: Double      // 0...1, probability of correct on medium difficulty
            var growthPerDay: Double     // additive per day
            var weakTopics: Set<TopicID>
            var strongTopics: Set<TopicID>
            var calibrationBias: Double  // positive = overconfident
        }
        let profiles: [String: Profile] = [
            "s1":  .init(baseAbility: 0.85, growthPerDay: 0.001, weakTopics: [.olasilik], strongTopics: [.turev, .limit], calibrationBias: -0.1),
            "s2":  .init(baseAbility: 0.55, growthPerDay: 0.006, weakTopics: [.integral, .trigonometri], strongTopics: [.polinomlar], calibrationBias: 0.15),
            "s3":  .init(baseAbility: 0.78, growthPerDay: 0.002, weakTopics: [.logaritma], strongTopics: [.integral, .limit], calibrationBias: 0.0),
            "s4":  .init(baseAbility: 0.45, growthPerDay: 0.008, weakTopics: [.turev, .integral, .trigonometri], strongTopics: [], calibrationBias: 0.25),
            "s5":  .init(baseAbility: 0.90, growthPerDay: 0.0,   weakTopics: [], strongTopics: [.turev, .integral, .trigonometri], calibrationBias: -0.05),
            "s6":  .init(baseAbility: 0.62, growthPerDay: 0.003, weakTopics: [.polinomlar], strongTopics: [.trigonometri], calibrationBias: 0.05),
            "s7":  .init(baseAbility: 0.72, growthPerDay: 0.001, weakTopics: [.olasilik], strongTopics: [.logaritma], calibrationBias: -0.08),
            "s8":  .init(baseAbility: 0.38, growthPerDay: 0.004, weakTopics: [.turev, .integral, .limit], strongTopics: [.geometri], calibrationBias: 0.30),
            "s9":  .init(baseAbility: 0.66, growthPerDay: 0.005, weakTopics: [.polinomlar], strongTopics: [.integral], calibrationBias: 0.10),
            "s10": .init(baseAbility: 0.50, growthPerDay: 0.007, weakTopics: [.trigonometri, .logaritma], strongTopics: [.polinomlar], calibrationBias: 0.20)
        ]

        // Seeded RNG so it's reproducible
        var rng = SeededGenerator(seed: 42)

        for test in tests {
            // Define a submission window: 0..7 days after createdAt, before dueAt+2d
            let createdAt = test.createdAt
            for student in students {
                guard let p = profiles[student.id] else { continue }

                // 80% chance student submits (some skip)
                if Double.random(in: 0...1, using: &rng) > 0.82 { continue }

                // Random offset within submission window
                let maxWindow = min(10*day, Date().timeIntervalSince(createdAt))
                if maxWindow <= 0 { continue }
                let offset = Double.random(in: 1*3600...maxWindow, using: &rng)
                let submittedAt = createdAt.addingTimeInterval(offset)
                if submittedAt > now { continue }

                let daysSinceJoin = max(0, submittedAt.timeIntervalSince(student.joinedAt) / day)
                let abilityToday = min(1.0, max(0.0, p.baseAbility + p.growthPerDay * daysSinceJoin))

                var answers: [Answer] = []
                for q in test.questions {
                    // Topic-adjusted ability
                    var prob = abilityToday
                    if p.weakTopics.contains(test.topic) { prob -= 0.20 }
                    if p.strongTopics.contains(test.topic) { prob += 0.15 }

                    // Difficulty adjustment
                    let diffPenalty: Double = [0, 0.10, 0.05, 0, -0.10, -0.20][q.difficulty.rawValue]
                    prob += diffPenalty
                    prob = min(0.98, max(0.05, prob))

                    let rand = Double.random(in: 0...1, using: &rng)
                    let isCorrect = rand < prob
                    let choice: Int
                    if isCorrect {
                        choice = q.correctIndex
                    } else {
                        let options = (0..<q.options.count).filter { $0 != q.correctIndex }
                        choice = options.randomElement(using: &rng) ?? 0
                    }

                    // Confidence reflects ability + bias + noise
                    let perceivedProb = min(1.0, max(0.0, prob + p.calibrationBias + Double.random(in: -0.15...0.15, using: &rng)))
                    let confidence: Confidence
                    if perceivedProb >= 0.70 { confidence = .sure }
                    else if perceivedProb >= 0.40 { confidence = .unsure }
                    else { confidence = .guess }

                    // Time spent: harder + less sure = longer (10-120s)
                    let baseTime = 15.0 + Double(q.difficulty.rawValue) * 8.0
                    let confMul = confidence == .sure ? 0.7 : confidence == .unsure ? 1.3 : 1.7
                    let noise = Double.random(in: 0.7...1.4, using: &rng)
                    let secs = baseTime * confMul * noise
                    let timeMs = Int(secs * 1000)

                    answers.append(Answer(questionId: q.id, choiceIndex: choice, timeMs: timeMs, confidence: confidence))
                }

                let sub = Submission(
                    id: "syn-\(test.id)-\(student.id)",
                    testId: test.id,
                    studentId: student.id,
                    submittedAt: submittedAt,
                    answers: answers
                )
                subs.append(sub)
            }
        }

        return subs.sorted { $0.submittedAt < $1.submittedAt }
    }
}

// MARK: - Seeded RNG

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
