
/*
 
 What I want you to do:
 
 1. add background
 2. un-hardcode everything --> add items (username + word 1/2/3) from signup to settings
 */



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
            
            
        
            
            LoginScreen (email: $email, password: $password)
            
        }
        
        
       }
       

   }

   #Preview {
       Settings()
   }
