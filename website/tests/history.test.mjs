// Saved history: answers, runs, statuses and plan progress survive a reload.
// Run with: node website/tests/history.test.mjs
import { readFileSync } from "node:fs";
import assert from "node:assert/strict";

// A stand-in for the browser's localStorage.
const mem = new Map();
globalThis.localStorage = { getItem: k => mem.get(k) ?? null, setItem: (k, v) => mem.set(k, String(v)) };

const store = await import("../history.js");
const { rank } = await import("../matcher.js");
const data = JSON.parse(readFileSync(new URL("../catalog.json", import.meta.url)));
const fixtures = JSON.parse(readFileSync(new URL("parity.json", import.meta.url)));

// First visit: empty.
let h = store.load();
assert.equal(h.runs.length, 0);
assert.equal(store.lastProfile(h, data), null);

// Two quiz runs, recorded and saved.
const [a, b] = fixtures;
store.record(h, a.profile, rank(a.profile, data), data);
store.record(h, b.profile, rank(b.profile, data), data);
assert.ok(store.save(h));

// Reload: answers and runs come back, and the last answers reproduce the same matches.
h = store.load();
assert.equal(h.runs.length, 2);
assert.match(h.runs[0].date, /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ$/, "dates match Swift's ISO-8601 format");
const last = store.lastProfile(h, data);
assert.deepEqual(rank(last, data).map(m => m.hobby.name), rank(b.profile, data).map(m => m.hobby.name));

// Statuses and steps.
const first = h.runs[0].matches[0].name;
store.toggleStep(h, first, 1);
assert.equal(store.stepDone(h, first, 1), true);
assert.equal(h.statuses[first], "trying", "ticking a step marks the hobby as trying");
store.toggleStep(h, first, 1);
assert.equal(h.steps[first], undefined, "unticking everything clears progress");
store.setStatus(h, first, "notForMe");
assert.deepEqual(store.notForMe(h), [first]);
store.setStatus(h, first, null);
assert.deepEqual(store.notForMe(h), []);

// Summaries: every suggested hobby, with counts and first/latest match.
store.setStatus(h, "Chess", "interested");
const sums = store.summaries(h);
const all = new Set([...h.runs.flatMap(r => r.matches.map(m => m.name)), "Chess"]);
assert.equal(sums.length, all.size);
const top = sums.find(s => s.name === h.runs[1].matches[0].name);
assert.equal(top.latestPercent, h.runs[1].matches[0].percent);
assert.equal(sums.find(s => s.name === "Chess").status, "interested");

// Broken or blocked storage never crashes.
mem.set("hobbymaxer.history", "{not json");
assert.equal(store.load().runs.length, 0);
globalThis.localStorage = { getItem() { throw new Error("blocked"); }, setItem() { throw new Error("blocked"); } };
assert.equal(store.load().runs.length, 0);
assert.equal(store.save(h), false);

console.log("history checks passed");
