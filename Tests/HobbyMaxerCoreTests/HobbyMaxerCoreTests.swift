@testable import HobbyMaxerCore
import XCTest

final class CatalogTests: XCTestCase {
    func testEveryHobbyHasAThreeStepPlan() {
        for hobby in Catalog.all {
            XCTAssertEqual(hobby.steps.count, 3, hobby.name)
            for step in hobby.steps {
                XCTAssertFalse(step.title.isEmpty, hobby.name)
                XCTAssertFalse(step.detail.isEmpty, hobby.name)
            }
        }
    }

    func testNamesAreUniqueAndDataIsWellFormed() {
        XCTAssertEqual(Set(Catalog.all.map(\.name)).count, Catalog.all.count)
        XCTAssertGreaterThanOrEqual(Catalog.all.count, 60)
        for hobby in Catalog.all {
            XCTAssertFalse(hobby.goals.isEmpty, hobby.name)
            XCTAssertFalse(hobby.interests.isEmpty, hobby.name)
            for trait in Trait.allCases {
                XCTAssert((0...1).contains(hobby.traits[trait]), "\(hobby.name) \(trait)")
            }
        }
    }
}

final class MatcherTests: XCTestCase {
    private func profile(_ scales: [Trait: Int], goals: Set<Goal> = [], interests: Set<Interest> = [],
                         budget: Cost = .medium, time: TimeNeed = .heavy, space: Space = .workshop) -> Profile {
        var p = Profile()
        p.scales = scales
        p.goals = goals
        p.interests = interests
        p.budget = budget
        p.time = time
        p.space = space
        return p
    }

    func testOutdoorActiveSocialPersonGetsSportsAndNature() {
        let p = profile([.social: 4, .outdoor: 4, .active: 4, .handsOn: 1, .creative: 0, .structured: 2],
                        goals: [.getFit, .meetPeople], interests: [.sports])
        let top = Matcher.rank(p).prefix(3).map(\.hobby.name)
        XCTAssert(top.contains("Rec Sports League"), "\(top)")
    }

    func testQuietCreativeMakerGetsCrafts() {
        let p = profile([.social: 0, .outdoor: 0, .active: 0, .handsOn: 4, .creative: 4, .structured: 2],
                        goals: [.makeThings, .relax], interests: [.crafts, .art], budget: .free)
        let top = Matcher.rank(p).map(\.hobby)
        XCTAssert(top.prefix(4).allSatisfy { $0.interests.contains(.crafts) || $0.interests.contains(.art) }, "\(top.map(\.name))")
        XCTAssert(top.allSatisfy { $0.traits[.active] <= 0.3 })
    }

    func testBudgetAndSpaceLimitsPushHobbiesDown() {
        let p = profile([.handsOn: 4, .creative: 3, .structured: 3], goals: [.makeThings], interests: [.crafts],
                        budget: .free, time: .light, space: .desk)
        let woodworking = Catalog.all.first { $0.name == "Woodworking" }!
        let match = Matcher.score(woodworking, for: p)
        XCTAssert(match.caveats.contains { $0.hasPrefix("Startup cost") })
        XCTAssert(match.caveats.contains { $0.hasPrefix("Usually takes") })
        XCTAssert(match.caveats.contains { $0.hasPrefix("Needs a garage") })
        XCTAssertFalse(Matcher.rank(p).contains { $0.hobby.name == "Woodworking" })
    }

    func testResultsStayVaried() {
        let p = profile([.social: 4, .active: 4, .outdoor: 3], goals: [.getFit], interests: [.sports])
        let matches = Matcher.rank(p)
        XCTAssertEqual(matches.count, 6)
        let primaries = Dictionary(grouping: matches, by: { $0.hobby.interests[0] })
        XCTAssert(primaries.values.allSatisfy { $0.count <= 2 })
    }

    func testDismissedHobbiesAreReplaced() {
        let p = profile([.social: 0, .creative: 4])
        let first = Matcher.rank(p)
        let next = Matcher.rank(p, excluding: [first[0].id])
        XCTAssertEqual(next.count, 6)
        XCTAssertFalse(next.contains { $0.id == first[0].id })
    }

    func testScoresAndReasonsAreSensible() {
        let p = profile([.outdoor: 4], interests: [.nature])
        for hobby in Catalog.all {
            let match = Matcher.score(hobby, for: p)
            XCTAssert((0...1).contains(match.score))
            XCTAssertFalse(match.reasons.isEmpty && match.caveats.isEmpty, hobby.name)
        }
    }

