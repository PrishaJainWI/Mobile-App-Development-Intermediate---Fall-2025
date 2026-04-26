import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to Tether").font(.largeTitle).bold()

            VStack(alignment: .leading, spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }

            Button {
                do { try userStore.login(email: email, password: password) }
                catch { errorMessage = error.localizedDescription }
            } label: {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }

            Button { showSignUp = true } label: { Text("Create an account").frame(maxWidth: .infinity) }
            .sheet(isPresented: $showSignUp) { SignUpView().environmentObject(userStore) }
        }
        .padding()
    }
}

#Preview { LoginView().environmentObject(UserStore()) }
