import Foundation

// MARK: - Date range

enum DateRange: String, CaseIterable, Identifiable {
    case last7, last30, allTime
    var id: String { rawValue }
    var label: String {
        switch self {
        case .last7: return "7 gün"
        case .last30: return "30 gün"
        case .allTime: return "Tümü"
        }
    }
    var days: Int? {
        switch self {
        case .last7: return 7
        case .last30: return 30
        case .allTime: return nil
        }
    }
    func contains(_ date: Date, now: Date = Date()) -> Bool {
        guard let d = days else { return true }
        return now.timeIntervalSince(date) <= TimeInterval(d) * 86400
    }
}

// MARK: - Series points

struct DailyPoint: Identifiable, Hashable {
    let id = UUID()
    let day: Date
    let avg: Int       // class avg %, 0...100
    let count: Int     // submissions
}

struct TopicAccuracy: Identifiable, Hashable {
    var id: TopicID { topic }
    let topic: TopicID
    let pct: Int
    let attempts: Int
    let correct: Int
}

struct QuestionStat: Identifiable, Hashable {
    let id: String         // testId+qId
    let testId: String
    let testTitle: String
    let topic: TopicID
    let questionText: String
    let difficultyRated: Int   // 1..5
    let attempts: Int
    let correct: Int
    let avgTimeMs: Int
    let confidence: ConfidenceDist
    var accuracy: Double { attempts > 0 ? Double(correct) / Double(attempts) : 0 }
    /// Discrimination index: correlation of question correctness with overall submission score.
    /// Range: -1 ... +1. Higher = question separates good from weak students.
    let discrimination: Double
}

struct ConfidenceDist: Hashable {
    var sure: Int = 0
    var unsure: Int = 0
    var guess: Int = 0
    var sureCorrect: Int = 0
    var unsureCorrect: Int = 0
    var guessCorrect: Int = 0
    var total: Int { sure + unsure + guess }
}

struct OutlierStudent: Identifiable, Hashable {
    let id: String         // studentId
    let student: Student
    let recentAvg: Int
    let prevAvg: Int
    let delta: Int         // recent - prev
    let attempts: Int
}

struct CalibrationPoint: Identifiable, Hashable {
    let id = UUID()
    let label: String       // "Eminim", "Kararsız", "Tahmin"
    let bucket: Confidence
    let stated: Int         // declared probability midpoint (e.g., 0.85, 0.5, 0.25)
    let actual: Int         // actual correctness %
    let count: Int
}

struct HeatCell: Identifiable, Hashable {
    var id: String { "\(studentId)-\(topic.rawValue)" }
    let studentId: String
    let studentName: String
    let topic: TopicID
    let pct: Int            // -1 means no attempts
    let attempts: Int
}

struct DeltaKPI: Hashable {
    let value: Int
    let prev: Int
    var delta: Int { value - prev }
    var hasPrev: Bool { prev > 0 }
}

// MARK: - Engine

@MainActor
final class Analytics {
    let store: AppStore
    init(_ store: AppStore) { self.store = store }

    // Filtered submissions
    func submissions(in range: DateRange) -> [Submission] {
        store.data.submissions.filter { range.contains($0.submittedAt) }
    }

    // MARK: Class average over time (daily)
    func dailyClassAverage(in range: DateRange) -> [DailyPoint] {
        let cal = Calendar.current
        let subs = submissions(in: range)
        let grouped = Dictionary(grouping: subs) { sub in
            cal.startOfDay(for: sub.submittedAt)
        }
        // Fill missing days for line continuity
        let endDate = cal.startOfDay(for: Date())
        let dayCount = range.days ?? 30
        let startDate: Date = {
            if let days = range.days {
                return cal.date(byAdding: .day, value: -(days - 1), to: endDate) ?? endDate
            } else {
                // Earliest submission
                if let earliest = store.data.submissions.map({ $0.submittedAt }).min() {
                    return cal.startOfDay(for: earliest)
                }
                return cal.date(byAdding: .day, value: -29, to: endDate) ?? endDate
            }
        }()

        var out: [DailyPoint] = []
        var cursor = startDate
        _ = dayCount
        while cursor <= endDate {
            let subsToday = grouped[cursor] ?? []
            if subsToday.isEmpty {
                out.append(DailyPoint(day: cursor, avg: 0, count: 0))
            } else {
                let pcts = subsToday.compactMap { sub -> Int? in
                    guard let t = store.test(byId: sub.testId) else { return nil }
                    return store.score(test: t, submission: sub).pct
                }
                let avg = pcts.isEmpty ? 0 : Int(round(Double(pcts.reduce(0, +)) / Double(pcts.count)))
                out.append(DailyPoint(day: cursor, avg: avg, count: subsToday.count))
            }
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? endDate.addingTimeInterval(86400)
            if out.count > 400 { break }
        }
        return out
    }

