// Checks the website's matcher against the Swift app's results.
// Regenerate fixtures with: swift run ExportCatalog website
// Run with: node website/tests/parity.test.mjs
import { readFileSync } from "node:fs";
import { rank } from "../matcher.js";

const here = new URL(".", import.meta.url);
const data = JSON.parse(readFileSync(new URL("../catalog.json", here)));
const fixtures = JSON.parse(readFileSync(new URL("parity.json", here)));

let failures = 0;
fixtures.forEach((f, i) => {
  const got = rank(f.profile, data, f.excluding);
  const same = got.length === f.matches.length && got.every((m, j) => {
    const want = f.matches[j];
    return m.hobby.name === want.name && Math.abs(m.score - want.score) < 1e-9 && m.percent === want.percent
      && JSON.stringify(m.reasons) === JSON.stringify(want.reasons)
      && JSON.stringify(m.caveats) === JSON.stringify(want.caveats);
  });
  if (!same) {
    failures++;
    if (failures <= 3) console.error(`Fixture ${i} differs:\n  swift: ${JSON.stringify(f.matches.map(m => [m.name, m.percent, m.reasons]))}\n  js:    ${JSON.stringify(got.map(m => [m.hobby.name, m.percent, m.reasons]))}`);
  }
});
console.log(`${fixtures.length - failures}/${fixtures.length} profiles match the Swift app`);
process.exit(failures ? 1 : 0);
