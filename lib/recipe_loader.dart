import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'models/recipe.dart';

/// Loads all `*.yaml` recipes from [dir], sorted by file name.
///
/// The file name without extension becomes the recipe slug.
List<Recipe> loadRecipes(Directory dir) {
  final files = dir
      .listSync()
      .whereType<File>()
      .where((it) => it.path.endsWith('.yaml'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  return [
    for (final file in files)
      Recipe.fromYaml(
        p.basenameWithoutExtension(file.path),
        loadYaml(file.readAsStringSync()) as Map,
      ),
  ];
}