    // MARK: Topic accuracy across class
    func topicAccuracy(in range: DateRange) -> [TopicAccuracy] {
        var dict: [TopicID: (correct: Int, total: Int)] = [:]
        for sub in submissions(in: range) {
            guard let t = store.test(byId: sub.testId) else { continue }
            for a in sub.answers {
                guard let q = t.questions.first(where: { $0.id == a.questionId }) else { continue }
                var v = dict[t.topic] ?? (0, 0)
                v.total += 1
                if a.choiceIndex == q.correctIndex { v.correct += 1 }
                dict[t.topic] = v
            }
        }
        return dict.map { (k, v) in
            let pct = v.total > 0 ? Int(round(Double(v.correct) / Double(v.total) * 100)) : 0
            return TopicAccuracy(topic: k, pct: pct, attempts: v.total, correct: v.correct)
        }.sorted { $0.pct < $1.pct }
    }

    // MARK: Per-question stats with discrimination index
    func questionStats(in range: DateRange) -> [QuestionStat] {
        var all: [QuestionStat] = []
        for test in store.data.tests {
            let testSubs = store.submissions(forTest: test.id).filter { range.contains($0.submittedAt) }
            guard !testSubs.isEmpty else { continue }

            // overall score per submission for this test
            let subScores: [(sub: Submission, pct: Double)] = testSubs.map {
                ($0, Double(store.score(test: test, submission: $0).pct))
            }
            let meanOverall = subScores.map { $0.pct }.reduce(0.0, +) / Double(subScores.count)

            for q in test.questions {
                var conf = ConfidenceDist()
                var correctCount = 0
                var totalCount = 0
                var totalTime = 0

                // For discrimination: per-submission this question score (1 / 0)
                var qScores: [(score: Double, overall: Double)] = []

                for (sub, overall) in subScores {
                    guard let a = sub.answers.first(where: { $0.questionId == q.id }) else { continue }
                    totalCount += 1
                    totalTime += a.timeMs
                    let isCorrect = (a.choiceIndex == q.correctIndex)
                    if isCorrect { correctCount += 1 }

                    switch a.confidence {
                    case .sure: conf.sure += 1; if isCorrect { conf.sureCorrect += 1 }
                    case .unsure: conf.unsure += 1; if isCorrect { conf.unsureCorrect += 1 }
                    case .guess: conf.guess += 1; if isCorrect { conf.guessCorrect += 1 }
                    }
                    qScores.append((isCorrect ? 1.0 : 0.0, overall))
                }

                let discrim: Double = {
                    guard qScores.count >= 3 else { return 0 }
                    let meanQ = qScores.map { $0.score }.reduce(0, +) / Double(qScores.count)
                    let meanO = meanOverall
                    var num = 0.0
                    var denQ = 0.0
                    var denO = 0.0
                    for s in qScores {
                        let dq = s.score - meanQ
                        let dod = s.overall - meanO
                        num += dq * dod
                        denQ += dq * dq
                        denO += dod * dod
                    }
                    let den = sqrt(denQ * denO)
                    return den > 0 ? num / den : 0
                }()

                let avgTime = totalCount > 0 ? totalTime / totalCount : 0
                all.append(QuestionStat(
                    id: "\(test.id)-\(q.id)",
                    testId: test.id, testTitle: test.title,
                    topic: test.topic,
                    questionText: q.text,
                    difficultyRated: q.difficulty.rawValue,
                    attempts: totalCount,
                    correct: correctCount,
                    avgTimeMs: avgTime,
                    confidence: conf,
                    discrimination: discrim
                ))
            }
        }
        return all
    }

    // MARK: Confidence calibration curve
    /// Returns three points: stated probability vs actual correctness for each confidence bucket.
    func calibration(in range: DateRange) -> (points: [CalibrationPoint], ece: Double) {
        var buckets: [Confidence: (correct: Int, total: Int)] = [
            .sure: (0, 0), .unsure: (0, 0), .guess: (0, 0)
        ]
        for sub in submissions(in: range) {
            guard let t = store.test(byId: sub.testId) else { continue }
            for a in sub.answers {
                guard let q = t.questions.first(where: { $0.id == a.questionId }) else { continue }
                var v = buckets[a.confidence] ?? (0, 0)
                v.total += 1
                if a.choiceIndex == q.correctIndex { v.correct += 1 }
                buckets[a.confidence] = v
            }
        }

        let stated: [Confidence: Int] = [.sure: 85, .unsure: 55, .guess: 30]
        var totalCount = 0
        var ece = 0.0
        var points: [CalibrationPoint] = []
        for c in [Confidence.sure, .unsure, .guess] {
            let v = buckets[c]!
            let actualPct = v.total > 0 ? Int(round(Double(v.correct) / Double(v.total) * 100)) : 0
            let claimed = stated[c]!
            points.append(CalibrationPoint(label: c.label, bucket: c, stated: claimed, actual: actualPct, count: v.total))
            totalCount += v.total
            ece += Double(v.total) * abs(Double(claimed - actualPct))
        }
        let eceNorm = totalCount > 0 ? ece / Double(totalCount) : 0
        return (points, eceNorm)
    }

