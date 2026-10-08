import 'package:recipe_book/release_notes.dart';
import 'package:test/test.dart';

void main() {
  group('parseRecipeChanges', () {
    test('keeps only recipe yaml files and maps statuses', () {
      final changes = parseRecipeChanges([
        'A\trecipes/sk-kolozvarska-kapusta.yaml',
        'M\trecipes/dezert-tiramisu.yaml',
        'D\trecipes/italian-pasta-carbonara.yaml',
        'R087\trecipes/palacinky.yaml\trecipes/dezert-palacinky.yaml',
        'M\trecipes/schema.json',
        'M\tlib/models/recipe.dart',
      ].join('\n'));

      expect(changes.map((c) => (c.kind, c.path, c.oldPath)), [
        (ChangeKind.added, 'recipes/sk-kolozvarska-kapusta.yaml', null),
        (ChangeKind.changed, 'recipes/dezert-tiramisu.yaml', null),
        (ChangeKind.removed, 'recipes/italian-pasta-carbonara.yaml', null),
        (
          ChangeKind.changed,
          'recipes/dezert-palacinky.yaml',
          'recipes/palacinky.yaml',
        ),
      ]);
    });

    test('empty output yields no changes', () {
      expect(parseRecipeChanges(''), isEmpty);
    });
  });

  group('formatReleaseNotes', () {
    test('lists recipes by kind, commits and the compare link', () {
      final notes = formatReleaseNotes(
        added: ['Koložvárska kapusta'],
        changed: ['Quiche', 'Tiramisu'],
        removed: ['Carbonara'],
        commits: ['fbefad4 Add recipes'],
        compareUrl: 'https://github.com/o/r/compare/227f6bc...fbefad4',
      );

      expect(notes, '''
## Recepty
- Pridané: Koložvárska kapusta
- Zmenené: Quiche, Tiramisu
- Odstránené: Carbonara

## Commity
- fbefad4 Add recipes

Celý diff: https://github.com/o/r/compare/227f6bc...fbefad4
''');
    });

    test('omits empty kinds and the recipe section when nothing changed', () {
      final notes = formatReleaseNotes(
        added: [],
        changed: [],
        removed: [],
        commits: ['eb47080 Allow running workflows manually'],
      );

      expect(notes, '''
## Commity
- eb47080 Allow running workflows manually
''');
    });

    test('title both added and removed counts as changed', () {
      final notes = formatReleaseNotes(
        added: ['Chicken Tikka Masala', 'Mango lassi'],
        changed: ['Palacinky'],
        removed: ['Chicken Tikka Masala', 'Carbonara'],
        commits: ['abc1234 Rename'],
      );

      expect(notes, contains('- Pridané: Mango lassi\n'));
      expect(notes, contains('- Zmenené: Palacinky, Chicken Tikka Masala\n'));
      expect(notes, contains('- Odstránené: Carbonara\n'));
    });

    test('shows only changed kinds', () {
      final notes = formatReleaseNotes(
        added: [],
        changed: ['Tiramisu'],
        removed: [],
        commits: ['abc1234 Fix'],
      );

      expect(notes, contains('- Zmenené: Tiramisu'));
      expect(notes, isNot(contains('Pridané')));
      expect(notes, isNot(contains('Odstránené')));
    });
  });
}
