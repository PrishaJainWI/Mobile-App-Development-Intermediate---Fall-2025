//
//  ContentView.swift
//  Tether
//
//  Created by local on 10/12/25.
//

//email, password, create account, new page that it leads to

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    var body: some View {

        NavigationStack {
            ZStack {
                GradientBackground()
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
                    .padding(.top, 560)
                    .rotationEffect(.degrees(-10))
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 550, height: 100)
                    .shadow(radius: 10)
                    .padding(.top, 560)
                    .rotationEffect(.degrees(-10))


                VStack {
                    Text("Welcome Back!")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                        .opacity(0.4)
                        .padding()

                    TextField("Email", text: $email)
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300, height: 50)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)
                    SecureField("Password", text: $password)
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300, height: 50)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)

                    NavigationLink(destination: Home()) {
                        Text("Login")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                            .opacity(0.4)
                            .padding()
                    }

                    NavigationLink(destination: SignUp()) {
                        Text("No account? Create one!")
                            .font(.system(size: 15, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                            .opacity(0.4)
                            .padding()
                    }

                }

            }
            .navigationTitle("")
        }

    }
}

#Preview {
    ContentView()
}
