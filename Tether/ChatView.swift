import SwiftUI

struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let isUser: Bool
    let text: String

    init(id: UUID = UUID(), isUser: Bool, text: String) {
        self.id = id
        self.isUser = isUser
        self.text = text
    }
}

struct ChatView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var messages: [ChatMessage] = [
        ChatMessage(isUser: false, text: "Hi! I'm your Tether assistant. How can I help today?")
    ]
    @State private var input: String = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }

                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { msg in
                                    bubble(for: msg).id(msg.id)
                                }
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 12)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .onChange(of: messages.count) { _, _ in
                            if let last = messages.last?.id {
                                withAnimation(.spring) { proxy.scrollTo(last, anchor: .bottom) }
                            }
                        }
                    }

                    HStack(spacing: 8) {
                        TextField("Message", text: $input, axis: .vertical)
                            .focused($inputFocused)
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.pink.opacity(0.25), lineWidth: 1))

                        Button { send() } label: {
                            Image(systemName: "paperplane.fill")
                                .padding(12)
                                .background(Theme.buttonGradient, in: Circle())
                                .foregroundStyle(.white)
                                .shadow(color: Theme.pink.opacity(0.45), radius: 6, y: 3)
                        }
                        .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Chat")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                        .foregroundStyle(Theme.pinkDeep)
                }
            }
        }
    }

    @ViewBuilder
    private func bubble(for msg: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if msg.isUser { Spacer(minLength: 40) }
            else {
                ZStack {
                    Circle().fill(Theme.pinkDeep)
                    Image(systemName: "face.smiling.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 30, height: 30)
            }

            Text(msg.text)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(
                    msg.isUser ? AnyShapeStyle(Theme.buttonGradient) : AnyShapeStyle(Color.white.opacity(0.85)),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .foregroundStyle(msg.isUser ? .white : .primary)
                .shadow(color: Theme.pink.opacity(msg.isUser ? 0.30 : 0.10), radius: 6, y: 2)
                .frame(maxWidth: 280, alignment: msg.isUser ? .trailing : .leading)

            if !msg.isUser { Spacer(minLength: 40) }
            else { AvatarView(email: userStore.currentUser?.email ?? "?", size: 30) }
        }
    }

    private func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(ChatMessage(isUser: true, text: trimmed))
        input = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let response: String
            let lower = trimmed.lowercased()
            if lower.contains("help") {
                response = "Sure — tell me what you're trying to do, and I'll walk you through it."
            } else if lower.contains("joke") {
                response = "Here's one: Why do Swift developers prefer structs? Because they value value!"
            } else if lower.contains("hi") || lower.contains("hello") {
                response = "Hey there! 💖 What are you up to today?"
            } else {
                response = "You said: \"\(trimmed)\". I'm here to assist — ask me anything!"
            }
            messages.append(ChatMessage(isUser: false, text: response))
        }
    }
}

#Preview { ChatView().environmentObject(UserStore()) }
