import Foundation
import SwiftUI
import UIKit

@MainActor
final class PostsStore: ObservableObject {
    @Published private(set) var posts: [APIPost] = []
    @Published private(set) var commentsByPost: [String: [APIComment]] = [:]
    @Published var isLoading: Bool = false
    @Published var lastError: String?
    @Published private(set) var isOffline: Bool = false

    init() {
        // Hydrate immediately from disk so the UI has something while we hit the network.
        self.posts = LocalCache.shared.loadPosts().sorted { $0.createdAt > $1.createdAt }
        self.commentsByPost = LocalCache.shared.loadComments()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await APIService.shared.fetchPosts()
            self.posts = fetched.sorted { $0.createdAt > $1.createdAt }
            self.lastError = nil
            self.isOffline = false
            LocalCache.shared.savePosts(self.posts)
        } catch {
            self.isOffline = true
            self.lastError = "Could not connect to server — using offline data."
            self.posts = LocalCache.shared.loadPosts().sorted { $0.createdAt > $1.createdAt }
        }
    }

    func createPost(authorEmail: String, text: String, image: UIImage?) async {
        do {
            let new = try await APIService.shared.createPost(authorEmail: authorEmail, text: text, image: image)
            posts.insert(new, at: 0)
            LocalCache.shared.savePosts(posts)
            lastError = nil
            isOffline = false
        } catch {
            // Offline fallback: stash a pending post and show it locally.
            let localId = "local-\(UUID().uuidString)"
            let imageBase64 = image?.jpegData(compressionQuality: 0.7)?.base64EncodedString()
            let pending = PendingPost(id: localId, authorEmail: authorEmail, text: text, imageBase64: imageBase64, createdAt: Date())
            LocalCache.shared.appendPendingPost(pending)

            let local = APIPost(_id: localId,
                                authorEmail: authorEmail,
                                text: text,
                                imageBase64: imageBase64,
                                createdAt: pending.createdAt,
                                likedBy: [],
                                commentCount: 0)
            posts.insert(local, at: 0)
            LocalCache.shared.savePosts(posts)
            isOffline = true
            lastError = "Could not connect to server — saved locally. Sync from Settings when online."
        }
    }

    func toggleLike(postID: String, by email: String) async {
        do {
            let updated = try await APIService.shared.toggleLike(postID: postID, email: email)
            if let idx = posts.firstIndex(where: { $0._id == postID }) {
                posts[idx] = updated
                LocalCache.shared.savePosts(posts)
            }
            isOffline = false
        } catch {
            // Toggle locally and queue.
            if let idx = posts.firstIndex(where: { $0._id == postID }) {
                var p = posts[idx]
                var liked = p.likedBy
                let nowLiked: Bool
                if let i = liked.firstIndex(of: email) { liked.remove(at: i); nowLiked = false }
                else { liked.append(email); nowLiked = true }
                p = APIPost(_id: p._id, authorEmail: p.authorEmail, text: p.text, imageBase64: p.imageBase64, createdAt: p.createdAt, likedBy: liked, commentCount: p.commentCount)
                posts[idx] = p
                LocalCache.shared.savePosts(posts)
                LocalCache.shared.upsertPendingLike(PendingLike(localPostId: postID, email: email, liked: nowLiked))
            }
            isOffline = true
            lastError = "Offline — like saved locally."
        }
    }

    func loadComments(for postID: String) async {
        do {
            let list = try await APIService.shared.fetchComments(postID: postID)
            let sorted = list.sorted { $0.createdAt < $1.createdAt }
            commentsByPost[postID] = sorted
            LocalCache.shared.saveComments(commentsByPost)
            isOffline = false
        } catch {
            isOffline = true
            commentsByPost[postID] = LocalCache.shared.loadComments()[postID] ?? []
        }
    }

    func addComment(postID: String, authorEmail: String, text: String) async {
        do {
            let comment = try await APIService.shared.addComment(postID: postID, authorEmail: authorEmail, text: text)
            var list = commentsByPost[postID] ?? []
            list.append(comment)
            commentsByPost[postID] = list
            LocalCache.shared.saveComments(commentsByPost)
            if let idx = posts.firstIndex(where: { $0._id == postID }) {
                let p = posts[idx]
                posts[idx] = APIPost(_id: p._id, authorEmail: p.authorEmail, text: p.text, imageBase64: p.imageBase64, createdAt: p.createdAt, likedBy: p.likedBy, commentCount: p.commentCount + 1)
                LocalCache.shared.savePosts(posts)
            }
            isOffline = false
        } catch {
            let localId = "local-\(UUID().uuidString)"
            let local = APIComment(_id: localId, postId: postID, authorEmail: authorEmail, text: text, createdAt: Date())
            var list = commentsByPost[postID] ?? []
            list.append(local)
            commentsByPost[postID] = list
            LocalCache.shared.saveComments(commentsByPost)
            LocalCache.shared.appendPendingComment(PendingComment(id: localId, localPostId: postID, authorEmail: authorEmail, text: text, createdAt: local.createdAt))
            if let idx = posts.firstIndex(where: { $0._id == postID }) {
                let p = posts[idx]
                posts[idx] = APIPost(_id: p._id, authorEmail: p.authorEmail, text: p.text, imageBase64: p.imageBase64, createdAt: p.createdAt, likedBy: p.likedBy, commentCount: p.commentCount + 1)
                LocalCache.shared.savePosts(posts)
            }
            isOffline = true
            lastError = "Offline — reply saved locally."
        }
    }

    // MARK: - Sync

    /// Push everything queued in the local JSON files up to the server.
    /// Returns a (synced, remaining) summary.
    func syncPendingToServer() async -> (synced: Int, remaining: Int) {
        var synced = 0

        // Posts: send each, remember mapping from local id → real server id.
        var pendingPosts = LocalCache.shared.loadPendingPosts()
        var idMap: [String: String] = [:]
        var keepPosts: [PendingPost] = []
        for p in pendingPosts {
            let img = p.imageBase64.flatMap { Data(base64Encoded: $0) }.flatMap { UIImage(data: $0) }
            do {
                let saved = try await APIService.shared.createPost(authorEmail: p.authorEmail, text: p.text, image: img)
                idMap[p.id] = saved._id
                synced += 1
            } catch {
                keepPosts.append(p)
            }
        }
        pendingPosts = keepPosts
        LocalCache.shared.savePendingPosts(pendingPosts)

        // Comments: rewrite postId via map if it was a local post.
        var keepComments: [PendingComment] = []
        for c in LocalCache.shared.loadPendingComments() {
            let serverPostId = idMap[c.localPostId] ?? c.localPostId
            if serverPostId.hasPrefix("local-") { keepComments.append(c); continue }
            do {
                _ = try await APIService.shared.addComment(postID: serverPostId, authorEmail: c.authorEmail, text: c.text)
                synced += 1
            } catch {
                keepComments.append(c)
            }
        }
        LocalCache.shared.savePendingComments(keepComments)

        // Likes: replay only the final state (we stored upserts so each is the latest).
        var keepLikes: [PendingLike] = []
        for like in LocalCache.shared.loadPendingLikes() {
            let serverPostId = idMap[like.localPostId] ?? like.localPostId
            if serverPostId.hasPrefix("local-") { keepLikes.append(like); continue }
            do {
                let post = try await APIService.shared.toggleLike(postID: serverPostId, email: like.email)
                let isLiked = post.likedBy.contains(like.email)
                if isLiked != like.liked {
                    _ = try await APIService.shared.toggleLike(postID: serverPostId, email: like.email)
                }
                synced += 1
            } catch {
                keepLikes.append(like)
            }
        }
        LocalCache.shared.savePendingLikes(keepLikes)

        // Refresh feed from server now that we've synced.
        await refresh()

        let remaining = LocalCache.shared.pendingCount
        return (synced, remaining)
    }

    var pendingCount: Int { LocalCache.shared.pendingCount }
}
