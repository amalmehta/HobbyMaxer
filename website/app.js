import { emptyProfile, rank } from "./matcher.js";
import { decode, encode, profileFromCode, sharePath } from "./share.js";
import * as store from "./history.js";

const ISSUE_URL = "https://github.com/amalmehta/HobbyMaxer/issues/new";
const app = document.getElementById("app");

const state = {
  stage: "welcome", index: 0, profile: emptyProfile(), dismissed: [], selected: null, shared: false,
  mineSelected: null,
};
let data;
let saved = store.load();
let storageOK = true;

const esc = s => String(s).replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);
const hobbyByName = name => data.hobbies.find(h => h.name === name);
const fmtDate = iso => new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" });
const persist = () => { storageOK = store.save(saved); };

// Developer hook for screenshots, matching the Mac app: ?demo=results, ?demo=mine or ?demo=quiz:<n>
function applyDemo() {
  const demo = new URLSearchParams(location.search).get("demo");
  if (!demo) return;
  Object.assign(state.profile, {
    scales: { social: 1, outdoor: 3, active: 1, handsOn: 4, creative: 3, structured: 2,
              competitive: 0, thrill: 1, patience: 3, screens: 0, selfTaught: 3 },
    goals: ["relax", "makeThings"], interests: ["nature", "food", "crafts"],
    community: ["food", "crafts"], nearby: ["trailsParks", "makerspace", "studios"],
  });
  if (demo === "results") showResults();
  if (demo === "mine") state.stage = "mine";
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
// Your own results leave out hobbies you've marked "Not for me"; someone else's shared results don't.
const excluded = () => (state.shared ? state.dismissed : [...new Set([...state.dismissed, ...store.notForMe(saved)])]);
const currentMatches = () => rank(state.profile, data, excluded());

// Keep the address bar in step: a result link on the results screen, a clean URL elsewhere.
function syncURL() {
  if (new URLSearchParams(location.search).has("demo")) return;
  const target = state.stage === "results" ? `${location.pathname}?${encode(state, data)}` : location.pathname;
  if (target !== location.pathname + location.search) history.replaceState(null, "", target);
}

function render() {
  if (state.stage === "welcome") renderWelcome();
  else if (state.stage === "quiz") renderQuiz();
  else if (state.stage === "mine") renderMine();
  else renderResults();
  syncURL();
}

function renderWelcome() {
  document.title = "Hobby Maxer";
  const last = saved.runs.at(-1);
  const top = last?.matches[0];
  app.innerHTML = `
    <section class="welcome">
      <div class="logo">🎯</div>
      <h1>Hobby Maxer</h1>
      ${last ? `
        <p class="muted">Welcome back.${top ? ` Last quiz ${fmtDate(last.date)} · top match ${esc(top.name)} (${top.percent}%)` : ""}</p>
        <div class="row center">
          <button class="btn primary" data-action="latest">See my latest matches</button>
          <button class="btn" data-action="start">Retake the quiz</button>
          <button class="btn" data-action="mine">My hobbies (${store.summaries(saved).length})</button>
        </div>` : `
        <p class="muted">Answer ${data.questions.length} questions about you, where you live and your life.
          Get hobbies that fit you — and a 3-step plan to start one.</p>
        <button class="btn primary" data-action="start">Start the quiz</button>`}
      <p class="muted small">${data.hobbies.length} hobbies · about 4 minutes · saved in this browser, nothing leaves it</p>
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
      <p class="counter">${esc(q.section)} · Question ${state.index + 1} of ${total}</p>
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
    case "multi": {
      const chosen = p[q.key];
      const max = q.max ?? q.options.length;
      return `<div class="chips">${q.options.map(o => {
        const on = chosen.includes(o.id);
        const full = !on && chosen.length >= max;
        return `<button class="chip" data-action="toggle" data-key="${q.key}" data-max="${max}" data-value="${o.id}"
                  aria-pressed="${on}" ${full ? "disabled" : ""}>${o.emoji}&nbsp; ${esc(o.label)}</button>`;
      }).join("")}</div>`;
    }
    default: // single
      return `<div class="options" role="radiogroup">${q.options.map((label, i) =>
        `<button class="option" role="radio" data-action="pick" data-key="${q.key}" data-value="${i}" aria-checked="${p[q.key] === i}">
           ${esc(label)}<span class="check"></span></button>`).join("")}</div>`;
  }
}

function renderResults() {
  const matches = currentMatches();
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
          <button class="btn" data-action="start">${state.shared ? "Take the quiz yourself" : "Retake quiz"}</button>
          <button class="btn" data-action="mine">My hobbies</button>
          ${onMac ? `<a class="app-link" href="hobbymaxer://results?${encode(state, data)}"
              title="Needs the Hobby Maxer Mac app">Open in the Mac app</a>` : ""}
          ${storageOK ? "" : `<p class="muted small">This browser isn't letting the site save — progress will be lost on reload.</p>`}
        </div>
      </nav>
      ${match ? detailHTML(match) : `<p class="detail muted">No more matches — retake the quiz.</p>`}
    </section>`;
}

function statusHTML(name) {
  const current = saved.statuses[name] ?? "";
  return `
    <div class="status" role="radiogroup" aria-label="Where are you with it?">
      <span class="status-label">Where are you with it?</span>
      ${[{ id: "", label: "Not sure yet" }, ...store.STATUSES].map(s => `
        <button class="seg" role="radio" data-action="status" data-name="${esc(name)}" data-value="${s.id}"
          aria-checked="${current === s.id}">${s.label}</button>`).join("")}
    </div>`;
}

function stepsHTML(h) {
  return `
    <h2>Your 3-step entry plan</h2>
    ${h.steps.map((s, i) => {
      const done = store.stepDone(saved, h.name, i);
      return `
        <div class="step${done ? " done" : ""}"><span class="num">${i + 1}</span>
          <div><span class="when">${esc(data.timing[i])}</span><strong>${esc(s.title)}</strong><p>${esc(s.detail)}</p></div>
          <button class="tick" data-action="step" data-name="${esc(h.name)}" data-value="${i}" aria-pressed="${done}"
            aria-label="${done ? "Done" : "Mark done"}: ${esc(s.title)}" title="${done ? "Mark as not done" : "Mark as done"}">${done ? "✓" : ""}</button>
        </div>`;
    }).join("")}`;
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
      ${statusHTML(h.name)}
      ${stepsHTML(h)}
      <button class="link-btn" data-action="dismiss" data-value="${esc(h.name)}" title="Hide this hobby and leave it out of future matches (undo in My hobbies)">
        Not for me — show another</button>
    </article>`;
}

function renderMine() {
  document.title = "My hobbies · Hobby Maxer";
  const all = store.summaries(saved);
  const groups = [["Trying", "trying"], ["Interested", "interested"], ["Suggested", null], ["Not for me", "notForMe"]]
    .map(([title, status]) => [title, all.filter(s => s.status === status)]).filter(([, rows]) => rows.length);
  if (!state.mineSelected && all.length) state.mineSelected = "hobby:" + all[0].name;
  const sel = state.mineSelected ?? "";
  const row = s => {
    const bits = [];
    if (s.timesSuggested) {
      bits.push(`Suggested ${s.timesSuggested}×`);
      if (s.firstPercent !== null) bits.push(s.firstPercent === s.latestPercent ? `${s.latestPercent}%` : `${s.firstPercent}% → ${s.latestPercent}%`);
    }
    if (s.stepsDone) bits.push(`${s.stepsDone}/3 steps`);
    return `
      <button class="match" data-action="mineSelect" data-value="hobby:${esc(s.name)}" aria-current="${sel === "hobby:" + s.name}">
        <span class="emoji">${hobbyByName(s.name)?.emoji ?? "•"}</span>
        <span><strong>${esc(s.name)}</strong><span class="sub">${esc(bits.join(" · "))}</span></span>
      </button>`;
  };
  app.innerHTML = `
    <section class="results">
      <nav class="sidebar" aria-label="My hobbies">
        <h2>My hobbies</h2>
        ${all.length ? "" : `<p class="muted small">Nothing yet — take the quiz and your suggestions will collect here.</p>`}
        ${groups.map(([title, rows]) => `<p class="group">${title}</p>${rows.map(row).join("")}`).join("")}
        ${saved.runs.length ? `<p class="group">Past quizzes</p>` : ""}
        ${saved.runs.map((r, i) => [r, i]).reverse().map(([r, i]) => `
          <button class="match" data-action="mineSelect" data-value="run:${i}" aria-current="${sel === "run:" + i}">
            <span class="emoji">🗓️</span>
            <span><strong>${fmtDate(r.date)}</strong><span class="sub">${esc(r.matches.slice(0, 3).map(m => m.name).join(", "))}</span></span>
          </button>`).join("")}
        <div class="sidebar-actions">
          ${saved.lastCode ? `<button class="btn primary" data-action="latest">Latest matches</button>` : ""}
          <button class="btn" data-action="home">Home</button>
        </div>
      </nav>
      ${mineDetailHTML(sel, all)}
    </section>`;
}

function mineDetailHTML(sel, all) {
  if (sel.startsWith("run:")) {
    const run = saved.runs[Number(sel.slice(4))];
    if (!run) return "";
    return `
      <article class="detail" id="detail">
        <h1 class="small-h1">Quiz on ${fmtDate(run.date)}</h1>
        ${run.matches.map(m => `
          <div class="run-row"><span class="emoji">${hobbyByName(m.name)?.emoji ?? "•"}</span><strong>${esc(m.name)}</strong>
            <span class="bar"><span class="track"><span class="fill" style="width:${m.percent}%"></span></span>${m.percent}% match</span></div>`).join("")}
        <button class="btn primary" data-action="openRun" data-value="${Number(sel.slice(4))}">Open these results</button>
      </article>`;
  }
  const s = all.find(x => "hobby:" + x.name === sel);
  const h = s && hobbyByName(s.name);
  if (!h) return `<p class="detail muted">${all.length ? "Pick a hobby or a past quiz." : ""}</p>`;
  const times = s.timesSuggested === 1 ? "once" : `${s.timesSuggested} times`;
  let story = s.timesSuggested ? `Suggested ${times}, first on ${fmtDate(s.firstSeen)}` : "";
  if (s.timesSuggested > 1) story += `, last on ${fmtDate(s.lastSeen)}`;
  if (s.timesSuggested && s.firstPercent !== s.latestPercent) story += ` — match went ${s.firstPercent}% → ${s.latestPercent}%`;
  return `
    <article class="detail" id="detail">
      <div class="head">
        <span class="emoji">${h.emoji}</span>
        <div>
          <h1>${esc(h.name)}</h1>
          <p>${esc(h.tagline)}</p>
          <div class="pills">${s.latestPercent !== null ? `<span class="pill strong">${s.latestPercent}% latest match</span>` : ""}
            <span class="pill">${esc(data.costs[h.cost])}</span><span class="pill">${esc(data.times[h.time])}</span></div>
        </div>
      </div>
      ${story ? `<p class="muted">🕘 ${esc(story)}</p>` : ""}
      ${statusHTML(h.name)}
      ${stepsHTML(h)}
    </article>`;
}

function showResults() {
  state.dismissed = [];
  state.selected = null;
  state.stage = "results";
}

function showProfile(profile) {
  Object.assign(state, { profile, shared: false });
  showResults();
}

const actions = {
  start() {
    Object.assign(state, { profile: store.lastProfile(saved, data) ?? emptyProfile(), shared: false, stage: "quiz", index: 0 });
  },
  next() {
    if (state.index < data.questions.length - 1) { state.index++; return; }
    state.shared = false;
    showResults();
    store.record(saved, state.profile, currentMatches(), data);
    persist();
  },
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
  // "Not for me": hides it now and leaves it out of your future matches.
  dismiss(el) {
    state.dismissed.push(el.dataset.value);
    store.setStatus(saved, el.dataset.value, "notForMe");
    persist();
  },
  status(el) {
    const name = el.dataset.name, value = el.dataset.value || null;
    if (value === "notForMe" && state.stage === "results") state.dismissed.push(name);
    store.setStatus(saved, name, value);
    persist();
  },
  step(el) {
    store.toggleStep(saved, el.dataset.name, Number(el.dataset.value));
    persist();
  },
  latest() {
    const p = store.lastProfile(saved, data);
    if (p) showProfile(p); else actions.start();
  },
  mine() { state.stage = "mine"; },
  mineSelect(el) {
    state.mineSelected = el.dataset.value;
    render();
    if (matchMedia("(max-width: 760px)").matches) document.getElementById("detail")?.scrollIntoView({ behavior: "smooth" });
    return true;
  },
  openRun(el) {
    const p = profileFromCode(saved.runs[Number(el.dataset.value)]?.code, data);
    if (p) showProfile(p);
  },
  home() { Object.assign(state, { stage: "welcome", shared: false }); },
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
