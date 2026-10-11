import HobbyMaxerCore
import SwiftUI

/// Every hobby you've been suggested, grouped by status, plus your past quizzes.
struct MyHobbiesView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selection: String?

    var body: some View {
        let summaries = model.history.summaries()
        NavigationSplitView {
            List(selection: $selection) {
                if summaries.isEmpty {
                    Text("Nothing yet — take the quiz and your suggestions will collect here.")
                        .foregroundStyle(.secondary)
                        .selectionDisabled()
                }
                ForEach(groups(summaries), id: \.title) { group in
                    Section(group.title) {
                        ForEach(group.rows) { row in
                            SummaryRow(summary: row).tag("hobby:" + row.name)
                        }
                    }
                }
                if !model.history.runs.isEmpty {
                    Section("Past quizzes") {
                        ForEach(Array(model.history.runs.enumerated().reversed()), id: \.offset) { index, run in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(run.date.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                                Text(run.matches.prefix(3).map(\.name).joined(separator: ", "))
                                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                            .tag("run:\(index)")
                        }
                    }
                }
            }
            .navigationTitle("My hobbies")
            .navigationSplitViewColumnWidth(min: 250, ideal: 280)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button("Home") { model.home() }
                    Spacer()
                    if model.history.lastCode != nil { Button("Latest matches") { model.showLatest() } }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .padding(12)
            }
        } detail: {
            if let selection, selection.hasPrefix("hobby:"),
               let hobby = Catalog.all.first(where: { $0.name == selection.dropFirst(6) }),
               let summary = summaries.first(where: { $0.name == hobby.name }) {
                TrackedHobbyDetail(hobby: hobby, summary: summary)
            } else if let selection, selection.hasPrefix("run:"), let i = Int(selection.dropFirst(4)),
                      model.history.runs.indices.contains(i) {
                RunDetail(run: model.history.runs[i])
            } else {
                Text(summaries.isEmpty ? "" : "Pick a hobby or a past quiz on the left").foregroundStyle(.secondary)
            }
        }
        .onAppear { if selection == nil { selection = summaries.first.map { "hobby:" + $0.name } } }
    }

    private func groups(_ all: [History.Summary]) -> [(title: String, rows: [History.Summary])] {
        let order: [(String, HobbyStatus?)] = [("Trying", .trying), ("Interested", .interested),
                                               ("Suggested", nil), ("Not for me", .notForMe)]
        return order.compactMap { title, status in
            let rows = all.filter { $0.status == status }
            return rows.isEmpty ? nil : (title, rows)
        }
    }
}

struct SummaryRow: View {
    let summary: History.Summary

    var body: some View {
        HStack(spacing: 10) {
            Text(Catalog.all.first { $0.name == summary.name }?.emoji ?? "•").font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(summary.name).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }

    private var subtitle: String {
        var parts: [String] = []
        if summary.timesSuggested > 0 {
            parts.append("Suggested \(summary.timesSuggested)×")
            if let first = summary.firstPercent, let latest = summary.latestPercent {
                parts.append(first == latest ? "\(latest)%" : "\(first)% → \(latest)%")
            }
        }
        if summary.stepsDone > 0 { parts.append("\(summary.stepsDone)/3 steps") }
        return parts.joined(separator: " · ")
    }
}

/// A hobby from history: status, how its match has moved, and the plan with your progress.
struct TrackedHobbyDetail: View {
    let hobby: Hobby
    let summary: History.Summary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top, spacing: 18) {
                    Text(hobby.emoji).font(.system(size: 56))
                    VStack(alignment: .leading, spacing: 6) {
                        Text(hobby.name).font(.system(size: 30, weight: .bold, design: .rounded))
                        Text(hobby.tagline).font(.title3).foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            if let latest = summary.latestPercent { Pill(text: "\(latest)% latest match", strong: true) }
                            Pill(text: hobby.cost.label)
                            Pill(text: hobby.time.label)
                        }
                        .padding(.top, 4)
                    }
                }
                if summary.timesSuggested > 0, let first = summary.firstSeen, let last = summary.lastSeen {
                    Label(history(first: first, last: last), systemImage: "clock.arrow.circlepath")
                        .foregroundStyle(.secondary)
                }
                StatusPicker(name: hobby.name)
                PlanSteps(hobby: hobby)
            }
            .padding(32)
            .padding(.bottom, 40)
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }

    private func history(first: Date, last: Date) -> String {
        let times = summary.timesSuggested == 1 ? "once" : "\(summary.timesSuggested) times"
        var text = "Suggested \(times), first on \(first.formatted(date: .abbreviated, time: .omitted))"
        if summary.timesSuggested > 1 { text += ", last on \(last.formatted(date: .abbreviated, time: .omitted))" }
        if let a = summary.firstPercent, let b = summary.latestPercent, a != b { text += " — match went \(a)% → \(b)%" }
        return text
    }
}

/// One past quiz: its matches, with a button to reopen it.
struct RunDetail: View {
    @EnvironmentObject private var model: AppModel
    let run: History.Run

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiz on \(run.date.formatted(date: .long, time: .shortened))").font(.title2.bold())
            ForEach(run.matches, id: \.name) { m in
                HStack(spacing: 10) {
                    Text(Catalog.all.first { $0.name == m.name }?.emoji ?? "•").font(.title2)
                    Text(m.name).font(.headline)
                    Spacer()
                    MatchBar(percent: m.percent)
                }
            }
            .frame(maxWidth: 460)
            Button("Open these results") { model.showRun(run) }
                .buttonStyle(.borderedProminent)
                .padding(.top, 6)
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
