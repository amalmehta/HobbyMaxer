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
            Text("Answer \(Quiz.questions.count) quick questions about how you like to spend your time.\nGet hobbies that fit you — and a 3-step plan to start one.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Start the quiz") { model.start() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .padding(.top, 8)
            Text("\(Catalog.all.count) hobbies · about 2 minutes · nothing leaves your Mac")
                .font(.callout)
                .foregroundStyle(.tertiary)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
