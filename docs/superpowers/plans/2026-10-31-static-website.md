# Static Website Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the cookbook as a static, phone-first website (contents page + one page per recipe) in `build/site/`, viewable from disk and deployed to GitHub Pages on every push to `main`.

**Architecture:** New `Renderer` methods render HTML5 site pages from new Mustache templates, reusing the shared `recipe_body.mustache` partial. A `SiteBuilder` writes pages, the site stylesheet and self-hosted fonts into a clean output dir; `bin/site.dart` drives it. The per-recipe standalone HTML build (`bin/html.dart`) is removed. A new `pages.yml` workflow deploys.

**Tech Stack:** Dart 3, `mustache_template`, `collection`, `intl`, `package:test`; plain CSS with `@font-face` (Caveat, Lora from Fontsource 5.1.0); GitHub Actions Pages deployment.

**Spec:** `docs/superpowers/specs/2026-10-31-static-website-design.md`

## Global Constraints

- Run everything from the repo root; templates and assets load by relative path.
- `dart analyze` and `dart test` must pass before every commit. Tests first; `test/` mirrors `lib/`.
- Keep Mustache HTML escaping on (`htmlEscapeValues: true`); `/` escapes to `&#x2F;`, that's fine.
- All site links and asset references are relative (`index.html`, `<slug>.html`, `style.css`, `fonts/…`). No `href="/…"`, no external URLs (no Google Fonts).
- Site pages: `<!DOCTYPE html>`, `<html lang="sk">`, `<meta charset="UTF-8">`, viewport meta. ePub pages keep XHTML 1.1 and `xml:lang`, and their output must not change.
- Visible site copy (Slovak): contents title `Recepty`, back link `‹ Obsah`, notes/source as in the ePub (`Zdroj:`).
- Design values: background `#fbf0c8`; rule lines `rgba(110,140,190,.3)` 1px every 30px; margin line `rgba(200,80,80,.35)`; text `#2e2a24`; headings `#8a3b1e`; tag pill `#e9c87a`; section-name underline `#e0a050`. Caveat 600 for title/`h2`/category headings, Lora (~17px) for everything else. Every line height and vertical margin is a multiple of the 30px row.
- Output dir `build/site/`, wiped before each build.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **Category names with spaces/diacritics** (`Slané pečivo`, `Rakúsko-Uhorská`): the tag link `#…` on the contents page and on recipe pages must match the category heading's `id` exactly. Pinned in Tasks 1 and 2.
2. **Titles with HTML-special characters** (`&`, `"`): escaped in the body *and* inside `<title>` and `og:` meta attributes. Pinned in Task 1.
3. **Renamed or deleted recipes:** a stale `<old-slug>.html` from a previous build must not survive. Pinned in Task 3.
4. **Opened from disk (`file://`):** any absolute or external URL breaks the page offline. Pinned by "no `href=\"/`" and "no `http` in CSS" assertions in Tasks 1–4.
5. **Long titles and wrapped steps on a narrow phone:** must wrap (no ellipsis) and every wrapped line must still sit on a ruled line. CSS only, so checked manually in Task 4 at 360px width with `Kokosový cheesecake s čokoládou a malinami` and a long step.

---

### Task 1: Site recipe page (replaces the standalone HTML page)

**Files:**
- Modify: `templates/recipe_body.mustache` (remove the leading `<h1>{{title}}</h1>`)
- Modify: `templates/recipe.html.mustache` (add `<h1>{{title}}</h1>` right before `{{> recipe_body}}`)
- Create: `templates/site/head.mustache` (partial: charset, viewport, `<title>`, `og:title`, `og:description`, `<link rel="stylesheet" href="style.css" />`)
- Create: `templates/site/recipe.html.mustache`
- Delete: `templates/recipe.standalone.html.mustache`, `bin/html.dart`
- Modify: `lib/rendering/renderer.dart` (remove `renderStandaloneRecipe` and `_standaloneRecipe`; add the methods below)
- Modify: `lib/epub/epub_packer.dart` (NCX `categoryId` uses `Renderer.categoryId`)
- Test: `test/rendering/renderer_test.dart`

