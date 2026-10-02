import Foundation

public struct Match: Identifiable, Sendable {
    public var id: String { hobby.id }
    public let hobby: Hobby
    /// 0...1 overall fit.
    public let score: Double
    public let reasons: [String]
    public let caveats: [String]

    public var percent: Int { Int((score * 100).rounded()) }
}

public enum Matcher {
    /// Ranks the catalog for a profile. Keeps results varied: at most two hobbies share a primary interest.
    public static func rank(_ profile: Profile, catalog: [Hobby] = Catalog.all,
                            excluding: Set<String> = [], limit: Int = 6) -> [Match] {
        let scored = catalog
            .filter { !excluding.contains($0.id) }
            .map { score($0, for: profile) }
            .sorted { $0.score != $1.score ? $0.score > $1.score : $0.hobby.name < $1.hobby.name }

        var picked: [Match] = []
        var perInterest: [Interest: Int] = [:]
        for match in scored where picked.count < limit {
            let primary = match.hobby.interests[0]
            if perInterest[primary, default: 0] >= 2 { continue }
            perInterest[primary, default: 0] += 1
            picked.append(match)
        }
        return picked
    }

    public static func score(_ hobby: Hobby, for profile: Profile) -> Match {
        // Trait fit: weighted closeness; strong answers (ends of the scale) count more than "in the middle".
        var weighted = 0.0, totalWeight = 0.0
        var strongMatches: [(trait: Trait, weight: Double)] = []
        for trait in Trait.allCases {
            let want = Double(profile.scale(trait)) / 4
            let weight = 0.3 + abs(want - 0.5) * 2
            let distance = abs(want - hobby.traits[trait])
            weighted += weight * distance
            totalWeight += weight
            if weight >= 0.8 && distance <= 0.3 { strongMatches.append((trait, weight)) }
        }
        let traitFit = 1 - weighted / totalWeight

        let sharedGoals = Goal.allCases.filter { profile.goals.contains($0) && hobby.goals.contains($0) }
        let goalFit = profile.goals.isEmpty ? 0.5 : Double(sharedGoals.count) / Double(profile.goals.count)

        let sharedInterests = hobby.interests.filter { profile.interests.contains($0) }
        let interestFit = profile.interests.isEmpty ? 0.5 : min(1, Double(sharedInterests.count) * 0.7)

        var score = 0.55 * traitFit + 0.2 * goalFit + 0.25 * interestFit

        // Practical limits shrink the score rather than hiding the hobby outright.
        var caveats: [String] = []
        let costOver = hobby.cost.rawValue - profile.budget.rawValue
        if costOver > 0 {
            score *= pow(0.6, Double(costOver))
            caveats.append("Startup cost (\(hobby.cost.label.lowercased())) is above your budget")
        }
        let timeOver = hobby.time.rawValue - profile.time.rawValue
        if timeOver > 0 {
            score *= pow(0.75, Double(timeOver))
            caveats.append("Usually takes \(hobby.time.label)")
        }
        let spaceOver = hobby.space.rawValue - profile.space.rawValue
        if spaceOver > 0 {
            score *= pow(0.5, Double(spaceOver))
            caveats.append("Needs \(hobby.space.label.lowercased())")
        }

        var reasons = strongMatches
            .sorted { $0.weight > $1.weight }
            .prefix(2)
            .map { phrase(for: $0.trait, high: profile.scale($0.trait) > 2) }
        if !sharedInterests.isEmpty {
            reasons.append("Taps into your love of \(list(sharedInterests.map { $0.label.lowercased() }))")
        }
        if !sharedGoals.isEmpty {
            reasons.append("Good for: \(list(sharedGoals.map { $0.label.lowercased() }))")
        }
        if costOver <= 0 {
            reasons.append("Starts \(hobby.cost.label.lowercased())")
        }

        return Match(hobby: hobby, score: min(1, max(0, score)), reasons: reasons, caveats: caveats)
    }

    static func phrase(for trait: Trait, high: Bool) -> String {
        switch (trait, high) {
        case (.social, false): "Works great on your own"
        case (.social, true): "Built around other people"
        case (.outdoor, false): "Happens indoors, any weather"
        case (.outdoor, true): "Gets you outside"
        case (.active, false): "Calm and low-impact"
        case (.active, true): "Gets you moving"
        case (.handsOn, false): "Mostly a thinking hobby"
        case (.handsOn, true): "Hands-on and tactile"
        case (.creative, false): "About skill and getting better"
        case (.creative, true): "You make or express something"
        case (.structured, false): "Freeform — no right way to do it"
        case (.structured, true): "Clear skills to level up through"
        }
    }

    static func list(_ items: [String]) -> String {
        switch items.count {
        case 0: ""
        case 1: items[0]
        default: items.dropLast().joined(separator: ", ") + " and " + items.last!
        }
    }
}
