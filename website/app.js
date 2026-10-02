import { emptyProfile, rank } from "./matcher.js";
import { decode, encode, sharePath } from "./share.js";

const ISSUE_URL = "https://github.com/amalmehta/HobbyMaxer/issues/new";
const app = document.getElementById("app");

const state = { stage: "welcome", index: 0, profile: emptyProfile(), dismissed: [], selected: null, shared: false };
let data;

const esc = s => String(s).replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);

// Developer hook for screenshots, matching the Mac app: ?demo=results or ?demo=quiz:<n>
function applyDemo() {
  const demo = new URLSearchParams(location.search).get("demo");
  if (!demo) return;
  Object.assign(state.profile, {
    scales: { social: 1, outdoor: 3, active: 1, handsOn: 4, creative: 3, structured: 2 },
    goals: ["relax", "makeThings"], interests: ["nature", "food", "crafts"],
  });
  if (demo === "results") showResults();
  const n = /^quiz:(\d+)$/.exec(demo)?.[1];
  if (n !== undefined && data.questions[n]) Object.assign(state, { stage: "quiz", index: Number(n) });
}

// Opening a result link goes straight to those results.
function applyShareLink() {
  const shared = decode(location.search, data);
  if (shared) Object.assign(state, shared, { stage: "results", shared: true });
  return Boolean(shared);
}

const shareURL = () => `${location.origin}${location.pathname}${sharePath(state, data)}`;
// iPads also report "Macintosh"; touch support tells them apart.
const onMac = /Macintosh/.test(navigator.userAgent) && navigator.maxTouchPoints === 0;

// Keep the address bar in step: a result link on the results screen, a clean URL elsewhere.
function syncURL() {
  if (new URLSearchParams(location.search).has("demo")) return;
  const target = state.stage === "results" ? `${location.pathname}?${encode(state, data)}` : location.pathname;
  if (target !== location.pathname + location.search) history.replaceState(null, "", target);
}

function render() {
  if (state.stage === "welcome") renderWelcome();
  else if (state.stage === "quiz") renderQuiz();
  else renderResults();
  syncURL();
}

function renderWelcome() {
  document.title = "Hobby Maxer";
  app.innerHTML = `
    <section class="welcome">
      <div class="logo">🎯</div>
      <h1>Hobby Maxer</h1>
      <p class="muted">Answer ${data.questions.length} quick questions about how you like to spend your time.
        Get hobbies that fit you — and a 3-step plan to start one.</p>
      <button class="btn primary" data-action="start">Start the quiz</button>
      <p class="muted small">${data.hobbies.length} hobbies · about 2 minutes · nothing leaves your browser</p>
    </section>`;
}

function renderQuiz() {
  const q = data.questions[state.index];
  const total = data.questions.length;
  const last = state.index === total - 1;
  document.title = `Question ${state.index + 1} · Hobby Maxer`;
  app.innerHTML = `
    <section class="quiz">
      <div class="progress" role="progressbar" aria-valuemin="1" aria-valuemax="${total}" aria-valuenow="${state.index + 1}">
        <div style="width:${((state.index + 1) / total) * 100}%"></div></div>
      <p class="counter">Question ${state.index + 1} of ${total}</p>
      <div class="question">
        <h2>${esc(q.prompt)}</h2>
        <p class="hint">${esc(q.hint)}</p>
        ${answerHTML(q)}
      </div>
      <div class="nav">
        <button class="btn" data-action="back">Back</button>
        <button class="btn primary" data-action="next">${last ? "See my hobbies" : "Next"}</button>
      </div>
    </section>`;
}

