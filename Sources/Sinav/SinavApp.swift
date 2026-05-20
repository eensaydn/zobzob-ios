import SwiftUI

enum AppRole: String, Codable {
    case student
    case teacher
}

@main
struct SinavApp: App {
    @State private var store = AppStore()

    init() {
        // Force Turkish locale on date formatters that don't specify one
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(\.locale, Locale(identifier: "tr_TR"))
                .tint(Theme.brand)
        }
    }
}

struct ContentView: View {
    @AppStorage("app_role") private var roleStorage: String = ""
    @AppStorage("app_studentId") private var studentIdStorage: String = ""

    @State private var role: AppRole? = nil
    @State private var pickedStudentId: String? = nil

    var body: some View {
        Group {
            switch role {
            case .student:
                if let id = pickedStudentId {
                    StudentTabView(studentId: id, role: $role, pickedStudentId: $pickedStudentId)
                } else {
                    WelcomeView(role: $role, pickedStudentId: $pickedStudentId)
                }
            case .teacher:
                TeacherTabView(role: $role)
            case .none:
                WelcomeView(role: $role, pickedStudentId: $pickedStudentId)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: role)
        .onAppear {
            if role == nil {
                role = AppRole(rawValue: roleStorage)
                pickedStudentId = studentIdStorage.isEmpty ? nil : studentIdStorage
            }
        }
        .onChange(of: role) { _, newValue in
            roleStorage = newValue?.rawValue ?? ""
        }
        .onChange(of: pickedStudentId) { _, newValue in
            studentIdStorage = newValue ?? ""
        }
    }
}
