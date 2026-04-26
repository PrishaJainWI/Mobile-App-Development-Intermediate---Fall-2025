//
//  ContentView.swift
//  Tether
//
//  Created by Prisha J. on 10/12/25.
//

/*
 What we need:
 - email
 - password
 */
import SwiftUI

struct LoginScreen: View {
    @Binding var email: String
    @Binding var password: String
    var body: some View {
        VStack{
            TextField("Email", text: $email)
                .bold(true)
                .padding(.leading,170)
                
      
            SecureField("Password", text: $password)
                .bold(true)
                .padding(.leading,170)
        }
    }
}



#Preview {
    LoginScreen(email: .constant("test"), password: .constant("123"))
}