function answerHTML(q) {
  const p = state.profile;
  switch (q.kind) {
    case "scale": {
      const value = p.scales[q.trait] ?? 2;
      const labels = [`Strongly ${q.left}`, q.left, "In between", q.right, `Strongly ${q.right}`];
      const dots = [44, 34, 26, 34, 44].map((size, i) =>
        `<button class="dot" data-action="scale" data-value="${i}" aria-pressed="${value === i}" aria-label="${esc(labels[i])}">
           <span style="width:${size}px;height:${size}px"></span></button>`).join("");
      return `<div class="scale"><span class="pole left">${esc(q.left)}</span><div class="dots">${dots}</div><span class="pole">${esc(q.right)}</span></div>`;
    }
    case "goals":
    case "interests": {
      const chosen = p[q.kind];
      return `<div class="chips">${data[q.kind].map(o => {
        const on = chosen.includes(o.id);
        const full = !on && chosen.length >= q.max;
        return `<button class="chip" data-action="toggle" data-key="${q.kind}" data-max="${q.max}" data-value="${o.id}"
                  aria-pressed="${on}" ${full ? "disabled" : ""}>${o.emoji}&nbsp; ${esc(o.label)}</button>`;
      }).join("")}</div>`;
    }
    default: {
      const key = q.kind; // budget | time | space
      const labels = { budget: data.costs, time: data.times, space: data.spaces }[key];
      return `<div class="options" role="radiogroup">${labels.map((label, i) =>
        `<button class="option" role="radio" data-action="pick" data-key="${key}" data-value="${i}" aria-checked="${p[key] === i}">
           ${esc(label)}<span class="check"></span></button>`).join("")}</div>`;
    }
  }
}

function renderResults() {
  const matches = rank(state.profile, data, state.dismissed);
  if (!matches.some(m => m.hobby.name === state.selected)) state.selected = matches[0]?.hobby.name ?? null;
  const match = matches.find(m => m.hobby.name === state.selected);
  document.title = match ? `${match.hobby.name} · Hobby Maxer` : "Hobby Maxer";
  app.innerHTML = `
    <section class="results">
      <nav class="sidebar" aria-label="Your matches">
        ${state.shared ? `<p class="shared-note">Someone shared these results with you.</p>` : ""}
        <h2>${state.shared ? "Shared matches" : "Your matches"}</h2>
        ${matches.map(m => `
          <button class="match" data-action="select" data-value="${esc(m.hobby.name)}" aria-current="${m === match}">
            <span class="emoji">${m.hobby.emoji}</span>
            <span><strong>${esc(m.hobby.name)}</strong>
              <span class="bar"><span class="track"><span class="fill" style="width:${m.percent}%"></span></span>${m.percent}% match</span></span>
          </button>`).join("")}
        <div class="sidebar-actions">
          <button class="btn primary" data-action="share" aria-live="polite">🔗 Share these results</button>
          <button class="btn" data-action="retake">${state.shared ? "Take the quiz yourself" : "Retake quiz"}</button>
          ${onMac ? `<a class="app-link" href="hobbymaxer://results?${encode(state, data)}"
              title="Needs the Hobby Maxer Mac app">Open in the Mac app</a>` : ""}
        </div>
      </nav>
      ${match ? detailHTML(match) : `<p class="detail muted">No more matches — retake the quiz.</p>`}
    </section>`;
}

function detailHTML(m) {
  const h = m.hobby;
  return `
    <article class="detail" id="detail">
      <div class="head">
        <span class="emoji">${h.emoji}</span>
        <div>
          <h1>${esc(h.name)}</h1>
          <p>${esc(h.tagline)}</p>
          <div class="pills"><span class="pill strong">${m.percent}% match</span>
            <span class="pill">${esc(data.costs[h.cost])}</span><span class="pill">${esc(data.times[h.time])}</span></div>
        </div>
      </div>
      <h3>Why it fits you</h3>
      <ul class="why">
        ${m.reasons.map(r => `<li>${esc(r)}</li>`).join("")}
        ${m.caveats.map(c => `<li class="caveat">${esc(c)}</li>`).join("")}
      </ul>
      <h2>Your 3-step entry plan</h2>
      ${h.steps.map((s, i) => `
        <div class="step"><span class="num">${i + 1}</span>
          <div><span class="when">${esc(data.timing[i])}</span><strong>${esc(s.title)}</strong><p>${esc(s.detail)}</p></div>
        </div>`).join("")}
      <button class="link-btn" data-action="dismiss" data-value="${esc(h.name)}" title="Hide this hobby and bring in the next best match">
        Not for me — show another</button>
    </article>`;
}

