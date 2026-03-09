//
//  Home.swift
//  Tether
//
//  Created by local on 10/24/25.
//

import SwiftUI

struct Home: View {
    let username: String
    @StateObject private var postData = PostData()
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with greeting
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hi \(username)! 👋")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                        
                        Text("Welcome back to Tether")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Profile icon
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.93, green: 0.2, blue: 0.45), Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 45, height: 45)
                        .overlay(
                            Text(username.prefix(1).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 15)
                .background(Color.white)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search posts...", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                Divider()
                
                // Feed with posts
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(postData.posts) { post in
                            PostCardView(post: post)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Post Card View Component
struct PostCardView: View {
    let post: Post
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // User info header
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.pink, Color.purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(post.username.prefix(1))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.system(size: 15, weight: .semibold))
                    Text(post.timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            // Image placeholder with gradient
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.93, green: 0.2, blue: 0.45).opacity(0.3),
                        Color.pink.opacity(0.2),
                        Color.purple.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.7))
                    Text(post.imageName.capitalized)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 400)
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: {
                    isLiked.toggle()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundColor(isLiked ? .red : .black)
                }
                
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 23))
                        .foregroundColor(.black)
                }
                
                Button(action: {}) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 23))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 23))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            // Likes count
            Text("\(isLiked ? post.likes + 1 : post.likes) likes")
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal)
                .padding(.bottom, 5)
            
            // Caption
            HStack(alignment: .top, spacing: 5) {
                Text(post.username)
                    .font(.system(size: 14, weight: .semibold))
                Text(post.caption)
                    .font(.system(size: 14))
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            Divider()
                .padding(.top, 5)
        }
    }
}

#Preview {
    Home(username: "Ayush")
}
