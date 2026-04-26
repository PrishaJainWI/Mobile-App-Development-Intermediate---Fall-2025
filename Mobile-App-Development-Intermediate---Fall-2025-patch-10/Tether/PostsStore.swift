import Foundation
import SwiftUI

struct Post: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var authorEmail: String
    var text: String
    var createdAt: Date = Date()
    var likedBy: [String] = [] // store user emails who liked

    var likeCount: Int { likedBy.count }
    func isLiked(by email: String) -> Bool { likedBy.contains(email) }
}

@MainActor
final class PostsStore: ObservableObject {
    @Published private(set) var posts: [Post] = []
    private let fileName = "posts.json"

    init() {
        Task { await load() }
    }

    private func fileURL() -> URL? {
        do {
            let docs = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return docs.appendingPathComponent(fileName)
        } catch {
            print("PostsStore: documents URL error: \(error)")
            return nil
        }
    }

    func load() async {
        guard let url = fileURL() else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Post].self, from: data)
            self.posts = decoded.sorted { $0.createdAt > $1.createdAt }
        } catch {
            self.posts = []
        }
    }

    private func save() {
        guard let url = fileURL() else { return }
        do {
            let data = try JSONEncoder().encode(posts)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("PostsStore: save error: \(error)")
        }
    }

    func createPost(authorEmail: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let post = Post(authorEmail: authorEmail, text: trimmed)
        posts.insert(post, at: 0)
        save()
    }

    func toggleLike(postID: UUID, by email: String) {
        guard let idx = posts.firstIndex(where: { $0.id == postID }) else { return }
        if let likeIdx = posts[idx].likedBy.firstIndex(of: email) {
            posts[idx].likedBy.remove(at: likeIdx)
        } else {
            posts[idx].likedBy.append(email)
        }
        save()
    }
}
