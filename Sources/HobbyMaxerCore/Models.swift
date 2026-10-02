import Foundation

/// The six personality dimensions every hobby and every person is placed on, from 0 to 1.
public enum Trait: String, CaseIterable, Sendable {
    case social, outdoor, active, handsOn, creative, structured
}

public struct Traits: Sendable, Equatable {
    public var social, outdoor, active, handsOn, creative, structured: Double

    public init(social: Double, outdoor: Double, active: Double, handsOn: Double, creative: Double, structured: Double) {
        self.social = social
        self.outdoor = outdoor
        self.active = active
        self.handsOn = handsOn
        self.creative = creative
        self.structured = structured
    }

    public subscript(_ trait: Trait) -> Double {
        switch trait {
        case .social: social
        case .outdoor: outdoor
        case .active: active
        case .handsOn: handsOn
        case .creative: creative
        case .structured: structured
        }
    }
}

/// What it costs to get started.
public enum Cost: Int, CaseIterable, Comparable, Sendable {
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
public enum TimeNeed: Int, CaseIterable, Comparable, Sendable {
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
public enum Space: Int, CaseIterable, Comparable, Sendable {
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

    public init() {}

    public func scale(_ trait: Trait) -> Int { scales[trait] ?? 2 }
}
