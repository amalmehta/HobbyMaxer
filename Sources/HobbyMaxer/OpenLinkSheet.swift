import AppKit
import HobbyMaxerCore
import SwiftUI

/// File ▸ Open Result Link… — paste a link someone shared from the website or the app.
struct OpenLinkSheet: View {
    @EnvironmentObject private var model: AppModel
    @State private var link = ""
    @State private var invalid = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Open Result Link").font(.title2.bold())
            Text("Paste a Hobby Maxer link someone shared with you.")
                .foregroundStyle(.secondary)
            TextField("https://amalmehta.github.io/HobbyMaxer/?r=…", text: $link)
                .textFieldStyle(.roundedBorder)
                .onSubmit(open)
                .onChange(of: link) { invalid = false }
            if invalid {
                Label("That isn't a Hobby Maxer result link.", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            }
            HStack {
                Spacer()
                Button("Cancel") { model.isOpeningLink = false }
                    .keyboardShortcut(.cancelAction)
                Button("Open", action: open)
                    .keyboardShortcut(.defaultAction)
                    .disabled(link.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 460)
        .onAppear {
            // Pre-fill from the clipboard when it already holds a result link.
            if let copied = NSPasteboard.general.string(forType: .string), ResultLink.decode(copied) != nil {
                link = copied
            }
        }
    }

    private func open() {
        if !model.open(link: link) { invalid = true }
    }
}
