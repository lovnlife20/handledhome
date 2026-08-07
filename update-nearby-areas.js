// Adds a "Nearby Areas We Serve" block to each handyman-<town>-pa.html location page,
// linking that town to the other towns nearest it.
//
//   node update-nearby-areas.js
//
// Run it from anywhere — paths resolve relative to this file, not the cwd.
//
// Why this exists: the location pages were a star topology. handyman-pittsburgh-area-pa.html
// linked out to all 18 towns, and 17 of those 18 linked back to no other town page at all —
// every town page was a dead end. Six of them (Baden, Crescent, Findlay, Kennedy,
// McKees Rocks, Pittsburgh-area) had only 2 inbound links each, both from hub pages.
// This wires the towns to each other so the location pages form a connected geographic
// cluster rather than spokes off a single hub.
//
// Neighbors are real western-PA adjacencies (Ohio River corridor, airport/Findlay corridor,
// Beaver County river towns, north hills, south hills). The lead sentence is written per
// cluster rather than shared, so this is not identical boilerplate across 19 pages.
//
// Same conventions as update-related-services.js: wrapped in marker comments, idempotent,
// inserted before the page's <div id="contact">. Edit the map here and re-run rather than
// hand-editing the generated block.
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const P = t => `handyman-${t}-pa.html`;

const NAME = {
  'moon-township': 'Moon Township', 'coraopolis': 'Coraopolis', 'robinson': 'Robinson Township',
  'crescent-township': 'Crescent Township', 'findlay-township': 'Findlay Township',
  'north-fayette-township': 'North Fayette Township', 'oakdale': 'Oakdale',
  'kennedy-township': 'Kennedy Township', 'mckees-rocks': 'McKees Rocks',
  'sewickley': 'Sewickley', 'aliquippa': 'Aliquippa', 'ambridge': 'Ambridge',
  'baden': 'Baden', 'monaca': 'Monaca', 'beaver': 'Beaver',
  'cranberry-township': 'Cranberry Township', 'wexford': 'Wexford',
  'mt-lebanon': 'Mt. Lebanon', 'pittsburgh-area': 'the greater Pittsburgh area',
};

// town -> [lead sentence, [nearby town keys]]
const M = {
  'moon-township': ['We are based in Moon Township, so everything around it is a short drive.',
    ['coraopolis', 'crescent-township', 'findlay-township', 'robinson']],
  'coraopolis': ['Coraopolis sits in the middle of our service area, right along the river.',
    ['moon-township', 'kennedy-township', 'robinson', 'sewickley']],
  'robinson': ['Robinson is minutes from our Moon Township base, and so is everything around it.',
    ['moon-township', 'kennedy-township', 'north-fayette-township', 'mckees-rocks']],
  'crescent-township': ['Crescent sits along the Ohio River just north of our Moon Township base.',
    ['moon-township', 'coraopolis', 'findlay-township', 'aliquippa']],
  'findlay-township': ['Findlay covers a lot of ground around the airport, and we work throughout it.',
    ['moon-township', 'north-fayette-township', 'oakdale', 'crescent-township']],
  'north-fayette-township': ['North Fayette borders several of the other communities we serve.',
    ['findlay-township', 'oakdale', 'robinson', 'moon-township']],
  'oakdale': ['Oakdale sits among the western suburbs we cover regularly.',
    ['north-fayette-township', 'findlay-township', 'robinson']],
  'kennedy-township': ['Kennedy sits between Coraopolis and McKees Rocks, and we serve all of it.',
    ['coraopolis', 'robinson', 'mckees-rocks', 'moon-township']],
  'mckees-rocks': ['McKees Rocks anchors the eastern end of our Ohio River service area.',
    ['kennedy-township', 'robinson', 'coraopolis']],
  'sewickley': ['Sewickley is a short drive from our Moon Township base, on both sides of the river.',
    ['coraopolis', 'moon-township', 'ambridge', 'baden']],
  'aliquippa': ['Aliquippa sits among the Beaver County river towns we work in regularly.',
    ['ambridge', 'monaca', 'beaver', 'crescent-township']],
  'ambridge': ['Ambridge is one of several Beaver County river boroughs we cover.',
    ['baden', 'aliquippa', 'sewickley', 'beaver']],
  'baden': ['Baden sits along the river among the Beaver County boroughs we serve.',
    ['ambridge', 'monaca', 'beaver', 'aliquippa']],
  'monaca': ['Monaca is one of the Beaver County river communities we work in.',
    ['beaver', 'aliquippa', 'baden', 'ambridge']],
  'beaver': ['Beaver sits at the center of the Beaver County towns we cover.',
    ['monaca', 'baden', 'ambridge', 'aliquippa']],
  'cranberry-township': ['Cranberry is at the northern edge of our service area.',
    ['wexford', 'sewickley']],
  'wexford': ['Wexford sits along the northern edge of the area we cover.',
    ['cranberry-township', 'sewickley']],
  'mt-lebanon': ['Mt. Lebanon is on the south side of the region we serve.',
    ['pittsburgh-area', 'robinson']],
};

const START = '  <!-- nearby-areas:start -->';
const END = '  <!-- nearby-areas:end -->';

function block(town, [lead, nearby]) {
  const links = nearby.map(n => `<a href="${P(n)}">${NAME[n]}</a>`);
  // 1 -> "A"; 2 -> "A and B"; 3+ -> "A, B, and C" (no comma before "and" on a pair)
  const list = links.length === 1 ? links[0]
    : links.length === 2 ? links.join(' and ')
    : links.slice(0, -1).join(', ') + ', and ' + links[links.length - 1];
  return [
    START,
    '  <div class="section">',
    '',
    '    <h2>Nearby Areas We Serve</h2>',
    '',
    '    <p class="muted-center">',
    `      ${lead} We also handle handyman work in ${list}.`,
    '    </p>',
    '',
    '  </div>',
    END,
    '',
    '',
  ].join('\n');
}

let changed = 0, links = 0;
for (const [town, cfg] of Object.entries(M)) {
  const p = path.join(ROOT, P(town));
  let html = fs.readFileSync(p, 'utf8');

  const re = new RegExp(`${START}[\\s\\S]*?${END}\\r?\\n(\\r?\\n)?`, '');
  html = html.replace(re, '');

  const anchor = '  <div id="contact" class="section">';
  const i = html.indexOf(anchor);
  if (i === -1) { console.error('NO ANCHOR: ' + P(town)); continue; }

  html = html.slice(0, i) + block(town, cfg) + html.slice(i);
  fs.writeFileSync(p, html);
  changed++; links += cfg[1].length;
}
console.log(`updated ${changed} location pages, ${links} neighbor links`);
