//
//  Reusable Items.swift
//  Tether
//
//  Created by Prisha J. on 10/24/25.
//

import SwiftUI

func GradientBackground() -> some View {
    LinearGradient(
        gradient: Gradient(colors: [Color.red.opacity(0.5), Color.pink.opacity(0.4)]),
    startPoint: .leading,
    endPoint: .trailing
    )
    .ignoresSafeArea()
}

struct CapsuleView:View{
    var body: some View{
       
            
    }

}

func loginCred(img: String, writtenField: String, text: Binding<String>) -> some View{
    HStack {
        Image(systemName: "person")
            .foregroundColor(.gray)
        if writtenField.lowercased().contains("password"){
            SecureField(writtenField, text: text)
                .autocapitalization(.none)
        }else {
            TextField(writtenField, text: text)
                .autocapitalization(.none)
                }
    }
    .padding()
    .background(Color.white.opacity(0.3))
    .cornerRadius(15)
    .padding(.horizontal, 50)
}
