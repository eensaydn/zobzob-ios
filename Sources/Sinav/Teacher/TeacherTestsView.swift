import SwiftUI

struct TeacherTestsView: View {
    @Environment(AppStore.self) private var store
    @State private var showNewTest = false
    @State private var query = ""

    var filtered: [MathTest] {
        let base = store.data.tests.sorted { $0.createdAt > $1.createdAt }
        if query.isEmpty { return base }
        return base.filter { $0.title.localizedCaseInsensitiveContains(query) ||
            $0.topic.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        Group {
            if filtered.isEmpty {
                ScrollView {
                    EmptyState(icon: "doc.badge.plus",
                               title: "Henüz test yok",
                               message: "Sağ üstteki + ile ilk testini oluştur.")
                        .padding(.top, 60)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filtered) { t in
                            NavigationLink {
                                TestDetailView(test: t)
                            } label: {
                                testRow(t)
                            }
                            .buttonStyle(PressableStyle())
                            .contextMenu {
                                Button(role: .destructive) {
                                    store.deleteTest(id: t.id)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Theme.canvas)
        .navigationTitle("Testler")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $query, prompt: "Test ara")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewTest = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showNewTest) {
            NavigationStack {
                TestEditorView()
            }
        }
    }

    private func testRow(_ t: MathTest) -> some View {
        let subCount = store.submissions(forTest: t.id).count
        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(t.topic.accent.opacity(0.13))
                Image(systemName: t.topic.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(t.topic.accent)
            }
            .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 4) {
                Text(t.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    TopicChip(topic: t.topic)
                    BadgePill(text: "\(t.questions.count) soru", tint: Theme.textSecondary)
                    BadgePill(text: "\(subCount) teslim", icon: "tray.fill", tint: Theme.brandSecondary)
                }
                Text("Oluşturuldu \(t.createdAt.formattedShort())" +
                     (t.dueAt.map { " • Son \($0.formattedShort())" } ?? ""))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.textTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}
