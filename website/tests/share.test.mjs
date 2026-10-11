// Round-trip and robustness tests for result links.
// Run with: node website/tests/share.test.mjs
import { readFileSync } from "node:fs";
import assert from "node:assert/strict";
import { codeFor, decode, encode, profileFromCode, sharePath, slug } from "../share.js";
import { rank } from "../matcher.js";

const data = JSON.parse(readFileSync(new URL("../catalog.json", import.meta.url)));
const fixtures = JSON.parse(readFileSync(new URL("parity.json", import.meta.url)));
let checks = 0;

// Every hobby has a unique slug.
assert.equal(new Set(data.hobbies.map(h => slug(h.name))).size, data.hobbies.length); checks++;

// Links round-trip and reproduce the same matches, for 300 varied answer sets.
for (const f of fixtures) {
  const first = rank(f.profile, data, f.excluding);
  const state = { profile: f.profile, dismissed: f.excluding, selected: first[first.length - 1].hobby.name };
  const back = decode("?" + encode(state, data), data);
  assert.ok(back, encode(state, data));
  assert.deepEqual(rank(back.profile, data, back.dismissed).map(m => m.hobby.name), first.map(m => m.hobby.name));
  assert.equal(back.selected, state.selected);
  assert.deepEqual(back.dismissed, f.excluding);
  // The Mac app builds the exact same links.
  assert.equal(encode(state, data), f.link);
  assert.equal("https://amalmehta.github.io/HobbyMaxer/" + sharePath(state, data), f.url);
  checks++;
}

// Example link from the docs decodes; unknown hobbies are ignored, not fatal.
const ex = decode("?r=1-134322-012-3-1c&h=container-gardening&x=bonsai,no-such-hobby", data);
assert.equal(ex.selected, "Container Gardening");
assert.deepEqual(ex.dismissed, ["Bonsai"]);
assert.deepEqual(ex.profile.goals, ["relax", "challenge"]); checks++;

// Format-1 links (before the location and life questions) still open, with defaults for the new answers.
const old = decode("?r=1-431001-110-3-1c", data);
assert.equal(old.profile.scales.social, 4);
assert.equal(old.profile.scales.competitive, undefined);
assert.deepEqual(old.profile.nearby, []);
assert.equal(old.profile.setting, 1); checks++;

// Every format-2 code round-trips exactly.
for (const f of fixtures) {
  const code = new URLSearchParams(f.link).get("r");
  assert.equal(codeFor(profileFromCode(code, data), data), code); checks++;
}

// Bad or missing codes are rejected.
for (const bad of ["", "?r=", "?r=2-134322-012-3-1c", "?r=1-934322-012-3-1c", "?r=1-13432-012-3-1c", "?r=1-134322-412-3-1c", "?r=1-134322-012-$-1c", "?demo=results"]) {
  assert.equal(decode(bad, data), null, bad); checks++;
}

// Picks beyond the quiz's limits are trimmed (2 goals, 3 interests).
const greedy = decode("?r=1-222222-111-zz-zzzz", data);
assert.equal(greedy.profile.goals.length, 2);
assert.equal(greedy.profile.interests.length, 3); checks++;

console.log(`${checks} share-link checks passed`);
