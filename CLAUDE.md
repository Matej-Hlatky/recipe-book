# Recipe Book

Dart scripts that build a Slovak cookbook (`build/recipes.epub`) from the YAML files in `recipes/`.

- Build ePub: `dart run bin/main.dart`
- Build HTML: `dart run bin/html.dart` (one self-contained file per recipe in `build/html/`, named after its YAML file)
- Test: `dart test` (CI runs `dart analyze` and `dart test` on every push)

## Recipe conventions

- One recipe per file, validated by `recipes/schema.json`.
- File names use a Slovak category prefix: `dezert-`, `kolac-`, `polievka-`, `priloha-`, `slane-`, `india-`, `sk-` (never English, e.g. `indian-`).
- `ingredients` and `steps` are either a flat list or a map of section name to list (e.g. `Cesto`, `Posýpka`, `Pečenie`). Use sections instead of YAML comments for content that belongs in the book. The final baking goes into its own `Pečenie` steps section; pre-baking a part (e.g. a crust) stays in that part's section.
- Write steps with **infinitives** (neurčitok), e.g. "Tekvicu ošúpať, odstrániť semienka, nakrájať na kúsky." — not "ošúpeme" (1st person plural) or "ošúpi" / "rozmixuj" (imperative).
- Put remarks (tips, dish size, servings, prep time) into `notes`; they render in italics below a horizontal line. Put the origin into `source`, preferably a URL (rendered as a link). Don't use YAML comments for recipe content.
