import 'dart:io';

import 'package:recipe_book/recipe_loader.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('recipes_'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('loads only yaml files, using the file name as slug', () {
    File('${dir.path}/dezert-tiramisu.yaml').writeAsStringSync('''
title: Tiramisu
category: Dezerty
steps:
  - Ukladať.
''');
    File('${dir.path}/schema.json').writeAsStringSync('{}');

    final recipes = loadRecipes(dir);

    expect(recipes.map((r) => r.slug), ['dezert-tiramisu']);
    expect(recipes.single.title, 'Tiramisu');
  });
}
