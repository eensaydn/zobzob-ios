import SwiftUI

// MARK: - AvatarView

struct AvatarView: View {
    let name: String
    var size: CGFloat = 40
    var showRing: Bool = false

    private var initials: String {
        let parts = name.split(separator: " ").map { String($0) }
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var colors: [Color] {
        let palette: [[Color]] = [
            [Color(red: 0.49, green: 0.31, blue: 0.93), Color(red: 0.38, green: 0.40, blue: 0.87)],
            [Color(red: 0.0, green: 0.55, blue: 0.85), Color(red: 0.0, green: 0.74, blue: 0.83)],
            [Color(red: 0.93, green: 0.27, blue: 0.51), Color(red: 0.95, green: 0.36, blue: 0.43)],
            [Color(red: 0.06, green: 0.65, blue: 0.55), Color(red: 0.06, green: 0.75, blue: 0.68)],
            [Color(red: 0.95, green: 0.58, blue: 0.06), Color(red: 0.97, green: 0.45, blue: 0.13)]
        ]
        let h = abs(name.hashValue) % palette.count
        return palette[h]
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.9), lineWidth: showRing ? 3 : 0)
        )
        .shadow(color: colors[0].opacity(0.25), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Badge

struct BadgePill: View {
    let text: String
    var icon: String? = nil
    var tint: Color = Theme.brand
    var prominent: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            if let icon { Image(systemName: icon).font(.system(size: 10, weight: .semibold)) }
            Text(text).font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(prominent ? .white : tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(prominent ? tint : tint.opacity(0.12), in: Capsule())
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let label: String
    let value: String
    var caption: String? = nil
    var tint: Color = Theme.brand
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                }
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(0.5)
            }
            .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            if let caption {
                Text(caption)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    var progress: Double
    var size: CGFloat = 90
    var lineWidth: CGFloat = 9
    var tint: Color = Theme.brand
    var label: String? = nil
    var caption: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.12), style: StrokeStyle(lineWidth: lineWidth))
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AngularGradient(colors: [tint.opacity(0.7), tint], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.85), value: progress)

            VStack(spacing: 0) {
                if let label {
                    Text(label).font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }
                if let caption {
                    Text(caption).font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Sparkline

struct SparklineView: View {
    let values: [Int]
    var tint: Color = Theme.brand
    var height: CGFloat = 80

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let padding: CGFloat = 12
            let maxV: Double = 100
            let count = max(values.count, 1)

            if values.isEmpty {
                Text("Veri yok")
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let points: [CGPoint] = values.enumerated().map { i, v in
                    let x = padding + (CGFloat(i) * (w - 2*padding)) / CGFloat(max(count - 1, 1))
                    let y = h - padding - (CGFloat(Double(v) / maxV) * (h - 2*padding))
                    return CGPoint(x: x, y: y)
                }

                ZStack {
                    // Area
                    Path { p in
                        guard let first = points.first else { return }
                        p.move(to: first)
                        for pt in points.dropFirst() { p.addLine(to: pt) }
                        p.addLine(to: CGPoint(x: points.last!.x, y: h - padding))
                        p.addLine(to: CGPoint(x: points.first!.x, y: h - padding))
                        p.closeSubpath()
                    }
                    .fill(LinearGradient(colors: [tint.opacity(0.32), tint.opacity(0.02)],
                                         startPoint: .top, endPoint: .bottom))

                    // Line
                    Path { p in
                        guard let first = points.first else { return }
                        p.move(to: first)
                        for pt in points.dropFirst() { p.addLine(to: pt) }
                    }
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                    // Dots
                    ForEach(Array(points.enumerated()), id: \.offset) { _, pt in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(tint, lineWidth: 2))
                            .position(pt)
                    }
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Topic chip

struct TopicChip: View {
    let topic: TopicID
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: topic.symbol)
                .font(.system(size: 10, weight: .semibold))
            Text(topic.name)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(topic.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(topic.accent.opacity(0.12), in: Capsule())
    }
}

// MARK: - Topic card

struct TopicCard: View {
    let topic: TopicID
    let pillCount: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(topic.glyph)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 2) {
                Text(topic.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("\(pillCount) formül")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .foregroundStyle(.white)
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(Theme.gradient(topic))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: topic.accent.opacity(0.30), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Daily pill featured card

struct PillFeatureCard: View {
    let pill: Pill
    var headerLabel: String = "Günün Hap Bilgisi"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "pills.fill")
                    .font(.system(size: 12, weight: .bold))
                Text(headerLabel.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.8)
            }
            .foregroundStyle(.white.opacity(0.85))

            VStack(alignment: .leading, spacing: 4) {
                Text(pill.topic.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Text(pill.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }

            Text(pill.formula)
                .font(.monoLarge)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(pill.note)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .foregroundStyle(.white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .bottomTrailing) {
                Theme.gradient(pill.topic)
                Text(pill.topic.glyph)
                    .font(.system(size: 180, weight: .bold, design: .serif))
                    .foregroundStyle(.white.opacity(0.07))
                    .offset(x: 30, y: 50)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: pill.topic.accent.opacity(0.35), radius: 18, x: 0, y: 10)
    }
}

// MARK: - Pill row (list)

struct PillRow: View {
    let pill: Pill
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(pill.topic.accent.opacity(0.13))
                Text(pill.topic.glyph)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(pill.topic.accent)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text(pill.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(pill.formula)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Empty state

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(Theme.textTertiary)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var trailing: AnyView? = nil
    init(_ title: String, trailing: AnyView? = nil) {
        self.title = title
        self.trailing = trailing
    }
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            if let trailing { trailing }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Progress bar row

struct ProgressRow: View {
    let label: String
    let value: Int
    var max: Int = 100
    var tint: Color = Theme.brand
    var suffix: String = "%"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(value)\(suffix)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }
            GeometryReader { p in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(uiColor: .tertiarySystemFill))
                    Capsule()
                        .fill(tint)
                        .frame(width: max > 0 ? p.size.width * CGFloat(value) / CGFloat(max) : 0)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Choice button

struct ChoiceButton: View {
    let label: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let isLocked: Bool
    let onTap: () -> Void

    var border: Color {
        if let isCorrect {
            return isCorrect ? Theme.green : Theme.rose
        }
        return isSelected ? Theme.brand : Color(uiColor: .separator).opacity(0.6)
    }

    var labelBg: Color {
        if let isCorrect { return isCorrect ? Theme.green : Theme.rose }
        return isSelected ? Theme.brand : Color(uiColor: .tertiarySystemFill)
    }

    var labelFg: Color {
        if isCorrect != nil { return .white }
        return isSelected ? .white : Theme.textSecondary
    }

    var body: some View {
        Button(action: { if !isLocked { onTap() } }) {
            HStack(spacing: 14) {
                Text(label)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(labelFg)
                    .frame(width: 32, height: 32)
                    .background(labelBg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Theme.brand.opacity(0.08) : Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(border, lineWidth: isSelected || isCorrect != nil ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Loading veil for empty stats

struct EmptyChartCard: View {
    let title: String
    let message: String
    let icon: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 44, height: 44)
                .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .semibold))
                Text(message).font(.system(size: 12)).foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Number tracker (animated)

struct NumberView: View {
    let value: Int
    var suffix: String = ""
    var prefix: String = ""

    var body: some View {
        Text("\(prefix)\(value)\(suffix)")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .contentTransition(.numericText())
    }
}
