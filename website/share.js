// Shareable result links and stored answers: quiz answers packed into a short, versioned code.
//
//   ?r=2-13143233013-012-9-j-12010100-1d-6&h=knitting&x=bonsai
//      │ │           │   │ │ │        │  └ community interests bitmask (base 36, catalog.json "interests" order)
//      │ │           │   │ │ │        └ nearby places bitmask (base 36, catalog.json "places" order)
//      │ │           │   │ │ └ setting, climate, company, schedule, noise, mess, body, travel
//      │ │           │   │ └ interests bitmask
//      │ │           │   └ goals bitmask
//      │ │           └ budget, time, space
//      │ └ eleven trait scales, 0–4, in catalog.json "traits" order
//      └ format version (format 1 — six scales, no life/location answers — is still read)
//   h = hobby being viewed, x = hobbies hidden with "Not for me" (both optional)
//
// Shared links put the hobby and its match % in the path instead — h/<slug>/<percent>/?r=…&x=… —
// so chat apps load that preview page (built at deploy) and show "a 79% match" in a rich
// preview; the page forwards here. Sources/HobbyMaxerCore/ResultLink.swift is the Swift side.
//
// Matches are recomputed from the answers, so links keep working when scoring changes.
// New options must be added at the end of their lists to keep old links valid.

import { emptyProfile, score } from "./matcher.js";

export const slug = name => name.toLowerCase().replace(/&/g, "and").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

const mask = (ids, all) => all.reduce((m, o, i) => (ids.includes(o.id) ? m | (1 << i) : m), 0).toString(36);
const unmask = (code, all) => {
  const m = parseInt(code, 36);
  return all.filter((_, i) => m & (1 << i)).map(o => o.id);
};
const LIFE = ["setting", "climate", "company", "schedule", "noise", "mess", "body", "travel"];

/** The answers as a format-2 code ("2-…"). */
export function codeFor(p, data) {
  return [
    "2",
    data.traits.map(t => p.scales[t] ?? 2).join(""),
    `${p.budget}${p.time}${p.space}`,
    mask(p.goals, data.goals),
    mask(p.interests, data.interests),
    LIFE.map(k => p[k]).join(""),
    mask(p.nearby, data.places),
    mask(p.community, data.interests),
  ].join("-");
}

/** Reads a format 1 or 2 answers code; null if it isn't one. */
export function profileFromCode(code, data) {
  const profile = emptyProfile();
  const v1 = /^1-([0-4]{6})-([0-3])([0-2])([0-2])-([0-9a-z]{1,4})-([0-9a-z]{1,4})$/.exec(code ?? "");
  const v2 = /^2-([0-4]{11})-([0-3])([0-2])([0-2])-([0-9a-z]{1,4})-([0-9a-z]{1,4})-([0-3][0-3][0-4][0-2][0-2][0-2][01][01])-([0-9a-z]{1,4})-([0-9a-z]{1,4})$/.exec(code ?? "");
  const m = v1 ?? v2;
  if (!m) return null;
  const [, scales, budget, time, space, goals, interests] = m;
  [...scales].forEach((v, i) => { profile.scales[data.traits[i]] = Number(v); });
  Object.assign(profile, {
    budget: Number(budget), time: Number(time), space: Number(space),
    goals: unmask(goals, data.goals).slice(0, 2),
    interests: unmask(interests, data.interests).slice(0, 3),
  });
  if (v2) {
    [...v2[7]].forEach((v, i) => { profile[LIFE[i]] = Number(v); });
    profile.nearby = unmask(v2[8], data.places);
    profile.community = unmask(v2[9], data.interests).slice(0, 3);
  }
  return profile;
}

export function encode(state, data) {
  const params = new URLSearchParams();
  params.set("r", codeFor(state.profile, data));
  if (state.selected) params.set("h", slug(state.selected));
  if (state.dismissed.length) params.set("x", state.dismissed.map(slug).join(","));
  return params.toString().replace(/%2C/g, ",");
}

/** Path + query to share, relative to the site root: "h/<slug>/<percent>/?r=…" (or "?r=…" with no hobby open). */
export function sharePath(state, data) {
  const rest = encode({ ...state, selected: null }, data);
  const hobby = data.hobbies.find(h => h.name === state.selected);
  if (!hobby) return "?" + rest;
  return `h/${slug(hobby.name)}/${score(hobby, state.profile, data).percent}/?${rest}`;
}

/** Returns { profile, selected, dismissed } or null if the link isn't a valid result link. */
export function decode(search, data) {
  const params = new URLSearchParams(search);
  const profile = profileFromCode(params.get("r"), data);
  if (!profile) return null;
  const byslug = Object.fromEntries(data.hobbies.map(h => [slug(h.name), h.name]));
  return {
    profile,
    selected: byslug[params.get("h")] ?? null,
    dismissed: (params.get("x") ?? "").split(",").map(s => byslug[s]).filter(Boolean),
  };
}
