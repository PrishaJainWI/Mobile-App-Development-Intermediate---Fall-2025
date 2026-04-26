import SwiftUI

@main
struct TetherApp: App {
    @StateObject private var userStore = UserStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userStore)
        }
    }
}
struct RootView: View {
    @EnvironmentObject var userStore: UserStore

    var body: some View {
        if userStore.currentUser != nil {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ChatView()
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }
            PostsView()
                .tabItem { Label("Posts", systemImage: "text.justify") }
            MessagesView()
                .tabItem { Label("Messages", systemImage: "envelope") }
        }
    }
}

