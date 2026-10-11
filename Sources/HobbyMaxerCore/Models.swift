import Foundation

/// The dimensions every hobby and every person is placed on, from 0 to 1. Order matters:
/// it's the order of the scale digits in result links, so new traits go at the end.
public enum Trait: String, CaseIterable, Sendable {
    case social, outdoor, active, handsOn, creative, structured
    /// No pressure ↔ head-to-head competition
    case competitive
    /// Safe and steady ↔ adrenaline
    case thrill
    /// Quick wins ↔ years of mastery
    case patience
    /// Screen-free ↔ screen-based
    case screens
    /// Learned with a teacher or class ↔ easy to teach yourself
    case selfTaught
}

public struct Traits: Sendable, Equatable {
    public var values: [Double]

    /// Values in `Trait.allCases` order.
    public init(_ values: [Double]) {
        precondition(values.count == Trait.allCases.count, "need one value per trait")
        self.values = values
    }

    public subscript(_ trait: Trait) -> Double { values[Trait.allCases.firstIndex(of: trait)!] }
}

/// Practical facts about a hobby that the quiz can rule in or out.
public enum Tag: String, CaseIterable, Sendable {
    /// Noisy to do at home (drums, power tools, DJing)
    case loud
    /// Paint, clay, sawdust, flour…
    case messy
    /// Hard on joints: running, jumping, falls, contact
    case highImpact
    /// Happens at fixed times: classes, leagues, rehearsals
    case scheduled
    /// Easy to take with you when traveling
    case portable
    /// Works well with kids along
    case familyFriendly
    /// Mostly a warm-weather outdoor hobby
    case seasonal
}

/// Places near someone that make a hobby easy (or possible) to do.
public enum Place: String, CaseIterable, Sendable {
    case trailsParks, water, gymPool, climbing, studios, makerspace, venues, courts, gameCafe, communityCenter

    public var label: String {
        switch self {
        case .trailsParks: "Trails, parks or open land"
        case .water: "A coast, lake or river"
        case .gymPool: "Gyms, pools or rec centers"
        case .climbing: "A climbing gym"
        case .studios: "Studios or classes (dance, art, martial arts)"
        case .makerspace: "A library or makerspace"
        case .venues: "Music venues, theaters or open mics"
        case .courts: "Sports courts or fields"
        case .gameCafe: "Game stores or board-game cafés"
        case .communityCenter: "A community center or volunteer groups"
        }
    }

    /// Short form for sentences: "Needs a climbing gym nearby".
    public var short: String {
        switch self {
        case .trailsParks: "trails or parks"
        case .water: "open water"
        case .gymPool: "a gym or pool"
        case .climbing: "a climbing gym"
        case .studios: "studios or classes"
        case .makerspace: "a library or makerspace"
        case .venues: "music or theater venues"
        case .courts: "courts or fields"
        case .gameCafe: "a game store or café"
        case .communityCenter: "a community center"
        }
    }

    public var emoji: String {
        switch self {
        case .trailsParks: "🥾"
        case .water: "🌊"
        case .gymPool: "🏋️"
        case .climbing: "🧗"
        case .studios: "🩰"
        case .makerspace: "📚"
        case .venues: "🎤"
        case .courts: "🏟️"
        case .gameCafe: "🎲"
        case .communityCenter: "🤝"
        }
    }
}

/// A single-choice quiz answer stored as a small integer in result links.
public protocol Choice: CaseIterable, Hashable, Sendable, RawRepresentable where RawValue == Int, AllCases == [Self] {
    var label: String { get }
}

public enum Setting: Int, Choice {
    case city, suburb, smallTown, rural
    public var label: String {
        switch self {
        case .city: "A big city"
        case .suburb: "A suburb"
        case .smallTown: "A small town"
        case .rural: "The countryside"
        }
    }
}

public enum Climate: Int, Choice {
    case snowy, hot, mild, rainy
    public var label: String {
        switch self {
        case .snowy: "Snowy winters"
        case .hot: "Hot most of the year"
        case .mild: "Mild most of the year"
        case .rainy: "Rainy a lot"
        }
    }
}

public enum Company: Int, Choice {
    case solo, partner, family, friends, newPeople
    public var label: String {
        switch self {
        case .solo: "On my own"
        case .partner: "With a partner"
        case .family: "With my kids or family"
        case .friends: "With friends"
        case .newPeople: "With new people"
        }
    }
}

public enum Schedule: Int, Choice {
    case evenings, weekends, irregular
    public var label: String {
        switch self {
        case .evenings: "Weekday evenings"
        case .weekends: "Weekends"
        case .irregular: "It changes week to week"
        }
    }
}

public enum Noise: Int, Choice {
    case fine, some, quiet
    public var label: String {
        switch self {
        case .fine: "Noise is fine"
        case .some: "A little noise is OK"
        case .quiet: "It has to be quiet"
        }
    }
}

public enum Mess: Int, Choice {
    case fine, some, tidy
    public var label: String {
        switch self {
        case .fine: "Mess is fine"
        case .some: "A little mess is OK"
        case .tidy: "Keep it tidy"
        }
    }
}

public enum Body: Int, Choice {
    case any, lowImpact
    public var label: String {
        switch self {
        case .any: "No limits"
        case .lowImpact: "I'd prefer low-impact"
        }
    }
}

