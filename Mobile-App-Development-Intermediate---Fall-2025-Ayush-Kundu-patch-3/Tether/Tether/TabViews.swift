//
//  TabViews.swift
//  Tether
//
//  Created by Ayush Kundu on 11/16/25.
//

import SwiftUI

struct TabViews: View {
    @State var username: String
    @State var email: String
    @State var password: String
    @State var fullName: String = ""
    @State var dateOfBirth: Date = Date()
    @State var bio: String = ""
    @State var gender: String = "Prefer not to say"
    @State var interests: String = ""
    @State private var selectedTab: Int = 1
    
    var body: some View {
        TabView ( selection : $selectedTab ) {
            
            Home(username: username)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)
           
            Settings(email: $email, password: $password, fullName: $fullName, username: $username, dateOfBirth: $dateOfBirth, bio: $bio, gender: $gender, interests: $interests)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    TabViews(
        username: "Ayush",
        email: "test@example.com",
        password: "password123",
        fullName: "Ayush Kundu",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -21, to: Date()) ?? Date(),
        bio: "iOS developer and coffee enthusiast",
        gender: "Male",
        interests: "Swift, Hiking, Photography"
    )
}
