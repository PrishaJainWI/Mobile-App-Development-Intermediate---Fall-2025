//
//  SignUp.swift
//  Tether
//
//  Created by Prisha J. on 10/24/25.
//




/*
 
 What you have to do:
 
 1.
 ABOVE CREATE ACCOUNT BUTTON

 allow user to write three words to describe them
 
 HOW: --> have three textboxes and store the word they write (similar to how we took the email) (DID ONE EXAMPLE FOR YOU STARTING FROM LINE #92)
 
 
 HOW TO CREATE A NEW FILE IF YOU NEED IT:
    1. right click on sign up file
    2. click new file from template
    3. click next
    4. name the file whatever you want
 */



import SwiftUI


struct SignUp: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var word1: String = ""
    @State private var word2: String = ""
    @State private var word3: String = ""
    
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
            
            VStack{
                Text("Sign Up")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                    .opacity(0.4)
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
                
                
                Text("Write three words which describe you")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                    .opacity(0.4)
                    .padding()
                
                TextField("type the first word here",text:$word1)
                    . font(.system(size: 20))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 30)
                    .frame(width: 300,height:50)
                    .background((Color.white.opacity(0.3)))
                    .cornerRadius(10)
                
                
                NavigationLink(destination: Home()){
                    Text("Create Account")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                        .opacity(0.4)
                        .padding()
                }
                
             
            
                
            }
                
        }
        .navigationTitle("Sign Up")


    }
}

#Preview {
    SignUp()
}


