import SwiftUI

struct PostsView: View {
    @EnvironmentObject var userStore: UserStore
    @StateObject private var postsStore = PostsStore()
    @State private var showingComposer = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(postsStore.posts) { post in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(post.authorEmail)
                                .font(.subheadline).foregroundStyle(.secondary)
                            Spacer()
                            Text(post.createdAt, style: .date)
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Text(post.text)
                            .font(.body)
                        HStack(spacing: 16) {
                            Button {
                                if let email = userStore.currentUser?.email {
                                    postsStore.toggleLike(postID: post.id, by: email)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: (userStore.currentUser.map { post.isLiked(by: $0.email) } ?? false) ? "heart.fill" : "heart")
                                        .foregroundStyle(.red)
                                    Text("\(post.likeCount)")
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Posts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingComposer = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingComposer) {
                NewPostView { text in
                    if let email = userStore.currentUser?.email { postsStore.createPost(authorEmail: email, text: text) }
                }
            }
        }
    }
}

struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    var onPost: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $text)
                    .frame(minHeight: 180)
                    .padding(8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                Spacer()
            }
            .padding()
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onPost(trimmed)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    PostsView().environmentObject(UserStore())
}
