import SwiftUI

enum Theme {
    // Brand — açık turuncu palet
    static let brand          = Color(red: 1.00, green: 0.55, blue: 0.26)   // #FF8C42 — primary
    static let brandSecondary = Color(red: 1.00, green: 0.66, blue: 0.36)   // #FFA85C — secondary
    static let brandAccent    = Color(red: 0.92, green: 0.42, blue: 0.13)   // #EB6A21 — emphasis
    static let brandSoft      = Color(red: 1.00, green: 0.88, blue: 0.72)   // #FFE0B8 — tint surfaces

    // Semantic — warm-leaning but still legible
    static let green = Color(red: 0.18, green: 0.66, blue: 0.40)
    static let amber = Color(red: 0.94, green: 0.61, blue: 0.04)
    static let rose  = Color(red: 0.91, green: 0.34, blue: 0.28)
    static let blue  = Color(red: 0.00, green: 0.51, blue: 0.78)

    // Surfaces (system-driven, dark-mode safe)
    static let canvas           = Color(uiColor: .systemGroupedBackground)
    static let surface          = Color(uiColor: .secondarySystemGroupedBackground)
    static let surfaceElevated  = Color(uiColor: .tertiarySystemGroupedBackground)
    static let separator        = Color(uiColor: .separator)

    // Text
    static let textPrimary   = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let textTertiary  = Color(uiColor: .tertiaryLabel)

    // Brand gradient
    static let brandGradient = LinearGradient(
        colors: [brand, brandSecondary],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let brandWarmBackground = LinearGradient(
        colors: [Color(red: 1.0, green: 0.97, blue: 0.93), Color(red: 1.0, green: 0.94, blue: 0.86)],
        startPoint: .top, endPoint: .bottom
    )

    static func gradient(_ topic: TopicID) -> LinearGradient {
        LinearGradient(
            colors: [topic.accent, topic.accent.opacity(0.7)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}

// MARK: - Typography

extension Font {
    static let largeNumber = Font.system(size: 56, weight: .bold, design: .rounded)
    static let bigNumber = Font.system(size: 28, weight: .bold, design: .rounded)
    static let mediumNumber = Font.system(size: 20, weight: .bold, design: .rounded)
    static let mono = Font.system(.body, design: .monospaced).weight(.semibold)
    static let monoLarge = Font.system(size: 22, weight: .semibold, design: .monospaced)
}

// MARK: - Haptics (legacy + modern via .sensoryFeedback in views)

enum Haptics {
    static func tap()      { let g = UIImpactFeedbackGenerator(style: .light); g.prepare(); g.impactOccurred() }
    static func soft()     { let g = UIImpactFeedbackGenerator(style: .soft);  g.prepare(); g.impactOccurred() }
    static func success()  { let g = UINotificationFeedbackGenerator();        g.prepare(); g.notificationOccurred(.success) }
    static func warning()  { let g = UINotificationFeedbackGenerator();        g.prepare(); g.notificationOccurred(.warning) }
    static func error()    { let g = UINotificationFeedbackGenerator();        g.prepare(); g.notificationOccurred(.error) }
}

// MARK: - View modifiers

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
}

// MARK: - Date helpers

extension Date {
    var dayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
    func formattedShort() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM"
        return f.string(from: self)
    }
    func formattedShortTime() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM, HH:mm"
        return f.string(from: self)
    }
    func formattedRelative() -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.unitsStyle = .short
        return f.localizedString(for: self, relativeTo: Date())
    }
}

func formatDuration(_ ms: Int) -> String {
    let s = Int(round(Double(ms) / 1000.0))
    if s < 60 { return "\(s) sn" }
    let m = s / 60
    let r = s % 60
    return r > 0 ? "\(m)d \(r)sn" : "\(m)dk"
}

let weekdayName: [Int: String] = [
    0: "Pazar", 1: "Pazartesi", 2: "Salı", 3: "Çarşamba",
    4: "Perşembe", 5: "Cuma", 6: "Cumartesi"
]
let weekdayShort: [Int: String] = [
    0: "Paz", 1: "Pzt", 2: "Sal", 3: "Çar", 4: "Per", 5: "Cum", 6: "Cmt"
]
