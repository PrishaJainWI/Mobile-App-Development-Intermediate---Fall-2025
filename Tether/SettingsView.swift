import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var postsStore: PostsStore
    @State private var serverURL: String = APIService.shared.baseURL.absoluteString
    @State private var serverSaved: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }

                ScrollView {
                    VStack(spacing: 16) {
                        // Profile header
                        VStack(spacing: 12) {
                            AvatarView(email: userStore.currentUser?.email ?? "?", size: 86)
                            Text(userStore.currentUser?.email ?? "")
                                .font(.headline)
                            if postsStore.isOffline {
                                HStack(spacing: 6) {
                                    Image(systemName: "wifi.slash")
                                    Text("Offline mode")
                                }
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Theme.pinkSoft, in: Capsule())
                                .foregroundStyle(Theme.pinkDeep)
                            } else {
                                HStack(spacing: 6) {
                                    Circle().fill(.green).frame(width: 8, height: 8)
                                    Text("Connected")
                                }
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(.green.opacity(0.12), in: Capsule())
                                .foregroundStyle(.green)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .tetherCard()

                        // Server card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "server.rack")
                                    .foregroundStyle(Theme.pinkDeep)
                                Text("Server").font(.subheadline.weight(.semibold))
                            }
                            TextField("API base URL", text: $serverURL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                                .pinkField()
                            HStack {
                                Button {
                                    if let url = URL(string: serverURL) {
                                        APIService.shared.baseURL = url
                                        serverSaved = true
                                    }
                                } label: {
                                    Label("Save", systemImage: "checkmark.circle.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Theme.pinkDeep)
                                }
                                if serverSaved {
                                    Text("Saved.").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .tetherCard()

                        // Account card
                        VStack(spacing: 0) {
                            Button(role: .destructive) {
                                userStore.logout()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Log out").fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .foregroundStyle(.red)
                        }
                        .tetherCard()

                    }
                    .padding(14)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                        .foregroundStyle(Theme.pinkDeep)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserStore())
        .environmentObject(PostsStore())
}
