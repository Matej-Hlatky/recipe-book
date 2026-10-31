import 'dart:io';

import '../models/recipe.dart';
import '../rendering/renderer.dart';

/// Writes the static website into [outDir].
class SiteBuilder {
  SiteBuilder(this.outDir);

  final Directory outDir;

  /// Deletes [outDir], then writes `index.html`, `<slug>.html` per recipe,
  /// `style.css` (from `assets/site.css`), `favicon.svg` and `fonts/` (every file in
  /// `assets/fonts/` except dotfiles, including the licence files).
  void build({
    required List<Recipe> recipes,
    required DateTime generatedAt,
    required String commitHash,
  }) {
    if (outDir.existsSync()) outDir.deleteSync(recursive: true);
    outDir.createSync(recursive: true);

    File('${outDir.path}/index.html').writeAsStringSync(
      Renderer.renderSiteIndex(
        recipes,
        generatedAt: generatedAt,
        commitHash: commitHash,
      ),
    );
    for (final recipe in recipes) {
      File('${outDir.path}/${recipe.slug}.html')
          .writeAsStringSync(Renderer.renderSiteRecipe(recipe));
    }

    File('assets/site.css').copySync('${outDir.path}/style.css');
    File('assets/favicon.svg').copySync('${outDir.path}/favicon.svg');
    final fontsDir = Directory('${outDir.path}/fonts')..createSync();
    for (final font in Directory('assets/fonts').listSync().whereType<File>()) {
      final name = font.uri.pathSegments.last;
      if (name.startsWith('.')) continue;
      font.copySync('${fontsDir.path}/$name');
    }
  }
}
