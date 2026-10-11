# Hobby Maxer

A Mac app and website that figure out which hobbies fit you — where you live, how you live — give you a 3-step plan to start one, and track how it goes.

**[Try it on the web →](https://amalmehta.github.io/HobbyMaxer/)**

![Your matches and a 3-step entry plan](docs/images/results.png)

| My hobbies, tracked over time | 26 questions, incl. where you live | Welcome back |
|---|---|---|
| ![My hobbies](docs/images/my-hobbies.png) | ![What's near you question](docs/images/quiz-nearby.png) | ![Welcome back](docs/images/welcome.png) |

### On the web

| Desktop | Phone |
|---|---|
| ![Website results](docs/images/website-results.jpg) | <img src="docs/images/website-phone.jpg" alt="Website on a phone" width="260"> |

Shared links preview like this in Messages, Slack and WhatsApp:

<img src="website/previews/knitting.jpg" alt="Link preview for Knitting" width="480">

## How it matches

```mermaid
flowchart LR
    Q["26 questions"] --> T["11 traits<br/>social · outdoor · active · hands-on<br/>creative · structured · competitive<br/>thrill · patience · screens · self-taught"]
    Q --> G["Goals + interests<br/>+ what your community likes"]
    Q --> W["Where you live<br/>setting · climate · what's nearby"]
    Q --> L["Your life<br/>budget · time · space · noise<br/>mess · schedule · company · body"]
    C[("86 hobbies")] --> S{"Score each hobby"}
    T --> S
    G -- "small boosts" --> S
    W -- "missing places shrink the score" --> S
    L -- "over a limit shrinks the score" --> S
    S --> R["Top 6, kept varied"] --> P["Why it fits + 3-step plan"] --> H[("Saved: history,<br/>status, steps done")]
```

## Links

- [Website](https://amalmehta.github.io/HobbyMaxer/)
- [Instructions](docs/INSTRUCTIONS.md) — set up, run and use
- [File Structure](docs/FILE-STRUCTURE.md) — what's where
