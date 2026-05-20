import Foundation
import Observation

@Observable
final class AppStore {
    var data: AppData

    private let storeURL: URL

    init() {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("sinav-state.json")
        self.storeURL = url

        if let raw = try? Data(contentsOf: url),
           let parsed = try? JSONDecoder.tr.decode(AppData.self, from: raw) {
            self.data = parsed
        } else {
            self.data = SampleData.defaultAppData()
            persist()
        }
    }

    // MARK: Persistence

    func persist() {
        if let encoded = try? JSONEncoder.tr.encode(data) {
            try? encoded.write(to: storeURL, options: [.atomic])
        }
    }

    func resetToSample() {
        data = SampleData.defaultAppData()
        persist()
    }

    // MARK: Students

    func addStudent(name: String, classroom: String) -> Student {
        let s = Student(id: UUID().uuidString, name: name, classroom: classroom, joinedAt: Date())
        data.students.append(s)
        persist()
        return s
    }

    func updateStudent(_ s: Student) {
        if let i = data.students.firstIndex(where: { $0.id == s.id }) {
            data.students[i] = s
            persist()
        }
    }

    func deleteStudent(id: String) {
        data.students.removeAll { $0.id == id }
        data.submissions.removeAll { $0.studentId == id }
        persist()
    }

    // MARK: Tests

    func addTest(_ t: MathTest) {
        data.tests.append(t)
        persist()
    }

    func updateTest(_ t: MathTest) {
        if let i = data.tests.firstIndex(where: { $0.id == t.id }) {
            data.tests[i] = t
            persist()
        }
    }

    func deleteTest(id: String) {
        data.tests.removeAll { $0.id == id }
        data.submissions.removeAll { $0.testId == id }
        persist()
    }

    // MARK: Submissions

    func submit(testId: String, studentId: String, answers: [Answer]) {
        let sub = Submission(
            id: UUID().uuidString,
            testId: testId, studentId: studentId,
            submittedAt: Date(), answers: answers
        )
        data.submissions.append(sub)
        persist()
    }

    // MARK: Program

    func setProgram(day: Int, topic: TopicID, note: String) {
        data.program[String(day)] = ProgramDay(topic: topic, note: note)
        persist()
    }
}

// MARK: - JSON

private extension JSONEncoder {
    static var tr: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.sortedKeys]
        return e
    }
}

private extension JSONDecoder {
    static var tr: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}

// MARK: - Computed helpers

extension AppStore {
    func test(byId id: String) -> MathTest? { data.tests.first { $0.id == id } }
    func student(byId id: String) -> Student? { data.students.first { $0.id == id } }

    func submissions(forStudent id: String) -> [Submission] {
        data.submissions.filter { $0.studentId == id }
    }

    func submissions(forTest id: String) -> [Submission] {
        data.submissions.filter { $0.testId == id }
    }

    func latestSubmission(student: String, test: String) -> Submission? {
        submissions(forStudent: student)
            .filter { $0.testId == test }
            .sorted { $0.submittedAt > $1.submittedAt }
            .first
    }

    func hasCompleted(student: String, test: String) -> Bool {
        latestSubmission(student: student, test: test) != nil
    }

    func score(test: MathTest, submission: Submission) -> (correct: Int, total: Int, pct: Int, time: Int) {
        var correct = 0
        var time = 0
        for a in submission.answers {
            if let q = test.questions.first(where: { $0.id == a.questionId }),
               let c = a.choiceIndex, c == q.correctIndex {
                correct += 1
            }
            time += a.timeMs
        }
        let total = test.questions.count
        let pct = total > 0 ? Int(round(Double(correct) / Double(total) * 100)) : 0
        return (correct, total, pct, time)
    }

    func xp(for submission: Submission, in test: MathTest) -> Int {
        var xp = 0
        for a in submission.answers {
            guard let q = test.questions.first(where: { $0.id == a.questionId }) else { continue }
            let isCorrect = (a.choiceIndex == q.correctIndex)
            if isCorrect {
                xp += 10
                xp += q.difficulty.rawValue * 2
                switch a.confidence {
                case .sure: xp += 5
                case .guess: xp += 3
                case .unsure: break
                }
                if a.timeMs > 0 && a.timeMs < 30_000 { xp += 5 }
            } else if a.confidence == .sure {
                xp -= 2
            }
        }
        return max(0, xp)
    }

