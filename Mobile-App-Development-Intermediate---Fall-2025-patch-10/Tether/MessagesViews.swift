import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var userStore: UserStore
    @StateObject private var store = MessagesStore()
    @State private var showingNewThread = false
    @State private var participantEmail = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.threads) { thread in
                    NavigationLink(value: thread) {
                        VStack(alignment: .leading) {
                            Text(thread.participantEmails.filter { $0 != userStore.currentUser?.email }.joined(separator: ", "))
                                .font(.headline)
                            Text(thread.lastMessagePreview)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationDestination(for: ThreadSummary.self) { thread in
                ChatThreadView(thread: thread)
                    .environmentObject(store)
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNewThread = true } label: { Image(systemName: "square.and.pencil") }
                }
            }
            .sheet(isPresented: $showingNewThread) {
                NavigationStack {
                    Form {
                        Section("Start a conversation") {
                            TextField("Recipient email", text: $participantEmail)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                    }
                    .navigationTitle("New Message")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) { Button("Cancel") { showingNewThread = false } }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Start") {
                                guard let me = userStore.currentUser?.email else { return }
                                let emails = Array(Set([me, participantEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()])).filter { !$0.isEmpty }
                                guard emails.count >= 2 else { return }
                                let id = store.startThread(with: emails)
                                showingNewThread = false
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ChatThreadView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var store: MessagesStore

    let thread: ThreadSummary
    @State private var input: String = ""

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(store.messages(in: thread.id)) { msg in
                            HStack {
                                if msg.senderEmail != userStore.currentUser?.email { Spacer(minLength: 0) }
                                Text(msg.text)
                                    .padding(10)
                                    .background(msg.senderEmail == userStore.currentUser?.email ? Color.accentColor : Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(msg.senderEmail == userStore.currentUser?.email ? .white : .primary)
                                if msg.senderEmail == userStore.currentUser?.email { Spacer(minLength: 0) }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }

            HStack(spacing: 8) {
                TextField("Message", text: $input, axis: .vertical)
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                Button {
                    send()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .padding(10)
                        .background(Color.accentColor, in: Circle())
                        .foregroundStyle(.white)
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(thread.participantEmails.filter { $0 != userStore.currentUser?.email }.joined(separator: ", "))
    }

    private func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let me = userStore.currentUser?.email else { return }
        store.sendMessage(in: thread.id, from: me, text: trimmed)
        input = ""
    }
}

#Preview {
    MessagesView().environmentObject(UserStore())
}
