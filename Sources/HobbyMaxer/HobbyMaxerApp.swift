import AppKit
import HobbyMaxerCore
import SwiftUI

@main
struct HobbyMaxerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        Window("Hobby Maxer", id: "main") {
            ContentView()
                .environmentObject(model)
                .onOpenURL { model.open(link: $0.absoluteString) }
                .frame(minWidth: 860, minHeight: 620)
                .tint(.accent)
        }
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Result Link…") { model.isOpeningLink = true }
                    .keyboardShortcut("l")
                Button("Retake Quiz") { model.retake() }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Lets `swift run` show a normal windowed app even without a bundle.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

extension Color {
    static let accent = Color(red: 0.93, green: 0.42, blue: 0.30)
}

@MainActor
final class AppModel: ObservableObject {
    enum Stage { case welcome, quiz, results }

    @Published var stage: Stage = .welcome
    @Published var questionIndex = 0
    @Published var profile = Profile()
    @Published var dismissed: Set<String> = []
    @Published var selectedID: String?
    /// True when showing results opened from someone's link.
    @Published var shared = false
    @Published var isOpeningLink = false

    init() {
        // Developer hook for screenshots: HOBBY_MAXER_DEMO=quiz:<n> or HOBBY_MAXER_DEMO=results
        guard let demo = ProcessInfo.processInfo.environment["HOBBY_MAXER_DEMO"] else { return }
        profile.scales = [.social: 1, .outdoor: 3, .active: 1, .handsOn: 4, .creative: 3, .structured: 2]
        profile.goals = [.relax, .makeThings]
        profile.interests = [.nature, .food, .crafts]
        if demo == "results" {
            selectedID = matches.first?.id
            stage = .results
        } else if demo.hasPrefix("quiz:"), let n = Int(demo.dropFirst(5)), Quiz.questions.indices.contains(n) {
            questionIndex = n
            stage = .quiz
        }
    }

    var question: Question { Quiz.questions[questionIndex] }
    var isLastQuestion: Bool { questionIndex == Quiz.questions.count - 1 }
    var matches: [Match] { Matcher.rank(profile, excluding: dismissed) }
    /// Website link that reopens exactly these results.
    var shareURL: URL { ResultLink.url(for: profile, selected: selectedID, dismissed: dismissed) }

    func start() {
        questionIndex = 0
        stage = .quiz
    }

    func next() {
        if isLastQuestion {
            dismissed = []
            selectedID = matches.first?.id
            stage = .results
        } else {
            questionIndex += 1
        }
    }

    func back() {
        if questionIndex == 0 { stage = .welcome } else { questionIndex -= 1 }
    }

    func dismiss(_ id: String) {
        dismissed.insert(id)
        if selectedID == id { selectedID = matches.first?.id }
    }

    /// Opens a website link, a hobbymaxer:// link, or a pasted "?r=…" query. Returns false if it isn't a result link.
    @discardableResult
    func open(link: String) -> Bool {
        guard let opened = ResultLink.decode(link) else { return false }
        profile = opened.profile
        dismissed = opened.dismissed
        let current = matches
        selectedID = current.contains { $0.id == opened.selected } ? opened.selected : current.first?.id
        shared = true
        isOpeningLink = false
        stage = .results
        return true
    }

    func retake() {
        profile = Profile()
        dismissed = []
        selectedID = nil
        shared = false
        questionIndex = 0
        stage = .welcome
    }
}
