// Every hobby has a link-preview page with Open Graph tags and an image.
// Regenerate with: swift run ExportCatalog website
// Run with: node website/tests/previews.test.mjs
import { existsSync, readFileSync } from "node:fs";
import assert from "node:assert/strict";
import { slug } from "../share.js";

const root = new URL("../", import.meta.url);
const site = "https://amalmehta.github.io/HobbyMaxer/";
const data = JSON.parse(readFileSync(new URL("catalog.json", root)));
const tag = (html, prop) => new RegExp(`<meta (?:property|name)="${prop}" content="([^"]*)"`).exec(html)?.[1];
const unesc = s => s.replace(/&quot;/g, '"').replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&amp;/g, "&");

const home = readFileSync(new URL("index.html", root), "utf8");
assert.equal(tag(home, "og:image"), `${site}previews/default.jpg`);
assert.ok(existsSync(new URL("previews/default.jpg", root)));

for (const hobby of data.hobbies) {
  const s = slug(hobby.name);
  const page = new URL(`h/${s}/index.html`, root);
  assert.ok(existsSync(page), `missing page for ${hobby.name}`);
  const html = readFileSync(page, "utf8");
  assert.equal(unesc(tag(html, "og:title")), `${hobby.name} — a Hobby Maxer match`);
  assert.equal(tag(html, "og:image"), `${site}previews/${s}.jpg`);
  assert.equal(tag(html, "og:url"), `${site}h/${s}/`);
  assert.equal(tag(html, "twitter:card"), "summary_large_image");
  assert.ok(html.includes(`params.set("h", "${s}")`), `${hobby.name} page doesn't forward to the app`);
  for (let pct = 0; pct <= 100; pct++) {
    const sub = readFileSync(new URL(`h/${s}/${pct}/index.html`, root), "utf8");
    const article = [8, 11, 18].includes(pct) || (pct >= 80 && pct <= 89) ? "an" : "a";
    assert.equal(unesc(tag(sub, "og:title")), `${hobby.name} — ${article} ${pct}% match for me`);
    // Badge rounded to the nearest 5%; plain image below 25%.
    const badge = Math.round(pct / 5) * 5;
    const file = badge >= 25 ? `${s}-${badge}.jpg` : `${s}.jpg`;
    assert.equal(tag(sub, "og:image"), `${site}previews/${file}`, `${s}/${pct}`);
    assert.ok(existsSync(new URL(`previews/${file}`, root)), `missing ${file}`);
    assert.equal(tag(sub, "og:url"), `${site}h/${s}/${pct}/`);
    assert.ok(sub.includes(`location.replace("../../../?"`), `${s}/${pct} forwards to the wrong place`);
  }
  const image = readFileSync(new URL(`previews/${s}.jpg`, root));
  assert.equal(image.readUInt16BE(0), 0xffd8, `${s}.jpg isn't a JPEG`);
  assert.ok(image.length < 300_000, `${s}.jpg is too big for chat apps`);
}
console.log(`${data.hobbies.length * 102} preview pages and their images checked`);
