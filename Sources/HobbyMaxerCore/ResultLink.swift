import Foundation

/// Website links to a set of results — the Swift side of website/share.js; the format is documented there.
/// website/tests/share.test.mjs checks both produce identical links.
public enum ResultLink {
    public static let website = URL(string: "https://amalmehta.github.io/HobbyMaxer/")!
    /// The Mac app's own link scheme: hobbymaxer://results?r=…
    public static let appScheme = "hobbymaxer"

    public struct Opened: Equatable {
        public var profile: Profile
        public var selected: String?
        public var dismissed: Set<String>
    }

    /// Shareable website link. With a selected hobby it goes through that hobby's preview page for
    /// its match % (h/<slug>/<percent>/), so chat apps show a rich preview; the page forwards to the results.
    public static func url(for profile: Profile, selected: String?, dismissed: Set<String>) -> URL {
        let rest = query(for: profile, selected: nil, dismissed: dismissed)
        let hobby = selected.flatMap { name in Catalog.all.first { $0.name == name } }
        let path = hobby.map { "h/\(slug($0.name))/\(Matcher.score($0, for: profile).percent)/" } ?? ""
        return URL(string: website.absoluteString + path + "?" + rest)!
    }

    public static func query(for profile: Profile, selected: String?, dismissed: Set<String>) -> String {
        var parts = ["r=\(code(for: profile))"]
        if let selected { parts.append("h=\(slug(selected))") }
        if !dismissed.isEmpty {
            let ordered = Catalog.all.map(\.name).filter(dismissed.contains)
            parts.append("x=" + ordered.map(slug).joined(separator: ","))
        }
        return parts.joined(separator: "&")
    }

    /// The answers as a compact versioned code (format 2):
    /// 2-<11 trait scales>-<budget time space>-<goals>-<interests>-<setting climate company schedule noise mess body travel>-<nearby>-<community>
    /// Masks are base-36 bitmasks in the enums' case order. Also used to store answers in history.
    public static func code(for profile: Profile) -> String {
        [
            "2",
            Trait.allCases.map { String(profile.scale($0)) }.joined(),
            "\(profile.budget.rawValue)\(profile.time.rawValue)\(profile.space.rawValue)",
            mask(Goal.allCases.map { profile.goals.contains($0) }),
            mask(Interest.allCases.map { profile.interests.contains($0) }),
            [profile.setting.rawValue, profile.climate.rawValue, profile.company.rawValue, profile.schedule.rawValue,
             profile.noise.rawValue, profile.mess.rawValue, profile.body.rawValue, profile.travel.rawValue]
                .map(String.init).joined(),
            mask(Place.allCases.map { profile.nearby.contains($0) }),
            mask(Interest.allCases.map { profile.community.contains($0) }),
        ].joined(separator: "-")
    }

    /// Reads an answers code (format 1 or 2). Format 1 (6 traits, no life/location answers) fills the rest with defaults.
    public static func profile(fromCode code: String) -> Profile? {
        var profile = Profile()
        func digits(_ s: Substring) -> [Int] { s.map { Int(String($0))! } }
        if let m = code.wholeMatch(of: #/1-([0-4]{6})-([0-3])([0-2])([0-2])-([0-9a-z]{1,4})-([0-9a-z]{1,4})/#) {
            for (trait, v) in zip(Trait.allCases, digits(m.1)) { profile.scales[trait] = v }
            profile.budget = Cost(rawValue: Int(m.2)!)!
            profile.time = TimeNeed(rawValue: Int(m.3)!)!
            profile.space = Space(rawValue: Int(m.4)!)!
            profile.goals = Set(unmask(String(m.5), Goal.allCases).prefix(2))
            profile.interests = Set(unmask(String(m.6), Interest.allCases).prefix(3))
            return profile
        }
        guard let m = code.wholeMatch(of: #/2-([0-4]{11})-([0-3])([0-2])([0-2])-([0-9a-z]{1,4})-([0-9a-z]{1,4})-([0-3])([0-3])([0-4])([0-2])([0-2])([0-2])([0-1])([0-1])-([0-9a-z]{1,4})-([0-9a-z]{1,4})/#)
        else { return nil }
        for (trait, v) in zip(Trait.allCases, digits(m.1)) { profile.scales[trait] = v }
        profile.budget = Cost(rawValue: Int(m.2)!)!
        profile.time = TimeNeed(rawValue: Int(m.3)!)!
        profile.space = Space(rawValue: Int(m.4)!)!
        profile.goals = Set(unmask(String(m.5), Goal.allCases).prefix(2))
        profile.interests = Set(unmask(String(m.6), Interest.allCases).prefix(3))
        profile.setting = Setting(rawValue: Int(m.7)!)!
        profile.climate = Climate(rawValue: Int(m.8)!)!
        profile.company = Company(rawValue: Int(m.9)!)!
        profile.schedule = Schedule(rawValue: Int(m.10)!)!
        profile.noise = Noise(rawValue: Int(m.11)!)!
        profile.mess = Mess(rawValue: Int(m.12)!)!
        profile.body = Body(rawValue: Int(m.13)!)!
        profile.travel = Travel(rawValue: Int(m.14)!)!
        profile.nearby = Set(unmask(String(m.15), Place.allCases))
        profile.community = Set(unmask(String(m.16), Interest.allCases).prefix(3))
        return profile
    }

    /// Link that opens these results in the Mac app.
    public static func appURL(for profile: Profile, selected: String?, dismissed: Set<String>) -> URL {
        URL(string: "\(appScheme)://results?" + query(for: profile, selected: selected, dismissed: dismissed))!
    }

    /// Reads a website link, an app link, or a bare "?r=…" query. Returns nil if it isn't a valid result link.
    public static func decode(_ link: String) -> Opened? {
        let text = link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let query = text.split(separator: "?", maxSplits: 1).last.map(String.init),
              text.contains("?") || text.hasPrefix("r="),
              let items = URLComponents(string: "?" + query)?.queryItems else { return nil }
        func value(_ name: String) -> String? { items.first { $0.name == name }?.value }

        guard let code = value("r"), let profile = profile(fromCode: code) else { return nil }

        let bySlug = Dictionary(uniqueKeysWithValues: Catalog.all.map { (slug($0.name), $0.name) })
        let dismissed = (value("x") ?? "").split(separator: ",").compactMap { bySlug[String($0)] }
        // The hobby comes from "h=" or, for preview-page links, from the ".../h/<slug>/" path.
        let pathSlug = text.firstMatch(of: #/\/h\/([a-z0-9-]+)\/(?:\d{1,3}\/)?\?/#).map { String($0.1) }
        let selected = (value("h") ?? pathSlug).flatMap { bySlug[$0] }
        return Opened(profile: profile, selected: selected, dismissed: Set(dismissed))
    }

    public static func slug(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private static func unmask<T>(_ code: String, _ all: [T]) -> [T] {
        let bits = Int(code, radix: 36) ?? 0
        return all.enumerated().filter { bits & (1 << $0.offset) != 0 }.map(\.element)
    }

    private static func mask(_ flags: [Bool]) -> String {
        let bits = flags.enumerated().reduce(0) { $1.element ? $0 | (1 << $1.offset) : $0 }
        return String(bits, radix: 36)
    }
}
