
/*
 
 What I want you to do:
 
 1. add background
 2. un-hardcode everything --> add items (username + word 1/2/3) from signup to settings
 */



import SwiftUI


struct Settings: View {
    @Binding  var email: String
    @Binding  var password: String
    @State private var newPassword: String = ""
    @State private var oldPassword: String = ""
    @State private var confPassword: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        
        ZStack{
            GradientBackground()
            VStack{
                
                
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 90, height: 90)
                    .offset(x: -140, y: -120)
                
                TextField(email.isEmpty ? "Username" : email, text: $email)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.gray)
                    .offset(x: 150, y: -200)
                
                Button("Edit Profile") {
                    
                }
                .padding(10)
                .foregroundColor(Color.black)
                .font(.system(size: 14))
                .overlay(RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray, lineWidth: 2)
                         
                )
                .offset(x: -10, y: -350)
                
                simpleText(text: "New Password")
                    .offset(x: 0, y: -150)
                loginCred(img: "lock", writtenField: "New Password", text: $newPassword)
                    .offset(x: 0, y: -150)

                // Confirm Password
                simpleText(text: "Confirm Password")
                    .offset(x: 0, y: -150)
                loginCred(img: "lock", writtenField: "Confirm Password", text: $confPassword)
                    .offset(x: 0, y: -150)
                
                HStack{
                    Button("Change"){
                        if newPassword.isEmpty || confPassword.isEmpty {
                            alertMessage = "Please fill in both password fields."
                            showAlert = true
                            
                        }else if !checkPassword(pass1: newPassword, pass2: confPassword) {
                            alertMessage = "Passwords do not match."
                            showAlert = true
                        }else {
                            password = newPassword
                            alertMessage = "Password changed successfully!"
                            newPassword = ""
                            confPassword = ""
                        }
                    }
                    .padding()
                    .background(Color(red: 0.7, green: 0.8, blue: 0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 7, x: 0.0, y: 7.0)
                    .offset(x: 0, y: -120)
                    
                    Button("Cancel") {
                        newPassword = ""
                        confPassword = ""
                    }
                    .padding()
                    .background(Color(red: 0.7, green: 0.8, blue: 0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 7, x: 0.0, y: 7.0)
                    .offset(x: 0, y: -120)
              
                }
                
            }
            
            
        }  .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        
    }
   }



func checkPassword(pass1: String, pass2: String) -> Bool {
    return pass1 == pass2
}

func simpleText(text: String) -> some View {
    Text(text)
        .font(.title2)
        .foregroundColor(.white)
        .frame(width: 300, alignment: .leading)
}

   #Preview {
       @Previewable @State var password = ""
       @Previewable @State var username = "Profile 1"
       
      return Settings(email: $username, password: $password)

   }
