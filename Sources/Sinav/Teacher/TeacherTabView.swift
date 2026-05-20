import SwiftUI

struct TeacherTabView: View {
    @Binding var role: AppRole?
    @State private var selectedTab: Tab = .panel

    enum Tab: Hashable { case panel, tests, classroom, program, insights }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(role: $role, switchTab: { selectedTab = $0 })
            }
            .tabItem { Label("Panel", systemImage: "chart.bar.doc.horizontal.fill") }
            .tag(Tab.panel)

            NavigationStack {
                TeacherTestsView()
            }
            .tabItem { Label("Testler", systemImage: "doc.text.fill") }
            .tag(Tab.tests)

            NavigationStack {
                ClassView()
            }
            .tabItem { Label("Sınıf", systemImage: "person.3.fill") }
            .tag(Tab.classroom)

            NavigationStack {
                ProgramView()
            }
            .tabItem { Label("Program", systemImage: "calendar") }
            .tag(Tab.program)

            NavigationStack {
                InsightsView()
            }
            .tabItem { Label("Analiz", systemImage: "chart.line.uptrend.xyaxis") }
            .tag(Tab.insights)
        }
        .tint(Theme.brand)
    }
}
