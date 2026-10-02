PROJECT NAME: hobby maxer

META-INSTRUCTIONS:

<Read it all before acting. Ask about anything unclear, contradictory or
 underspecified — before starting and mid-build. Ask in the question widget
 (AskUserQuestion): related questions batched, concrete options, your
 recommendation first. Plain text only if the widget isn't available.>

<Don't expand scope. Anything not listed here is a proposal, including changes
 to this file — propose it, don't do it.>

<Prefer doing over describing: run the code, write the files, test it.>

<Always in scope, no proposal needed: when it goes on GitHub, a README that is
 easy to read at a glance — a line on what it is, then clear visuals
 (screenshots, a diagram or a chart), then links. Everything else goes in
 linked files: docs/INSTRUCTIONS.md (setup, run, use) and
 docs/FILE-STRUCTURE.md (what's where). Also a small unobtrusive feedback tab
 if what you're building is an application rather than a script.>

<If what you're building is an application, build it as a Mac app first; the
 website comes after, as its own step.>

<Name things the way a person would say them — "Goal Tracker", not
 goal_tracker — for the app, its windows, titles, files people open, repo
 descriptions and README headings. When you create the GitHub repo, name it
 with no "_" or "-": one word or joined words, e.g. GoalTracker.>

<Finish by listing every deliverable: path, what it is, how to check it works.>

<Git rules (no Claude attribution, never commit .claude/) are in
 ~/.claude/CLAUDE.md and apply on their own — nothing to repeat here.>

<Keep the changelog at the bottom current.>

CONTEXT:

figure out what sort of hobbies would fit someone, uniquely. then give them a 3 step entry plan into it

OPEN QUESTIONS / ASSUMPTIONS:

<Agent fills in: what it guessed, what it decided without asking.>

Asked and answered (2026-10-01):
- Matching: built-in quiz + scoring against a curated catalog, offline, no API key.
- Mac app: native SwiftUI, built with Swift Package Manager into "Hobby Maxer.app".
- Feedback tab: opens a pre-filled email to amal.mehta@gmail.com.
- Scope this session: Mac app + private GitHub repo "HobbyMaxer". Website is a later step.

Decided without asking:
- 11 questions: six 5-point trait scales (solo↔social, indoor↔outdoor, calm↔active,
  head↔hands, skill↔expression, freeform↔structured), goals (up to 2), interests
  (up to 3), startup budget, weekly time, home space.
- Catalog of 64 hobbies, each with a hand-written 3-step plan timed
  "This week / Weeks 2–4 / By month 3". Costs are rough US-dollar estimates.
- Score = 55% trait closeness (strong answers weigh more) + 20% goals + 25% interests;
  going over budget/time/space shrinks the score instead of hiding the hobby, and is
  shown as a caveat.
- "Uniquely": top 6 shown, at most 2 sharing a primary interest; "Not for me" swaps
  in the next match. A test checks ≥90% of hobbies get recommended to some random profile.
- Answers aren't saved between launches; nothing leaves the Mac.
- Developer-only HOBBY_MAXER_DEMO env var opens a screen directly, used for README screenshots
  (you declined letting me click through the app).
- macOS 14+; ad-hoc signed (not notarized).

Website (asked and answered 2026-10-02):
- Hosted on GitHub Pages; repo made public to allow it.
- Catalog + quiz exported from Swift to website/catalog.json (one source of truth);
  scoring ported to JavaScript, with a parity test against 300 Swift results that
  runs before every deploy.
- Website feedback opens a pre-filled GitHub issue (no email address on the web).
- Same flow and look as the Mac app; light/dark; phone layout.

Website, decided without asking:
- Plain HTML/CSS/JS, no framework or build step; nothing stored, nothing sent anywhere.
- ?demo=results / ?demo=quiz:<n> mirror the Mac app's screenshot hook.

Shareable result links (2026-10-02, decided without asking):
- Website only. Links look like ?r=1-131432-010-9-j&h=knitting&x=bonsai: a versioned
  code of the quiz answers, plus the hobby being viewed and any hidden ones.
  Matches are recomputed on open, so old links survive scoring changes.
- The address bar always holds the current result link; "Share these results" uses the
  phone share sheet or copies the link, falling back to a selectable link box if the
  browser blocks the clipboard.
- Opening a link shows "Someone shared these results with you" and "Take the quiz yourself".
- Invalid links fall back to the welcome screen.

Mac app share button (2026-10-02, decided without asking):
- Results sidebar gets "Share these results" (macOS share menu) and "Copy link"; both give
  the website result link, so recipients don't need the app.
- Links are built by ResultLink.swift in the shared core; the website test checks the Swift
  and JavaScript code produce identical links for 300 answer sets.

Proposals (not done — say the word):
- Save/export a plan (PDF, Reminders or Calendar events for the 3 steps).
- Remember answers and past results between launches.
- Optional Claude API mode for free-text, more personal suggestions.
- Notarized, signed release build / DMG on GitHub Releases.
- Let the Mac app open result links itself (a hobbymaxer:// link or "Open in app" on the website).
- Rich link previews (per-result image/title) when pasted into chat apps.

CHANGELOG:

- 2026-10-01 — created
- 2026-10-01 — built v1 Mac app (SwiftUI): 11-question quiz, 64-hobby catalog with 3-step plans, matcher, feedback tab, tests, README + docs; pushed to private GitHub repo HobbyMaxer
- 2026-10-02 — added share button and copy-link to the Mac app (same links as the website)
- 2026-10-02 — added shareable result links to the website
- 2026-10-02 — built the website (website/), shared catalog export + JS/Swift parity test, GitHub Pages deploy; repo made public
- 2026-09-15 — added meta-instruction: built-out applications include a small feedback tab
- 2026-09-15 — added meta-instruction: no "Claude" attribution in commits, PRs, or branches
- 2026-09-16 — added meta-instruction: always include a README when adding to GitHub
- 2026-09-16 — changed meta-instruction: ask clarifying questions in the question widget
- 2026-09-17 — added meta-instructions: Claude never a contributor; never commit .claude/
- 2026-09-26 — compressed the meta-instructions and every field prompt; git rules moved to the global instruction file
- 2026-09-27 — added meta-instruction: applications are built as a Mac app first, then a website
- 2026-09-28 — folded inputs, instructions, constraints, deliverables and done criteria into one free-form CONTEXT
- 2026-09-28 — changed meta-instruction: a README on GitHub always includes a visual
- 2026-09-28 — added meta-instruction: name things like a person would, never snake_case
- 2026-09-28 — changed meta-instruction: README leads with visuals; instructions live in a linked guide
- 2026-09-28 — changed meta-instruction: README is visuals and links; details in docs/INSTRUCTIONS.md and docs/FILE-STRUCTURE.md
- 2026-09-29 — changed meta-instruction: GitHub repo names have no "_" or "-"
