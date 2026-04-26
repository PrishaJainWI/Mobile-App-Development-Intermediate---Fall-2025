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
    @State private var messages: [ChatMessage] = [ChatMessage(isUser: false, text: "Hi! I’m your AI assistant. How can I help?")]
    @State private var input: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { msg in
                                HStack {
                                    if msg.isUser { Spacer() }
                                    Text(msg.text)
                                        .padding(12)
                                        .background(msg.isUser ? Color.accentColor : Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
                                        .foregroundStyle(msg.isUser ? .white : .primary)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: msg.isUser ? .trailing : .leading)
                                    if !msg.isUser { Spacer() }
                                }
                                .id(msg.id)
                            }
                        }
                        .padding(.vertical)
                    }
                }

                HStack(spacing: 8) {
                    TextField("Message", text: $input, axis: .vertical)
                        .padding(10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    Button { send() } label: {
                        Image(systemName: "paperplane.fill")
                            .padding(10)
                            .background(Color.accentColor, in: Circle())
                            .foregroundStyle(.white)
                    }
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .navigationTitle("Chat")
        }
    }

    private func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(ChatMessage(isUser: true, text: trimmed))
        input = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let response: String
            if trimmed.lowercased().contains("help") {
                response = "Sure — tell me what you’re trying to do, and I’ll walk you through it."
            } else if trimmed.lowercased().contains("joke") {
                response = "Here’s one: Why do Swift developers prefer structs? Because they value value!"
            } else {
                response = "You said: \"\(trimmed)\". I’m here to assist — ask me anything!"
            }
            messages.append(ChatMessage(isUser: false, text: response))
        }
    }
}

#Preview { ChatView().environmentObject(UserStore()) }
