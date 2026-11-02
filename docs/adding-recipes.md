# Adding a recipe

Each recipe is one YAML file in `recipes/`, validated by [`recipes/schema.json`](../recipes/schema.json). Recipes are written in Slovak with full diacritics.

## File name

The file name is the recipe's address on the website (`kolac-babovka.yaml` → `…/kolac-babovka.html`), so keep it short, lowercase and without diacritics. Start it with a Slovak prefix:

- preferably the cuisine the dish comes from: `it-` (talianska), `es-` (španielska), `india-` (indická), `sk-` (rakúsko-uhorská);
- otherwise the dish type: `hlavne-`, `polievka-`, `priloha-`, `slane-`, `dezert-`, `kolac-`.

Don't rename existing files, since that would break links to them.

## Fields

```yaml
# yaml-language-server: $schema=./schema.json
---
title: Krémová tekvicová polievka
category: Polievky
ingredients:
  - 1 kg tekvice Hokkaido
  - 1 cibuľa
steps:
  - Tekvicu ošúpať, odstrániť semienka, nakrájať na kúsky.
  - Zeleninu zaliať vývarom a variť pod pokrievkou domäkka.
notes:
  - "Počet porcií: 4"
source: https://example.sk/recept
```

- `title` and `category` are required. `category` is the dish type – `Hlavné jedlá`, `Polievky`, `Prílohy`, `Slané pečivo` or `Dezerty a koláče` – and recipes with the same category are grouped together in the contents, sorted by title.
- `ingredients` and `steps` are either a flat list or a map of section name to list, e.g. `Cesto`, `Posýpka`, `Pečenie`. A field can't mix both. The final baking goes into its own `Pečenie` section.
- `notes` holds remarks: tips, servings, prep time. They're shown in italics below the recipe, and `https://` addresses in them become links.
- `source` is where the recipe comes from, preferably a URL.

## Writing style

- Write steps with infinitives: "Tekvicu ošúpať, nakrájať na kúsky." – not "ošúpeme" or "ošúpaj".
- Use normal spaces. The build adds a no-break space after short words (`a`, `v`, `do`, `na`, …), so they never end a line.
- Put everything that belongs in the book into fields, not YAML comments.
