import 'dart:io';

import 'package:recipe_book/recipe_loader.dart';
import 'package:recipe_book/rendering/renderer.dart';

/// Builds one self-contained HTML file per recipe into `build/html/`,
/// named after its source YAML file.
void main() {
  final outDir = Directory('build/html')..createSync(recursive: true);
  final css = File('assets/style.css').readAsStringSync();

  final recipes = loadRecipes(Directory('recipes'));
  for (final recipe in recipes) {
    File('${outDir.path}/${recipe.slug}.html')
        .writeAsStringSync(Renderer.renderStandaloneRecipe(recipe, css: css));
  }

  print('Generated ${recipes.length} recipes in ${outDir.path}/');
}