**Interfaces:**
- Produces:
  - `static String Renderer.categoryId(String category)`: lowercase, spaces → `-`, diacritics kept (`'Slané pečivo'` → `'slané-pečivo'`). This is the same rule the NCX uses today, so the ePub output doesn't change.
  - `static String Renderer.renderSiteRecipe(Recipe recipe)`
  - Partial resolver knows `recipe_body` and `site_head`. `site_head` expects `pageTitle` and `description`.

Site recipe page structure (class names are used by the CSS in Task 4):

```html
<body>
  <nav class="back"><a href="index.html">‹ Obsah</a></nav>
  <main class="page">
    <h1>{{title}}</h1>
    <p class="tagline"><a class="tag" href="index.html#{{categoryId}}">{{category}}</a></p>
    {{> recipe_body}}
  </main>
</body>
```

- [ ] **Step 1: Write the failing tests**

In `group('Renderer.renderRecipe')`, replace the `standalone page …` test with:
- `ePub recipe page still has exactly one title heading`: `'<h1>Koláč</h1>'.allMatches(html)` has length 1.

Add `group('Renderer.categoryId')`:
- `categoryId('Slané pečivo') == 'slané-pečivo'`, `categoryId('Rakúsko-Uhorská') == 'rakúsko-uhorská'`, `categoryId('Dezerty') == 'dezerty'`.

