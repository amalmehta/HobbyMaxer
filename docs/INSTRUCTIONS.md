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

1. Click **Start the quiz** and answer 26 questions in three parts — **You** (11 personality scales, goals, interests), **Where you live** (city to countryside, climate, what's near you, what your community is into) and **Your life** (who with, when you're free, budget, time, space, noise, mess, physical limits, travel). Return = Next, Esc = Back.
2. Your top 6 matches appear on the left with a match score. Click one to see **why it fits you** and your **3-step entry plan** (this week → weeks 2–4 → by month 3).
3. Not feeling one? **Not for me — show another** swaps in the next best match and leaves it out of future quizzes (undo it in My hobbies).
   On each hobby, set **Where are you with it?** (Interested / Trying it / Not for me) and tick off plan steps as you do them — ticking a step marks it as "Trying it".
   **My hobbies** (⌘Y) lists everything you've ever been suggested, grouped by status, with how often it came up and how its match changed (e.g. 89% → 87%), plus your past quizzes, which you can reopen.
   **Everything is saved** between launches in `~/Library/Application Support/Hobby Maxer/history.json`. Next time you open the app it says welcome back, and **Retake the quiz** starts from your last answers.
4. **Share these results** (Messages, Mail, AirDrop…) or **Copy link** gives a website link that opens exactly these matches — anyone can open it in a browser, no app needed.
5. **Opening links in the app:** click a `hobbymaxer://` link (the website shows **Open in the Mac app** on Macs), or choose **File ▸ Open Result Link…** (⌘L) and paste any Hobby Maxer website link — it pre-fills if one is on your clipboard. Shared results show **Shared with you** and **Take the quiz yourself**.
   The `hobbymaxer://` link type is registered when `build-app.sh` runs (and whenever macOS first sees the app). Ordinary `https://` website links still open in the browser — making them open the app directly would need a notarized app and a domain the app is verified with, which a GitHub project site can't provide.
6. **Retake quiz** (or ⇧⌘R) starts over.
7. The small **Feedback** tab in the corner opens a pre-filled email.

Nothing leaves your Mac — matching runs offline against the built-in catalog.

## The website

Live at **https://amalmehta.github.io/HobbyMaxer/** — same quiz, same 86 hobbies, same results as the Mac app, with the same saving, statuses, plan tick-offs and My hobbies. The website saves in that browser (localStorage), so each browser keeps its own history; private windows or blocked storage still work but forget on reload (the page says so). It is plain HTML, CSS and JavaScript in `website/`, with no build step.

Run it locally (it loads `catalog.json`, so it needs a web server, not a double-click):

```bash
python3 -m http.server 8765 --directory website
```

Then open http://localhost:8765. Feedback on the website opens a pre-filled GitHub issue.

**Sharing results:** on the results screen the address bar always holds a link to exactly what you're seeing — your answers, the hobby you're viewing, and any you hid with "Not for me". **🔗 Share these results** copies it (or opens the share sheet on a phone). Whoever opens it sees the same matches, marked as shared, with a button to take the quiz themselves. Links contain only quiz answers; matches are recomputed when opened. The format is documented at the top of `website/share.js`.

**Link previews:** shared links go through a small static page for the hobby and its match % (`…/h/knitting/79/?r=…`) that carries Open Graph tags, so Messages, Slack, WhatsApp and others show "Knitting — a 79% match for me" with the hobby's preview image (emoji, tagline, 3 steps); the page then forwards to the results. There's one page per hobby per percentage (64 × 101), plus `…/h/knitting/` without a %. The image carries a "~80%" badge rounded to the nearest 5% (25%–100%; plain card below 25%), while the title shows the exact %. The main site has its own preview.

Only the inputs are committed: one card per hobby (`website/previews/<hobby>.jpg`) and the badge pieces (`website/previews/badges/`), drawn on a Mac by `swift run ExportCatalog website` — re-run it after editing hobbies and commit the result. The 6,528 pages and 1,024 badged cards are built from those by `scripts/previews/build.mjs` during each GitHub deploy (about a minute), so they never land in git. To build them locally: `cp -R website /tmp/site && npm ci --prefix scripts/previews && node scripts/previews/build.mjs /tmp/site`. Chat apps cache previews, so a changed image may take a while to show up for a link that was already shared.

Website tests:

```bash
node website/tests/parity.test.mjs
node website/tests/share.test.mjs
node website/tests/history.test.mjs
node website/tests/previews.test.mjs /tmp/site   # after building the previews as above
```

**Deploying:** every push to `main` that touches `website/` runs `.github/workflows/website.yml`, which checks the website still matches the Mac app and publishes to GitHub Pages (repo Settings → Pages → Source: GitHub Actions).

## The preview image server

`og/` is a tiny Vercel project that draws link-preview images with the exact match %: `GET /<hobby>/<percent>.png` lays the pre-drawn badge `website/previews/badges/<percent>.png` over the hobby card `website/previews/<hobby>.jpg` (both fetched from the live site) and returns a 1200×630 PNG, cached for a year. Unknown hobbies or percentages outside 0–100 get a 404.

- **Deploy:** Vercel is connected to this repo with Root Directory `og`, so every push redeploys it.
- **Test locally:** serve the website (`python3 -m http.server 8766 --directory website`), then `cd og && npm install && PREVIEW_ASSETS=http://localhost:8766/previews/ npm test` — it renders `og/test/knitting-79.png` and checks bad requests are refused.
- **Switching pages to it:** set `IMAGE_SERVER` in `scripts/previews/build.mjs` to the Vercel address and push; the next deploy points the pages at it and stops building the badged cards.

## Edit the hobbies

All hobbies live in `Sources/HobbyMaxerCore/Catalog.swift`. Each entry has a name, emoji, tagline, six trait values (0–1), cost, time, space, goals, interests (first = primary) and three plan steps. Then update the website and check both still agree:

```bash
swift test
swift run ExportCatalog website
node website/tests/parity.test.mjs
```

`ExportCatalog` writes `website/catalog.json` (what the site loads) and `website/tests/parity.json` (300 sample answers with the Mac app's results). `parity.json` also holds the link the Mac app builds for each answer set, and `share.test.mjs` checks the website builds the identical one. The parity test fails if the website's matcher (`website/matcher.js`) disagrees with the Swift one — if you change scoring in `Matcher.swift`, make the same change in `matcher.js`.

## Screenshots (for maintainers)

The app accepts a developer-only environment variable that opens it straight to a screen with a sample profile, so README images can be captured with `screencapture`:

```bash
HOBBY_MAXER_DEMO=results "build/Hobby Maxer.app/Contents/MacOS/HobbyMaxer"
```

Use `quiz:<n>` (0–10) to open a specific question. The website does the same with `?demo=results` or `?demo=quiz:<n>`.
