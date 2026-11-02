# Recipe Book

A Slovak cookbook built from the YAML recipes in `recipes/`: an ePub e-book and a static website that can be installed on a phone as an offline app.

**Website:** <https://matej-hlatky.github.io/recipe-book/>

## Build

Run from the repository root:

- `dart run bin/main.dart` builds `build/recipes.epub`
- `dart run bin/site.dart` builds the website into `build/site/`; open `build/site/index.html` in a browser to check it
- `dart analyze` and `dart test` check the code

## More

- [Adding a recipe](docs/adding-recipes.md): file names, fields and writing style
- [App on the phone](docs/app.md): installing, offline use and testing it before a deploy
- [Releases and deployment](docs/releases.md): what happens on every push to `main`
- [Website design](docs/superpowers/specs/2026-10-31-static-website-design.md)
