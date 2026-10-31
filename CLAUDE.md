# Recipe Book

Dart scripts that build a Slovak cookbook from the YAML recipes in `recipes/`: an ePub (`build/recipes.epub`) and a static website (`build/site/`), deployed to https://matej-hlatky.github.io/recipe-book/ and installable as an offline app (PWA).

## Commands

Run from the repository root (templates and assets are loaded by relative path).

- `dart run bin/main.dart` – build the ePub
- `dart run bin/site.dart` – build the website into `build/site/` (`index.html`, one page per recipe, CSS, favicon, fonts, app manifest, icons, service worker); check it by opening `build/site/index.html` from disk (offline mode needs a web server)
- `dart run bin/release_notes.dart <from> <to> [repoUrl]` – print release notes for a commit range
- `dart analyze` and `dart test` – both must pass before committing
- `python3 -m http.server -d build/site 8000` – serve the site to check the app (install, offline), which doesn't run from `file://`
- `sh tool/render_icons.sh` – re-render the app icons in `assets/icons/` after changing `assets/favicon.svg` or `tool/icon-maskable.svg` (macOS, Chrome)

## Code map

- `lib/models/recipe.dart` – `Recipe` and `Section`, parsing and validation of one YAML file
- `lib/recipe_loader.dart` – loads `recipes/*.yaml`, sorted by file name; the file name is the slug
- `lib/rendering/renderer.dart` – Mustache rendering of recipe, cover and contents pages (ePub) and the site recipe and contents pages
- `lib/rendering/typography.dart` – `bindShortWords`: no-break space after short Slovak words
- `lib/git.dart` – commit hash helper shared by the ePub and site builds
- `lib/site/site_builder.dart` – writes the website: contents page, recipe pages, stylesheet, favicon, manifest, icons, fonts, and last `sw.js` listing all of them
- `lib/epub/epub_packer.dart` – ePub archive (OPF, NCX, pages, assets)
- `lib/release_notes.dart` – parses `git diff --name-status`, formats release notes
- `templates/recipe_body.mustache` – recipe content shared by the ePub page (`recipe.html.mustache`) and the site page (`templates/site/recipe.html.mustache`)
- `templates/site/` – site head partial, contents page, recipe page (HTML5), service worker (`sw.js.mustache`)
- `assets/site.css`, `assets/fonts/`, `assets/favicon.svg`, `assets/manifest.webmanifest`, `assets/icons/` – site only; the ePub uses `assets/style.css`
- `recipes/schema.json` – JSON schema for recipe files; keep it in sync with `Recipe.fromYaml`
- `docs/superpowers/specs/2026-10-31-static-website-design.md` – website design (look, page contents, app, build, deploy); keep it in sync with site changes

## Workflow

- Work on a feature branch; squash-merge it into `main`.
- Write tests first (`test/` mirrors `lib/`).
- CI: `test.yml` runs analyze and tests on every push; `build.yml` builds the ePub and the website for PRs; `release.yml` runs on every push to `main` and creates a release tagged with the Bratislava date and time (e.g. `2026-10-08_21-36`), the ePub attached and notes since the previous `main` commit; `pages.yml` publishes the website (`build/site`) to GitHub Pages on every push to `main`. All workflows can also be run manually; releases and Pages deployments only from `main`.

## Gotchas

- Mustache HTML-escapes `/` as `&#x2F;`; that is valid, keep escaping on (URLs may contain `&`).
- ePub pages use the XHTML 1.1 doctype, which allows only `xml:lang` (not `lang`).
- Read git output as UTF-8 (`stdoutEncoding: utf8`), otherwise diacritics break on Windows.
- `mustache_template` only allows inverted sections (`{{^x}}`) on bools, lists and maps; use a bool flag (e.g. `isLink`), not a string.
- Site links open in a new tab via the `newTab` flag; the ePub never sets it (XHTML 1.1 has no `target`).
- No-break spaces are the U+00A0 character, never `&nbsp;` (ePub readers don't always know the entity).
- The service worker only runs from a web server, not from `file://`. Its cache name includes the build time, so every deploy replaces the offline copy.
- Site CSS keeps a 30px vertical rhythm so text sits on the ruled lines: every line height and vertical margin is a multiple of `--row`. Check changes at phone width.

## Recipe conventions

- One recipe per file, validated by `recipes/schema.json`.
- File names use a Slovak category prefix: `dezert-`, `kolac-`, `polievka-`, `priloha-`, `slane-`, `india-`, `sk-` (never English, e.g. `indian-`).
- Slovak text is written with full diacritics.
- Use normal spaces; the build adds the no-break space after short words (`a`, `v`, `do`, `na`, …). Don't type U+00A0 or `&nbsp;` into recipes.
- `ingredients` and `steps` are either a flat list or a map of section name to list (e.g. `Cesto`, `Posýpka`, `Pečenie`); a field can't mix both. Use sections instead of YAML comments for content that belongs in the book. The final baking goes into its own `Pečenie` steps section; pre-baking a part (e.g. a crust) stays in that part's section.
- Write steps with **infinitives** (neurčitok), e.g. "Tekvicu ošúpať, odstrániť semienka, nakrájať na kúsky." – not "ošúpeme" (1st person plural) or "rozmixuj" (imperative).
- Put remarks (tips, dish size, servings, prep time) into `notes`; they render in italics below a horizontal line, and `https://` URLs in them become links. Put the origin into `source`, preferably a URL (rendered as a link). Don't use YAML comments for recipe content.