    func metrics(forStudent id: String, leaderboardRank: Int? = nil) -> StudentMetrics {
        var m = StudentMetrics()
        let mySubs = submissions(forStudent: id)
        var topicAcc: [TopicID: (correct: Int, total: Int)] = [:]
        var trend: [Int] = []
        var topicsTouched = Set<TopicID>()

        for sub in mySubs.sorted(by: { $0.submittedAt < $1.submittedAt }) {
            guard let test = test(byId: sub.testId) else { continue }
            let sc = score(test: test, submission: sub)
            m.totalXP += xp(for: sub, in: test)
            m.totalCorrect += sc.correct
            m.totalSubmissions += 1
            trend.append(sc.pct)
            if sc.correct == sc.total { m.hasPerfect = true }
            if sc.time > 0 && sc.time < 5*60*1000 { m.hasFast = true }
            topicsTouched.insert(test.topic)
            var acc = topicAcc[test.topic] ?? (0, 0)
            acc.correct += sc.correct
            acc.total += sc.total
            topicAcc[test.topic] = acc

            for a in sub.answers {
                guard let q = test.questions.first(where: { $0.id == a.questionId }) else { continue }
                if q.difficulty.rawValue >= 4 && a.choiceIndex == q.correctIndex {
                    m.hardCorrect += 1
                }
                if a.confidence == .sure {
                    m.confidentCount += 1
                    if a.choiceIndex == q.correctIndex { m.confidentCorrect += 1 }
                }
            }
        }

        m.topicAccuracy = topicAcc
        m.scoreTrend = trend
        m.uniqueTopics = topicsTouched.count
        m.averageScore = trend.isEmpty ? 0 : Int(round(Double(trend.reduce(0, +)) / Double(trend.count)))
        m.calibration = m.confidentCount > 0 ? Int(round(Double(m.confidentCorrect) / Double(m.confidentCount) * 100)) : 0

        // Streak
        let days = Set(mySubs.map { $0.submittedAt.dayKey })
        var streak = 0
        let cal = Calendar.current
        var cursor = Date()
        for i in 0..<400 {
            if days.contains(cursor.dayKey) {
                streak += 1
                cursor = cal.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            } else if i == 0 {
                cursor = cal.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            } else {
                break
            }
        }
        m.streak = streak

        // Level (quadratic curve: level = floor(sqrt(xp/50)) + 1)
        let lvl = Int(floor(sqrt(Double(m.totalXP) / 50.0))) + 1
        let prevXP = (lvl - 1) * (lvl - 1) * 50
        let nextXP = lvl * lvl * 50
        m.level = lvl
        m.xpInLevel = m.totalXP - prevXP
        m.xpForNextLevel = nextXP - prevXP
        m.levelProgress = m.xpForNextLevel > 0 ? Double(m.xpInLevel) / Double(m.xpForNextLevel) : 0

        m.isRankOne = (leaderboardRank == 1)
        return m
    }

    struct LeaderboardRow: Identifiable {
        let id: String
        let student: Student
        let metrics: StudentMetrics
        let rank: Int
    }

    func leaderboard() -> [LeaderboardRow] {
        var rows = data.students.map { s -> (Student, StudentMetrics) in
            (s, metrics(forStudent: s.id))
        }
        rows.sort { $0.1.totalXP > $1.1.totalXP }
        return rows.enumerated().map { (i, row) in
            var m = row.1
            m.isRankOne = (i == 0)
            return LeaderboardRow(id: row.0.id, student: row.0, metrics: m, rank: i + 1)
        }
    }

    // MARK: Class averages

    func classAverage() -> Int {
        let pcts = data.submissions.compactMap { sub -> Int? in
            guard let t = test(byId: sub.testId) else { return nil }
            return score(test: t, submission: sub).pct
        }
        return pcts.isEmpty ? 0 : Int(round(Double(pcts.reduce(0, +)) / Double(pcts.count)))
    }
}
