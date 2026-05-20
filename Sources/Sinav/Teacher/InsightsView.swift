import SwiftUI
import Charts

struct InsightsView: View {
    @Environment(AppStore.self) private var store
    @State private var range: DateRange = .last30
    @State private var sortMode: QuestionSort = .hardest
    @State private var selectedQuestion: QuestionStat? = nil

    enum QuestionSort: String, CaseIterable, Identifiable {
        case hardest, easiest, mostDiscriminating, lowDiscriminating
        var id: String { rawValue }
        var label: String {
            switch self {
            case .hardest: return "En zor"
            case .easiest: return "En kolay"
            case .mostDiscriminating: return "Ayırt edici"
            case .lowDiscriminating: return "Zayıf soru"
            }
        }
    }

    private var analytics: Analytics { Analytics(store) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                rangePicker
                trajectorySection
                volumeSection
                topicsSection
                calibrationSection
                difficultySection
                heatmapSection
                questionRanking
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            .padding(.top, 4)
        }
        .background(Theme.canvas)
        .navigationTitle("Analiz")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedQuestion) { q in
            QuestionDetailSheet(stat: q, store: store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var rangePicker: some View {
        Picker("Aralık", selection: $range) {
            ForEach(DateRange.allCases) { r in Text(r.label).tag(r) }
        }
        .pickerStyle(.segmented)
    }

    // MARK: Trajectory

    private var trajectorySection: some View {
        let points = analytics.dailyClassAverage(in: range)
        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Sınıf Yörüngesi", subtitle: "Günlük sınıf ortalama başarı")
            ClassAverageChart(points: points)
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Submission velocity

    private var volumeSection: some View {
        let points = analytics.dailyClassAverage(in: range)
        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Teslim Hızı", subtitle: "Günlük gönderim sayısı")
            SubmissionsBar(points: points)
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Topics

    private var topicsSection: some View {
        let topics = analytics.topicAccuracy(in: range)
        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Konu Bazlı Başarı", subtitle: "Hangi konu çalıştırılmalı?")
            if topics.isEmpty {
                EmptyChartCard(title: "Veri yok",
                               message: "Bu aralıkta cevap yok.",
                               icon: "chart.pie")
            } else {
                TopicBarChart(topics: topics)
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Calibration

    private var calibrationSection: some View {
        let result = analytics.calibration(in: range)
        return VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Güven Sezgiu",
                          subtitle: "Beyan ettikleri güven gerçekle uyuşuyor mu?")
            CalibrationChart(points: result.points, ece: result.ece)
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Difficulty vs success scatter

    private var difficultySection: some View {
        let stats = analytics.questionStats(in: range)
        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Zorluk vs Başarı",
                          subtitle: "Verdiğin zorluk etiketi gerçeği yansıtıyor mu? (nokta = soru, büyüklük = cevap sayısı)")
            if stats.isEmpty {
                EmptyChartCard(title: "Veri yok",
                               message: "Yeterli soru cevabı yok.",
                               icon: "scope")
            } else {
                DifficultyScatter(stats: stats)

                // Legend
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TopicID.allCases) { t in
                            HStack(spacing: 4) {
                                Circle().fill(t.accent).frame(width: 8, height: 8)
                                Text(t.name).font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Heatmap

    private var heatmapSection: some View {
        let cells = analytics.heatmap()
        let students = store.data.students
        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Öğrenci × Konu Isı Haritası",
                          subtitle: "Hangi öğrencinin hangi konuda boşluğu var?")
            if cells.allSatisfy({ $0.pct < 0 }) {
                EmptyChartCard(title: "Veri yok",
                               message: "Hiçbir öğrenci henüz cevap vermemiş.",
                               icon: "square.grid.4x3.fill")
            } else {
                Heatmap(cells: cells, students: students, topics: TopicID.allCases)

                HStack(spacing: 12) {
                    legendDot(color: Theme.rose, label: "<%50")
                    legendDot(color: Theme.amber, label: "%50-70")
                    legendDot(color: Theme.green, label: ">%70")
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Question ranking

    private var questionRanking: some View {
        let all = analytics.questionStats(in: range).filter { $0.attempts > 0 }
        let sorted: [QuestionStat] = {
            switch sortMode {
            case .hardest: return all.sorted { $0.accuracy < $1.accuracy }
            case .easiest: return all.sorted { $0.accuracy > $1.accuracy }
            case .mostDiscriminating: return all.sorted { $0.discrimination > $1.discrimination }
            case .lowDiscriminating: return all.sorted { $0.discrimination < $1.discrimination }
            }
        }()

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SORU BAZLI ANALİZ")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(Theme.textSecondary)
                    Text("Discrimination index = soru güçlü öğrenciyi zayıftan ayırıyor mu?")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textTertiary)
                }
                Spacer()
            }

            Picker("Sırala", selection: $sortMode) {
                ForEach(QuestionSort.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            if sorted.isEmpty {
                EmptyChartCard(title: "Veri yok",
                               message: "Soruların performansı için cevap gerekli.",
                               icon: "list.bullet.below.rectangle")
            } else {
                VStack(spacing: 6) {
                    ForEach(sorted.prefix(8)) { q in
                        Button {
                            Haptics.tap()
                            selectedQuestion = q
                        } label: {
                            questionRow(q)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
    }

    private func questionRow(_ q: QuestionStat) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(q.topic.accent.opacity(0.13))
                Image(systemName: q.topic.symbol).foregroundStyle(q.topic.accent)
            }
            .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(q.questionText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Text("%\(Int(q.accuracy * 100)) başarı")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(q.accuracy >= 0.7 ? Theme.green : q.accuracy >= 0.4 ? Theme.amber : Theme.rose)
                    Text("• \(q.attempts) cevap")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.textTertiary)
                    Text("• ⏱ \(formatDuration(q.avgTimeMs))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text("DI")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundStyle(Theme.textTertiary)
                Text(String(format: "%+.2f", q.discrimination))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(diColor(q.discrimination))
            }
        }
        .padding(.vertical, 6).padding(.horizontal, 8)
        .background(Theme.canvas, in: RoundedRectangle(cornerRadius: 10))
    }

    private func diColor(_ d: Double) -> Color {
        if d >= 0.30 { return Theme.green }
        if d >= 0.10 { return Theme.amber }
        return Theme.rose
    }

    private func sectionHeader(_ title: String, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased(with: Locale(identifier: "tr_TR")))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(Theme.textSecondary)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 10, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

// MARK: - Question detail sheet

struct QuestionDetailSheet: View {
    let stat: QuestionStat
    let store: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    TopicChip(topic: stat.topic)
                    Text(stat.questionText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(stat.testTitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(16)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))

                HStack(spacing: 10) {
                    metricBox("Başarı", "%\(Int(stat.accuracy * 100))", tint: stat.accuracy >= 0.7 ? Theme.green : stat.accuracy >= 0.4 ? Theme.amber : Theme.rose)
                    metricBox("Cevap", "\(stat.attempts)", tint: Theme.brandSecondary)
                    metricBox("Süre", formatDuration(stat.avgTimeMs), tint: Theme.amber)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("AYIRT EDİCİLİK (DI)")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(Theme.textSecondary)
                    HStack {
                        Text(String(format: "%+.2f", stat.discrimination))
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(stat.discrimination >= 0.30 ? Theme.green : stat.discrimination >= 0.10 ? Theme.amber : Theme.rose)
                        Spacer()
                        Text(diNote(stat.discrimination))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(14)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text("GÜVEN DAĞILIMI")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(Theme.textSecondary)
                    confidenceBar(stat.confidence)
                }
                .padding(14)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(16)
        }
        .background(Theme.canvas)
    }

    private func metricBox(_ label: String, _ value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(0.5).foregroundStyle(tint)
            Text(value).font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func confidenceBar(_ c: ConfidenceDist) -> some View {
        let total = max(c.total, 1)
        return VStack(alignment: .leading, spacing: 10) {
            confidenceRow(label: "Eminim", color: Theme.green,
                          total: c.sure, correct: c.sureCorrect, of: total)
            confidenceRow(label: "Kararsız", color: Theme.amber,
                          total: c.unsure, correct: c.unsureCorrect, of: total)
            confidenceRow(label: "Tahmin", color: Theme.rose,
                          total: c.guess, correct: c.guessCorrect, of: total)
        }
    }

    private func confidenceRow(label: String, color: Color, total: Int, correct: Int, of all: Int) -> some View {
        let acc = total > 0 ? Int(round(Double(correct) / Double(total) * 100)) : 0
        return HStack {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(label).font(.system(size: 13, weight: .semibold))
            }
            Spacer()
            Text("\(total) cevap · %\(acc) doğru")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func diNote(_ d: Double) -> String {
        if d >= 0.40 { return "Mükemmel.\nGüçlü öğrenciyi zayıftan iyi ayırıyor." }
        if d >= 0.30 { return "İyi.\nKullanılabilir kalite." }
        if d >= 0.10 { return "Orta.\nGözden geçirebilirsin." }
        if d > 0     { return "Zayıf.\nDeğişik öğrenciler farklı bilgiyor." }
        return "Negatif.\nMuhtemelen tuzak/hatalı şık. Düzelt."
    }
}
