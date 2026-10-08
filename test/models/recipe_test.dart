import 'package:recipe_book/models/recipe.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

Recipe _parse(String source) =>
    Recipe.fromYaml('test-recipe', loadYaml(source) as Map);

void main() {
  group('Recipe.fromYaml', () {
    test('flat lists become a single unnamed section', () {
      final recipe = _parse('''
title: Halušky
category: Prílohy
ingredients:
  - múka
  - vajce
steps:
  - Zmiešať.
  - Uvariť.
''');

      expect(recipe.ingredients, hasLength(1));
      expect(recipe.ingredients.single.name, isNull);
      expect(recipe.ingredients.single.items, ['múka', 'vajce']);
      expect(recipe.steps, hasLength(1));
      expect(recipe.steps.single.name, isNull);
      expect(recipe.steps.single.items, ['Zmiešať.', 'Uvariť.']);
    });

    test('maps become named sections in written order', () {
      final recipe = _parse('''
title: Koláč
category: Koláče
ingredients:
  Cesto:
    - múka
    - maslo
  Posýpka:
    - cukor
steps:
  Cesto:
    - Vymiešať.
  Pečenie:
    - Piecť pri 180°.
''');

      expect(recipe.ingredients.map((s) => s.name), ['Cesto', 'Posýpka']);
      expect(recipe.ingredients[0].items, ['múka', 'maslo']);
      expect(recipe.ingredients[1].items, ['cukor']);
      expect(recipe.steps.map((s) => s.name), ['Cesto', 'Pečenie']);
      expect(recipe.steps[1].items, ['Piecť pri 180°.']);
    });

    test('missing ingredients yield no sections', () {
      final recipe = _parse('''
title: Voda
category: Nápoje
steps:
  - Naliať.
''');

      expect(recipe.ingredients, isEmpty);
    });

    test('invalid shape throws FormatException naming the recipe', () {
      expect(
        () => _parse('''
title: Zlý
category: Iné
ingredients: len text
steps:
  - Nič.
'''),
        throwsA(
          isA<FormatException>()
              .having((e) => e.message, 'message', contains('test-recipe'))
              .having((e) => e.message, 'message', contains('ingredients')),
        ),
      );
    });

    test('notes and source are parsed', () {
      final recipe = _parse('''
title: Tiramisu
category: Dezerty
steps:
  - Ukladať.
notes:
  - Polovičná dávka sa zmestí do 1l dózy.
source: https://youtu.be/c4-9rR-YxZk
''');

      expect(recipe.notes, ['Polovičná dávka sa zmestí do 1l dózy.']);
      expect(recipe.source, 'https://youtu.be/c4-9rR-YxZk');
    });

    test('missing notes and source yield empty notes and null source', () {
      final recipe = _parse('''
title: Voda
category: Nápoje
steps:
  - Naliať.
''');

      expect(recipe.notes, isEmpty);
      expect(recipe.source, isNull);
    });

    test('notes that are not a list throw FormatException', () {
      expect(
        () => _parse('''
title: Zlý
category: Iné
steps:
  - Nič.
notes: len text
'''),
        throwsA(
          isA<FormatException>()
              .having((e) => e.message, 'message', contains('test-recipe'))
              .having((e) => e.message, 'message', contains('notes')),
        ),
      );
    });

    test('non-list section value throws FormatException', () {
      expect(
        () => _parse('''
title: Zlý
category: Iné
steps:
  Cesto: Vymiešať.
'''),
        throwsA(
          isA<FormatException>()
              .having((e) => e.message, 'message', contains('steps')),
        ),
      );
    });
  });
}
