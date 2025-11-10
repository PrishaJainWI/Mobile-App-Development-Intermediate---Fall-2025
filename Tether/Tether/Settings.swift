//
//  Settings.swift
//  Tether
//
//  Created by Ayush Kundu on 11/2/25.
//

import SwiftUI

import SwiftUI

struct Settings: View {
    var body: some View {
        Circle()
            .stroke(Color.gray, lineWidth: 2)
            .frame(width: 90, height: 90)
            .offset(x: -120, y: -280)
        
        Text("Username")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(Color.gray)
            .offset(x: 0, y: -370)
        
        Button("Edit Profile") {

        }
        .padding(10)
        .foregroundColor(Color.black)
        .font(.system(size: 14))
        .overlay(RoundedRectangle(cornerRadius: 30)
            .stroke(Color.gray, lineWidth: 2)
                 
        )
        .offset(x: -10, y: -370)
    }
}

#Preview {
    Settings()
}
