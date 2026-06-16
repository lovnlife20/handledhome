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

## Editing checklist for adding a new service page

1. Create the new `*-moon-township-pa.html` page (copy an existing service page as
   a template; keep the inline nav + footer).
2. Add the service to the footer nav **on every page** (inline footers).
3. Add it to the homepage (`index.html`): service card, footer link, and the
   JSON-LD `hasOfferCatalog` + a `Service` schema entry on the new page.
4. Add a `<url>` entry to `sitemap.xml`.
5. Cross-link from related service pages where it makes sense.
