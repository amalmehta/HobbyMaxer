// Saved answers, past quiz runs and hobby progress, kept in this browser's localStorage.
// Same JSON shape as the Mac app's History (Sources/HobbyMaxerCore/History.swift).
import { codeFor, profileFromCode } from "./share.js";

const KEY = "hobbymaxer.history";
const MAX_RUNS = 200;
export const STATUSES = [
  { id: "interested", label: "Interested" },
  { id: "trying", label: "Trying it" },
  { id: "notForMe", label: "Not for me" },
];

const empty = () => ({ version: 1, lastCode: null, runs: [], statuses: {}, steps: {} });
// Swift's ISO-8601 dates have no milliseconds; match them so files stay interchangeable.
const now = () => new Date().toISOString().replace(/\.\d{3}Z$/, "Z");

/** Loads saved history; private windows or blocked storage just start empty. */
export function load() {
  try {
    const saved = JSON.parse(localStorage.getItem(KEY));
    return saved && saved.version === 1 ? { ...empty(), ...saved } : empty();
  } catch {
    return empty();
  }
}

/** Returns false if the browser wouldn't let us save. */
export function save(history) {
  try {
    localStorage.setItem(KEY, JSON.stringify(history));
    return true;
  } catch {
    return false;
  }
}

export const lastProfile = (history, data) => (history.lastCode ? profileFromCode(history.lastCode, data) : null);
export const notForMe = history => Object.keys(history.statuses).filter(n => history.statuses[n] === "notForMe");
export const stepDone = (history, name, i) => Boolean(history.steps[name]?.[i]);

export function record(history, profile, matches, data) {
  const code = codeFor(profile, data);
  history.lastCode = code;
  history.runs.push({ date: now(), code, matches: matches.map(m => ({ name: m.hobby.name, percent: m.percent })) });
  if (history.runs.length > MAX_RUNS) history.runs.splice(0, history.runs.length - MAX_RUNS);
}

export function setStatus(history, name, status) {
  if (status) history.statuses[name] = status;
  else delete history.statuses[name];
}

export function toggleStep(history, name, i) {
  const done = history.steps[name] ?? [false, false, false];
  while (done.length <= i) done.push(false);
  done[i] = !done[i];
  if (done.includes(true)) history.steps[name] = done;
  else delete history.steps[name];
  // Ticking off a step means you're trying it.
  if (done.includes(true) && !history.statuses[name]) history.statuses[name] = "trying";
}

/** Every hobby ever suggested or marked, most recently seen first. */
export function summaries(history) {
  const names = [], seen = new Set();
  for (const run of [...history.runs].reverse()) {
    for (const m of run.matches) if (!seen.has(m.name)) { seen.add(m.name); names.push(m.name); }
  }
  for (const name of [...Object.keys(history.statuses), ...Object.keys(history.steps)].sort()) {
    if (!seen.has(name)) { seen.add(name); names.push(name); }
  }
  return names.map(name => {
    const hits = history.runs.flatMap(r => r.matches.filter(m => m.name === name).map(m => ({ date: r.date, percent: m.percent })));
    return {
      name,
      timesSuggested: hits.length,
      firstSeen: hits[0]?.date ?? null,
      lastSeen: hits.at(-1)?.date ?? null,
      firstPercent: hits[0]?.percent ?? null,
      latestPercent: hits.at(-1)?.percent ?? null,
      status: history.statuses[name] ?? null,
      stepsDone: (history.steps[name] ?? []).filter(Boolean).length,
    };
  });
}
