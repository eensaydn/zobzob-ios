import Foundation
import SwiftUI

// MARK: - Topic

/// 2026 AYT/12. sınıf MEB müfredatına göre düzenlendi.
enum TopicID: String, Codable, CaseIterable, Identifiable {
    case turev, integral, limit, trigonometri, logaritma
    case diziler, polinomlar, karmasik
    case olasilik, fonksiyonlar, analitik, geometri

    var id: String { rawValue }

    var name: String {
        switch self {
        case .turev: return "Türev"
        case .integral: return "İntegral"
        case .limit: return "Limit & Süreklilik"
        case .trigonometri: return "Trigonometri"
        case .logaritma: return "Üstel & Logaritma"
        case .diziler: return "Diziler"
        case .polinomlar: return "Polinomlar"
        case .karmasik: return "Karmaşık Sayılar"
        case .olasilik: return "Olasılık & Sayma"
        case .fonksiyonlar: return "Fonksiyonlar"
        case .analitik: return "Analitik Geometri"
        case .geometri: return "Geometri"
        }
    }

    /// Sınav tarafı: TYT veya AYT
    var section: String {
        switch self {
        case .turev, .integral, .limit, .diziler, .karmasik, .analitik: return "AYT"
        case .trigonometri, .logaritma, .polinomlar: return "AYT"
        case .olasilik, .fonksiyonlar, .geometri: return "TYT & AYT"
        }
    }

    var symbol: String {
        switch self {
        case .turev: return "function"
        case .integral: return "integral"
        case .limit: return "arrow.right.to.line"
        case .trigonometri: return "wave.3.right"
        case .logaritma: return "log"
        case .diziler: return "list.number"
        case .polinomlar: return "x.squareroot"
        case .karmasik: return "i.square.fill"
        case .olasilik: return "dice"
        case .fonksiyonlar: return "f.cursive"
        case .analitik: return "scope"
        case .geometri: return "triangle"
        }
    }

    var glyph: String {
        switch self {
        case .turev: return "𝑑𝑦/𝑑𝑥"
        case .integral: return "∫"
        case .limit: return "lim"
        case .trigonometri: return "sin"
        case .logaritma: return "log"
        case .diziler: return "aₙ"
        case .polinomlar: return "P(x)"
        case .karmasik: return "𝑖"
        case .olasilik: return "P"
        case .fonksiyonlar: return "ƒ"
        case .analitik: return "(x,y)"
        case .geometri: return "△"
        }
    }

    /// Warm-leaning kategorik renkler — açık turuncu brand ile uyumlu, heatmap için yine ayırt edici.
    var accent: Color {
        switch self {
        case .turev:         return Color(red: 0.92, green: 0.42, blue: 0.13)  // burnt orange
        case .integral:      return Color(red: 0.85, green: 0.30, blue: 0.40)  // terracotta
        case .limit:         return Color(red: 0.91, green: 0.50, blue: 0.21)  // tangerine
        case .trigonometri:  return Color(red: 0.06, green: 0.65, blue: 0.55)  // teal
        case .logaritma:     return Color(red: 0.96, green: 0.71, blue: 0.20)  // amber
        case .diziler:       return Color(red: 0.55, green: 0.36, blue: 0.84)  // violet
        case .polinomlar:    return Color(red: 0.78, green: 0.30, blue: 0.74)  // magenta
        case .karmasik:      return Color(red: 0.00, green: 0.51, blue: 0.78)  // marine blue
        case .olasilik:      return Color(red: 0.71, green: 0.20, blue: 0.45)  // berry
        case .fonksiyonlar:  return Color(red: 0.38, green: 0.40, blue: 0.87)  // indigo
        case .analitik:      return Color(red: 0.20, green: 0.55, blue: 0.32)  // forest green
        case .geometri:      return Color(red: 0.45, green: 0.45, blue: 0.55)  // slate
        }
    }
}

// MARK: - Difficulty