Add `group('Renderer.renderSiteRecipe')`, using the `Koláč` recipe from the removed standalone test but with `category: 'Slané pečivo'`:
- `is an HTML5 page in Slovak for phones`: starts with `<!DOCTYPE html>`, contains `lang="sk"` and `name="viewport"`, not `xml:lang`.
- `links the shared stylesheet`: contains `href="style.css"`, not `<style>`.
- `links back to the contents`: contains `<a href="index.html">‹ Obsah</a>`.
- `category tag links to its section on the contents page`: contains `<a class="tag" href="index.html#slané-pečivo">Slané pečivo</a>`.
- `keeps the shared recipe content`: one `<h1>Koláč</h1>`, its index is before the tag's index; contains `<h3>Cesto</h3>`, `<li>Piecť.</li>`, `<em>Cez noc.</em>`, `Zdroj: Babka`.
- `uses only relative links`: `isNot(contains('href="/'))`, `isNot(contains('http'))`. The recipe has no URL source.
- `escapes the title everywhere`: title `Chlieb & "maslo"`. Contains `<title>Chlieb &amp; &quot;maslo&quot;</title>` and `content="Chlieb &amp; &quot;maslo&quot;"`, and has no raw `& "`.
- `sets link preview tags`: contains `property="og:title" content="Koláč"` and `property="og:description" content="Slané pečivo"`.

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/rendering/renderer_test.dart`
Expected: compile errors for `categoryId` and `renderSiteRecipe`. Also run `dart analyze`: it fails on `bin/html.dart` once the method is gone, so delete `bin/html.dart` in Step 3.

- [ ] **Step 3: Implement**

- Move the `<h1>` as described in Files.
- Add the templates.
- In `_recipeData`, add `categoryId`, `pageTitle` (= title) and `description` (= category).
- Add `categoryId` and `renderSiteRecipe`.
- Remove the standalone template, its method and `bin/html.dart`.
- Change `epub_packer.dart` to call `Renderer.categoryId(entry.key)`.

- [ ] **Step 4: Verify**

Run: `dart analyze && dart test`. Expected: no issues, all tests pass.
Run: `git stash -q && dart run bin/main.dart && cp build/recipes.epub /tmp/before.epub; git stash pop -q && dart run bin/main.dart`, then compare the unzipped contents of `/tmp/before.epub` and `build/recipes.epub`, ignoring `content.opf`'s modified date and the TOC timestamp line. Expected: the recipe pages are identical except for whitespace around the `<h1>`. (Use the scratchpad dir instead of `/tmp` if your harness provides one.)

- [ ] **Step 5: Commit**: `Add site recipe page, drop standalone HTML page`

---

### Task 2: Site contents page

**Files:**
- Create: `templates/site/index.html.mustache`
- Modify: `lib/rendering/renderer.dart`
- Test: `test/rendering/renderer_test.dart`

**Interfaces:**
- Consumes: `Renderer.categoryId`, `site_head` partial (Task 1).
- Produces: `static String Renderer.renderSiteIndex(List<Recipe> recipes, {required DateTime generatedAt, required String commitHash})`.
  - Grouping and order are the same as `renderToc`: `groupBy` category, categories sorted by name, recipes in input order. Extract the shared grouping into a private helper instead of copying it.
  - Footer date format is the same as the ePub contents page: `yyyy-MM-dd HH:mm` UTC plus ` UTC`.

Structure:

```html
<main class="page contents">
  <h1>Recepty</h1>
  <p class="subtitle">z našej kuchyne</p>
  <nav class="tags">{{#categories}}<a class="tag" href="#{{id}}">{{name}}</a> {{/categories}}</nav>
  {{#categories}}
  <h2 id="{{id}}">{{name}}</h2>
  <ul class="recipes">{{#recipes}}<li><a href="{{slug}}.html">{{title}}</a></li>{{/recipes}}</ul>
  {{/categories}}
  <footer>{{generatedAt}} · {{commitHash}}</footer>
</main>
```

- [ ] **Step 1: Write the failing tests** in `group('Renderer.renderSiteIndex')`. Recipes: `kolac-babovka`/`Bábovka`/`Koláče`, `slane-osie-hniezda`/`Osie hniezda`/`Slané pečivo`, `dezert-palacinky`/`Palacinky`/`Dezerty`. Use `generatedAt: DateTime.utc(2026, 10, 31, 9, 5)` and `commitHash: 'abc1234'`.
  - `is an HTML5 page titled Recepty`: starts with `<!DOCTYPE html>`, contains `<title>Recepty</title>`, `<h1>Recepty</h1>`, `href="style.css"`.
  - `links every recipe by its file name`: contains `<a href="kolac-babovka.html">Bábovka</a>`, and the same for the other two.
  - `category tags jump to matching headings`: for each category, contains `<a class="tag" href="#slané-pečivo">Slané pečivo</a>` and `<h2 id="slané-pečivo">Slané pečivo</h2>` (same id).
  - `categories are sorted by name`: index of `>Dezerty</h2>` < `>Koláče</h2>` < `>Slané pečivo</h2>`.
  - `shows build time and commit`: contains `2026-10-31 09:05 UTC · abc1234`.
  - `uses only relative links`: `isNot(contains('href="/'))`, `isNot(contains('http'))`.

- [ ] **Step 2: Run** `dart test test/rendering/renderer_test.dart`. Expected: FAIL, because `renderSiteIndex` isn't defined.

- [ ] **Step 3: Implement** the template and `renderSiteIndex`. Pass `pageTitle: 'Recepty'` and `description: 'Recepty z našej kuchyne'` to `site_head`.

- [ ] **Step 4: Verify** with `dart analyze && dart test`. Expected: all pass.

- [ ] **Step 5: Commit**: `Add site contents page`

---

### Task 3: Site builder and `bin/site.dart`

**Files:**
- Create: `lib/git.dart`: `String gitCommitHash()`, moved from `bin/main.dart` (read with `stdoutEncoding: utf8`)
- Modify: `bin/main.dart` to use it
- Create: `lib/site/site_builder.dart`
- Create: `bin/site.dart`
- Create: `assets/site.css` (placeholder, a single comment line. Task 4 fills it in.)
- Create: `assets/fonts/.gitkeep` (Task 4 adds the fonts)
- Test: `test/site/site_builder_test.dart`, `test/git_test.dart`
- Modify: `README.md`, `CLAUDE.md`: replace the `bin/html.dart` lines with `dart run bin/site.dart`. Add to `README.md`: "builds the website into `build/site/`; open `build/site/index.html` in a browser to check it". Add `lib/site/site_builder.dart` to the CLAUDE.md code map and update the `recipe_body.mustache` line (it's shared by the ePub page and `templates/site/recipe.html.mustache`).

**Interfaces:**
- Consumes: `Renderer.renderSiteRecipe`, `Renderer.renderSiteIndex`.
- Produces:
  ```dart
  class SiteBuilder {
    SiteBuilder(this.outDir);
    final Directory outDir;
    /// Deletes [outDir], then writes index.html, <slug>.html per recipe,
    /// style.css (from assets/site.css) and fonts/ (every file in assets/fonts/
    /// except dotfiles, including the licence files).
    void build({required List<Recipe> recipes, required DateTime generatedAt, required String commitHash});
  }
  String gitCommitHash();
  ```
- `bin/site.dart` builds into `build/site` and prints `Generated <n> recipes in build/site/ – open build/site/index.html`.

- [ ] **Step 1: Write the failing tests**
  - `test/git_test.dart`: `gitCommitHash()` matches `RegExp(r'^[0-9a-f]{7,}$')`.
  - `test/site/site_builder_test.dart`, with `outDir` = a `Directory.systemTemp.createTempSync()` subdir, deleted in `tearDown`:
    - `writes the contents page and one page per recipe`: two recipes, so `index.html`, `a.html` and `b.html` exist.
    - `copies the stylesheet and fonts`: `style.css` content equals `assets/site.css`. Every non-dot file in `assets/fonts/` exists under `fonts/`.
    - `removes pages from earlier builds`: pre-create `outDir/old.html`, build, and `old.html` is gone.

- [ ] **Step 2: Run** `dart test test/site test/git_test.dart`. Expected: FAIL, because `SiteBuilder` and `gitCommitHash` don't exist yet.

- [ ] **Step 3: Implement**: `lib/git.dart`, `SiteBuilder`, `bin/site.dart`, the placeholder assets and the doc updates.

- [ ] **Step 4: Verify**
  - `dart analyze && dart test`: all pass.
  - `dart run bin/main.dart`: still builds the ePub.
  - `dart run bin/site.dart`: `build/site/` has `index.html`, 18 recipe pages and `style.css`.

- [ ] **Step 5: Commit**: `Add site builder and bin/site.dart`

---

### Task 4: Notebook stylesheet and self-hosted fonts

**Files:**
- Create: `assets/fonts/` with these files from `https://cdn.jsdelivr.net/npm/@fontsource/<family>@5.1.0/files/<name>`:
  - `lora-latin-400-normal.woff2`, `lora-latin-ext-400-normal.woff2`
  - `lora-latin-400-italic.woff2`, `lora-latin-ext-400-italic.woff2`
  - `lora-latin-600-normal.woff2`, `lora-latin-ext-600-normal.woff2`
  - `caveat-latin-600-normal.woff2`, `caveat-latin-ext-600-normal.woff2`
  - `LICENSE-lora.txt` and `LICENSE-caveat.txt`, from `…/@fontsource/<family>@5.1.0/LICENSE`
- Delete: `assets/fonts/.gitkeep`
- Modify: `assets/site.css`
- Test: `test/site/site_css_test.dart`

**Interfaces:**
- Consumes the class names from Tasks 1–2: `.back`, `.page`, `.tagline`, `.tag`, `.subtitle`, `.tags`, `.recipes`, `.contents`, `footer`, and the shared body's `h2`, `h3`, `ul`, `ol`, `hr`, `.notes`.

- [ ] **Step 1: Write the failing test** `test/site/site_css_test.dart`:
  - `every font the stylesheet references exists`: every `url(fonts/…)` in `assets/site.css` names a file in `assets/fonts/`, and there are at least 8 matches.
  - `loads nothing from the network`: `assets/site.css` doesn't contain `http` or `@import`.
- [ ] **Step 2: Run** `dart test test/site/site_css_test.dart`. Expected: FAIL, because the placeholder has no `url(fonts/`.
- [ ] **Step 3: Download the fonts and write `assets/site.css`.**
  - Write one `@font-face` per file, using `font-display: swap`. Copy each `unicode-range` from Fontsource's `…/@fontsource/<family>@5.1.0/index.css` (latin vs latin-ext blocks).
  - The page background is the yellow paper with ruled lines, using the Global Constraints values. Put it on `html`/`body` so the lines scroll with the page.
  - Use `--row: 30px`, `line-height: var(--row)`, and `background-position: 0 -5px` so the text sits just above each line. (The mockup used the same values.)
  - `.page` has the red margin line on its left border, about 34px left padding, a max width of about 36em, and is centred.
  - Headings, lists, `hr`, `.notes`, the tag pill and the footer all keep the 30px rhythm: margins of 0 or `var(--row)`, h1 `line-height: calc(var(--row) * 2)`, `hr` takes exactly one row.
  - Contents-page recipe links: block, with no underline. Long titles wrap; never use `text-overflow`.
- [ ] **Step 4: Verify**
  - `dart analyze && dart test`: all pass.
  - Run `dart run bin/site.dart`. Open `build/site/index.html` from disk in a browser with devtools at 360×740 (portrait phone).
  - Check: the fonts load with diacritics (`ľščťžýáíéúäôň`), and the network tab shows no external requests.
  - Check: on `slane-quiche-kozi-syr-brokolica.html` and `dezert-cheesecake-kokosovy.html`, every text line, including wrapped steps and the notes, sits on a ruled line all the way to the bottom.
  - Check: the tag links jump to the right sections, and the back link works.
  - Check: on a desktop width, the column is centred and readable.
- [ ] **Step 5: Commit**: `Add notebook stylesheet and self-hosted fonts`

---

### Task 5: Deploy to GitHub Pages

**Files:**
- Create: `.github/workflows/pages.yml`
- Modify: `.github/workflows/build.yml` (also run `dart run bin/site.dart` and upload `build/site/` as artifact `site`)
- Modify: `README.md`, `CLAUDE.md` (Workflow/CI line)

`pages.yml`:
- Triggers: `push` to `main` and `workflow_dispatch`.
- Job `if: github.ref == 'refs/heads/main'`, with the same comment as `release.yml`.
- `permissions: { contents: read, pages: write, id-token: write }`, `concurrency: { group: pages, cancel-in-progress: false }`.
- Steps: checkout, setup-dart, `dart pub get`, `dart run bin/site.dart`, `actions/configure-pages`, `actions/upload-pages-artifact` with `path: build/site`, `actions/deploy-pages` (`id: deployment`).
- `environment: { name: github-pages, url: ${{ steps.deployment.outputs.page_url }} }`.
- Use the current major version of each Pages action. Check the latest on GitHub; the repo already uses `checkout@v7`, so pick versions in line with that.

README addition: "Every push to `main` also publishes the website to GitHub Pages (public). One-time setup: the repository must be public, and Settings → Pages → Source must be set to "GitHub Actions"."

- [ ] **Step 1: Write the workflow files and doc updates.**
- [ ] **Step 2: Verify**
  - Parse both YAML files: `dart run` a one-off script in the scratchpad that calls `loadYaml` on them, or use `ruby -ryaml -e 'YAML.load_file(ARGV[0])' <file>`. Expected: no error.
  - `dart analyze && dart test`: all pass.
- [ ] **Step 3: Commit**: `Deploy the website to GitHub Pages`
