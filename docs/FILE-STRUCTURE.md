# File Structure

```
Hobby Maxer
├── README.md                     At-a-glance overview
├── hobby maxer.md                Project brief, decisions and changelog
├── Package.swift                 Swift package: core library, app, tests
├── scripts/
│   ├── build-app.sh              Builds "build/Hobby Maxer.app"
│   └── make-icon.swift           Draws the app icon
├── Sources/
│   ├── HobbyMaxerCore/           Logic (no UI) — tested
│   │   ├── Models.swift          Traits, cost/time/space, goals, interests, Hobby, Profile
│   │   ├── Catalog.swift         The 64 hobbies and their 3-step plans
│   │   ├── Quiz.swift            The 11 questions
│   │   └── Matcher.swift         Scoring, reasons/caveats, varied top-6 ranking
│   └── HobbyMaxer/               The Mac app (SwiftUI)
│       ├── HobbyMaxerApp.swift   App entry, window, app state
│       ├── ContentView.swift     Screen switcher + welcome screen
│       ├── QuizView.swift        Question screens (scale, chips, options)
│       ├── ResultsView.swift     Match list + hobby detail and plan
│       └── FeedbackTab.swift     Corner feedback tab (opens an email)
├── Tests/HobbyMaxerCoreTests/    Catalog and matcher tests
└── docs/
    ├── INSTRUCTIONS.md           Setup, run, use
    ├── FILE-STRUCTURE.md         This file
    └── images/                   README screenshots
```

`build/` and `.build/` are generated and not committed.
