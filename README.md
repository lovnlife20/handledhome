# handledhome

Static marketing site for Handled Home (Moon Township, PA), hosted on
GitHub Pages at **handledhome.net**. Pure HTML/CSS — no framework, no build step.

## Architecture notes (read before editing the header or footer)

There is **no server-side include or build step**. `.nojekyll` is present, which
disables GitHub Pages' Jekyll includes. As a result:

- **Every page carries its own inline `<nav>` and `<footer>` markup.** The header
  and footer are *not* pulled in from a shared file at request time.
- `header.html` and `footer.html` are **reference copies only** — no rendered page
  links to or fetches them. Editing them alone changes nothing on the live site.
  (Note: `header.html` uses an older `desktop-nav` layout that no current page
  actually uses; the live pages use the inline `nav.nav` structure.)

### Keeping header/footer in sync across pages

Because each page has its own copy, sitewide header/footer changes are applied by
**find-and-replace propagation scripts** (`*.ps1` in the repo root, e.g.
`update-nav.ps1`, `nav-update.ps1`, `update-mobile-nav.ps1`, `update-schema.ps1`).
These scripts have the markup **hardcoded inside the script** (they do not read
`header.html`/`footer.html`) and regex-replace the corresponding block in every
HTML file.

Caveats if you re-run them:

- The `$dir` path inside each script is **hardcoded** (historically
  `C:\Users\aprus\Claude\handledhome`). Update it to wherever the repo is checked
  out on the current machine before running.
- Some scripts are **stale** — they target older nav structures that no longer
  match the current pages. Read the script before running it.
- For a one-off addition (e.g. adding a single new service link to the footer),
  it's often safer to do a targeted string insertion across `*.html` than to run
  a whole legacy script.

### Related Services cross-links (`update-related-services.js`)

Every service page ends with a **Related Services** block just above the estimate
form, listing 4–5 related services with a short reason for each. These are
generated, not hand-written:

```
node update-related-services.js
```

Unlike the `*.ps1` scripts above, this one resolves paths from its own location
(`__dirname`), so it runs correctly from any working directory and needs no
per-machine path edit.

- The link map at the top of the script is the **source of truth** for which
  service pages point at each other.
- The generated block is wrapped in `<!-- related-services:start -->` / `:end`
  markers. Re-running strips the old block before inserting, so it is safe to run
  repeatedly and never stacks duplicates.
- **Do not hand-edit the generated block** in the HTML — the next run overwrites
  it. Edit the map in the script and re-run.
- It uses existing `.section` / `.box` / `.services-list` classes, so it needs no
  CSS change and no `style.css?v=` cache-buster bump.

### Nearby Areas cross-links (`update-nearby-areas.js`)

Each `handyman-<town>-pa.html` location page ends with a **Nearby Areas We Serve**
block linking the towns closest to it:

```
node update-nearby-areas.js
```

Same conventions as `update-related-services.js` — `__dirname`-relative, wrapped in
`<!-- nearby-areas:start -->` / `:end` markers, idempotent, edit the map and re-run
rather than hand-editing the HTML.

Why it exists: the location pages used to be a star topology. `handyman-pittsburgh-area-pa.html`
linked out to all 18 towns and 17 of those linked back to no other town page, so each
town page was a dead end.

**Gotcha:** these blocks contain the string `Areas We Serve`, so any script that
searches for that string to find a *service* page's areas paragraph will also match
location pages. Match on `>Areas We Serve<` or skip `handyman-*` files.

## Editing checklist for adding a new service page

1. Create the new `*-moon-township-pa.html` page (copy an existing service page as
   a template; keep the inline nav + footer).
2. Add the service to the footer nav **on every page** (inline footers).
3. Add it to the homepage (`index.html`): service card, footer link, and the
   JSON-LD `hasOfferCatalog` + a `Service` schema entry on the new page.
4. Add a `<url>` entry to `sitemap.xml`.
5. Cross-link from related service pages: add an entry for the new page in
   `update-related-services.js`, add it as a target in a few related pages' lists
   so it has inbound links too, then re-run the script.
