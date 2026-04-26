import Foundation

struct Message: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var threadID: UUID
    var senderEmail: String
    var text: String
    var sentAt: Date = Date()
}

struct ThreadSummary: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var participantEmails: [String] // includes current user and others
    var lastMessagePreview: String = ""
    var lastUpdated: Date = Date()
}

@MainActor
final class MessagesStore: ObservableObject {
    @Published private(set) var threads: [ThreadSummary] = []
    @Published private(set) var messages: [Message] = []

    private let threadsFile = "threads.json"
    private let messagesFile = "messages.json"

    init() {
        Task { await loadAll() }
    }

    private func docsURL() -> URL? {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print("MessagesStore: docs error: \(error)")
            return nil
        }
    }

    private func loadAll() async {
        await loadThreads()
        await loadMessages()
    }

    func loadThreads() async {
        guard let docs = docsURL() else { return }
        let url = docs.appendingPathComponent(threadsFile)
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([ThreadSummary].self, from: data)
            self.threads = decoded.sorted { $0.lastUpdated > $1.lastUpdated }
        } catch {
            self.threads = []
        }
    }

    func loadMessages() async {
        guard let docs = docsURL() else { return }
        let url = docs.appendingPathComponent(messagesFile)
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Message].self, from: data)
            self.messages = decoded.sorted { $0.sentAt < $1.sentAt }
        } catch {
            self.messages = []
        }
    }

    private func saveThreads() {
        guard let docs = docsURL() else { return }
        let url = docs.appendingPathComponent(threadsFile)
        do {
            let data = try JSONEncoder().encode(threads)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("MessagesStore: save threads error: \(error)")
        }
    }

    private func saveMessages() {
        guard let docs = docsURL() else { return }
        let url = docs.appendingPathComponent(messagesFile)
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("MessagesStore: save messages error: \(error)")
        }
    }

    func startThread(with participants: [String]) -> UUID {
        let thread = ThreadSummary(participantEmails: participants)
        threads.insert(thread, at: 0)
        saveThreads()
        return thread.id
    }

    func sendMessage(in threadID: UUID, from senderEmail: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let msg = Message(threadID: threadID, senderEmail: senderEmail, text: trimmed)
        messages.append(msg)
        if let idx = threads.firstIndex(where: { $0.id == threadID }) {
            threads[idx].lastMessagePreview = trimmed
            threads[idx].lastUpdated = Date()
            threads.sort { $0.lastUpdated > $1.lastUpdated }
        }
        saveMessages()
        saveThreads()
    }

    func messages(in threadID: UUID) -> [Message] {
        messages.filter { $0.threadID == threadID }.sorted { $0.sentAt < $1.sentAt }
    }
}
