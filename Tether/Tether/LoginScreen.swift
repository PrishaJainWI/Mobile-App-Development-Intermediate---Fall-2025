//
//  ContentView.swift
//  Tether
//
//  Created by local on 10/12/25.
//

/*
 What we need:
 - email
 - password
 */
import SwiftUI

struct ContentView: View {
    @State var email: String = ""
    @State var password: String = ""
    var body: some View {
        VStack{
            TextField("Email", text: $email)
                .bold(true)
                .padding(.leading,170)
                
               
            TextField("Password", text: $password)
                .bold(true)
                .padding(.leading,170)
        }
    }
}



#Preview {
    ContentView()
}
