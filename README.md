# Hobby Maxer

A Mac app that figures out which hobbies fit you — and gives you a 3-step plan to start one.

![Your matches and a 3-step entry plan](docs/images/results.png)

| Welcome | Quick questions | Pick what pulls at you |
|---|---|---|
| ![Welcome](docs/images/welcome.png) | ![Scale question](docs/images/quiz-scale.png) | ![Interests question](docs/images/quiz-interests.png) |

## How it matches

```mermaid
flowchart LR
    Q["11 questions"] --> T["6 traits<br/>solo↔social · indoor↔outdoor<br/>calm↔active · head↔hands<br/>skill↔expression · freeform↔structured"]
    Q --> G["Goals + interests"]
    Q --> L["Budget · time · space"]
    C[("64 hobbies")] --> S{"Score each hobby"}
    T --> S
    G --> S
    L -- "over a limit shrinks the score" --> S
    S --> R["Top 6, kept varied"] --> P["Why it fits +<br/>3-step entry plan"]
```

## Links

- [Instructions](docs/INSTRUCTIONS.md) — set up, run and use
- [File Structure](docs/FILE-STRUCTURE.md) — what's where
