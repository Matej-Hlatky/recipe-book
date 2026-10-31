# Recipe Book

Scripts to build recipe book (cookbook) from a set of .yaml files into an .epub e-book and a static website.

- `dart run bin/main.dart` builds `build/recipes.epub`
- `dart run bin/site.dart` builds the website into `build/site/`; open `build/site/index.html` in a browser to check it (no server needed)

The website looks like a handwritten recipe notebook and is made for reading on a phone: a contents page grouped by category and one page per recipe, so a single recipe can be shared as a link (e.g. `…/kolac-babovka.html`). See [the design](docs/superpowers/specs/2026-10-31-static-website-design.md).

Every push to `main` creates a GitHub release named by date and time (e.g. `2026-10-08_21-36`) with the ePub attached and notes listing added, changed and removed recipes since the previous `main` commit.

Every push to `main` also publishes the website to GitHub Pages (public). One-time setup: the repository must be public, and Settings → Pages → Source must be set to "GitHub Actions".
