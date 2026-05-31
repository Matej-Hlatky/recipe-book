import 'dart:io';

import 'package:recipe_book/epub/epub_packer.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:yaml/yaml.dart';

void main() {
  final buildDir = Directory('build');
  if (!buildDir.existsSync()) buildDir.createSync();

  final now = DateTime.now();
  final commitHash = _gitCommitHash();

  final recipes = Directory('recipes')
      .listSync()
      .whereType<File>()
      .where((File it) => it.path.endsWith('.yaml'))
      .map((File it) => Recipe.fromYaml(
            it.uri.pathSegments.last.replaceAll('.yaml', ''),
            loadYaml(it.readAsStringSync()) as Map,
          ))
      .toList();

  EpubPacker(File('build/recipes.epub')).pack(
    recipes: recipes,
    modifiedAt: now,
    commitHash: commitHash,
  );
  print('Generated build/recipes.epub');
}

String _gitCommitHash() {
  final result = Process.runSync('git', ['rev-parse', '--short', 'HEAD']);

  return (result.stdout as String).trim();
}
