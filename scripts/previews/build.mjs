// Builds the link-preview files into a copy of the website at deploy time, so they aren't committed:
//   h/<slug>/index.html and h/<slug>/<0-100>/index.html   6,528 pages with Open Graph tags that
//       forward to the results (chat apps read the tags; they don't run JavaScript)
//   previews/<slug>-<25…100>.jpg                         cards with a "~80%" badge (1,024 images)
// Inputs are committed: website/catalog.json, previews/<slug>.jpg and previews/badges/approx-*.png
// (drawn on a Mac by `swift run ExportCatalog website`).
//
// Usage: node scripts/previews/build.mjs <site-folder>     (e.g. _site, a copy of website/)
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import sharp from "sharp";
import { slug } from "../../website/share.js";

const out = process.argv[2];
if (!out) throw new Error("Usage: node scripts/previews/build.mjs <site-folder>");

const SITE = "https://amalmehta.github.io/HobbyMaxer/";
// The og/ preview server, e.g. "https://hobbymaxer.vercel.app". When set, pages use its exact-% images.
const IMAGE_SERVER = null;
const BADGE_AT = { left: 235, top: 344 }; // on the card's emoji tile; same spot as og/api/og.js

const data = JSON.parse(readFileSync(join(out, "catalog.json"), "utf8"));

/** The rounded badge an exact % shows (nearest 5); null below 25%. */
export const badgeFor = pct => { const b = Math.round(pct / 5) * 5; return b >= 25 ? Math.min(b, 100) : null; };
/** "a 79%" but "an 80%", "an 8%", "an 11%", "an 18%". */
export const article = pct => ([8, 11, 18].includes(pct) || (pct >= 80 && pct <= 89) ? "an" : "a");
const esc = s => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");

function page(hobby, s, pct) {
  const here = `${SITE}h/${s}/` + (pct === null ? "" : `${pct}/`);
  const root = pct === null ? "../../" : "../../../";
  const title = pct === null ? `${hobby.name} — a Hobby Maxer match` : `${hobby.name} — ${article(pct)} ${pct}% match for me`;
  const badge = pct === null ? null : badgeFor(pct);
  const image = IMAGE_SERVER && pct !== null ? `${IMAGE_SERVER}/${s}/${pct}.png`
    : `${SITE}previews/` + (badge ? `${s}-${badge}.jpg` : `${s}.jpg`);
  const note = IMAGE_SERVER && pct !== null ? ` ${article(pct)[0].toUpperCase() + article(pct).slice(1)} ${pct}% match.`
    : badge ? ` About ${article(badge)} ${badge}% match.` : "";
  const description = pct === null ? `${hobby.tagline} See the 3-step plan to get started.`
    : `Hobby Maxer matched me with ${hobby.name}. ${hobby.tagline} Here's the 3-step plan to start.`;
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${esc(hobby.name)} · Hobby Maxer</title>
  <meta name="description" content="${esc(description)}">
  <link rel="canonical" href="${here}">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="Hobby Maxer">
  <meta property="og:title" content="${esc(title)}">
  <meta property="og:description" content="${esc(description)}">
  <meta property="og:url" content="${here}">
  <meta property="og:image" content="${image}">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:image:alt" content="${esc(`${hobby.emoji} ${hobby.name}: ${hobby.tagline}${note}`)}">
  <meta name="twitter:card" content="summary_large_image">
  <!-- Generated at deploy by scripts/previews/build.mjs. -->
  <script>
    const params = new URLSearchParams(location.search);
    params.set("h", "${s}");
    location.replace("${root}?" + params.toString().replace(/%2C/g, ","));
  </script>
</head>
<body>
  <p><a href="${root}">Open Hobby Maxer</a></p>
</body>
</html>
`;
}

let pages = 0, images = 0;
const jobs = [];
for (const hobby of data.hobbies) {
  const s = slug(hobby.name);
  for (const pct of [null, ...Array.from({ length: 101 }, (_, i) => i)]) {
    const dir = join(out, "h", s, pct === null ? "" : String(pct));
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "index.html"), page(hobby, s, pct));
    pages++;
  }
  if (!IMAGE_SERVER) {
    for (let b = 25; b <= 100; b += 5) {
      jobs.push(sharp(join(out, "previews", `${s}.jpg`))
        .composite([{ input: join(out, "previews", "badges", `approx-${b}.png`), ...BADGE_AT }])
        .jpeg({ quality: 80, mozjpeg: true })
        .toFile(join(out, "previews", `${s}-${b}.jpg`)));
      images++;
    }
  }
}
await Promise.all(jobs);
console.log(`Built ${pages} preview pages and ${images} badged cards in ${out}`);
