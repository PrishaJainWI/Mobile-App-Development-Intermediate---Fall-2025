import Foundation

struct PendingPost: Codable, Identifiable {
    var id: String        // local id used as APIPost._id while offline
    var authorEmail: String
    var text: String
    var imageBase64: String?
    var createdAt: Date
}

struct PendingComment: Codable, Identifiable {
    var id: String
    var localPostId: String   // may be a local id (synced into a real id later)
    var authorEmail: String
    var text: String
    var createdAt: Date
}

struct PendingLike: Codable, Identifiable {
    var id: String { localPostId + "::" + email }
    var localPostId: String
    var email: String
    var liked: Bool
}

@MainActor
final class LocalCache {
    static let shared = LocalCache()

    private let postsFile = "posts.json"
    private let commentsFile = "comments.json"
    private let pendingPostsFile = "pending_posts.json"
    private let pendingCommentsFile = "pending_comments.json"
    private let pendingLikesFile = "pending_likes.json"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d
    }()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; return e
    }()

    private func url(for name: String) -> URL? {
        do {
            let docs = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return docs.appendingPathComponent(name)
        } catch {
            print("LocalCache url error: \(error)")
            return nil
        }
    }

    private func read<T: Decodable>(_ file: String, as: T.Type, default value: T) -> T {
        guard let url = url(for: file), let data = try? Data(contentsOf: url) else { return value }
        return (try? decoder.decode(T.self, from: data)) ?? value
    }

    private func write<T: Encodable>(_ value: T, to file: String) {
        guard let url = url(for: file) else { return }
        do { try encoder.encode(value).write(to: url, options: [.atomic]) }
        catch { print("LocalCache write error \(file): \(error)") }
    }

    // MARK: cached server snapshot

    func loadPosts() -> [APIPost] { read(postsFile, as: [APIPost].self, default: []) }
    func savePosts(_ posts: [APIPost]) { write(posts, to: postsFile) }

    func loadComments() -> [String: [APIComment]] { read(commentsFile, as: [String: [APIComment]].self, default: [:]) }
    func saveComments(_ map: [String: [APIComment]]) { write(map, to: commentsFile) }

    // MARK: pending queues

    func loadPendingPosts() -> [PendingPost] { read(pendingPostsFile, as: [PendingPost].self, default: []) }
    func savePendingPosts(_ list: [PendingPost]) { write(list, to: pendingPostsFile) }
    func appendPendingPost(_ p: PendingPost) {
        var list = loadPendingPosts(); list.append(p); savePendingPosts(list)
    }

    func loadPendingComments() -> [PendingComment] { read(pendingCommentsFile, as: [PendingComment].self, default: []) }
    func savePendingComments(_ list: [PendingComment]) { write(list, to: pendingCommentsFile) }
    func appendPendingComment(_ c: PendingComment) {
        var list = loadPendingComments(); list.append(c); savePendingComments(list)
    }

    func loadPendingLikes() -> [PendingLike] { read(pendingLikesFile, as: [PendingLike].self, default: []) }
    func savePendingLikes(_ list: [PendingLike]) { write(list, to: pendingLikesFile) }
    func upsertPendingLike(_ like: PendingLike) {
        var list = loadPendingLikes()
        list.removeAll { $0.id == like.id }
        list.append(like)
        savePendingLikes(list)
    }

    var pendingCount: Int {
        loadPendingPosts().count + loadPendingComments().count + loadPendingLikes().count
    }
}
