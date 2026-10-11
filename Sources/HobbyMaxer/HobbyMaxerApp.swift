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
                Button("My Hobbies") { model.stage = .myHobbies }
                    .keyboardShortcut("y")
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
    enum Stage { case welcome, quiz, results, myHobbies }

    @Published var stage: Stage = .welcome
    @Published var questionIndex = 0
    @Published var profile = Profile()
    /// Hidden this session (and, when viewing someone's link, the hobbies they hid).
    @Published var dismissed: Set<String> = []
    @Published var selectedID: String?
    /// True when showing results opened from someone's link.
    @Published var shared = false
    @Published var isOpeningLink = false
    /// Saved between launches.
    @Published var history: History { didSet { save() } }

    /// ~/Library/Application Support/Hobby Maxer/history.json (HOBBY_MAXER_STORE overrides, for testing).
    static let storeURL: URL = {
        if let path = ProcessInfo.processInfo.environment["HOBBY_MAXER_STORE"] { return URL(fileURLWithPath: path) }
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Hobby Maxer/history.json")
    }()

    init() {
        history = History.load(from: Self.storeURL)
        if let last = history.lastProfile { profile = last }

        // Developer hook for screenshots: HOBBY_MAXER_DEMO=quiz:<n>, results or mine
        guard let demo = ProcessInfo.processInfo.environment["HOBBY_MAXER_DEMO"] else { return }
        profile.scales = [.social: 1, .outdoor: 3, .active: 1, .handsOn: 4, .creative: 3, .structured: 2,
                          .competitive: 0, .thrill: 1, .patience: 3, .screens: 0, .selfTaught: 3]
        profile.goals = [.relax, .makeThings]
        profile.interests = [.nature, .food, .crafts]
        profile.community = [.food, .crafts]
        profile.nearby = [.trailsParks, .makerspace, .studios]
        if demo == "results" {
            selectedID = matches.first?.id
            stage = .results
        } else if demo == "mine" {
            stage = .myHobbies
        } else if demo.hasPrefix("quiz:"), let n = Int(demo.dropFirst(5)), Quiz.questions.indices.contains(n) {
            questionIndex = n
            stage = .quiz
        }
    }

    var question: Question { Quiz.questions[questionIndex] }
    var isLastQuestion: Bool { questionIndex == Quiz.questions.count - 1 }
    /// Your own results leave out hobbies you've marked "Not for me"; someone else's shared results don't.
    var excluded: Set<String> { shared ? dismissed : dismissed.union(history.notForMe) }
    var matches: [Match] { Matcher.rank(profile, excluding: excluded) }
    /// Website link that reopens exactly these results.
    var shareURL: URL { ResultLink.url(for: profile, selected: selectedID, dismissed: dismissed) }

    /// Starts the quiz from your last answers (or blank the first time).
    func start() {
        profile = history.lastProfile ?? Profile()
        shared = false
        questionIndex = 0
        stage = .quiz
    }

    func next() {
        if isLastQuestion {
            dismissed = []
            shared = false
            history.record(profile, matches: matches)
            selectedID = matches.first?.id
            stage = .results
        } else {
            questionIndex += 1
        }
    }

    func back() {
        if questionIndex == 0 { stage = .welcome } else { questionIndex -= 1 }
    }

    /// "Not for me": hides it now and leaves it out of your future matches.
    func dismiss(_ id: String) {
        dismissed.insert(id)
        history.setStatus(.notForMe, for: id)
        if selectedID == id { selectedID = matches.first?.id }
    }

    func setStatus(_ status: HobbyStatus?, for name: String) {
        if status == .notForMe { dismiss(name) } else { history.setStatus(status, for: name) }
    }

    func toggleStep(_ index: Int, for name: String) { history.toggleStep(index, for: name) }

    func showLatest() {
        guard let last = history.lastProfile else { return start() }
        show(last)
    }

    func showRun(_ run: History.Run) {
        if let p = ResultLink.profile(fromCode: run.code) { show(p) }
    }

    private func show(_ p: Profile) {
        profile = p
        dismissed = []
        shared = false
        selectedID = matches.first?.id
        stage = .results
    }

    /// Opens a website link, a hobbymaxer:// link, or a pasted "?r=…" query. Returns false if it isn't a result link.
    @discardableResult
    func open(link: String) -> Bool {
        guard let opened = ResultLink.decode(link) else { return false }
        profile = opened.profile
        dismissed = opened.dismissed
        shared = true
        let current = matches
        selectedID = current.contains { $0.id == opened.selected } ? opened.selected : current.first?.id
        isOpeningLink = false
        stage = .results
        return true
    }

    func home() {
        shared = false
        stage = .welcome
    }

    func retake() { start() }

    private func save() {
        do { try history.save(to: Self.storeURL) } catch { NSLog("Hobby Maxer: couldn't save history: \(error)") }
    }
}
