import HobbyMaxerCore
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Group {
            switch model.stage {
            case .welcome: WelcomeView()
            case .quiz: QuizView()
            case .results: ResultsView()
            case .myHobbies: MyHobbiesView()
            }
        }
        .overlay(alignment: .bottomTrailing) { FeedbackTab() }
        .sheet(isPresented: $model.isOpeningLink) { OpenLinkSheet() }
        .animation(.easeInOut(duration: 0.2), value: model.stage)
    }
}

struct WelcomeView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text("🎯").font(.system(size: 72))
            Text("Hobby Maxer")
                .font(.system(size: 44, weight: .bold, design: .rounded))
            if let last = model.history.runs.last {
                Text("Welcome back.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                if let top = last.matches.first {
                    Text("Last quiz \(last.date.formatted(date: .abbreviated, time: .omitted)) · top match \(top.name) (\(top.percent)%)")
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 12) {
                    Button("See my latest matches") { model.showLatest() }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                    Button("Retake the quiz") { model.start() }
                    Button("My hobbies (\(model.history.summaries().count))") { model.stage = .myHobbies }
                }
                .controlSize(.large)
                .padding(.top, 8)
            } else {
                Text("Answer \(Quiz.questions.count) questions about you, where you live and your life.\nGet hobbies that fit you — and a 3-step plan to start one.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Start the quiz") { model.start() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .keyboardShortcut(.defaultAction)
                    .padding(.top, 8)
            }
            Text("\(Catalog.all.count) hobbies · about 4 minutes · saved on this Mac, nothing leaves it")
                .font(.callout)
                .foregroundStyle(.tertiary)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
