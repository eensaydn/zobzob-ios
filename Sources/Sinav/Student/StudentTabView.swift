import SwiftUI

struct StudentTabView: View {
    let studentId: String
    @Binding var role: AppRole?
    @Binding var pickedStudentId: String?

    @State private var selectedTab: Tab = .today
    @State private var pillToShow: Pill? = nil
    @State private var showLibrary = false
    @State private var libraryPresetTopic: TopicID? = nil

    enum Tab: Hashable { case today, tests, motivation, leaderboard, profile }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodayView(studentId: studentId,
                          onOpenPill: { pillToShow = $0 },
                          onOpenTopic: { topic in
                              libraryPresetTopic = topic
                              showLibrary = true
                          },
                          onGoToTests: { selectedTab = .tests },
                          onGoToLibrary: {
                              libraryPresetTopic = nil
                              showLibrary = true
                          },
                          onGoToMotivation: { selectedTab = .motivation })
            }
            .tabItem { Label("Bugün", systemImage: "sun.max.fill") }
            .tag(Tab.today)

            NavigationStack {
                StudentTestsView(studentId: studentId)
            }
            .tabItem { Label("Ödevler", systemImage: "doc.text.fill") }
            .tag(Tab.tests)

            NavigationStack {
                MotivationView()
            }
            .tabItem { Label("Motivasyon", systemImage: "sparkles") }
            .tag(Tab.motivation)

            NavigationStack {
                LeaderboardView(currentStudentId: studentId)
            }
            .tabItem { Label("Sıralama", systemImage: "trophy.fill") }
            .tag(Tab.leaderboard)

            NavigationStack {
                ProfileView(studentId: studentId,
                            onOpenLibrary: {
                                libraryPresetTopic = nil
                                showLibrary = true
                            },
                            onLogout: {
                                pickedStudentId = nil
                                role = nil
                            })
            }
            .tabItem { Label("Profilim", systemImage: "person.crop.circle.fill") }
            .tag(Tab.profile)
        }
        .tint(Theme.brand)
        .sheet(item: $pillToShow) { p in
            PillDetailSheet(pill: p)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLibrary) {
            NavigationStack {
                LibraryView(presetTopic: libraryPresetTopic,
                            onOpenPill: { pillToShow = $0 })
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Kapat") { showLibrary = false }
                        }
                    }
            }
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Pill detail sheet

struct PillDetailSheet: View {
    let pill: Pill
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    TopicChip(topic: pill.topic)
                    Text(pill.title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }

                Text(pill.formula)
                    .font(.monoLarge)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 22)
                    .padding(.horizontal, 16)
                    .background(
                        LinearGradient(colors: [pill.topic.accent.opacity(0.14), pill.topic.accent.opacity(0.04)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(pill.topic.accent.opacity(0.20), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Label("Püf Noktası", systemImage: "lightbulb.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.amber)
                    Text(pill.note)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 6) {
                    Label("Örnek", systemImage: "text.book.closed.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.brand)
                    Text(pill.example)
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(20)
        }
        .background(Theme.canvas)
    }
}
