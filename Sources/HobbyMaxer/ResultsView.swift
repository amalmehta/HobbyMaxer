import AppKit
import HobbyMaxerCore
import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let matches = model.matches
        NavigationSplitView {
            List(matches, selection: $model.selectedID) { match in
                HStack(spacing: 10) {
                    Text(match.hobby.emoji).font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(match.hobby.name).font(.headline)
                        MatchBar(percent: match.percent)
                    }
                }
                .padding(.vertical, 4)
                .tag(match.id)
            }
            .navigationTitle("Your matches")
            .navigationSplitViewColumnWidth(min: 230, ideal: 250)
            .safeAreaInset(edge: .bottom) { SidebarActions() }
        } detail: {
            if let match = matches.first(where: { $0.id == model.selectedID }) {
                HobbyDetail(match: match)
            } else {
                Text("Pick a hobby on the left").foregroundStyle(.secondary)
            }
        }
    }
}

/// Share, copy-link and retake buttons under the match list.
struct SidebarActions: View {
    @EnvironmentObject private var model: AppModel
    @State private var copied = false

    var body: some View {
        VStack(spacing: 8) {
            ShareLink(item: model.shareURL, subject: Text("My Hobby Maxer matches"),
                      message: Text("Hobbies that fit me, with a 3-step plan to start each one")) {
                Label("Share these results", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .help("Send a link that opens these results on the Hobby Maxer website")

            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(model.shareURL.absoluteString, forType: .string)
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
            } label: {
                Label(copied ? "Link copied" : "Copy link", systemImage: copied ? "checkmark" : "link")
                    .frame(maxWidth: .infinity)
            }

            Button("Retake quiz") { model.retake() }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
        .controlSize(.large)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

struct MatchBar: View {
    let percent: Int

    var body: some View {
        HStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.15))
                    Capsule().fill(Color.accent).frame(width: geo.size.width * CGFloat(percent) / 100)
                }
            }
            .frame(width: 90, height: 6)
            Text("\(percent)% match").font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct HobbyDetail: View {
    @EnvironmentObject private var model: AppModel
    let match: Match

    var body: some View {
        let hobby = match.hobby
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top, spacing: 18) {
                    Text(hobby.emoji).font(.system(size: 60))
                    VStack(alignment: .leading, spacing: 6) {
                        Text(hobby.name).font(.system(size: 32, weight: .bold, design: .rounded))
                        Text(hobby.tagline).font(.title3).foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            Pill(text: "\(match.percent)% match", strong: true)
                            Pill(text: hobby.cost.label)
                            Pill(text: hobby.time.label)
                        }
                        .padding(.top, 4)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Why it fits you").font(.headline)
                    ForEach(match.reasons, id: \.self) { reason in
                        Label(reason, systemImage: "checkmark").foregroundStyle(.primary)
                    }
                    ForEach(match.caveats, id: \.self) { caveat in
                        Label(caveat, systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your 3-step entry plan").font(.title2.bold())
                    ForEach(Array(hobby.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(Color.accent))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(PlanStep.timing[index].uppercased())
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.accent)
                                Text(step.title).font(.headline)
                                Text(step.detail).foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(0.08)))
                    }
                }

                Button("Not for me — show another") { model.dismiss(hobby.id) }
                    .help("Hide this hobby and bring in the next best match")
            }
            .padding(32)
            .padding(.bottom, 40)
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }
}

struct Pill: View {
    let text: String
    var strong = false

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(strong ? Color.accent.opacity(0.2) : Color.secondary.opacity(0.12)))
            .foregroundStyle(strong ? Color.accent : .secondary)
    }
}
