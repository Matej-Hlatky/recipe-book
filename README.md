# Recipe Book

Scripts to build a Slovak recipe book (cookbook) from a set of .yaml files in `recipes/` into an .epub e-book and a static website.

**Website:** <https://matej-hlatky.github.io/recipe-book/>

## Build

Run from the repository root:

- `dart run bin/main.dart` builds `build/recipes.epub`
- `dart run bin/site.dart` builds the website into `build/site/`; open `build/site/index.html` in a browser to check it (no server needed)
- `dart analyze` and `dart test` check the code

## Website

The website looks like a handwritten recipe notebook and is made for reading on a phone: a contents page grouped by category and one page per recipe, so a single recipe can be shared as a link (e.g. `…/kolac-babovka.html`). See [the design](docs/superpowers/specs/2026-10-31-static-website-design.md).

Short Slovak words (`a`, `v`, `do`, `na`, …) never end a line: the build adds a no-break space after them, on the website and in the ePub. Write recipes with normal spaces.

## App on the phone

Open the website on the phone and install it: Safari → Share → "Add to Home Screen", or Chrome → menu → "Install app". It opens full-screen, works offline with every recipe saved, and when online always shows the latest version, so new recipes appear right after a deploy without reinstalling.

The offline part needs a web server, so it doesn't work when opening the files from disk. To try it locally, run `python3 -m http.server -d build/site 8000` and open <http://localhost:8000>.

After changing the icon (`assets/favicon.svg`), re-render the app icons with `sh tool/render_icons.sh` (macOS with Chrome).

## Releases and deployment

Every push to `main`:

- creates a GitHub release named by date and time (e.g. `2026-10-08_21-36`) with the ePub attached and notes listing added, changed and removed recipes since the previous `main` commit;
- publishes the website to GitHub Pages (public).

Pull requests build the ePub and the website as downloadable artifacts. Pages needs a public repository and Settings → Pages → Source set to "GitHub Actions" (already done for this repository).