    func testResultLinkMatchesWebsiteFormat() {
        var p = Profile()
        p.scales = [.social: 1, .outdoor: 3, .active: 1, .handsOn: 4, .creative: 3, .structured: 2]
        p.goals = [.relax, .makeThings]
        p.interests = [.nature, .food, .crafts]
        p.budget = .free
        p.time = .moderate
        p.space = .desk
        let url = ResultLink.url(for: p, selected: "Knitting", dismissed: ["Bonsai"])
        let knitting = Catalog.all.first { $0.name == "Knitting" }!
        let percent = Matcher.score(knitting, for: p).percent
        // Same link the website produces for these answers (checked in website/tests/share.test.mjs).
        XCTAssertEqual(url.absoluteString,
                       "https://amalmehta.github.io/HobbyMaxer/h/knitting/\(percent)/?r=2-13143222222-010-9-j-12011100-0-0&x=bonsai")
        XCTAssertEqual(ResultLink.slug("Electronics & Arduino"), "electronics-and-arduino")
        XCTAssertEqual(ResultLink.slug("3D Printing"), "3d-printing")
        XCTAssertEqual(Set(Catalog.all.map { ResultLink.slug($0.name) }).count, Catalog.all.count)
    }

    /// Links made by the website (and the Swift exporter) open the same results in the app.
    func testDecodingWebsiteLinksReproducesResults() throws {
        let fixtures = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("website/tests/parity.json")
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: fixtures)) as! [[String: Any]]
        XCTAssertEqual(json.count, 300)
        for fixture in json {
            let link = fixture["link"] as! String
            let shareURL = fixture["url"] as! String
            let want = (fixture["matches"] as! [[String: Any]]).map { $0["name"] as! String }
            for form in [shareURL, "https://amalmehta.github.io/HobbyMaxer/?\(link)", "hobbymaxer://results?\(link)", "?\(link)"] {
                let opened = try XCTUnwrap(ResultLink.decode(form), form)
                XCTAssertEqual(Matcher.rank(opened.profile, excluding: opened.dismissed).map(\.hobby.name), want, form)
                XCTAssertEqual(opened.selected, want.last)
                XCTAssertEqual(ResultLink.query(for: opened.profile, selected: opened.selected, dismissed: opened.dismissed), link)
            }
        }
    }

    func testBadLinksAreRejected() {
        for bad in ["", "hello", "https://amalmehta.github.io/HobbyMaxer/", "?r=", "?r=2-134322-012-3-1c",
                    "?r=1-934322-012-3-1c", "?r=1-13432-012-3-1c", "?r=1-134322-412-3-1c", "?r=1-134322-012-$-1c"] {
            XCTAssertNil(ResultLink.decode(bad), bad)
        }
        let opened = ResultLink.decode("  hobbymaxer://results?r=1-222222-111-zz-zzzz&h=nope&x=bonsai,nope  ")
        XCTAssertEqual(opened?.profile.goals.count, 2)
        XCTAssertEqual(opened?.profile.interests.count, 3)
        XCTAssertNil(opened?.selected)
        XCTAssertEqual(opened?.dismissed, ["Bonsai"])
    }

    /// Links from before the location and life questions still open, with defaults for the new answers.
    func testFormatOneLinksStillOpen() throws {
        let opened = try XCTUnwrap(ResultLink.decode("https://amalmehta.github.io/HobbyMaxer/h/knitting/79/?r=1-431001-110-3-1c&x=bonsai"))
        XCTAssertEqual(opened.profile.scale(.social), 4)
        XCTAssertEqual(opened.profile.scale(.competitive), 2)
        XCTAssertEqual(opened.profile.nearby, [])
        XCTAssertEqual(opened.profile.setting, .suburb)
        XCTAssertEqual(opened.selected, "Knitting")
        XCTAssertEqual(opened.dismissed, ["Bonsai"])
    }

    func testQuizHasAtLeast25QuestionsAndCoversEveryAnswer() {
        XCTAssertGreaterThanOrEqual(Quiz.questions.count, 25)
        var traits = Set<Trait>(), singles = Set<SingleKey>(), multis = Set<MultiKey>()
        for q in Quiz.questions {
            switch q.kind {
            case let .scale(t, _, _): traits.insert(t)
            case let .single(k): singles.insert(k)
            case let .multi(k, _): multis.insert(k)
            }
        }
        XCTAssertEqual(traits, Set(Trait.allCases))
        XCTAssertEqual(singles, Set(SingleKey.allCases))
        XCTAssertEqual(multis, Set(MultiKey.allCases))
    }

    func testLifeAnswersSteerResults() {
        let base = profile([.handsOn: 3], interests: [.music])
        let loud = Catalog.all.filter { $0.tags.contains(.loud) }
        let rough = Catalog.all.filter { $0.tags.contains(.highImpact) }
        XCTAssertFalse(loud.isEmpty)
        XCTAssertFalse(rough.isEmpty)

        var quiet = base; quiet.noise = .quiet
        for h in loud {
            XCTAssertLessThan(Matcher.score(h, for: quiet).score, Matcher.score(h, for: base).score, h.name)
            XCTAssert(Matcher.score(h, for: quiet).caveats.contains("Can be loud at home"))
        }
        var gentle = base; gentle.body = .lowImpact
        for h in rough { XCTAssertLessThan(Matcher.score(h, for: gentle).score, Matcher.score(h, for: base).score, h.name) }

        // A hobby that needs a place: having it nearby beats living rurally without it.
        let needy = Catalog.all.first { !$0.needs.isEmpty }!
        var near = base; near.nearby = [needy.needs[0]]; near.setting = .rural
        var far = base; far.nearby = [needy.needs[0] == .water ? .studios : .water]; far.setting = .rural
        XCTAssertGreaterThan(Matcher.score(needy, for: near).score, Matcher.score(needy, for: far).score)
        XCTAssert(Matcher.score(needy, for: near).reasons.contains { $0.hasPrefix("You have") })

        // What your community is into gives a small push.
        var local = base; local.community = Set(needy.interests.prefix(1))
        XCTAssertGreaterThanOrEqual(Matcher.score(needy, for: local).score, Matcher.score(needy, for: base).score)
    }

    /// Different people should see different hobbies: most of the catalog should be reachable.
    func testMostHobbiesShowUpForSomeone() {
        var rng = SystemRandomNumberGenerator()
        var seen: Set<String> = []
        for _ in 0..<3000 {
            var p = Profile()
            for trait in Trait.allCases { p.scales[trait] = Int.random(in: 0...4, using: &rng) }
            p.goals = Set(Goal.allCases.shuffled(using: &rng).prefix(Int.random(in: 0...2, using: &rng)))
            p.interests = Set(Interest.allCases.shuffled(using: &rng).prefix(Int.random(in: 0...3, using: &rng)))
            p.budget = Cost.allCases.randomElement(using: &rng)!
            p.time = TimeNeed.allCases.randomElement(using: &rng)!
            p.space = Space.allCases.randomElement(using: &rng)!
            p.community = Set(Interest.allCases.shuffled(using: &rng).prefix(Int.random(in: 0...3, using: &rng)))
            p.nearby = Set(Place.allCases.shuffled(using: &rng).prefix(Int.random(in: 0...5, using: &rng)))
            for key in [SingleKey.setting, .climate, .company, .schedule, .noise, .mess, .body, .travel] {
                p[single: key] = Int.random(in: 0..<key.options.count, using: &rng)
            }
            Matcher.rank(p).forEach { seen.insert($0.id) }
        }
        let unseen = Catalog.all.map(\.name).filter { !seen.contains($0) }
        XCTAssertLessThanOrEqual(unseen.count, Catalog.all.count / 10, "Never recommended: \(unseen)")
    }
}

