//
//  Post.swift
//  Tether
//
//  Created by Ayush Kundu on 12/6/25.
//

import SwiftUI

// Post model to match JSON structure
struct Post: Identifiable, Codable {
    let id: Int
    let username: String
    let caption: String
    let imageName: String
    let likes: Int
    let timeAgo: String
}

// Class to load posts from JSON
class PostData: ObservableObject {
    @Published var posts: [Post] = []
    
    init() {
        loadPosts()
    }
    
    func loadPosts() {
        guard let url = Bundle.main.url(forResource: "posts", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not load posts.json")
            return
        }
        
        let decoder = JSONDecoder()
        if let decodedPosts = try? decoder.decode([Post].self, from: data) {
            self.posts = decodedPosts
        }
    }
}

