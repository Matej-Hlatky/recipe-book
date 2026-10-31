# Static website for the cookbook

## Intent

The cookbook already builds as an ePub. Matej wants the same recipes as a
static website on GitHub Pages, mainly so a single recipe can be **sent to
someone as a link**. People will read it on a phone held upright, often
while cooking.

The site should feel warm and personal, like a handwritten family recipe
notebook, not like a modern recipe blog.

## Goals

- A contents page (home) listing all recipes grouped by category, each
  linking to its own recipe page.
- One page per recipe with a stable URL derived from the recipe file name,
  e.g. `kolac-babovka.html`.
- Readable and comfortable on a phone in portrait; acceptable on desktop.
- Build locally with one command and check the result by opening
  `build/site/index.html` straight from disk (`file://`), with no local server.
- Deploy automatically to GitHub Pages on every push to `main`.

## Non-goals

- No search, filtering, dark mode, or JavaScript.
- No photos and no cover page. The ePub cover (`assets/cover.png`) is not
  used on the site.
- No change to the ePub's look. (Shared content changes, such as URLs in
  notes becoming links, apply to both.)
- No PR preview deployments; local preview is enough.

## Anti-goals

- A page that looks like a generic recipe blog or a plain unstyled document.
- Text that is hard to read on a phone (too small, low contrast, a fancy
  script used for body text).
- Links that break when opened from disk (absolute `/…` paths) or that
  change between builds.
- The website and ePub showing different recipe content.

## Design: "grandma's notebook"

Chosen from mockups during brainstorming (lined notebook paper, handwritten
headings).

- **Paper:** warm yellow background (`#fbf0c8`) with faint blue ruled lines
  (`rgba(110,140,190,.3)`) every 30px, and a faint red margin line
  (`rgba(200,80,80,.35)`) on the left of the content column.
- **The lines scroll with the page**, and every line of text sits on a
  ruled line. All line heights and vertical margins are multiples of one
  row (30px). Headings use one or two rows. The rule pattern is shifted
  5px up so the text baseline rests just above each line. Anything that
  would break this rhythm (e.g. a few pixels of gap between paragraphs) is
  out; use a whole blank row or a visual marker instead.
- **Fonts:** Caveat 600 (handwritten) for the page title and `h2` headings
  (`Suroviny`, `Postup`, category names); Lora (17px) for everything else.
  Section names inside ingredients/steps (`Príprava`, `Pečenie`) are Lora
  semibold with an amber underline (`#e0a050`).
- **Colours:** dark-brown ink text (`#2e2a24`), rust headings and accents
  (`#8a3b1e`), category tag on an amber pill (`#e9c87a`).
- **Lists:** plain round bullets and step numbers, both in the text colour.
- **Scrollbar:** amber thumb (`#d2a85e`) on a slightly darker paper track
  (`#f3e4b0`), rust on hover in WebKit browsers.
- **Favicon:** Material Symbols "menu_book" (Outlined, Apache 2.0) on a
  white rounded tile, pages filled with the paper colour, outline in rust.
  The white tile keeps it visible on dark browser tabs.
- Content column at most 36em wide, centred on desktop.

### Contents page (`index.html`)

- Handwritten title "Recepty" and the subtitle "z našej kuchyne".
- A row of category tags; each jumps to that category's section on the
  same page (`#anchor`).
- Categories in the same order as the ePub contents page (sorted by name).
  Each category heading links to itself, so a category can be shared as
  `index.html#koláče`.
- Each category lists its recipes as a bulleted list of links, followed by
  a small amber "›". Long titles wrap onto the next ruled line (never
  truncated). Hovering a link fades an underline in and out (0.3s); the
  arrow is not underlined.
- Footer: build date/time and short commit hash, like the ePub contents page.

### Recipe page (`<slug>.html`)

- "‹ Obsah" link back to `index.html` at the top, padded for an easier tap.
- Handwritten title, category tag (linking to that category on the contents
  page), then the shared recipe body: ingredients and steps with their
  sections, then notes (italic) and source.
- Each note and the source line start with a hanging dash, so entries are
  told apart without breaking the line rhythm.
- `http(s)://` URLs inside notes become links (in the ePub too). Trailing
  punctuation and brackets around a URL stay outside the link.
- On the site, links in notes and the source open in a new tab
  (`target="_blank" rel="noopener"`). The ePub keeps them in the reader:
  XHTML 1.1 has no `target`.
- `<title>` is the recipe title, `lang="sk"`, viewport meta for phones, and
  Open Graph `og:title` / `og:description` (the category) so a link sent in
  a chat app shows the recipe name.

## How it is built

- `bin/site.dart` (`dart run bin/site.dart`) writes the site into
  `build/site/`: `index.html`, one `<slug>.html` per recipe, `style.css`,
  `favicon.svg` and a `fonts/` folder. It wipes `build/site/` first, so
  deleted or renamed recipes leave no stale pages.
- It replaced the earlier per-recipe HTML build (`bin/html.dart`).
- `templates/recipe_body.mustache` is shared by the ePub and site recipe
  pages, so both show the same content. Site-only markup (back link,
  category tag) lives in `templates/site/`. The `<h1>` moved out of the
  shared body into each page template, so the tag can sit under the title.
  Changes to the shared body must keep the ePub valid XHTML 1.1.
- **Links are relative** everywhere, so the same files work from disk and
  on GitHub Pages under `https://<user>.github.io/<repo>/`.
- **Fonts are self-hosted:** Caveat and Lora woff2 files (latin and
  latin-ext subsets, for Slovak diacritics) from Fontsource 5.1.0 under
  `assets/fonts/` with their OFL licences. No requests to Google Fonts.
- The site stylesheet (`assets/site.css`) is separate from the ePub's
  `assets/style.css`.
- Build date and commit hash come from `lib/git.dart`, shared with the
  ePub build.

## Deployment

- `.github/workflows/pages.yml`: on push to `main` (and manual runs, which
  deploy only from `main`, like `release.yml`), builds the site and
  publishes `build/site/` with `actions/upload-pages-artifact` and
  `actions/deploy-pages`. Permissions `pages: write`, `id-token: write`;
  concurrency group `pages`.
- `build.yml` (PRs) also builds the site and uploads it as an artifact, so
  template errors show up before merging.
- The site is public: anyone with a link can read the recipes. One-time
  setup by Matej: make the repository public, and set Settings → Pages →
  Source to "GitHub Actions" (also in `README.md`).

## Testing

Tests first, `test/` mirrors `lib/`, and `dart analyze` and `dart test`
must pass.

- Renderer tests for both site pages: HTML5 and Slovak, relative links
  only, back link, category anchors with diacritics, linked category
  headings, escaping in `<title>` and `og:` attributes, URLs in notes
  linked, new-tab links on the site but not in the ePub, favicon link.
- Site builder tests: contents page and one page per recipe, stylesheet,
  favicon, fonts and licences copied, stale pages removed.
- Stylesheet tests: every `url(fonts/…)` exists, nothing loaded from the
  network.
- Manual check: open `build/site/index.html` at phone width, follow links
  both ways, confirm text sits on the ruled lines.