enum Difficulty: Int, Codable, CaseIterable, Identifiable {
    case veryEasy = 1, easy = 2, medium = 3, hard = 4, veryHard = 5

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .veryEasy: return "Çok Kolay"
        case .easy: return "Kolay"
        case .medium: return "Orta"
        case .hard: return "Zor"
        case .veryHard: return "Çok Zor"
        }
    }
    var tint: Color {
        switch self {
        case .veryEasy, .easy: return Theme.green
        case .medium: return Theme.amber
        case .hard, .veryHard: return Theme.rose
        }
    }
}

// MARK: - Confidence

enum Confidence: String, Codable, CaseIterable, Identifiable {
    case sure, unsure, guess

    var id: String { rawValue }
    var label: String {
        switch self {
        case .sure: return "Eminim"
        case .unsure: return "Kararsızım"
        case .guess: return "Tahmin"
        }
    }
    var tint: Color {
        switch self {
        case .sure: return Theme.green
        case .unsure: return Theme.amber
        case .guess: return Theme.rose
        }
    }
}

// MARK: - Pill (hap bilgi / formula)

struct Pill: Codable, Identifiable, Hashable {
    let id: String
    let topic: TopicID
    let title: String
    let formula: String
    let note: String
    let example: String
}

// MARK: - Student

struct Student: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var classroom: String
    var joinedAt: Date

    var initials: String {
        let parts = name.split(separator: " ").map { String($0) }
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }
}

// MARK: - Question

struct Question: Codable, Identifiable, Hashable {
    var id: String
    var text: String
    var options: [String]
    var correctIndex: Int
    var difficulty: Difficulty
    var subtopic: String
}

// MARK: - Test

struct MathTest: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var topic: TopicID
    var createdAt: Date
    var dueAt: Date?
    var questions: [Question]
}

// MARK: - Submission

struct Answer: Codable, Hashable {
    var questionId: String
    var choiceIndex: Int?
    var timeMs: Int
    var confidence: Confidence
}

struct Submission: Codable, Identifiable, Hashable {
    var id: String
    var testId: String
    var studentId: String
    var submittedAt: Date
    var answers: [Answer]
}

// MARK: - Weekly Program

struct ProgramDay: Codable, Hashable {
    var topic: TopicID
    var note: String
}

typealias WeeklyProgram = [Int: ProgramDay]  // 0 = Sunday ... 6 = Saturday

// MARK: - Achievement

struct Achievement: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let test: (StudentMetrics) -> Bool

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Achievement, rhs: Achievement) -> Bool { lhs.id == rhs.id }
}

// MARK: - Computed metrics

struct StudentMetrics {
    var totalXP: Int = 0
    var level: Int = 1
    var levelProgress: Double = 0
    var xpForNextLevel: Int = 50
    var xpInLevel: Int = 0
    var totalSubmissions: Int = 0
    var totalCorrect: Int = 0
    var streak: Int = 0
    var hasPerfect: Bool = false
    var hasFast: Bool = false
    var hardCorrect: Int = 0
    var confidentCount: Int = 0
    var confidentCorrect: Int = 0
    var calibration: Int = 0
    var uniqueTopics: Int = 0
    var isRankOne: Bool = false
    var averageScore: Int = 0
    var topicAccuracy: [TopicID: (correct: Int, total: Int)] = [:]
    var scoreTrend: [Int] = []
}

// MARK: - App State (persisted)

struct AppData: Codable {
    var students: [Student]
    var tests: [MathTest]
    var submissions: [Submission]
    var program: [String: ProgramDay]  // key as "0".."6"
    var teacherPin: String
    var schemaVersion: Int

    var programByDay: WeeklyProgram {
        get {
            var dict: WeeklyProgram = [:]
            for (k, v) in program {
                if let i = Int(k) { dict[i] = v }
            }
            return dict
        }
        set {
            var dict: [String: ProgramDay] = [:]
            for (k, v) in newValue { dict[String(k)] = v }
            program = dict
        }
    }
}
