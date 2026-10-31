# Recipe Book

Scripts to build recipe book (cookbook) from a set of .yaml files into a single .epub e-book.

- `dart run bin/main.dart` builds `build/recipes.epub`
- `dart run bin/site.dart` builds the website into `build/site/`; open `build/site/index.html` in a browser to check it

Every push to `main` creates a GitHub release named by date and time (e.g. `2026-10-08_21-36`) with the ePub attached and notes listing added, changed and removed recipes since the previous `main` commit.
