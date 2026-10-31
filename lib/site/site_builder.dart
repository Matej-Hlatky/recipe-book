import 'dart:io';

import '../models/recipe.dart';
import '../rendering/renderer.dart';

/// Writes the static website into [outDir].
class SiteBuilder {
  SiteBuilder(this.outDir);

  final Directory outDir;

  /// Deletes [outDir], then writes `index.html`, `<slug>.html` per recipe,
  /// `style.css` (from `assets/site.css`), `favicon.svg`,
  /// `manifest.webmanifest`, `icons/`, `fonts/` (every file in
  /// `assets/fonts/` except dotfiles, including the licence files) and
  /// `sw.js`, which saves all of them for offline use.
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
    File('assets/manifest.webmanifest')
        .copySync('${outDir.path}/manifest.webmanifest');
    _copyDir(Directory('assets/icons'), 'icons');
    _copyDir(Directory('assets/fonts'), 'fonts');

    // Written last, so it lists everything above.
    File('${outDir.path}/sw.js').writeAsStringSync(
      Renderer.renderServiceWorker(
        version: '$commitHash-${generatedAt.millisecondsSinceEpoch}',
        files: ['./', ..._builtFiles()],
      ),
    );
  }

  /// Copies every file in [source] except dotfiles into [name] in [outDir].
  void _copyDir(Directory source, String name) {
    final target = Directory('${outDir.path}/$name')..createSync();
    for (final file in source.listSync().whereType<File>()) {
      final fileName = file.uri.pathSegments.last;
      if (fileName.startsWith('.')) continue;
      file.copySync('${target.path}/$fileName');
    }
  }

  /// Paths of all files in [outDir], relative to it, sorted.
  List<String> _builtFiles() => outDir
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.substring(outDir.path.length + 1))
      .toList()
    ..sort();
}
