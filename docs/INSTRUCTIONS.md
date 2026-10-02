# Instructions

## Requirements

- macOS 14 (Sonoma) or later
- Xcode or the Xcode Command Line Tools (Swift 5.9+)

## Build the app

```bash
./scripts/build-app.sh
```

This creates **`build/Hobby Maxer.app`** (with its icon). Open it by double-clicking, or:

```bash
open "build/Hobby Maxer.app"
```

Drag it into `/Applications` to keep it. The app is ad-hoc signed, so the first time you open a copy on another Mac you may need to right-click → **Open**.

## Run during development

```bash
swift run HobbyMaxer
```

## Run the tests

```bash
swift test
```

The tests check the catalog (every hobby has a 3-step plan, unique names, valid traits) and the matcher (sensible top picks, budget/space limits, varied results, and that most hobbies get recommended to *someone*).

## Use it

1. Click **Start the quiz** and answer 11 questions (Return = Next, Esc = Back).
2. Your top 6 matches appear on the left with a match score. Click one to see **why it fits you** and your **3-step entry plan** (this week → weeks 2–4 → by month 3).
3. Not feeling one? **Not for me — show another** swaps in the next best match.
4. **Retake quiz** (or ⇧⌘R) starts over.
5. The small **Feedback** tab in the corner opens a pre-filled email.

Nothing leaves your Mac — matching runs offline against the built-in catalog.

## The website

Live at **https://amalmehta.github.io/HobbyMaxer/** — same quiz, same 64 hobbies, same results as the Mac app. It is plain HTML, CSS and JavaScript in `website/`, with no build step.

Run it locally (it loads `catalog.json`, so it needs a web server, not a double-click):

```bash
python3 -m http.server 8765 --directory website
```

Then open http://localhost:8765. Feedback on the website opens a pre-filled GitHub issue.

**Deploying:** every push to `main` that touches `website/` runs `.github/workflows/website.yml`, which checks the website still matches the Mac app and publishes to GitHub Pages (repo Settings → Pages → Source: GitHub Actions).

## Edit the hobbies

All hobbies live in `Sources/HobbyMaxerCore/Catalog.swift`. Each entry has a name, emoji, tagline, six trait values (0–1), cost, time, space, goals, interests (first = primary) and three plan steps. Then update the website and check both still agree:

```bash
swift test
swift run ExportCatalog website
node website/tests/parity.test.mjs
```

`ExportCatalog` writes `website/catalog.json` (what the site loads) and `website/tests/parity.json` (300 sample answers with the Mac app's results). The parity test fails if the website's matcher (`website/matcher.js`) disagrees with the Swift one — if you change scoring in `Matcher.swift`, make the same change in `matcher.js`.

## Screenshots (for maintainers)

The app accepts a developer-only environment variable that opens it straight to a screen with a sample profile, so README images can be captured with `screencapture`:

```bash
HOBBY_MAXER_DEMO=results "build/Hobby Maxer.app/Contents/MacOS/HobbyMaxer"
```

Use `quiz:<n>` (0–10) to open a specific question. The website does the same with `?demo=results` or `?demo=quiz:<n>`.
