import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isWorking = false
    @State private var showSignUp = false
    @State private var showServerConfig = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
                .onTapGesture { hideKeyboard() }

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 24)

                    // Logo
                    ZStack {
                        Circle()
                            .fill(Theme.buttonGradient)
                            .frame(width: 96, height: 96)
                            .shadow(color: Theme.pink.opacity(0.45), radius: 18, y: 8)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 6) {
                        Text("Tether")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.pinkDeep)
                        Text("Share moments with the people you love.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 14) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .pinkField()

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .pinkField()
                    }
                    .padding(.horizontal, 4)

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        Task { await doLogin() }
                    } label: {
                        HStack {
                            if isWorking { ProgressView().tint(.white) }
                            else { Text("Log In") }
                        }
                    }
                    .buttonStyle(PrimaryPinkButtonStyle())
                    .disabled(isWorking)

                    HStack(spacing: 4) {
                        Text("New here?").foregroundStyle(.secondary)
                        Button("Create an account") { showSignUp = true }
                            .foregroundStyle(Theme.pinkDeep)
                            .fontWeight(.semibold)
                    }
                    .font(.footnote)
                    .sheet(isPresented: $showSignUp) { SignUpView().environmentObject(userStore) }

                    Button {
                        showServerConfig = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "server.rack")
                            Text("Server settings")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .sheet(isPresented: $showServerConfig) { ServerConfigView() }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { hideKeyboard() }.foregroundStyle(Theme.pinkDeep)
            }
        }
    }

    private func doLogin() async {
        errorMessage = nil
        isWorking = true
        defer { isWorking = false }
        do {
            try await userStore.login(email: email, password: password)
        } catch {
            errorMessage = "\(error.localizedDescription)\nServer: \(APIService.shared.baseURL.absoluteString)"
        }
    }
}

struct ServerConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var serverURL: String = APIService.shared.baseURL.absoluteString
    @State private var saved: Bool = false
    @State private var probeResult: String?
    @State private var probing: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("API base URL") {
                    TextField("http://192.168.x.x:4000", text: $serverURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    Text("Simulator: http://localhost:4000\nPhysical iPhone on same Wi-Fi: http://<your-mac-LAN-IP>:4000")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        if let url = URL(string: serverURL) {
                            APIService.shared.baseURL = url
                            saved = true
                        }
                    } label: {
                        Label("Save", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Theme.pinkDeep)
                    }
                    Button {
                        Task { await probe() }
                    } label: {
                        HStack {
                            if probing { ProgressView() }
                            Label("Test connection", systemImage: "wifi")
                                .foregroundStyle(Theme.pinkDeep)
                        }
                    }
                    .disabled(probing)
                    if let probeResult { Text(probeResult).font(.caption) }
                    if saved && probeResult == nil {
                        Text("Saved.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient)
            .navigationTitle("Server Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(Theme.pinkDeep)
                }
            }
        }
    }

    private func probe() async {
        probing = true
        defer { probing = false }
        guard let base = URL(string: serverURL),
              let url = URL(string: "/health", relativeTo: base) else {
            probeResult = "Invalid URL."
            return
        }
        APIService.shared.baseURL = base
        saved = true
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                probeResult = "✅ Server reachable."
            } else {
                probeResult = "⚠️ Server returned non-200."
            }
        } catch {
            probeResult = "❌ \(error.localizedDescription)"
        }
    }
}

#Preview { LoginView().environmentObject(UserStore()) }
