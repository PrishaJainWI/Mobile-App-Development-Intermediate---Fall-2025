//
//  TabViews.swift
//  Tether
//
//  Created by Ayush Kundu on 11/16/25.
//

import SwiftUI

struct TabViews: View {
    let username: String
    @State private var selectedTab: Int = 1
    
    var body: some View {
        TabView ( selection : $selectedTab ) {
            
            Home(username: username)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)
           
            Settings()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    TabViews(username: "Ayush")
}
