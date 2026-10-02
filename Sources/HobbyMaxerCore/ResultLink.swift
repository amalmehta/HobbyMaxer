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

    /// Shareable website link. With a selected hobby it goes through that hobby's preview page
    /// (h/<slug>/), so chat apps show a rich preview; the page forwards to the results.
    public static func url(for profile: Profile, selected: String?, dismissed: Set<String>) -> URL {
        let rest = query(for: profile, selected: nil, dismissed: dismissed)
        let path = selected.map { "h/\(slug($0))/" } ?? ""
        return URL(string: website.absoluteString + path + "?" + rest)!
    }

    public static func query(for profile: Profile, selected: String?, dismissed: Set<String>) -> String {
        let code = [
            "1",
            Trait.allCases.map { String(profile.scale($0)) }.joined(),
            "\(profile.budget.rawValue)\(profile.time.rawValue)\(profile.space.rawValue)",
            mask(Goal.allCases.map { profile.goals.contains($0) }),
            mask(Interest.allCases.map { profile.interests.contains($0) }),
        ].joined(separator: "-")
        var parts = ["r=\(code)"]
        if let selected { parts.append("h=\(slug(selected))") }
        if !dismissed.isEmpty {
            let ordered = Catalog.all.map(\.name).filter(dismissed.contains)
            parts.append("x=" + ordered.map(slug).joined(separator: ","))
        }
        return parts.joined(separator: "&")
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

        guard let code = value("r"),
              let m = code.wholeMatch(of: #/1-([0-4]{6})-([0-3])([0-2])([0-2])-([0-9a-z]{1,4})-([0-9a-z]{1,4})/#)
        else { return nil }

        var profile = Profile()
        for (trait, digit) in zip(Trait.allCases, m.1) { profile.scales[trait] = Int(String(digit))! }
        profile.budget = Cost(rawValue: Int(m.2)!)!
        profile.time = TimeNeed(rawValue: Int(m.3)!)!
        profile.space = Space(rawValue: Int(m.4)!)!
        profile.goals = Set(unmask(String(m.5), Goal.allCases).prefix(2))
        profile.interests = Set(unmask(String(m.6), Interest.allCases).prefix(3))

        let bySlug = Dictionary(uniqueKeysWithValues: Catalog.all.map { (slug($0.name), $0.name) })
        let dismissed = (value("x") ?? "").split(separator: ",").compactMap { bySlug[String($0)] }
        // The hobby comes from "h=" or, for preview-page links, from the ".../h/<slug>/" path.
        let pathSlug = text.firstMatch(of: #/\/h\/([a-z0-9-]+)\/?\?/#).map { String($0.1) }
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
