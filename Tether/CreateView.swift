import SwiftUI
import PhotosUI
import UIKit

struct CreateView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var postsStore: PostsStore

    @State private var text: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var isPosting: Bool = false
    @State private var feedback: String?
    @State private var feedbackIsError: Bool = false
    @FocusState private var textFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Author row
                        HStack(spacing: 10) {
                            AvatarView(email: userStore.currentUser?.email ?? "?", size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(userStore.currentUser?.email ?? "")
                                    .font(.subheadline.weight(.semibold))
                                Text("Sharing to the feed")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .tetherCard()

                        // Composer
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What's on your mind?")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.pinkDeep)
                            TextEditor(text: $text)
                                .focused($textFocused)
                                .frame(minHeight: 130)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.pink.opacity(0.25), lineWidth: 1))
                                .overlay(alignment: .topLeading) {
                                    if text.isEmpty {
                                        Text("Say something kind…")
                                            .foregroundStyle(.secondary)
                                            .padding(14)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }
                        .tetherCard()

                        // Photo
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Photo").font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.pinkDeep)
                                Spacer()
                                if pickedImage != nil {
                                    Button(role: .destructive) {
                                        pickedImage = nil
                                        selectedItem = nil
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                            .font(.caption.weight(.semibold))
                                    }
                                }
                            }

                            if let img = pickedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 240)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.pink.opacity(0.25), lineWidth: 1))
                            } else {
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 34, weight: .semibold))
                                            .foregroundStyle(Theme.pinkDeep)
                                        Text("Tap to pick a photo")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(Theme.pinkDeep)
                                        Text("(optional)")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 160)
                                    .background(Theme.pinkSoft, in: RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(Theme.pink.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [6])))
                                }
                            }

                            if pickedImage != nil {
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    Label("Change photo", systemImage: "photo.stack")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Theme.pinkDeep)
                                }
                            }
                        }
                        .tetherCard()
                        .onChange(of: selectedItem) { _, newItem in
                            Task {
                                guard let newItem else { return }
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) {
                                    pickedImage = img
                                }
                            }
                        }

                        if let feedback {
                            Text(feedback)
                                .font(.footnote)
                                .foregroundStyle(feedbackIsError ? .red : Theme.pinkDeep)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background((feedbackIsError ? Color.red : Theme.pink).opacity(0.1),
                                            in: RoundedRectangle(cornerRadius: 12))
                        }

                        Button {
                            Task { await submit() }
                        } label: {
                            HStack {
                                if isPosting { ProgressView().tint(.white) }
                                else {
                                    Image(systemName: "paperplane.fill")
                                    Text("Share Post")
                                }
                            }
                        }
                        .buttonStyle(PrimaryPinkButtonStyle())
                        .disabled(isPosting || (text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pickedImage == nil))
                    }
                    .padding(14)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Create")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                        .foregroundStyle(Theme.pinkDeep)
                }
            }
        }
    }

    private func submit() async {
        guard let email = userStore.currentUser?.email else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        isPosting = true
        defer { isPosting = false }
        await postsStore.createPost(authorEmail: email, text: trimmed, image: pickedImage)
        if postsStore.lastError == nil {
            text = ""
            pickedImage = nil
            selectedItem = nil
            feedback = "Posted! 💖"
            feedbackIsError = false
        } else {
            feedback = postsStore.lastError
            feedbackIsError = true
        }
    }
}

#Preview {
    CreateView()
        .environmentObject(UserStore())
        .environmentObject(PostsStore())
}
