import Foundation

/// Website links to a set of results — the Swift side of website/share.js; the format is documented there.
/// website/tests/share.test.mjs checks both produce identical links.
public enum ResultLink {
    public static let website = URL(string: "https://amalmehta.github.io/HobbyMaxer/")!

    public static func url(for profile: Profile, selected: String?, dismissed: Set<String>) -> URL {
        URL(string: website.absoluteString + "?" + query(for: profile, selected: selected, dismissed: dismissed))!
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

    public static func slug(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private static func mask(_ flags: [Bool]) -> String {
        let bits = flags.enumerated().reduce(0) { $1.element ? $0 | (1 << $1.offset) : $0 }
        return String(bits, radix: 36)
    }
}
