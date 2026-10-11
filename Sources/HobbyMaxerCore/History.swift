import Foundation

/// Where someone is with a suggested hobby.
public enum HobbyStatus: String, Codable, CaseIterable, Sendable {
    case interested, trying, notForMe

    public var label: String {
        switch self {
        case .interested: "Interested"
        case .trying: "Trying it"
        case .notForMe: "Not for me"
        }
    }
}

/// Everything saved between launches: the last answers, every quiz run, and progress on hobbies.
/// The website stores the same JSON shape in localStorage (website/history.js) — keep them in step.
public struct History: Codable, Equatable, Sendable {
    public struct Run: Codable, Equatable, Sendable {
        public var date: Date
        /// Answers as a ResultLink code ("2-…").
        public var code: String
        public var matches: [RunMatch]
    }

    public struct RunMatch: Codable, Equatable, Sendable {
        public var name: String
        public var percent: Int
    }

    /// One row of "My hobbies": everything known about a hobby across runs.
    public struct Summary: Identifiable, Equatable, Sendable {
        public var id: String { name }
        public let name: String
        public let timesSuggested: Int
        public let firstSeen: Date?
        public let lastSeen: Date?
        public let firstPercent: Int?
        public let latestPercent: Int?
        public let status: HobbyStatus?
        public let stepsDone: Int
    }

    public static let maxRuns = 200

    public var version = 1
    /// The most recent answers, so the quiz can start from them.
    public var lastCode: String?
    public var runs: [Run] = []
    public var statuses: [String: HobbyStatus] = [:]
    public var steps: [String: [Bool]] = [:]

    public init() {}

    public var lastProfile: Profile? { lastCode.flatMap(ResultLink.profile(fromCode:)) }

    /// Hobbies the person has ruled out; left out of future matches.
    public var notForMe: Set<String> { Set(statuses.filter { $0.value == .notForMe }.keys) }

    public mutating func record(_ profile: Profile, matches: [Match], at date: Date = Date()) {
        let code = ResultLink.code(for: profile)
        lastCode = code
        runs.append(Run(date: date, code: code, matches: matches.map { RunMatch(name: $0.hobby.name, percent: $0.percent) }))
        if runs.count > Self.maxRuns { runs.removeFirst(runs.count - Self.maxRuns) }
    }

    public mutating func setStatus(_ status: HobbyStatus?, for name: String) {
        statuses[name] = status
    }

    public func stepDone(_ index: Int, for name: String) -> Bool {
        steps[name].map { index < $0.count && $0[index] } ?? false
    }

    public mutating func toggleStep(_ index: Int, for name: String) {
        var done = steps[name] ?? [false, false, false]
        while done.count <= index { done.append(false) }
        done[index].toggle()
        steps[name] = done.contains(true) ? done : nil
        // Ticking off a step means you're trying it.
        if done.contains(true) && statuses[name] == nil { statuses[name] = .trying }
    }

    /// Every hobby ever suggested or marked, most recently seen first.
    public func summaries() -> [Summary] {
        var names = [String]()
        var seen = Set<String>()
        for run in runs.reversed() {
            for m in run.matches where seen.insert(m.name).inserted { names.append(m.name) }
        }
        for name in (Array(statuses.keys) + Array(steps.keys)).sorted() where seen.insert(name).inserted {
            names.append(name)
        }
        return names.map { name in
            let hits = runs.compactMap { run in run.matches.first { $0.name == name }.map { (run.date, $0.percent) } }
            return Summary(name: name, timesSuggested: hits.count, firstSeen: hits.first?.0, lastSeen: hits.last?.0,
                           firstPercent: hits.first?.1, latestPercent: hits.last?.1, status: statuses[name],
                           stepsDone: steps[name]?.filter { $0 }.count ?? 0)
        }
    }

    // MARK: Saving

    public static func load(from url: URL) -> History {
        guard let data = try? Data(contentsOf: url) else { return History() }
        return (try? decoder.decode(History.self, from: data)) ?? History()
    }

    public func save(to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Self.encoder.encode(self).write(to: url, options: .atomic)
    }

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
