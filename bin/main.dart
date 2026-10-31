import 'dart:io';

import 'package:recipe_book/epub/epub_packer.dart';
import 'package:recipe_book/git.dart';
import 'package:recipe_book/recipe_loader.dart';

void main() {
  final buildDir = Directory('build');
  if (!buildDir.existsSync()) buildDir.createSync();

  final now = DateTime.now();
  final commitHash = gitCommitHash();

  final recipes = loadRecipes(Directory('recipes'));

  EpubPacker(File('build/recipes.epub')).pack(
    recipes: recipes,
    modifiedAt: now,
    commitHash: commitHash,
  );
  print('Generated build/recipes.epub');
}
