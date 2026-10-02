// Exports the catalog and quiz to the website, plus parity fixtures so the
// JavaScript matcher can be checked against this Swift one.
// Usage: swift run ExportCatalog [website-folder]
import Foundation
import HobbyMaxerCore

let folder = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "website")

func options<T: RawRepresentable>(_ cases: [T], _ label: (T) -> String, _ emoji: (T) -> String) -> [[String: Any]] {
    cases.map { ["id": $0.rawValue, "label": label($0), "emoji": emoji($0)] }
}

func questionJSON(_ q: Question) -> [String: Any] {
    var out: [String: Any] = ["id": q.id, "prompt": q.prompt, "hint": q.hint]
    switch q.kind {
    case let .scale(trait, left, right):
        out["kind"] = "scale"; out["trait"] = trait.rawValue; out["left"] = left; out["right"] = right
    case let .goals(max): out["kind"] = "goals"; out["max"] = max
    case let .interests(max): out["kind"] = "interests"; out["max"] = max
    case .budget: out["kind"] = "budget"
    case .time: out["kind"] = "time"
    case .space: out["kind"] = "space"
    }
    return out
}

func hobbyJSON(_ h: Hobby) -> [String: Any] {
    [
        "name": h.name, "emoji": h.emoji, "tagline": h.tagline,
        "traits": Dictionary(uniqueKeysWithValues: Trait.allCases.map { ($0.rawValue, h.traits[$0]) }),
        "cost": h.cost.rawValue, "time": h.time.rawValue, "space": h.space.rawValue,
        "goals": Goal.allCases.filter { h.goals.contains($0) }.map(\.rawValue),
        "interests": h.interests.map(\.rawValue),
        "steps": h.steps.map { ["title": $0.title, "detail": $0.detail] },
    ]
}

let catalog: [String: Any] = [
    "traits": Trait.allCases.map(\.rawValue),
    "goals": options(Goal.allCases, \.label, \.emoji),
    "interests": options(Interest.allCases, \.label, \.emoji),
    "costs": Cost.allCases.map(\.label),
    "times": TimeNeed.allCases.map(\.label),
    "spaces": Space.allCases.map(\.label),
    "timing": PlanStep.timing,
    "questions": Quiz.questions.map(questionJSON),
    "hobbies": Catalog.all.map(hobbyJSON),
]

// Deterministic random profiles (SplitMix64) and the Swift matcher's answers for them.
struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

var rng = SplitMix64(state: 2026)
var fixtures: [[String: Any]] = []
for _ in 0..<300 {
    var p = Profile()
    for trait in Trait.allCases { p.scales[trait] = Int.random(in: 0...4, using: &rng) }
    p.goals = Set(Goal.allCases.shuffled(using: &rng).prefix(Int.random(in: 0...2, using: &rng)))
    p.interests = Set(Interest.allCases.shuffled(using: &rng).prefix(Int.random(in: 0...3, using: &rng)))
    p.budget = Cost.allCases.randomElement(using: &rng)!
    p.time = TimeNeed.allCases.randomElement(using: &rng)!
    p.space = Space.allCases.randomElement(using: &rng)!
    let excluded = Bool.random(using: &rng) ? Set([Catalog.all.randomElement(using: &rng)!.id]) : []
    let profileJSON: [String: Any] = [
        "scales": Dictionary(uniqueKeysWithValues: p.scales.map { ($0.key.rawValue, $0.value) }),
        "goals": Goal.allCases.filter { p.goals.contains($0) }.map(\.rawValue),
        "interests": Interest.allCases.filter { p.interests.contains($0) }.map(\.rawValue),
        "budget": p.budget.rawValue, "time": p.time.rawValue, "space": p.space.rawValue,
    ]
    let ranked = Matcher.rank(p, excluding: excluded)
    let link = ResultLink.query(for: p, selected: ranked.last?.hobby.name, dismissed: excluded)
    let url = ResultLink.url(for: p, selected: ranked.last?.hobby.name, dismissed: excluded).absoluteString
    let matches = ranked.map {
        ["name": $0.hobby.name, "score": $0.score, "percent": $0.percent, "reasons": $0.reasons, "caveats": $0.caveats] as [String: Any]
    }
    fixtures.append(["profile": profileJSON, "excluding": Array(excluded), "matches": matches, "link": link, "url": url])
}

func write(_ object: Any, to path: String) throws {
    let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    let url = folder.appendingPathComponent(path)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
    print("Wrote \(url.path)")
}

try write(catalog, to: "catalog.json")
try write(fixtures, to: "tests/parity.json")
try Previews.write(to: folder)