    // MARK: Outliers — recent vs prior week
    func outliers(now: Date = Date()) -> (struggling: [OutlierStudent], rising: [OutlierStudent]) {
        let cal = Calendar.current
        let recentStart = cal.date(byAdding: .day, value: -7, to: now) ?? now
        let priorStart = cal.date(byAdding: .day, value: -14, to: now) ?? now

        func avg(_ subs: [Submission]) -> (avg: Int, count: Int) {
            let pcts = subs.compactMap { s -> Int? in
                guard let t = store.test(byId: s.testId) else { return nil }
                return store.score(test: t, submission: s).pct
            }
            return (pcts.isEmpty ? 0 : Int(round(Double(pcts.reduce(0, +)) / Double(pcts.count))), pcts.count)
        }

        var rows: [OutlierStudent] = []
        for st in store.data.students {
            let all = store.submissions(forStudent: st.id)
            let recent = all.filter { $0.submittedAt >= recentStart && $0.submittedAt <= now }
            let prior = all.filter { $0.submittedAt >= priorStart && $0.submittedAt < recentStart }
            let r = avg(recent)
            let p = avg(prior)
            guard r.count > 0 || p.count > 0 else { continue }
            rows.append(OutlierStudent(id: st.id, student: st, recentAvg: r.avg, prevAvg: p.avg, delta: r.avg - p.avg, attempts: r.count + p.count))
        }

        // Struggling: low recent avg or large drop
        let struggling = rows
            .filter { $0.attempts > 0 && ($0.recentAvg < 60 || $0.delta < -10) }
            .sorted { ($0.recentAvg, $0.delta) < ($1.recentAvg, $1.delta) }
            .prefix(5)
            .map { $0 }

        let rising = rows
            .filter { $0.delta > 5 && $0.attempts > 0 }
            .sorted { $0.delta > $1.delta }
            .prefix(5)
            .map { $0 }

        return (Array(struggling), Array(rising))
    }

    // MARK: Heatmap — students × topics
    func heatmap() -> [HeatCell] {
        var cells: [HeatCell] = []
        for st in store.data.students {
            for topic in TopicID.allCases {
                var correct = 0, total = 0
                for sub in store.submissions(forStudent: st.id) {
                    guard let t = store.test(byId: sub.testId), t.topic == topic else { continue }
                    for a in sub.answers {
                        guard let q = t.questions.first(where: { $0.id == a.questionId }) else { continue }
                        total += 1
                        if a.choiceIndex == q.correctIndex { correct += 1 }
                    }
                }
                let pct = total > 0 ? Int(round(Double(correct) / Double(total) * 100)) : -1
                cells.append(HeatCell(studentId: st.id, studentName: st.name, topic: topic, pct: pct, attempts: total))
            }
        }
        return cells
    }

