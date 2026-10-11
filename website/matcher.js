// Port of Sources/HobbyMaxerCore/Matcher.swift — keep the two in step.
// tests/parity.test.mjs checks this file against results exported from Swift.

const PHRASES = {
  social: ["Works great on your own", "Built around other people"],
  outdoor: ["Happens indoors, any weather", "Gets you outside"],
  active: ["Calm and low-impact", "Gets you moving"],
  handsOn: ["Mostly a thinking hobby", "Hands-on and tactile"],
  creative: ["About skill and getting better", "You make or express something"],
  structured: ["Freeform — no right way to do it", "Clear skills to level up through"],
  competitive: ["No pressure to compete", "Plenty of friendly competition"],
  thrill: ["Safe and steady", "A bit of adrenaline"],
  patience: ["Quick early wins", "Something to master over years"],
  screens: ["Gets you off screens", "Screen-friendly"],
  selfTaught: ["Best learned with a teacher or class", "Easy to teach yourself"],
};

// Enum orders, matching the Swift Int raw values.
export const SETTING = ["city", "suburb", "smallTown", "rural"];
export const CLIMATE = ["snowy", "hot", "mild", "rainy"];
export const COMPANY = ["solo", "partner", "family", "friends", "newPeople"];

export function emptyProfile() {
  return {
    scales: {}, goals: [], interests: [], community: [], nearby: [],
    budget: 1, time: 1, space: 0,
    setting: 1, climate: 2, company: 0, schedule: 1, noise: 1, mess: 1, body: 0, travel: 0,
  };
}

const scaleOf = (profile, trait) => profile.scales[trait] ?? 2;

function list(items) {
  if (items.length <= 1) return items.join("");
  return items.slice(0, -1).join(", ") + " and " + items[items.length - 1];
}

export function score(hobby, profile, data) {
  let weighted = 0, totalWeight = 0;
  const strong = [];
  for (const trait of data.traits) {
    const want = scaleOf(profile, trait) / 4;
    const weight = 0.3 + Math.abs(want - 0.5) * 2;
    const distance = Math.abs(want - hobby.traits[trait]);
    weighted += weight * distance;
    totalWeight += weight;
    if (weight >= 0.8 && distance <= 0.3) strong.push({ trait, weight });
  }
  const traitFit = 1 - weighted / totalWeight;

  const sharedGoals = data.goals.filter(g => profile.goals.includes(g.id) && hobby.goals.includes(g.id));
  const goalFit = profile.goals.length === 0 ? 0.5 : sharedGoals.length / profile.goals.length;

  const interestsById = Object.fromEntries(data.interests.map(i => [i.id, i]));
  const sharedInterests = hobby.interests.filter(i => profile.interests.includes(i)).map(i => interestsById[i]);
  const interestFit = profile.interests.length === 0 ? 0.5 : Math.min(1, sharedInterests.length * 0.7);

  let s = 0.55 * traitFit + 0.2 * goalFit + 0.25 * interestFit;
  const has = tag => hobby.tags.includes(tag);
  const social = hobby.traits.social;

  const reasons = strong
    .sort((a, b) => b.weight - a.weight)
    .slice(0, 2)
    .map(m => PHRASES[m.trait][scaleOf(profile, m.trait) > 2 ? 1 : 0]);
  if (sharedInterests.length) reasons.push(`Taps into your love of ${list(sharedInterests.map(i => i.label.toLowerCase()))}`);

  if (hobby.interests.some(i => profile.community.includes(i))) {
    s += social >= 0.6 ? 0.08 : 0.05;
    reasons.push("Popular with people around you");
  }
  if (sharedGoals.length) reasons.push(`Good for: ${list(sharedGoals.map(g => g.label.toLowerCase()))}`);
  const company = COMPANY[profile.company];
  if (company === "newPeople" && social >= 0.7) {
    s += 0.04;
    reasons.push("A natural way to meet new people");
  }
  if (company === "family" && has("familyFriendly")) {
    s += 0.04;
    reasons.push("Easy to do with kids along");
  }
  if (profile.travel === 1 && has("portable")) {
    s += 0.04;
    reasons.push("Comes with you when you travel");
  }

  const caveats = [];
  const costOver = hobby.cost - profile.budget;
  if (costOver > 0) {
    s *= Math.pow(0.6, costOver);
    caveats.push(`Startup cost (${data.costs[hobby.cost].toLowerCase()}) is above your budget`);
  }
  const timeOver = hobby.time - profile.time;
  if (timeOver > 0) {
    s *= Math.pow(0.75, timeOver);
    caveats.push(`Usually takes ${data.times[hobby.time]}`);
  }
  const spaceOver = hobby.space - profile.space;
  if (spaceOver > 0) {
    s *= Math.pow(0.5, spaceOver);
    caveats.push(`Needs ${data.spaces[hobby.space].toLowerCase()}`);
  }
  if (hobby.needs.length) {
    const places = Object.fromEntries(data.places.map(p => [p.id, p]));
    const near = hobby.needs.find(p => profile.nearby.includes(p));
    if (near) {
      reasons.push(`You have ${places[near].short} nearby`);
    } else {
      const factors = profile.nearby.length === 0 ? [1.0, 0.95, 0.8, 0.65] : [0.85, 0.8, 0.65, 0.5];
      const factor = factors[profile.setting];
      if (factor < 1) {
        s *= factor;
        caveats.push(`Needs ${places[hobby.needs[0]].short} nearby`);
      }
    }
  }
  const climate = CLIMATE[profile.climate];
  if (climate === "snowy" && has("seasonal")) {
    s *= 0.88;
    caveats.push("Mostly a warm-weather hobby");
  }
  if (climate === "rainy" && hobby.traits.outdoor >= 0.8) {
    s *= 0.93;
    caveats.push("Weather-dependent where you live");
  }
  if (company === "family" && !has("familyFriendly")) {
    s *= 0.9;
    caveats.push("Harder with kids along");
  }
  if (profile.schedule === 2 && has("scheduled")) {
    s *= 0.8;
    caveats.push("Usually runs on a fixed schedule");
  }
  if (has("loud") && profile.noise !== 0) {
    s *= profile.noise === 2 ? 0.6 : 0.85;
    caveats.push("Can be loud at home");
  }
  if (has("messy") && profile.mess !== 0) {
    s *= profile.mess === 2 ? 0.6 : 0.85;
    caveats.push("Can get messy");
  }
  if (has("highImpact") && profile.body === 1) {
    s *= 0.5;
    caveats.push("High-impact on the body");
  }

  if (costOver <= 0) reasons.push(`Starts ${data.costs[hobby.cost].toLowerCase()}`);

  const final = Math.min(1, Math.max(0, s));
  return { hobby, score: final, percent: Math.round(final * 100), reasons, caveats };
}

/** Top matches, at most two sharing a primary interest. */
export function rank(profile, data, excluding = [], limit = 6) {
  const scored = data.hobbies
    .filter(h => !excluding.includes(h.name))
    .map(h => score(h, profile, data))
    .sort((a, b) => a.score !== b.score ? b.score - a.score : (a.hobby.name < b.hobby.name ? -1 : 1));
  const picked = [], perInterest = {};
  for (const m of scored) {
    if (picked.length >= limit) break;
    const primary = m.hobby.interests[0];
    if ((perInterest[primary] ?? 0) >= 2) continue;
    perInterest[primary] = (perInterest[primary] ?? 0) + 1;
    picked.push(m);
  }
  return picked;
}
