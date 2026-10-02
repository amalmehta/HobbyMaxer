import AppKit
import SwiftUI

/// Small "Feedback" tab in the corner; sending opens a pre-filled email.
struct FeedbackTab: View {
    static let address = "amal.mehta@gmail.com"

    @State private var isOpen = false
    @State private var message = ""

    var body: some View {
        Button { isOpen = true } label: {
            Label("Feedback", systemImage: "bubble.left")
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(.regularMaterial))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .padding(12)
        .help("Send feedback about Hobby Maxer")
        .sheet(isPresented: $isOpen) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Send Feedback").font(.title2.bold())
                Text("What worked, what didn't, what hobby was missing?")
                    .foregroundStyle(.secondary)
                TextEditor(text: $message)
                    .font(.body)
                    .frame(height: 140)
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.quaternary))
                HStack {
                    Spacer()
                    Button("Cancel") { isOpen = false }
                        .keyboardShortcut(.cancelAction)
                    Button("Send") {
                        send()
                        isOpen = false
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(20)
            .frame(width: 420)
        }
    }

    private func send() {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = Self.address
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Hobby Maxer feedback"),
            URLQueryItem(name: "body", value: message),
        ]
        if let url = components.url { NSWorkspace.shared.open(url) }
        message = ""
    }
}
