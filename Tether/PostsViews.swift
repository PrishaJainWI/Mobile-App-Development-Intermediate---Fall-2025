import SwiftUI
import UIKit

struct PostsView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var postsStore: PostsStore

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    if postsStore.isOffline {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                            Text("Offline — using saved data. Sync from Settings.")
                                .font(.caption)
                            Spacer()
                        }
                        .padding(.vertical, 8).padding(.horizontal, 14)
                        .background(.ultraThinMaterial)
                        .overlay(Rectangle().fill(Theme.pink.opacity(0.4)).frame(height: 1), alignment: .bottom)
                        .foregroundStyle(Theme.pinkDeep)
                    }

                    Group {
                        if postsStore.posts.isEmpty && postsStore.isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                Text("Loading posts…").foregroundStyle(.secondary).font(.footnote)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if postsStore.posts.isEmpty {
                            ContentUnavailableView {
                                Label("No posts yet", systemImage: "sparkles")
                                    .foregroundStyle(Theme.pinkDeep)
                            } description: {
                                Text("Tap the Create tab to share your first post.")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 14) {
                                    ForEach(postsStore.posts) { post in
                                        NavigationLink(value: post) {
                                            PostRowView(post: post)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                            }
                            .refreshable { await postsStore.refresh() }
                        }
                    }
                }
            }
            .navigationTitle("Posts")
            .navigationDestination(for: APIPost.self) { post in
                PostDetailView(post: post)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await postsStore.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(Theme.pinkDeep)
                    }
                }
            }
            .task {
                if postsStore.posts.isEmpty { await postsStore.refresh() }
            }
        }
    }
}

struct PostRowView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var postsStore: PostsStore
    let post: APIPost

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                AvatarView(email: post.authorEmail, size: 38)
                VStack(alignment: .leading, spacing: 1) {
                    Text(post.authorEmail)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(post.createdAt, style: .relative)
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if post._id.hasPrefix("local-") {
                    Text("Pending")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Theme.pinkSoft, in: Capsule())
                        .foregroundStyle(Theme.pinkDeep)
                }
            }

            if !post.text.isEmpty {
                Text(post.text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let img = post.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 320)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.pink.opacity(0.2), lineWidth: 1))
            }

            HStack(spacing: 22) {
                Button {
                    Task {
                        if let email = userStore.currentUser?.email {
                            await postsStore.toggleLike(postID: post._id, by: email)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: (userStore.currentUser.map { post.isLiked(by: $0.email) } ?? false) ? "heart.fill" : "heart")
                            .foregroundStyle(Theme.pinkDeep)
                            .symbolEffect(.bounce, value: post.likeCount)
                        Text("\(post.likeCount)")
                            .foregroundStyle(.primary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Theme.pinkSoft, in: Capsule())
                }
                .buttonStyle(.plain)

                HStack(spacing: 6) {
                    Image(systemName: "bubble.right.fill")
                        .foregroundStyle(Theme.pinkDeep)
                    Text("\(post.commentCount)")
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Theme.pinkSoft, in: Capsule())

                Spacer()
            }
            .font(.subheadline.weight(.medium))
        }
        .tetherCard()
    }
}

struct PostDetailView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var postsStore: PostsStore
    let post: APIPost
    @State private var commentText: String = ""
    @FocusState private var commentFocused: Bool

    private var currentPost: APIPost {
        postsStore.posts.first(where: { $0._id == post._id }) ?? post
    }

    private var comments: [APIComment] {
        postsStore.commentsByPost[post._id] ?? []
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
                .onTapGesture { hideKeyboard() }

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        PostRowView(post: currentPost)

                        Text("Replies")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.pinkDeep)
                            .padding(.top, 4)

                        if comments.isEmpty {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right")
                                Text("Be the first to reply.")
                            }
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        } else {
                            VStack(spacing: 10) {
                                ForEach(comments) { c in
                                    CommentBubble(comment: c)
                                }
                            }
                        }
                    }
                    .padding(14)
                }
                .scrollDismissesKeyboard(.interactively)

                HStack(spacing: 8) {
                    AvatarView(email: userStore.currentUser?.email ?? "?", size: 30)
                    TextField("Write a reply…", text: $commentText, axis: .vertical)
                        .focused($commentFocused)
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.pink.opacity(0.25), lineWidth: 1))
                    Button {
                        Task { await sendComment() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .padding(10)
                            .background(Theme.buttonGradient, in: Circle())
                            .foregroundStyle(.white)
                            .shadow(color: Theme.pink.opacity(0.45), radius: 6, y: 3)
                    }
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                }
                .padding(12)
                .background(.ultraThinMaterial)
            }
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { hideKeyboard() }
                    .foregroundStyle(Theme.pinkDeep)
            }
        }
        .task { await postsStore.loadComments(for: post._id) }
    }

    private func sendComment() async {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let email = userStore.currentUser?.email else { return }
        commentText = ""
        commentFocused = false
        await postsStore.addComment(postID: post._id, authorEmail: email, text: trimmed)
    }
}

struct CommentBubble: View {
    let comment: APIComment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(email: comment.authorEmail, size: 32)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorEmail).font(.caption.weight(.semibold))
                    Spacer()
                    Text(comment.createdAt, style: .relative)
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Text(comment.text).font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.pink.opacity(0.18), lineWidth: 1))
        }
    }
}

#Preview {
    PostsView()
        .environmentObject(UserStore())
        .environmentObject(PostsStore())
}
