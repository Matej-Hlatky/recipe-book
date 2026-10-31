import 'dart:io';

import 'package:recipe_book/git.dart';
import 'package:recipe_book/recipe_loader.dart';
import 'package:recipe_book/site/site_builder.dart';

/// Builds the static website into `build/site/`.
void main() {
  final recipes = loadRecipes(Directory('recipes'));

  SiteBuilder(Directory('build/site')).build(
    recipes: recipes,
    generatedAt: DateTime.now(),
    commitHash: gitCommitHash(),
  );

  print('Generated ${recipes.length} recipes in build/site/ '
      '– open build/site/index.html');
}
