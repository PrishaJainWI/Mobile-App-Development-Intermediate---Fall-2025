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
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header matching Home
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Settings")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.93, green: 0.2, blue: 0.45))
                        Text("Manage your account")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(red: 0.93, green: 0.2, blue: 0.45), .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 45, height: 45)
                        .overlay(
                            Text(username.prefix(1).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 15)
                .background(Color.white)

                Divider()

                ScrollView {
                    VStack(spacing: 16) {
                        // Profile Header card
                        HStack(alignment: .center, spacing: 16) {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [Color.pink, Color.purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(username.prefix(1).uppercased())
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Full Name", text: $fullName)
                                    .font(.system(size: 18, weight: .semibold))
                                TextField("@username", text: $username)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("Email", text: $email)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // Details sections
                        sectionLabel("Personal Info")

                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Date of Birth")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Gender")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                Picker("Gender", selection: $gender) {
                                    Text("Female").tag("Female")
                                    Text("Male").tag("Male")
                                    Text("Non-binary").tag("Non-binary")
                                    Text("Prefer not to say").tag("Prefer not to say")
                                }
                                .pickerStyle(.menu)
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Bio")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                TextField("Tell people about yourself", text: $bio, axis: .vertical)
                                    .lineLimit(3, reservesSpace: true)
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Interests")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                TextField("Comma separated interests", text: $interests)
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        sectionLabel("Security")

                        VStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("New Password")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                SecureField("New Password", text: $newPassword)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                SecureField("Confirm Password", text: $confPassword)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }

                            HStack {
                                Button("Change") {
                                    if newPassword.isEmpty || confPassword.isEmpty {
                                        alertMessage = "Please fill in both password fields."
                                        showAlert = true
                                    } else if !checkPassword(pass1: newPassword, pass2: confPassword) {
                                        alertMessage = "Passwords do not match."
                                        showAlert = true
                                    } else {
                                        password = newPassword
                                        alertMessage = "Password changed successfully!"
                                        newPassword = ""
                                        confPassword = ""
                                    }
                                }
                                .font(.system(size: 16, weight: .bold))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.93, green: 0.2, blue: 0.45))
                                .foregroundColor(.white)
                                .cornerRadius(12)

                                Button("Cancel") {
                                    newPassword = ""
                                    confPassword = ""
                                }
                                .font(.system(size: 16, weight: .bold))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 12)
                }
            }
        }
        .alert("Notice", isPresented: $showAlert) {
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

private func sectionLabel(_ text: String) -> some View {
    Text(text)
        .font(.headline)
        .foregroundColor(.gray)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
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

