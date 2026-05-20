import SwiftUI

struct WelcomeView: View {
    @Binding var role: AppRole?
    @Binding var pickedStudentId: String?
    @Environment(AppStore.self) private var store

    @State private var showStudentSheet = false
    @State private var showTeacherSheet = false

    var body: some View {
        ZStack {
            BackgroundCanvas()

            VStack(spacing: 0) {
                Spacer(minLength: 28)

                // App mascot
                VStack(spacing: 16) {
                    ZobMascot(size: 110)

                    VStack(spacing: 4) {
                        Text("ZoB ZoB")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .tracking(-0.5)
                        Text("merhaba! beraber çalışalım ✨")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer(minLength: 28)

                VStack(spacing: 12) {
                    RoleButton(
                        title: "Öğrenciyim",
                        subtitle: "test çöz, hap bilgi topla, eğlen 🎓",
                        icon: "graduationcap.fill",
                        gradient: [Theme.brandSecondary, Color(red: 0.99, green: 0.78, blue: 0.30)]
                    ) { showStudentSheet = true }

                    RoleButton(
                        title: "Öğretmenim",
                        subtitle: "sınıfını yakından takip et 👋",
                        icon: "person.crop.rectangle.fill",
                        gradient: [Theme.brand, Theme.brandAccent]
                    ) { showTeacherSheet = true }
                }
                .padding(.horizontal, 20)

                Spacer()

                Text("v1.0 · sevgiyle yapıldı")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showStudentSheet) {
            StudentPickerSheet(role: $role, pickedStudentId: $pickedStudentId)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTeacherSheet) {
            TeacherLoginSheet(role: $role)
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Role button

private struct RoleButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
            }
            .padding(14)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PressableStyle())
    }
}

// MARK: - Pressable style (subtle scale)

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Background canvas

struct BackgroundCanvas: View {
    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()

            // Warm pastel glow blobs — peachy & friendly
            Circle()
                .fill(Theme.brand.opacity(0.22))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -120, y: -280)

            Circle()
                .fill(Color(red: 1.0, green: 0.84, blue: 0.66).opacity(0.45))
                .frame(width: 300, height: 300)
                .blur(radius: 85)
                .offset(x: 150, y: -200)

            Circle()
                .fill(Theme.brandSecondary.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 95)
                .offset(x: 100, y: 320)

            Circle()
                .fill(Color(red: 1.0, green: 0.72, blue: 0.42).opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: -150, y: 280)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Student picker sheet

struct StudentPickerSheet: View {
    @Binding var role: AppRole?
    @Binding var pickedStudentId: String?
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var showNewStudent = false

    var filtered: [Student] {
        if query.trimmingCharacters(in: .whitespaces).isEmpty { return store.data.students }
        return store.data.students.filter { $0.name.localizedCaseInsensitiveContains(query) ||
            $0.classroom.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showNewStudent = true
                    } label: {
                        Label("Yeni öğrenci oluştur", systemImage: "plus.circle.fill")
                            .foregroundStyle(Theme.brand)
                    }
                }

                Section("Öğrenciler") {
                    if filtered.isEmpty {
                        Text("Eşleşen öğrenci yok").foregroundStyle(Theme.textSecondary)
                    } else {
                        ForEach(filtered) { s in
                            Button {
                                Haptics.tap()
                                pickedStudentId = s.id
                                role = .student
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    AvatarView(name: s.name, size: 38)
                                    VStack(alignment: .leading) {
                                        Text(s.name).foregroundStyle(Theme.textPrimary)
                                            .font(.system(size: 15, weight: .semibold))
                                        Text(s.classroom).font(.caption).foregroundStyle(Theme.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(Theme.textTertiary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Ara")
            .navigationTitle("Kimsin? 👋")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showNewStudent) {
                NewStudentSheet { s in
                    pickedStudentId = s.id
                    role = .student
                    dismiss()
                }
                .presentationDetents([.height(340)])
            }
        }
    }
}

struct NewStudentSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var classroom = "12-A"

    var onCreated: (Student) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Yeni Öğrenci") {
                    TextField("Ad Soyad", text: $name)
                        .autocorrectionDisabled()
                    TextField("Sınıf (örn. 12-A)", text: $classroom)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Kayıt Ol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Oluştur") {
                        let s = store.addStudent(
                            name: name.trimmingCharacters(in: .whitespaces),
                            classroom: classroom.trimmingCharacters(in: .whitespaces)
                        )
                        Haptics.success()
                        onCreated(s)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Teacher login sheet

struct TeacherLoginSheet: View {
    @Binding var role: AppRole?
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var pin = ""
    @State private var shake = false
    @FocusState private var pinFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(LinearGradient(colors: [Theme.brand, Theme.brandAccent],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text("Hoş geldin öğretmenim 👨‍🏫")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("küçük bir şifre yeter 🤫")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.top, 8)

            SecureField("• • • •", text: $pin)
                .keyboardType(.numberPad)
                .focused($pinFocused)
                .multilineTextAlignment(.center)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .tracking(8)
                .padding(.vertical, 14)
                .frame(maxWidth: 240)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
                .offset(x: shake ? -6 : 0)
                .animation(.default.repeatCount(3, autoreverses: true).speed(4), value: shake)

            Button {
                if pin == store.data.teacherPin {
                    Haptics.success()
                    role = .teacher
                    dismiss()
                } else {
                    Haptics.error()
                    shake.toggle()
                    pin = ""
                }
            } label: {
                Text("Gir")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)

            Text("Demo PIN: 1234")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.textTertiary)

            Spacer()
        }
        .padding(.top, 30)
        .onAppear { pinFocused = true }
    }
}
