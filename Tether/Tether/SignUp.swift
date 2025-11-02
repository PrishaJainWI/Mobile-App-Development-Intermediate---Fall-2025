//
//  SignUp.swift
//  Tether
//
//  Created by Prisha J. on 10/24/25.
//

import SwiftUI


struct SignUp: View {
    @State private var email: String = ""
    @State private var password: String = ""
    var body: some View {
        
        NavigationStack{
        ZStack {
            Gradient()
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: 550, height: 100)
                .shadow(radius: 10)
                .padding(.bottom, 660)
                .rotationEffect(.degrees(10))
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: 550, height: 100)
                .shadow(radius: 10)
                .padding(.bottom, 660)
                .rotationEffect(.degrees(10))

            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: 550, height: 100)
                .shadow(radius: 10)
                .padding(.top, 660)
                .rotationEffect(.degrees(-10))
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: 550, height: 100)
                .shadow(radius: 10)
                .padding(.top, 660)
                .rotationEffect(.degrees(-10))
            
            VStack{
                Text("Sign Up")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.93, green: 1.0, blue: 0.75))
                    .padding()
                
                TextField("Email",text:$email)
                    . font(.system(size: 20))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 30)
                    .frame(width: 300,height:50)
                    .background((Color.white.opacity(0.3)))
                    .cornerRadius(10)
                SecureField("Password",text:$password)
                    . font(.system(size: 20))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 30)
                    .frame(width: 300,height:50)
                    .background((Color.white.opacity(0.3)))
                    .cornerRadius(10)
                
                NavigationLink(destination: ContentView()){
                    Text("Create Account")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.93, green: 1.0, blue: 0.75))
                        .padding()
                }
                
             
            
                
            }
                
            }
         
        }.navigationTitle(Text("Sign Up"))


    }
}

#Preview {
    ContentView()
}

