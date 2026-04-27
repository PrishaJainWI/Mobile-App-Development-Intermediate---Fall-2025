//
//  Create.swift
//  Tether
//
//  Created by Ayush Kundu on 3/22/26.
//

import SwiftUI

struct Create: View {
    let username: String
    
    var body: some View {
    
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hi \(username)! 👋")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                        
                        Text("Welcome back to Tether")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
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
                    }
                }
            }
        }
                        
    }


#Preview {
    Create(username: "Ayush")
}
