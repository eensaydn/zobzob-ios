import SwiftUI

struct LibraryView: View {
    var presetTopic: TopicID? = nil
    var onOpenPill: (Pill) -> Void

    @State private var query = ""
    @State private var selectedTopic: TopicID? = nil

    var filteredPills: [Pill] {
        let base = selectedTopic.map { t in PillBank.byTopic(t) } ?? PillBank.all
        if query.trimmingCharacters(in: .whitespaces).isEmpty { return base }
        return base.filter { p in
            p.title.localizedCaseInsensitiveContains(query) ||
            p.formula.localizedCaseInsensitiveContains(query) ||
            p.note.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if selectedTopic == nil && query.isEmpty {
                    topicsGrid
                } else {
                    pillsList
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 8)
        }
        .background(Theme.canvas)
        .searchable(text: $query, prompt: "Formül veya konu ara")
        .navigationTitle(selectedTopic?.name ?? "Konular")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if selectedTopic != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tümü") {
                        Haptics.tap()
                        selectedTopic = nil
                    }
                    .font(.system(size: 14, weight: .semibold))
                }
            }
        }
        .onAppear {
            if let p = presetTopic { selectedTopic = p }
        }
    }

    // MARK: Topics grid

    private var topicsGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Hap bilgiler ve formüller — konuya göre tüm külliyat.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                      spacing: 12) {
                ForEach(TopicID.allCases) { topic in
                    Button {
                        Haptics.tap()
                        selectedTopic = topic
                    } label: {
                        TopicCard(topic: topic, pillCount: PillBank.byTopic(topic).count)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    // MARK: Pills list

    private var pillsList: some View {
        LazyVStack(spacing: 10) {
            if filteredPills.isEmpty {
                EmptyState(icon: "magnifyingglass", title: "Sonuç yok",
                           message: "Aramana uygun formül bulunamadı.")
                    .padding(.top, 30)
            } else {
                ForEach(filteredPills) { p in
                    Button {
                        Haptics.tap()
                        onOpenPill(p)
                    } label: {
                        PillRow(pill: p)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }
}
