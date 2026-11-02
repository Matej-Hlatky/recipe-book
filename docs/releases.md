# Releases and deployment

Every push to `main`:

- creates a GitHub release named by date and time (e.g. `2026-10-08_21-36`) with the ePub attached and notes listing added, changed and removed recipes since the previous `main` commit;
- publishes the website to GitHub Pages.

Every push runs `dart analyze` and the tests. Pull requests also build the ePub and the website as downloadable artifacts.

All workflows can be run manually from the Actions tab; releases and Pages deployments only from `main`. Pages needs a public repository and Settings → Pages → Source set to "GitHub Actions" (already done for this repository).
