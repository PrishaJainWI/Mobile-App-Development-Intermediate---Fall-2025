import Foundation

struct User: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var email: String
    var password: String
}

@MainActor
final class UserStore: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published var currentUser: User?

    private let fileName = "users.json"

    init() {
        Task { await loadUsers() }
    }

    private func fileURL() -> URL? {
        do {
            let docs = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return docs.appendingPathComponent(fileName)
        } catch {
            print("UserStore: Failed to get documents directory: \(error)")
            return nil
        }
    }

    func loadUsers() async {
        guard let url = fileURL() else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([User].self, from: data)
            self.users = decoded
        } catch {
            self.users = []
        }
    }

    private func saveUsers() {
        guard let url = fileURL() else { return }
        do {
            let data = try JSONEncoder().encode(users)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("UserStore: Failed to save users: \(error)")
        }
    }

    func signUp(email: String, password: String) throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedEmail.isEmpty, !password.isEmpty else { throw AuthError.missingFields }
        guard !users.contains(where: { $0.email == trimmedEmail }) else { throw AuthError.emailTaken }
        let newUser = User(email: trimmedEmail, password: password)
        users.append(newUser)
        saveUsers()
        currentUser = newUser
    }

    func login(email: String, password: String) throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let user = users.first(where: { $0.email == trimmedEmail && $0.password == password }) else {
            throw AuthError.invalidCredentials
        }
        currentUser = user
    }

    func logout() { currentUser = nil }

    enum AuthError: LocalizedError {
        case missingFields, emailTaken, invalidCredentials
        var errorDescription: String? {
            switch self {
            case .missingFields: return "Please enter all fields."
            case .emailTaken: return "This email is already registered."
            case .invalidCredentials: return "Invalid email or password."
            }
        }
    }
}