    // MARK: Period-over-period KPIs
    func kpis(now: Date = Date()) -> (avg: DeltaKPI, submissions: DeltaKPI, calibration: DeltaKPI, completion: DeltaKPI) {
        let cal = Calendar.current
        let recentStart = cal.date(byAdding: .day, value: -7, to: now) ?? now
        let priorStart = cal.date(byAdding: .day, value: -14, to: now) ?? now

        func avgPct(_ subs: [Submission]) -> Int {
            let pcts = subs.compactMap { s -> Int? in
                guard let t = store.test(byId: s.testId) else { return nil }
                return store.score(test: t, submission: s).pct
            }
            return pcts.isEmpty ? 0 : Int(round(Double(pcts.reduce(0, +)) / Double(pcts.count)))
        }

        func calibrationECE(_ subs: [Submission]) -> Int {
            var conf: [Confidence: (Int, Int)] = [.sure: (0,0), .unsure: (0,0), .guess: (0,0)]
            for sub in subs {
                guard let t = store.test(byId: sub.testId) else { continue }
                for a in sub.answers {
                    guard let q = t.questions.first(where: { $0.id == a.questionId }) else { continue }
                    var v = conf[a.confidence] ?? (0, 0)
                    v.1 += 1
                    if a.choiceIndex == q.correctIndex { v.0 += 1 }
                    conf[a.confidence] = v
                }
            }
            let stated: [Confidence: Int] = [.sure: 85, .unsure: 55, .guess: 30]
            var ece = 0.0, total = 0
            for c in Confidence.allCases {
                let v = conf[c]!
                if v.1 == 0 { continue }
                let actual = Int(round(Double(v.0) / Double(v.1) * 100))
                ece += Double(v.1) * Double(abs(stated[c]! - actual))
                total += v.1
            }
            return total > 0 ? Int(round(ece / Double(total))) : 0
        }

        let recent = store.data.submissions.filter { $0.submittedAt >= recentStart && $0.submittedAt <= now }
        let prior = store.data.submissions.filter { $0.submittedAt >= priorStart && $0.submittedAt < recentStart }

        let avg = DeltaKPI(value: avgPct(recent), prev: avgPct(prior))
        let count = DeltaKPI(value: recent.count, prev: prior.count)
        // Calibration "score" = 100 - ECE (higher better)
        let calRecent = max(0, 100 - calibrationECE(recent))
        let calPrior = max(0, 100 - calibrationECE(prior))
        let cal2 = DeltaKPI(value: calRecent, prev: calPrior)

        // Completion: of tests assigned in window, how many submitted (per student)
        let studentCount = store.data.students.count
        func completion(_ subs: [Submission]) -> Int {
            // unique (studentId, testId) over how many tests assigned/created in that window
            let testsWindow = Set(subs.map { $0.testId })
            guard !testsWindow.isEmpty, studentCount > 0 else { return 0 }
            let expected = testsWindow.count * studentCount
            let actual = Set(subs.map { "\($0.studentId)-\($0.testId)" }).count
            return Int(round(Double(actual) / Double(expected) * 100))
        }
        let comp = DeltaKPI(value: completion(recent), prev: completion(prior))

        return (avg, count, cal2, comp)
    }

    // MARK: Alerts (today's action items)
    enum Alert: Identifiable, Hashable {
        case overdueTest(MathTest, missing: Int)
        case weakTopic(TopicID, pct: Int, attempts: Int)
        case strugglingStudent(Student, pct: Int)
        case hardestQuestion(QuestionStat)

        var id: String {
            switch self {
            case .overdueTest(let t, _): return "overdue-\(t.id)"
            case .weakTopic(let t, _, _): return "weak-\(t.rawValue)"
            case .strugglingStudent(let s, _): return "struggling-\(s.id)"
            case .hardestQuestion(let q): return "hard-\(q.id)"
            }
        }
    }

    func alerts(now: Date = Date()) -> [Alert] {
        var out: [Alert] = []

        // Overdue tests
        for t in store.data.tests {
            if let due = t.dueAt, due < now {
                let submitted = store.submissions(forTest: t.id).map { $0.studentId }
                let missing = store.data.students.filter { !submitted.contains($0.id) }.count
                if missing > 0 {
                    out.append(.overdueTest(t, missing: missing))
                }
            }
        }

        // Weak topics: <55% over recent 14d
        let recent = submissions(in: .last30)
        if !recent.isEmpty {
            var dict: [TopicID: (correct: Int, total: Int)] = [:]
            for sub in recent {
                guard let t = store.test(byId: sub.testId) else { continue }
                for a in sub.answers {
                    guard let q = t.questions.first(where: { $0.id == a.questionId }) else { continue }
                    var v = dict[t.topic] ?? (0, 0)
                    v.total += 1
                    if a.choiceIndex == q.correctIndex { v.correct += 1 }
                    dict[t.topic] = v
                }
            }
            for (topic, v) in dict where v.total >= 8 {
                let pct = Int(round(Double(v.correct) / Double(v.total) * 100))
                if pct < 55 { out.append(.weakTopic(topic, pct: pct, attempts: v.total)) }
            }
        }

        // Struggling students
        let (struggling, _) = outliers(now: now)
        for s in struggling.prefix(3) where s.recentAvg < 50 {
            out.append(.strugglingStudent(s.student, pct: s.recentAvg))
        }

        // Hardest question
        let stats = questionStats(in: .last30)
        if let hardest = stats.filter({ $0.attempts >= 4 }).min(by: { $0.accuracy < $1.accuracy }) {
            if hardest.accuracy < 0.4 { out.append(.hardestQuestion(hardest)) }
        }

        return out
    }
}
