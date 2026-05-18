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
    @State private var fullName: String = ""
    @State private var username: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var bio: String = ""
    @State private var gender: String = "Prefer not to say"
    @State private var interests: String = ""
    
    var body: some View {
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
                .padding(.top, 660)
                .rotationEffect(.degrees(-10))
            Capsule()
                .fill(Color.white.opacity(0.5))
                .frame(width: 550, height: 100)
                .shadow(radius: 10)
                .padding(.top, 660)
                .rotationEffect(.degrees(-10))
            
            ScrollView {
                VStack(spacing: 14){
                    Text("Sign Up")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                        .opacity(0.4)
                        .padding()
                    
                    Divider().background(Color.white.opacity(0.3))
                        .padding(.horizontal, 24)
                    
                    Text("Account Details")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                    
                    TextField("Full Name", text: $fullName)
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300, height: 50)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)
                        .padding(.vertical, 2)

                    TextField("Username", text: $username)
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300, height: 50)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)
                        .padding(.vertical, 2)
                    
                    TextField("Email",text:$email)
                        . font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300,height:50)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)
                        .padding(.vertical, 2)
                    SecureField("Password",text:$password)
                        . font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300,height:50)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)
                        .padding(.vertical, 2)
                    
                    Text("Profile")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 6)
                        .padding(.horizontal, 30)

                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300, height: 50)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)
                        .padding(.vertical, 2)

                    Picker("Gender", selection: $gender) {
                        Text("Female").tag("Female")
                        Text("Male").tag("Male")
                        Text("Non-binary").tag("Non-binary")
                        Text("Prefer not to say").tag("Prefer not to say")
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 20))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 30)
                    .frame(width: 300, height: 50)
                    .background((Color.white.opacity(0.3)))
                    .cornerRadius(10)
                    .padding(.vertical, 2)

                    TextField("Bio", text: $bio, axis: .vertical)
                        .font(.system(size: 18))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300)
                        .lineLimit(3, reservesSpace: true)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)
                        .padding(.vertical, 2)

                    TextField("Interests (comma separated)", text: $interests)
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 30)
                        .frame(width: 300, height: 50)
                        .background((Color.white.opacity(0.3)))
                        .cornerRadius(10)
                        .padding(.vertical, 2)
                    
                    NavigationLink(destination: TabViews(
                        username: (username.isEmpty ? (email.isEmpty ? "User" : email.components(separatedBy: "@").first ?? "User") : username),
                        email: email,
                        password: password,
                        fullName: fullName,
                        dateOfBirth: dateOfBirth,
                        bio: bio,
                        gender: gender,
                        interests: interests
                    )
                    .navigationBarBackButtonHidden(true)){
                        Text("Create Account")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                            .opacity(0.4)
                            .padding()
                            .padding(.top, 8)
                    }
                    
                 
                    
                }
                .padding(.vertical)
            }
                
        }
        .navigationTitle("Sign Up")


    }
}

#Preview {
    SignUp()
}

