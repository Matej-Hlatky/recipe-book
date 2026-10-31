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
- No changes to the ePub output.
- No PR preview deployments; local preview is enough.

## Anti-goals

- A page that looks like a generic recipe blog or a plain unstyled document.
- Text that is hard to read on a phone (too small, low contrast, a fancy
  script used for body text).
- Links that break when opened from disk (absolute `/…` paths) or that
  change between builds.
- The website and ePub showing different recipe content.

## Design: "grandma's notebook"

Approved by mockup (option B v2). The visual reference is
`.superpowers/brainstorm/*/content/visual-style-b-v2.html` (recipe page) and
`contents.html` option 2 (contents page, **without** the sketch). These
mockups are local and not committed; the essentials are below.

- **Paper:** warm yellow background (`#fbf0c8`) with faint blue ruled lines
  every 30px, and a faint red margin line on the left of the content column.
- **The lines scroll with the page**, and every line of text sits on a
  ruled line. All line heights and vertical margins are multiples of one
  row (30px). Headings use one or two rows. The rule pattern is shifted
  (about -5px) so the text baseline rests just above each line.
- **Fonts:** Caveat (handwritten) for the page title and section headings
  (`Suroviny`, `Postup`, category names); Lora for everything else, about
  17px. Section names inside ingredients/steps (`Príprava`, `Pečenie`) are
  Lora semibold with an amber underline.
- **Colours:** dark-brown ink text (`#2e2a24`), rust headings (`#8a3b1e`),
  category tag on an amber pill (`#e9c87a`).
- Content column limited to a comfortable reading width on desktop
  (builder's choice, around 36em), centred.

### Contents page (`index.html`)

- Handwritten title "Recepty", a subtitle line (mockup used "z našej
  kuchyne"; builder may keep it).
- A row of category tags; each jumps to that category's section on the
  same page (`#anchor`).
- Categories in the same order as the ePub contents page (sorted by name),
  each with a handwritten heading and its recipe titles as links. Long
  titles wrap onto the next ruled line (don't truncate them; the mockup's
  ellipsis was only for the narrow frame).
- Footer: build date/time and short commit hash, like the ePub contents page.

### Recipe page (`<slug>.html`)

- "‹ Obsah" link back to `index.html` at the top.
- Handwritten title, category tag (linking to that category on the contents
  page), then the shared recipe body: ingredients and steps with their
  sections, then notes (italic) and source (link if a URL), as in the ePub.
- `<title>` is the recipe title, `lang="sk"`, viewport meta for phones.
- Open Graph title tags (`og:title`, and `og:description` with the category)
  so a link sent in a chat app shows the recipe name. *(Builder's call; a
  nice-to-have, keep it to static meta tags.)*

## How it gets built

- **New script** `bin/site.dart` (`dart run bin/site.dart`) writes the site
  into `build/site/`: `index.html`, one `<slug>.html` per recipe,
  `style.css`, and a `fonts/` folder.
- **Replaces** the current per-recipe HTML build: remove `bin/html.dart`,
  `templates/recipe.standalone.html.mustache`,
  `Renderer.renderStandaloneRecipe` and its tests, and update `README.md`
  and `CLAUDE.md` (commands and code map).
- **Reuses** `templates/recipe_body.mustache` as a partial so the ePub and
  site render the same recipe content. If the site needs extra markup around
  it (back link, tag), put that in the new site templates, not in the shared
  body; changes to the shared body must keep the ePub valid XHTML 1.1.
  *(Design call:* the category tag goes between the title and the body, so
  move the `<h1>` out of `recipe_body.mustache` into `recipe.html.mustache`
  and the site template; the ePub output stays the same.)
- New templates for the site's recipe page and contents page (HTML5).
  Shared site layout (head, fonts, stylesheet link) may be a partial.
- **Links are relative** everywhere (`index.html`, `kolac-babovka.html`,
  `style.css`, `fonts/…`), so the same files work from disk and on
  GitHub Pages under `https://<user>.github.io/<repo>/`.
- **Fonts are self-hosted:** Caveat and Lora woff2 files (latin and
  latin-ext subsets, needed for Slovak diacritics) committed under
  `assets/fonts/` with their OFL licence, referenced via `@font-face` in the
  site stylesheet. No requests to Google Fonts.
- Site stylesheet is its own file (e.g. `assets/site.css`), separate from
  the ePub's `assets/style.css`, so the ePub look is unchanged.
- Build date and commit hash come from the same source as the ePub build
  (`git rev-parse --short HEAD`); share the helper rather than copying it.
- The script cleans `build/site/` before writing, so deleted or renamed
  recipes don't leave stale pages behind.

## Deployment

- New workflow `.github/workflows/pages.yml`: on push to `main` (and
  `workflow_dispatch`, deploying only from `main`, like `release.yml`), set
  up Dart, `dart pub get`, `dart run bin/site.dart`, then publish
  `build/site/` with `actions/upload-pages-artifact` and
  `actions/deploy-pages`.
- Permissions `pages: write`, `id-token: write`; concurrency group `pages`.
- The site is public: anyone with a link can read the recipes. Matej will
  make the repository public (GitHub Pages on a free plan needs that); this
  is not part of the build work.
- One-time manual step for Matej: repo Settings → Pages → Source: "GitHub
  Actions". Mention it in `README.md`.
- `build.yml` (PRs) may also build the site so template errors show up
  before merging (builder's call).

## Testing

Per the repo workflow: tests first, `test/` mirrors `lib/`, and
`dart analyze` and `dart test` must pass.

- Renderer tests for the site recipe page and contents page: relative links,
  back link, category anchors, diacritics, HTML escaping kept on.
- A test that the site builder writes `index.html`, one page per recipe,
  `style.css` and the fonts, and removes stale files.
- Manual check: open `build/site/index.html` in a browser at phone width,
  follow links both ways, confirm text sits on the ruled lines.

## Left to the builder

- Exact file and class names (e.g. a `SiteBuilder` in `lib/site/`).
- Exact CSS beyond the design values above, including desktop width and
  link/hover styling.
- Whether to keep the contents subtitle and the Open Graph tags.
- Whether `build.yml` builds the site too.