final class HistoryTests: XCTestCase {
    func testRunsStatusesAndStepsSurviveAReload() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("hm-\(UUID().uuidString)/history.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        XCTAssertEqual(History.load(from: url), History(), "no file yet means empty history")

        var p = Profile()
        p.scales = [.social: 0, .handsOn: 4, .creative: 4]
        p.nearby = [.studios]
        p.climate = .snowy
        var h = History()
        h.record(p, matches: Matcher.rank(p), at: Date(timeIntervalSince1970: 1_790_000_000))
        p.scales[.social] = 4
        h.record(p, matches: Matcher.rank(p), at: Date(timeIntervalSince1970: 1_790_100_000))
        let first = h.runs[0].matches[0].name
        h.toggleStep(0, for: first)
        h.setStatus(.notForMe, for: h.runs[1].matches[0].name)
        try h.save(to: url)

        let back = History.load(from: url)
        XCTAssertEqual(back, h)
        XCTAssertEqual(back.lastProfile, p, "last answers come back exactly")
        XCTAssertEqual(back.statuses[first], .trying, "ticking a step marks it as trying")
        XCTAssertTrue(back.stepDone(0, for: first))
        XCTAssertEqual(back.notForMe, [h.runs[1].matches[0].name])

        let summary = try XCTUnwrap(back.summaries().first { $0.name == first })
        XCTAssertEqual(summary.stepsDone, 1)
        XCTAssertEqual(summary.firstSeen, Date(timeIntervalSince1970: 1_790_000_000))
        XCTAssertEqual(Set(back.summaries().map(\.name)).count, back.summaries().count, "no duplicates")
    }

    func testUntickingClearsProgressAndRunsAreCapped() {
        var h = History()
        h.toggleStep(2, for: "Chess")
        h.toggleStep(2, for: "Chess")
        XCTAssertNil(h.steps["Chess"])
        for _ in 0..<(History.maxRuns + 5) { h.record(Profile(), matches: []) }
        XCTAssertEqual(h.runs.count, History.maxRuns)
    }

    func testCorruptFileStartsFresh() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("hm-bad-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("{not json".utf8).write(to: url)
        XCTAssertEqual(History.load(from: url), History())
    }
}