public enum Travel: Int, Choice {
    case rarely, often
    public var label: String {
        switch self {
        case .rarely: "Rarely"
        case .often: "Often — I'm on the move"
        }
    }
}

/// What it costs to get started.
public enum Cost: Int, Choice, Comparable {
    case free, low, medium, high

    public var label: String {
        switch self {
        case .free: "Under $20"
        case .low: "Under $100"
        case .medium: "Under $500"
        case .high: "$500 or more"
        }
    }

    public static func < (a: Cost, b: Cost) -> Bool { a.rawValue < b.rawValue }
}

/// Typical weekly time to make real progress.
public enum TimeNeed: Int, Choice, Comparable {
    case light, moderate, heavy

    public var label: String {
        switch self {
        case .light: "1–2 hours a week"
        case .moderate: "3–5 hours a week"
        case .heavy: "6+ hours a week"
        }
    }

    public static func < (a: TimeNeed, b: TimeNeed) -> Bool { a.rawValue < b.rawValue }
}

/// Space needed at home.
public enum Space: Int, Choice, Comparable {
    case desk, room, workshop

    public var label: String {
        switch self {
        case .desk: "A desk or a corner"
        case .room: "A spare room or a big table"
        case .workshop: "A garage, yard or workshop"
        }
    }

    public static func < (a: Space, b: Space) -> Bool { a.rawValue < b.rawValue }
}

public enum Goal: String, CaseIterable, Sendable {
    case relax, challenge, meetPeople, makeThings, getFit, learn

    public var label: String {
        switch self {
        case .relax: "Unwind"
        case .challenge: "A challenge"
        case .meetPeople: "Meet people"
        case .makeThings: "Make things"
        case .getFit: "Get fit"
        case .learn: "Learn something"
        }
    }

    public var emoji: String {
        switch self {
        case .relax: "🌿"
        case .challenge: "🔥"
        case .meetPeople: "👋"
        case .makeThings: "🛠️"
        case .getFit: "💪"
        case .learn: "🧠"
        }
    }
}

public enum Interest: String, CaseIterable, Sendable {
    case nature, food, music, art, crafts, words, games, tech, science, sports, animals, performance

    public var label: String {
        switch self {
        case .nature: "Nature"
        case .food: "Food & drink"
        case .music: "Music"
        case .art: "Art"
        case .crafts: "Crafts"
        case .words: "Words & languages"
        case .games: "Games & puzzles"
        case .tech: "Tech"
        case .science: "Science"
        case .sports: "Sports"
        case .animals: "Animals"
        case .performance: "Performing"
        }
    }

    public var emoji: String {
        switch self {
        case .nature: "🌲"
        case .food: "🍜"
        case .music: "🎵"
        case .art: "🎨"
        case .crafts: "🧵"
        case .words: "📝"
        case .games: "🎲"
        case .tech: "💻"
        case .science: "🔬"
        case .sports: "🏅"
        case .animals: "🐾"
        case .performance: "🎭"
        }
    }
}

public struct PlanStep: Sendable, Equatable {
    public let title: String
    public let detail: String

    /// When each of the three steps should happen.
    public static let timing = ["This week", "Weeks 2–4", "By month 3"]
}

public struct Hobby: Identifiable, Sendable, Equatable {
    public var id: String { name }
    public let name: String
    public let emoji: String
    public let tagline: String
    public let traits: Traits
    public let cost: Cost
    public let time: TimeNeed
    public let space: Space
    public let goals: Set<Goal>
    /// First entry is the primary interest, used to keep results varied.
    public let interests: [Interest]
    public let tags: Set<Tag>
    /// Places that make it possible (any one is enough); empty means it works anywhere.
    public let needs: [Place]
    public let steps: [PlanStep]
}

/// A person's quiz answers.
public struct Profile: Sendable, Equatable {
    /// Each trait answered on a 5-point scale, 0...4. Missing means the middle (no preference).
    public var scales: [Trait: Int] = [:]
    public var goals: Set<Goal> = []
    public var interests: Set<Interest> = []
    public var budget: Cost = .low
    public var time: TimeNeed = .moderate
    public var space: Space = .desk
    /// What the person's community is into.
    public var community: Set<Interest> = []
    public var nearby: Set<Place> = []
    public var setting: Setting = .suburb
    public var climate: Climate = .mild
    public var company: Company = .solo
    public var schedule: Schedule = .weekends
    public var noise: Noise = .some
    public var mess: Mess = .some
    public var body: Body = .any
    public var travel: Travel = .rarely

    public init() {}

    public func scale(_ trait: Trait) -> Int { scales[trait] ?? 2 }

    /// An unanswered scale and a middle answer mean the same thing, so they compare equal.
    public static func == (a: Profile, b: Profile) -> Bool {
        Trait.allCases.allSatisfy { a.scale($0) == b.scale($0) }
            && a.goals == b.goals && a.interests == b.interests && a.community == b.community && a.nearby == b.nearby
            && a.budget == b.budget && a.time == b.time && a.space == b.space
            && a.setting == b.setting && a.climate == b.climate && a.company == b.company && a.schedule == b.schedule
            && a.noise == b.noise && a.mess == b.mess && a.body == b.body && a.travel == b.travel
    }
}
