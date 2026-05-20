import SwiftUI

struct LeaderboardView: View {
    let currentStudentId: String
    @Environment(AppStore.self) private var store

    private var rows: [AppStore.LeaderboardRow] { store.leaderboard() }
    private var myRow: AppStore.LeaderboardRow? { rows.first { $0.student.id == currentStudentId } }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                podiumSection
                listSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 4)
        }
        .background(Theme.canvas)
        .navigationTitle("Sıralama")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: Podium

    private var podiumSection: some View {
        let top = Array(rows.prefix(3))
        let p1 = top.indices.contains(0) ? top[0] : nil
        let p2 = top.indices.contains(1) ? top[1] : nil
        let p3 = top.indices.contains(2) ? top[2] : nil
        return HStack(alignment: .bottom, spacing: 12) {
            podiumColumn(row: p2, place: 2, height: 88)
            podiumColumn(row: p1, place: 1, height: 116)
            podiumColumn(row: p3, place: 3, height: 70)
        }
        .padding(.vertical, 8)
    }

    private func podiumColumn(row: AppStore.LeaderboardRow?, place: Int, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            if let row {
                Image(systemName: place == 1 ? "crown.fill" : place == 2 ? "medal.fill" : "rosette")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(place == 1 ? Theme.amber : place == 2 ? .gray : Color(red: 0.7, green: 0.45, blue: 0.16))
                AvatarView(name: row.student.name, size: place == 1 ? 56 : 46, showRing: true)
                VStack(spacing: 0) {
                    Text(row.student.firstName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text("\(row.metrics.totalXP) puan")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
            } else {
                Image(systemName: "person.fill.questionmark")
                    .foregroundStyle(Theme.textTertiary)
                    .frame(width: 46, height: 46)
            }
            RoundedRectangle(cornerRadius: 12)
                .fill(place == 1
                      ? LinearGradient(colors: [Theme.amber, Theme.amber.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                      : place == 2
                      ? LinearGradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                      : LinearGradient(colors: [Color(red: 0.7, green: 0.45, blue: 0.16), Color(red: 0.65, green: 0.40, blue: 0.10).opacity(0.6)], startPoint: .top, endPoint: .bottom))
                .frame(height: height)
                .overlay(Text("\(place)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 6),
                         alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Full list

    private var listSection: some View {
        VStack(spacing: 8) {
            ForEach(rows) { r in
                row(r)
            }

            if let me = myRow, me.rank > 3 {
                Text(rankFooter(me))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
    }

    private func rankFooter(_ me: AppStore.LeaderboardRow) -> String {
        guard me.rank > 1, let above = rows.first(where: { $0.rank == me.rank - 1 }) else { return "" }
        let diff = above.metrics.totalXP - me.metrics.totalXP
        return "Sıralamada #\(me.rank)'sin. Bir üstte olmak için \(diff) puan daha."
    }

    private func row(_ r: AppStore.LeaderboardRow) -> some View {
        let isMe = r.student.id == currentStudentId
        return HStack(spacing: 12) {
            Text("\(r.rank)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(r.rank <= 3 ? Theme.amber : Theme.textTertiary)
                .frame(width: 28)

            AvatarView(name: r.student.name, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(r.student.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    if isMe {
                        Text("SEN")
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 5).padding(.vertical, 1.5)
                            .background(Theme.brand, in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
                HStack(spacing: 8) {
                    Label("L\(r.metrics.level)", systemImage: "star.fill")
                        .labelStyle(.titleAndIcon)
                    if r.metrics.streak > 0 {
                        Label("\(r.metrics.streak)", systemImage: "flame.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    Label("\(r.metrics.totalCorrect)", systemImage: "checkmark.circle.fill")
                        .labelStyle(.titleAndIcon)
                }
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Text("\(r.metrics.totalXP)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.brand)
        }
        .padding(12)
        .background(
            (isMe ? Theme.brand.opacity(0.08) : Theme.surface),
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isMe ? Theme.brand.opacity(0.4) : .clear, lineWidth: 1.5)
        )
    }
}
