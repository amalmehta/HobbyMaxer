# Hobby Maxer

A Mac app and website that figure out which hobbies fit you — and give you a 3-step plan to start one.

**[Try it on the web →](https://amalmehta.github.io/HobbyMaxer/)**

![Your matches and a 3-step entry plan](docs/images/results.png)

| Welcome | Quick questions | Pick what pulls at you |
|---|---|---|
| ![Welcome](docs/images/welcome.png) | ![Scale question](docs/images/quiz-scale.png) | ![Interests question](docs/images/quiz-interests.png) |

### On the web

| Desktop | Phone |
|---|---|
| ![Website results](docs/images/website-results.png) | <img src="docs/images/website-phone.jpg" alt="Website on a phone" width="260"> |

Shared links preview like this in Messages, Slack and WhatsApp:

<img src="website/previews/knitting.jpg" alt="Link preview for Knitting" width="480">

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

- [Website](https://amalmehta.github.io/HobbyMaxer/)
- [Instructions](docs/INSTRUCTIONS.md) — set up, run and use
- [File Structure](docs/FILE-STRUCTURE.md) — what's where
