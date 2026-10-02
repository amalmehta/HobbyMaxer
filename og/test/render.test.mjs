// Renders a preview locally and checks bad requests are refused.
// Needs the website served locally:  python3 -m http.server 8766 --directory website
// Run with:  cd og && PREVIEW_ASSETS=http://localhost:8766/previews/ npm test
import { writeFileSync } from "node:fs";
import assert from "node:assert/strict";
import handler from "../api/og.js";

const get = path => {
  const [, slug, file] = path.split("/");
  return handler(new Request(`https://example.test/api/og?h=${slug}&f=${encodeURIComponent(file)}`));
};

const res = await get("/knitting/79.png");
assert.equal(res.status, 200);
assert.equal(res.headers.get("content-type"), "image/png");
const png = Buffer.from(await res.arrayBuffer());
assert.equal(png.readUInt32BE(16), 1200);
assert.equal(png.readUInt32BE(20), 630);
writeFileSync(new URL("knitting-79.png", import.meta.url), png);

for (const bad of ["/knitting/101.png", "/knitting/-1.png", "/knitting/79.jpg", "/knitting/07.png", "/nope/79.png", "/knitting/79"]) {
  assert.equal((await get(bad)).status, 404, bad);
}
console.log(`Rendered test/knitting-79.png (${Math.round(png.length / 1024)} KB); bad requests refused`);