function showResults() {
  state.dismissed = [];
  state.selected = null;
  state.stage = "results";
}

const actions = {
  start() { state.stage = "quiz"; state.index = 0; },
  next() { if (state.index === data.questions.length - 1) showResults(); else state.index++; },
  back() { if (state.index === 0) state.stage = "welcome"; else state.index--; },
  scale(el) { state.profile.scales[data.questions[state.index].trait] = Number(el.dataset.value); },
  toggle(el) {
    const list = state.profile[el.dataset.key], v = el.dataset.value;
    if (list.includes(v)) list.splice(list.indexOf(v), 1);
    else if (list.length < Number(el.dataset.max)) list.push(v);
  },
  pick(el) { state.profile[el.dataset.key] = Number(el.dataset.value); },
  select(el) {
    state.selected = el.dataset.value;
    render();
    if (matchMedia("(max-width: 760px)").matches) document.getElementById("detail")?.scrollIntoView({ behavior: "smooth" });
    return true;
  },
  dismiss(el) { state.dismissed.push(el.dataset.value); },
  retake() { Object.assign(state, { stage: "welcome", index: 0, profile: emptyProfile(), dismissed: [], selected: null, shared: false }); },
  share(el) {
    const url = shareURL();
    const done = label => { el.textContent = label; setTimeout(() => { el.textContent = "🔗 Share these results"; }, 2000); };
    // Phones get the system share sheet; elsewhere the link is copied.
    if (navigator.share && matchMedia("(pointer: coarse)").matches) {
      navigator.share({ title: "My Hobby Maxer matches", url }).catch(() => {});
    } else {
      const showLink = () => {
        // Clipboard blocked: show the link, selected, so it can be copied by hand.
        let box = el.parentElement.querySelector(".share-link");
        if (!box) {
          box = Object.assign(document.createElement("input"), { className: "share-link", readOnly: true });
          box.setAttribute("aria-label", "Link to these results");
          el.after(box);
        }
        box.value = url;
        box.focus();
        box.select();
        done("Copy the link below");
      };
      (navigator.clipboard?.writeText(url) ?? Promise.reject()).then(() => done("✓ Link copied"), showLink);
    }
    return true;
  },
};

app.addEventListener("click", e => {
  const el = e.target.closest("[data-action]");
  if (!el || el.disabled) return;
  const rendered = actions[el.dataset.action](el);
  if (!rendered) render();
  const focus = el.dataset.action === "next" || el.dataset.action === "back" || el.dataset.action === "start";
  if (focus) app.querySelector(`[data-action="${el.dataset.action === "start" ? "next" : el.dataset.action}"]`)?.focus();
});

document.addEventListener("keydown", e => {
  if (state.stage !== "quiz" || document.querySelector("dialog[open]")) return;
  if (e.key === "Enter" && !e.target.closest("button")) { e.preventDefault(); actions.next(); render(); }
  if (e.key === "Escape") { actions.back(); render(); }
});

// Feedback tab
const dialog = document.getElementById("feedback");
const text = document.getElementById("feedback-text");
const send = document.getElementById("feedback-send");
document.getElementById("feedback-tab").addEventListener("click", () => dialog.showModal());
text.addEventListener("input", () => { send.disabled = !text.value.trim(); });
send.addEventListener("click", () => {
  // Opened directly in the click so pop-up blockers treat it as user-initiated.
  const url = `${ISSUE_URL}?${new URLSearchParams({ title: "Website feedback", body: text.value })}`;
  window.open(url, "_blank", "noopener");
  dialog.close();
  text.value = "";
  send.disabled = true;
});

data = await fetch("catalog.json").then(r => r.json());
if (!applyShareLink()) applyDemo();
render();
