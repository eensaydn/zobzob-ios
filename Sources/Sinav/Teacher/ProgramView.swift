import SwiftUI

struct ProgramView: View {
    @Environment(AppStore.self) private var store

    private let days = [1, 2, 3, 4, 5, 6, 0]
    private var todayIdx: Int { Calendar.current.component(.weekday, from: Date()) - 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                introCard
                weeklyEditor
                pillsPreview
            }
            .padding(16)
        }
        .background(Theme.canvas)
        .navigationTitle("Program")
        .navigationBarTitleDisplayMode(.large)
    }

    private var introCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Theme.brand.opacity(0.14)).frame(width: 44, height: 44)
                Image(systemName: "calendar").foregroundStyle(Theme.brand)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Haftalık Konu Planı")
                    .font(.system(size: 15, weight: .semibold))
                Text("Her güne bir konu ata; öğrenciler ana ekranlarında görür.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var weeklyEditor: some View {
        VStack(spacing: 10) {
            ForEach(days, id: \.self) { d in
                dayRow(d)
            }
        }
    }

    private func dayRow(_ d: Int) -> some View {
        let prog = store.data.programByDay[d] ?? ProgramDay(topic: .turev, note: "")
        let isToday = d == todayIdx

        return VStack(spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(prog.topic.accent.opacity(0.14))
                        .frame(width: 40, height: 40)
                    Image(systemName: prog.topic.symbol)
                        .foregroundStyle(prog.topic.accent)
                }
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Text(weekdayName[d] ?? "")
                            .font(.system(size: 15, weight: .semibold))
                        if isToday {
                            Text("BUGÜN").font(.system(size: 9, weight: .heavy))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Theme.brand, in: Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                    Text(prog.topic.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                Picker("Konu", selection: Binding(
                    get: { prog.topic },
                    set: { store.setProgram(day: d, topic: $0, note: prog.note) }
                )) {
                    ForEach(TopicID.allCases) { t in Text(t.name).tag(t) }
                }
                .pickerStyle(.menu)
                .tint(Theme.textPrimary)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))

                TextField("Not", text: Binding(
                    get: { prog.note },
                    set: { store.setProgram(day: d, topic: prog.topic, note: $0) }
                ))
                .font(.system(size: 13))
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isToday ? Theme.brand.opacity(0.4) : .clear, lineWidth: 1.5)
        )
    }

    private var pillsPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HAFTANIN HAP BİLGİLERİ")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.6).foregroundStyle(Theme.textSecondary)
            VStack(spacing: 8) {
                ForEach(0..<7) { i in
                    let p = PillBank.todayPill(offset: i)
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(p.topic.accent.opacity(0.13))
                                .frame(width: 40, height: 40)
                            Image(systemName: p.topic.symbol)
                                .foregroundStyle(p.topic.accent)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(i == 0 ? "Bugün" : nextDay(i))
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .tracking(0.5)
                                .foregroundStyle(Theme.textSecondary)
                            Text(p.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)
                                .lineLimit(1)
                            Text(p.formula)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(p.topic.accent)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private func nextDay(_ offset: Int) -> String {
        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: offset, to: Date()) ?? Date()
        let dayIdx = cal.component(.weekday, from: date) - 1
        return weekdayShort[dayIdx] ?? ""
    }
}
