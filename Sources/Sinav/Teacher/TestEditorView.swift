import SwiftUI

struct TestEditorView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var topic: TopicID = .turev
    @State private var dueDate: Date = Date().addingTimeInterval(86400 * 3)
    @State private var hasDueDate: Bool = true
    @State private var questions: [Question] = [TestEditorView.newQuestion()]

    static func newQuestion() -> Question {
        Question(id: UUID().uuidString,
                 text: "",
                 options: ["", "", "", "", ""],
                 correctIndex: 0,
                 difficulty: .medium,
                 subtopic: "")
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        questions.allSatisfy { q in
            !q.text.trimmingCharacters(in: .whitespaces).isEmpty &&
            q.options.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
    }

    var body: some View {
        Form {
            Section("Test Bilgileri") {
                TextField("Başlık (örn. Türev Final Provası)", text: $title)

                Picker("Konu", selection: $topic) {
                    ForEach(TopicID.allCases) { t in
                        Label(t.name, systemImage: t.symbol).tag(t)
                    }
                }

                Toggle("Son tarih belirle", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("Son tarih", selection: $dueDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
            }

            ForEach($questions) { $q in
                Section {
                    questionEditor($q)
                } header: {
                    HStack {
                        Text("Soru \((questions.firstIndex(where: { $0.id == q.id }) ?? 0) + 1)")
                        Spacer()
                        if questions.count > 1 {
                            Button(role: .destructive) {
                                questions.removeAll { $0.id == q.id }
                            } label: {
                                Image(systemName: "trash").foregroundStyle(Theme.rose)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Section {
                Button {
                    questions.append(TestEditorView.newQuestion())
                } label: {
                    Label("Soru ekle", systemImage: "plus.circle.fill")
                        .foregroundStyle(Theme.brand)
                }
            }
        }
        .navigationTitle("Yeni Test")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("İptal") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Kaydet") {
                    let test = MathTest(
                        id: UUID().uuidString,
                        title: title.trimmingCharacters(in: .whitespaces),
                        topic: topic,
                        createdAt: Date(),
                        dueAt: hasDueDate ? dueDate : nil,
                        questions: questions.map { q in
                            var nq = q
                            nq.text = q.text.trimmingCharacters(in: .whitespaces)
                            nq.subtopic = q.subtopic.trimmingCharacters(in: .whitespaces)
                            nq.options = q.options.map { $0.trimmingCharacters(in: .whitespaces) }
                            return nq
                        }
                    )
                    store.addTest(test)
                    Haptics.success()
                    dismiss()
                }
                .disabled(!isValid)
            }
        }
    }

    @ViewBuilder
    private func questionEditor(_ q: Binding<Question>) -> some View {
        TextField("Soru metni", text: q.text, axis: .vertical)
            .lineLimit(2...4)

        ForEach(Array(q.options.indices), id: \.self) { i in
            HStack(spacing: 10) {
                Button {
                    q.wrappedValue.correctIndex = i
                } label: {
                    Image(systemName: q.wrappedValue.correctIndex == i ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(q.wrappedValue.correctIndex == i ? Theme.green : Theme.textTertiary)
                }
                .buttonStyle(.plain)

                TextField("Seçenek \(["A","B","C","D","E"][i])", text: q.options[i])
            }
        }

        Picker("Zorluk", selection: q.difficulty) {
            ForEach(Difficulty.allCases) { d in
                Text(d.label).tag(d)
            }
        }

        TextField("Alt konu etiketi (örn. Zincir kuralı)", text: q.subtopic)
    }
}
