import Foundation

public struct Question: Identifiable, Sendable {
    public enum Kind: Sendable {
        case scale(Trait, left: String, right: String)
        case goals(max: Int)
        case interests(max: Int)
        case budget
        case time
        case space
    }

    public let id: Int
    public let prompt: String
    public let hint: String
    public let kind: Kind
}

public enum Quiz {
    public static let questions: [Question] = [
        Question(id: 0, prompt: "When you recharge, you'd rather be…", hint: "Pick the dot closest to you.",
                 kind: .scale(.social, left: "On my own", right: "Around people")),
        Question(id: 1, prompt: "Where do you feel best?", hint: "Pick the dot closest to you.",
                 kind: .scale(.outdoor, left: "Indoors", right: "Outside")),
        Question(id: 2, prompt: "How much do you want to move?", hint: "Pick the dot closest to you.",
                 kind: .scale(.active, left: "Calm and still", right: "Moving and sweaty")),
        Question(id: 3, prompt: "What do you like to work with?", hint: "Pick the dot closest to you.",
                 kind: .scale(.handsOn, left: "My head", right: "My hands")),
        Question(id: 4, prompt: "What feels more rewarding?", hint: "Pick the dot closest to you.",
                 kind: .scale(.creative, left: "Mastering a skill", right: "Making or expressing something")),
        Question(id: 5, prompt: "How do you like to learn?", hint: "Pick the dot closest to you.",
                 kind: .scale(.structured, left: "Freeform, no rules", right: "Clear steps and levels")),
        Question(id: 6, prompt: "What do you want out of a hobby?", hint: "Pick up to 2.",
                 kind: .goals(max: 2)),
        Question(id: 7, prompt: "Which of these pull at you?", hint: "Pick up to 3.",
                 kind: .interests(max: 3)),
        Question(id: 8, prompt: "What can you spend to get started?", hint: "Rough startup cost, not ongoing.",
                 kind: .budget),
        Question(id: 9, prompt: "How much time can you give it?", hint: "Be honest — a hobby you keep beats one you drop.",
                 kind: .time),
        Question(id: 10, prompt: "How much space do you have at home?", hint: "For gear and doing it at home.",
                 kind: .space),
    ]
}
