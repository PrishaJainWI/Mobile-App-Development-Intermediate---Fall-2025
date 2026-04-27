import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isWorking = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }

                ScrollView {
                    VStack(spacing: 22) {
                        ZStack {
                            Circle()
                                .fill(Theme.buttonGradient)
                                .frame(width: 78, height: 78)
                                .shadow(color: Theme.pink.opacity(0.4), radius: 14, y: 6)
                            Image(systemName: "sparkles")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 8)

                        Text("Join Tether")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.pinkDeep)

                        VStack(spacing: 14) {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .pinkField()

                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                                .pinkField()

                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .pinkField()
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                        }

                        Button {
                            Task { await doSignUp() }
                        } label: {
                            HStack {
                                if isWorking { ProgressView().tint(.white) }
                                else { Text("Sign Up") }
                            }
                        }
                        .buttonStyle(PrimaryPinkButtonStyle())
                        .disabled(isWorking)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.pinkDeep)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                        .foregroundStyle(Theme.pinkDeep)
                }
            }
        }
    }

    private func doSignUp() async {
        errorMessage = nil
        guard password == confirmPassword else { errorMessage = "Passwords do not match."; return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await userStore.signUp(email: email, password: password)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview { SignUpView().environmentObject(UserStore()) }
