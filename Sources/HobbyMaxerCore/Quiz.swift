import Foundation

/// Single-choice answers, stored as Ints on the profile.
public enum SingleKey: String, CaseIterable, Sendable {
    case setting, climate, company, schedule, budget, time, space, noise, mess, body, travel

    public var options: [String] {
        switch self {
        case .setting: Setting.allCases.map(\.label)
        case .climate: Climate.allCases.map(\.label)
        case .company: Company.allCases.map(\.label)
        case .schedule: Schedule.allCases.map(\.label)
        case .budget: Cost.allCases.map(\.label)
        case .time: TimeNeed.allCases.map(\.label)
        case .space: Space.allCases.map(\.label)
        case .noise: Noise.allCases.map(\.label)
        case .mess: Mess.allCases.map(\.label)
        case .body: Body.allCases.map(\.label)
        case .travel: Travel.allCases.map(\.label)
        }
    }
}

/// Multiple-choice answers, stored as sets on the profile.
public enum MultiKey: String, CaseIterable, Sendable {
    case goals, interests, community, nearby

    /// (id, label, emoji) in link-bitmask order.
    public var options: [(id: String, label: String, emoji: String)] {
        switch self {
        case .goals: Goal.allCases.map { ($0.rawValue, $0.label, $0.emoji) }
        case .interests, .community: Interest.allCases.map { ($0.rawValue, $0.label, $0.emoji) }
        case .nearby: Place.allCases.map { ($0.rawValue, $0.label, $0.emoji) }
        }
    }
}

public struct Question: Identifiable, Sendable {
    public enum Kind: Sendable {
        case scale(Trait, left: String, right: String)
        case single(SingleKey)
        /// max nil = pick as many as apply
        case multi(MultiKey, max: Int?)
    }

    public let id: Int
    public let section: String
    public let prompt: String
    public let hint: String
    public let kind: Kind
}

public enum Quiz {
    private static let dot = "Pick the dot closest to you."

    private static let list: [(String, String, String, Question.Kind)] = [
        // You
        ("You", "When you recharge, you'd rather be…", dot, .scale(.social, left: "On my own", right: "Around people")),
        ("You", "Where do you feel best?", dot, .scale(.outdoor, left: "Indoors", right: "Outside")),
        ("You", "How much do you want to move?", dot, .scale(.active, left: "Calm and still", right: "Moving and sweaty")),
        ("You", "What do you like to work with?", dot, .scale(.handsOn, left: "My head", right: "My hands")),
        ("You", "What feels more rewarding?", dot, .scale(.creative, left: "Mastering a skill", right: "Making or expressing something")),
        ("You", "How do you like to learn?", dot, .scale(.structured, left: "Freeform, no rules", right: "Clear steps and levels")),
        ("You", "How do you feel about competing?", dot, .scale(.competitive, left: "No pressure, please", right: "I love a good contest")),
        ("You", "How about a bit of risk?", dot, .scale(.thrill, left: "Keep it safe", right: "Bring on the adrenaline")),
        ("You", "Quick wins or a long game?", dot, .scale(.patience, left: "Quick wins", right: "Years to master")),
        ("You", "Screens in your hobby?", dot, .scale(.screens, left: "Get me off screens", right: "Screens are great")),
        ("You", "How do you pick things up best?", dot, .scale(.selfTaught, left: "With a teacher or class", right: "Teaching myself")),
        ("You", "What do you want out of a hobby?", "Pick up to 2.", .multi(.goals, max: 2)),
        ("You", "Which of these pull at you?", "Pick up to 3.", .multi(.interests, max: 3)),
        // Where you live
        ("Where you live", "Where do you live?", "Roughly — nothing leaves your device.", .single(.setting)),
        ("Where you live", "What's the weather like there?", "Pick the closest.", .single(.climate)),
        ("Where you live", "What's near you?", "Pick everything within easy reach.", .multi(.nearby, max: nil)),
        ("Where you live", "What's your community into?", "Friends, neighbors, local scene — pick up to 3.", .multi(.community, max: 3)),
        // Your life
        ("Your life", "Who would you do it with?", "Pick the closest.", .single(.company)),
        ("Your life", "When are you usually free?", "Pick the closest.", .single(.schedule)),
        ("Your life", "What can you spend to get started?", "Rough startup cost, not ongoing.", .single(.budget)),
        ("Your life", "How much time can you give it?", "Be honest — a hobby you keep beats one you drop.", .single(.time)),
        ("Your life", "How much space do you have at home?", "For gear and doing it at home.", .single(.space)),
        ("Your life", "Can you make noise at home?", "Think neighbors, roommates, kids asleep.", .single(.noise)),
        ("Your life", "How do you feel about mess at home?", "Clay, paint, sawdust, flour…", .single(.mess)),
        ("Your life", "Anything to go easy on physically?", "Totally optional — it just steers away from high-impact picks.", .single(.body)),
        ("Your life", "How often are you traveling or away?", "Some hobbies come with you; some don't.", .single(.travel)),
    ]

    public static let questions: [Question] = list.enumerated().map { i, q in
        Question(id: i, section: q.0, prompt: q.1, hint: q.2, kind: q.3)
    }
}

// MARK: Generic access, so the app UI and the website exporter can treat questions uniformly.

extension Profile {
    public subscript(single key: SingleKey) -> Int {
        get {
            switch key {
            case .setting: setting.rawValue
            case .climate: climate.rawValue
            case .company: company.rawValue
            case .schedule: schedule.rawValue
            case .budget: budget.rawValue
            case .time: time.rawValue
            case .space: space.rawValue
            case .noise: noise.rawValue
            case .mess: mess.rawValue
            case .body: body.rawValue
            case .travel: travel.rawValue
            }
        }
        set {
            switch key {
            case .setting: setting = Setting(rawValue: newValue) ?? setting
            case .climate: climate = Climate(rawValue: newValue) ?? climate
            case .company: company = Company(rawValue: newValue) ?? company
            case .schedule: schedule = Schedule(rawValue: newValue) ?? schedule
            case .budget: budget = Cost(rawValue: newValue) ?? budget
            case .time: time = TimeNeed(rawValue: newValue) ?? time
            case .space: space = Space(rawValue: newValue) ?? space
            case .noise: noise = Noise(rawValue: newValue) ?? noise
            case .mess: mess = Mess(rawValue: newValue) ?? mess
            case .body: body = Body(rawValue: newValue) ?? body
            case .travel: travel = Travel(rawValue: newValue) ?? travel
            }
        }
    }

    /// Selected option ids for a multiple-choice question.
    public subscript(multi key: MultiKey) -> Set<String> {
        get {
            switch key {
            case .goals: Set(goals.map(\.rawValue))
            case .interests: Set(interests.map(\.rawValue))
            case .community: Set(community.map(\.rawValue))
            case .nearby: Set(nearby.map(\.rawValue))
            }
        }
        set {
            switch key {
            case .goals: goals = Set(newValue.compactMap(Goal.init(rawValue:)))
            case .interests: interests = Set(newValue.compactMap(Interest.init(rawValue:)))
            case .community: community = Set(newValue.compactMap(Interest.init(rawValue:)))
            case .nearby: nearby = Set(newValue.compactMap(Place.init(rawValue:)))
            }
        }
    }
}
