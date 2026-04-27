import SwiftUI
import UIKit

@main
struct TetherApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var postsStore = PostsStore()

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userStore)
                .environmentObject(postsStore)
                .tint(Theme.pinkDeep)
        }
    }

    private func configureAppearance() {
        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.backgroundColor = UIColor.clear
        nav.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.pinkDeep),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        nav.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Theme.pinkDeep),
            .font: UIFont.systemFont(ofSize: 34, weight: .heavy)
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        let tab = UITabBarAppearance()
        tab.configureWithDefaultBackground()
        tab.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
        let pink = UIColor(Theme.pinkDeep)
        tab.stackedLayoutAppearance.selected.iconColor = pink
        tab.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: pink]
        tab.inlineLayoutAppearance.selected.iconColor = pink
        tab.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: pink]
        tab.compactInlineLayoutAppearance.selected.iconColor = pink
        tab.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: pink]
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
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
    @EnvironmentObject var postsStore: PostsStore

    var body: some View {
        TabView {
            PostsView()
                .tabItem { Label("Posts", systemImage: "rectangle.stack.fill") }
            CreateView()
                .tabItem { Label("Create", systemImage: "plus.circle.fill") }
            ChatView()
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .task {
            if postsStore.posts.isEmpty { await postsStore.refresh() }
        }
    }
}
