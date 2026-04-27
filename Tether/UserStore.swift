import Foundation

struct User: Codable, Equatable, Identifiable {
    var id: String
    var email: String
}

@MainActor
final class UserStore: ObservableObject {
    @Published var currentUser: User?

    private let savedUserKey = "tether.currentUser"

    init() {
        if let data = UserDefaults.standard.data(forKey: savedUserKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
        }
    }

    private func persist(_ user: User?) {
        if let user, let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: savedUserKey)
        } else {
            UserDefaults.standard.removeObject(forKey: savedUserKey)
        }
    }

    func signUp(email: String, password: String) async throws {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, !password.isEmpty else { throw AuthError.missingFields }
        let api = try await APIService.shared.signUp(email: trimmed, password: password)
        let user = User(id: api._id, email: api.email)
        currentUser = user
        persist(user)
    }

    func login(email: String, password: String) async throws {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, !password.isEmpty else { throw AuthError.missingFields }
        let api = try await APIService.shared.login(email: trimmed, password: password)
        let user = User(id: api._id, email: api.email)
        currentUser = user
        persist(user)
    }

    func logout() {
        currentUser = nil
        persist(nil)
    }

    enum AuthError: LocalizedError {
        case missingFields
        var errorDescription: String? {
            switch self {
            case .missingFields: return "Please enter all fields."
            }
        }
    }
}
