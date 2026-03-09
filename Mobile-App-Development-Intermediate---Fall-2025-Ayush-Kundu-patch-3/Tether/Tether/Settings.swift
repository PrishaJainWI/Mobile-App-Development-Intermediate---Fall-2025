/*
 
 What I want you to do:
 
 1. add background
 2. un-hardcode everything --> add items (username + word 1/2/3) from signup to settings
 */



import SwiftUI


struct Settings: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var fullName: String
    @Binding var username: String
    @Binding var dateOfBirth: Date
    @Binding var bio: String
    @Binding var gender: String
    @Binding var interests: String
    @State private var newPassword: String = ""
    @State private var confPassword: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        
        ZStack{
            GradientBackground()
            VStack(spacing: 16){
                
                // Profile Header
                HStack(alignment: .center, spacing: 16) {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text(username.prefix(1).uppercased())
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.gray)
                        )
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Full Name", text: $fullName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.white)
                        TextField("@username", text: $username)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.white.opacity(0.9))
                        TextField("Email", text: $email)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                Divider().background(Color.white.opacity(0.2))
                    .padding(.horizontal)
                
                // User Details
                Group {
                    simpleText(text: "Date of Birth")
                    DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 4)

                    simpleText(text: "Gender")
                    Picker("Gender", selection: $gender) {
                        Text("Female").tag("Female")
                        Text("Male").tag("Male")
                        Text("Non-binary").tag("Non-binary")
                        Text("Prefer not to say").tag("Prefer not to say")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                    simpleText(text: "Bio")
                    TextField("Tell people about yourself", text: $bio, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 4)

                    simpleText(text: "Interests")
                    TextField("Comma separated interests", text: $interests)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }
                .padding(.top, 8)
                
                Text("Security")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                simpleText(text: "New Password")
                loginCred(img: "lock", writtenField: "New Password", text: $newPassword)
                    .padding(.top, 6)

                // Confirm Password
                simpleText(text: "Confirm Password")
                loginCred(img: "lock", writtenField: "Confirm Password", text: $confPassword)
                
                HStack{
                    Button("Change"){
                        if newPassword.isEmpty || confPassword.isEmpty {
                            alertMessage = "Please fill in both password fields."
                            showAlert = true
                            
                        }else if !checkPassword(pass1: newPassword, pass2: confPassword) {
                            alertMessage = "Passwords do not match."
                            showAlert = true
                        } else {
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
                    
                    Button("Cancel") {
                        newPassword = ""
                        confPassword = ""
                    }
                    .padding()
                    .background(Color(red: 0.7, green: 0.8, blue: 0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 7, x: 0.0, y: 7.0)
              
                }
                .padding(.top, 8)
                
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
       @Previewable @State var email = "test@example.com"
       @Previewable @State var password = "password123"
       @Previewable @State var fullName = "Profile 1"
       @Previewable @State var username = "profile1"
       @Previewable @State var dateOfBirth = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
       @Previewable @State var bio = "I love Swift and design."
       @Previewable @State var gender = "Prefer not to say"
       @Previewable @State var interests = "Swift, UI, Music"
       return Settings(email: $email, password: $password, fullName: $fullName, username: $username, dateOfBirth: $dateOfBirth, bio: $bio, gender: $gender, interests: $interests)
   }

