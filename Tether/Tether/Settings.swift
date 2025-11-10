//
//  Settings.swift
//  Tether
//
//  Created by Ayush Kundu on 11/2/25.
//

import SwiftUI

import SwiftUI


struct Settings: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack{
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 90, height: 90)
                .offset(x: -120, y: -260)
            
            TextField(email.isEmpty ? "Username" : email, text: $email)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.gray)
                .offset(x: 150, y: -350)
            
            Button("Edit Profile") {
                
            }
            .padding(10)
            .foregroundColor(Color.black)
            .font(.system(size: 14))
            .overlay(RoundedRectangle(cornerRadius: 30)
                .stroke(Color.gray, lineWidth: 2)
                     
            )
            .offset(x: -10, y: -350)
            
            
            Text("First name Last name")
                .font(.system(size:16, weight: .medium))
                .foregroundColor(Color.gray)
                .offset(x: -50, y: -325)
            
            LoginScreen (email: $email, password: $password)
                
        }
        
    }
    

}

#Preview {
    Settings()
}
