import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:recipe_book/epub/epub_packer.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/rendering/renderer.dart';
import 'package:yaml/yaml.dart';

void main() {
  final recipesDir = Directory('recipes');
  final buildDir = Directory('build');

  if (buildDir.existsSync()) buildDir.deleteSync(recursive: true);
  buildDir.createSync();

  File('assets/style.css').copySync(p.join(buildDir.path, 'style.css'));

  final commitHash = _gitCommitHash();

  File(p.join(buildDir.path, 'cover.html')).writeAsStringSync(
    Renderer.renderCover(
      generatedAt: DateTime.now(),
      commitHash: commitHash,
    ),
  );
  print('Generated build/cover.html');

  final recipes = <Recipe>[];
  final files = recipesDir
      .listSync()
      .whereType<File>()
      .where((it) => it.path.endsWith('.yaml'));

  for (final File file in files) {
    final slug = p.basenameWithoutExtension(file.path);
    final recipe = Recipe.fromYaml(
      slug,
      loadYaml(file.readAsStringSync()) as Map,
    );

    File(p.join(buildDir.path, '${recipe.slug}.html'))
        .writeAsStringSync(Renderer.renderRecipe(recipe));
    recipes.add(recipe);
    print('Generated build/${recipe.slug}.html');
  }

  File(p.join(buildDir.path, 'toc.html'))
      .writeAsStringSync(Renderer.renderToc(recipes));
  print('Generated build/toc.html');

  EpubPacker.pack(recipes, p.join(buildDir.path, 'recipes.epub'));
  print('Generated build/recipes.epub');
}

String _gitCommitHash() {
  final result = Process.runSync('git', ['rev-parse', '--short', 'HEAD']);
  return (result.stdout as String).trim();
}
