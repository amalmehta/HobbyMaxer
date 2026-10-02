import HobbyMaxerCore
import SwiftUI

struct QuizView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        let question = model.question
        VStack(spacing: 0) {
            ProgressView(value: Double(model.questionIndex + 1), total: Double(Quiz.questions.count))
                .padding(.horizontal, 40)
                .padding(.top, 24)
            Text("Question \(model.questionIndex + 1) of \(Quiz.questions.count)")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            Spacer()

            VStack(spacing: 10) {
                Text(question.prompt)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(question.hint)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 32)

            answer(for: question)
                .frame(maxWidth: 640)
                .id(question.id)

            Spacer()

            HStack {
                Button("Back") { model.back() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(model.isLastQuestion ? "See my hobbies" : "Next") { model.next() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
            .controlSize(.large)
            .padding(.horizontal, 40)
            .padding(.bottom, 28)
            .padding(.trailing, 90) // keep clear of the feedback tab
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func answer(for question: Question) -> some View {
        switch question.kind {
        case let .scale(trait, left, right):
            ScalePicker(left: left, right: right, value: Binding(
                get: { model.profile.scale(trait) },
                set: { model.profile.scales[trait] = $0 }))
        case let .goals(max):
            ChipGrid(items: Goal.allCases, label: { "\($0.emoji)  \($0.label)" },
                     selection: $model.profile.goals, max: max)
        case let .interests(max):
            ChipGrid(items: Interest.allCases, label: { "\($0.emoji)  \($0.label)" },
                     selection: $model.profile.interests, max: max)
        case .budget:
            OptionList(items: Cost.allCases, label: \.label, selection: $model.profile.budget)
        case .time:
            OptionList(items: TimeNeed.allCases, label: \.label, selection: $model.profile.time)
        case .space:
            OptionList(items: Space.allCases, label: \.label, selection: $model.profile.space)
        }
    }
}

/// Five dots between two poles.
struct ScalePicker: View {
    let left: String
    let right: String
    @Binding var value: Int

    var body: some View {
        HStack(spacing: 18) {
            Text(left)
                .font(.headline)
                .frame(width: 150, alignment: .trailing)
                .multilineTextAlignment(.trailing)
            ForEach(0..<5) { index in
                let size: CGFloat = [44, 34, 26, 34, 44][index]
                Button { value = index } label: {
                    Circle()
                        .fill(value == index ? Color.accent : Color.secondary.opacity(0.15))
                        .overlay(Circle().strokeBorder(Color.accent.opacity(value == index ? 0 : 0.5), lineWidth: 2))
                        .frame(width: size, height: size)
                        .frame(width: 48, height: 48)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(["Strongly \(left)", left, "In between", right, "Strongly \(right)"][index])
            }
            Text(right)
                .font(.headline)
                .frame(width: 150, alignment: .leading)
        }
    }
}

/// Multi-select chips with a cap.
struct ChipGrid<Item: Hashable>: View {
    let items: [Item]
    let label: (Item) -> String
    @Binding var selection: Set<Item>
    let max: Int

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
            ForEach(items, id: \.self) { item in
                let isOn = selection.contains(item)
                let isFull = !isOn && selection.count >= max
                Button {
                    if isOn { selection.remove(item) } else if !isFull { selection.insert(item) }
                } label: {
                    Text(label(item))
                        .font(.body.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12)
                            .fill(isOn ? Color.accent.opacity(0.18) : Color.secondary.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isOn ? Color.accent : .clear, lineWidth: 2))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .opacity(isFull ? 0.4 : 1)
            }
        }
    }
}

/// Single-select list of cards.
struct OptionList<Item: Hashable>: View {
    let items: [Item]
    let label: KeyPath<Item, String>
    @Binding var selection: Item

    var body: some View {
        VStack(spacing: 10) {
            ForEach(items, id: \.self) { item in
                let isOn = selection == item
                Button { selection = item } label: {
                    HStack {
                        Text(item[keyPath: label]).font(.title3.weight(.medium))
                        Spacer()
                        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(isOn ? Color.accent : .secondary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(isOn ? Color.accent.opacity(0.14) : Color.secondary.opacity(0.08)))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: 460)
    }
}
