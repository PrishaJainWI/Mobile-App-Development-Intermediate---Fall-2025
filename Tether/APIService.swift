import Foundation
import UIKit

enum APIError: LocalizedError {
    case badURL
    case server(String)
    case decoding
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .badURL: return "Invalid request URL."
        case .server(let msg): return msg
        case .decoding: return "Could not parse server response."
        case .network(let e): return e.localizedDescription
        }
    }
}

final class APIService {
    static let shared = APIService()

    // Defaults to localhost (simulator-friendly). Persisted across launches in
    // UserDefaults under "tether.baseURL"; configurable from the login screen
    // and the Settings tab.
    var baseURL: URL {
        get {
            if let saved = UserDefaults.standard.string(forKey: "tether.baseURL"),
               let url = URL(string: saved) {
                return url
            }
            return URL(string: "http://localhost:4000")!
        }
        set {
            UserDefaults.standard.set(newValue.absoluteString, forKey: "tether.baseURL")
        }
    }

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 60
        return URLSession(configuration: cfg)
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    // MARK: - Auth

    func signUp(email: String, password: String) async throws -> APIUser {
        try await post("/signup", body: ["email": email, "password": password])
    }

    func login(email: String, password: String) async throws -> APIUser {
        try await post("/login", body: ["email": email, "password": password])
    }

    // MARK: - Posts

    func fetchPosts() async throws -> [APIPost] {
        try await get("/posts")
    }

    func createPost(authorEmail: String, text: String, image: UIImage?) async throws -> APIPost {
        var body: [String: Any] = [
            "authorEmail": authorEmail,
            "text": text
        ]
        if let image, let data = image.jpegData(compressionQuality: 0.7) {
            body["imageBase64"] = data.base64EncodedString()
        }
        return try await postJSON("/posts", json: body)
    }

    func toggleLike(postID: String, email: String) async throws -> APIPost {
        try await postJSON("/posts/\(postID)/like", json: ["email": email])
    }

    func fetchComments(postID: String) async throws -> [APIComment] {
        try await get("/posts/\(postID)/comments")
    }

    func addComment(postID: String, authorEmail: String, text: String) async throws -> APIComment {
        try await postJSON("/posts/\(postID)/comments", json: ["authorEmail": authorEmail, "text": text])
    }

    // MARK: - Helpers

    private func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.badURL }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        return try await perform(req)
    }

    private func post<T: Decodable>(_ path: String, body: [String: String]) async throws -> T {
        try await postJSON(path, json: body)
    }

    private func postJSON<T: Decodable>(_ path: String, json: [String: Any]) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.badURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: json)
        return try await perform(req)
    }

    private func perform<T: Decodable>(_ req: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse else { throw APIError.server("Invalid response") }
            if !(200..<300).contains(http.statusCode) {
                if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let msg = obj["error"] as? String {
                    throw APIError.server(msg)
                }
                throw APIError.server("HTTP \(http.statusCode)")
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding
            }
        } catch let e as APIError {
            throw e
        } catch {
            throw APIError.network(error)
        }
    }
}

// MARK: - DTOs

struct APIUser: Codable, Equatable, Identifiable {
    var id: String { _id }
    var _id: String
    var email: String
}

struct APIPost: Codable, Identifiable, Equatable, Hashable {
    var id: String { _id }
    var _id: String
    var authorEmail: String
    var text: String
    var imageBase64: String?
    var createdAt: Date
    var likedBy: [String]
    var commentCount: Int

    var likeCount: Int { likedBy.count }
    func isLiked(by email: String) -> Bool { likedBy.contains(email) }

    var image: UIImage? {
        guard let imageBase64, let data = Data(base64Encoded: imageBase64) else { return nil }
        return UIImage(data: data)
    }
}

struct APIComment: Codable, Identifiable, Equatable, Hashable {
    var id: String { _id }
    var _id: String
    var postId: String
    var authorEmail: String
    var text: String
    var createdAt: Date
}
