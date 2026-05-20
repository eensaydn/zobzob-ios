import SwiftUI

struct MotivationView: View {
    @State private var selectedTheme: Motivation.Theme? = nil
    @State private var shareSheet = false
    @State private var bounceTrigger = 0

    private var today: Motivation { MotivationBank.today() }
    private var browse: [Motivation] {
        if let t = selectedTheme { return MotivationBank.byTheme(t) }
        return MotivationBank.all
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                heroQuote
                themeFilter
                quotesList
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 4)
        }
        .background(Theme.canvas)
        .navigationTitle("Motivasyon")
        .navigationBarTitleDisplayMode(.large)
        .sensoryFeedback(.impact(weight: .light), trigger: bounceTrigger)
    }

    // MARK: Today's hero

    private var heroQuote: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .heavy))
                    .symbolEffect(.bounce, value: bounceTrigger)
                Text("BUGÜNÜN SÖZÜ")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.8)
                Spacer()
                Text(todayDateLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .opacity(0.85)
            }
            .foregroundStyle(.white.opacity(0.95))

            Text("\u{201C}\(today.quote)\u{201D}")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 4)

            HStack {
                Image(systemName: today.theme.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text("— \(today.author)")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Button {
                    bounceTrigger &+= 1
                    UIPasteboard.general.string = "\u{201C}\(today.quote)\u{201D}\n— \(today.author)"
                    Haptics.success()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(8)
                        .background(.white.opacity(0.18), in: Circle())
                }
            }
            .foregroundStyle(.white)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [Theme.brand, Theme.brandSecondary, Theme.brandAccent.opacity(0.85)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                // Decorative quote glyph
                Text("\u{201C}")
                    .font(.system(size: 280, weight: .bold, design: .serif))
                    .foregroundStyle(.white.opacity(0.10))
                    .offset(x: 25, y: 100)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.brand.opacity(0.35), radius: 18, x: 0, y: 10)
    }

    private var todayDateLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM"
        return f.string(from: Date())
    }

    // MARK: Theme filter

    private var themeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                themeChip(nil, label: "Hepsi", icon: "infinity")
                ForEach([Motivation.Theme.math, .turkish, .effort, .mindset, .wisdom], id: \.self) { t in
                    themeChip(t, label: t.label, icon: t.icon)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func themeChip(_ theme: Motivation.Theme?, label: String, icon: String) -> some View {
        let active = selectedTheme == theme
        return Button {
            Haptics.tap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selectedTheme = theme
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 11, weight: .semibold))
                Text(label).font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(active ? .white : Theme.brand)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(active ? Theme.brand : Theme.brand.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: Quotes list

    private var quotesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ARŞİV")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(browse.count) söz")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.textTertiary)
            }

            VStack(spacing: 8) {
                ForEach(browse) { m in
                    quoteRow(m)
                }
            }
        }
    }

    private func quoteRow(_ m: Motivation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Theme.brand.opacity(0.14)).frame(width: 36, height: 36)
                Image(systemName: m.theme.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.brand)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\u{201C}\(m.quote)\u{201D}")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text("— \(m.author)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
    }
}
