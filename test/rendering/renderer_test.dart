import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/rendering/renderer.dart';
import 'package:test/test.dart';

void main() {
  group('Renderer.renderRecipe', () {
    test('unnamed section renders without a section heading', () {
      final html = Renderer.renderRecipe(
        const Recipe(
          slug: 'halusky',
          title: 'Halušky',
          category: 'Prílohy',
          ingredients: [Section(items: ['múka'])],
          steps: [Section(items: ['Uvariť.'])],
        ),
      );

      expect(html, isNot(contains('<h3>')));
      expect(html, contains('<li>múka</li>'));
      expect(html, contains('<li>Uvariť.</li>'));
    });

    test('ePub recipe page is marked as Slovak', () {
      final html = Renderer.renderRecipe(
        const Recipe(slug: 'voda', title: 'Voda', category: 'Nápoje'),
      );

      expect(html, contains('xml:lang="sk"'));
    });

    test('recipe without notes and source has no footer', () {
      final html = Renderer.renderRecipe(
        const Recipe(slug: 'voda', title: 'Voda', category: 'Nápoje'),
      );

      expect(html, isNot(contains('<hr')));
      expect(html, isNot(contains('Zdroj')));
    });

    test('notes render in italics below a horizontal line', () {
      final html = Renderer.renderRecipe(
        const Recipe(
          slug: 'tiramisu',
          title: 'Tiramisu',
          category: 'Dezerty',
          notes: ['Cez noc v chladničke.'],
        ),
      );

      expect(html, contains('<hr'));
      expect(html, contains('<em>Cez noc v chladničke.</em>'));
      expect(html.indexOf('<hr'), lessThan(html.indexOf('Cez noc')));
    });

    test('URL source renders as a link', () {
      final html = Renderer.renderRecipe(
        const Recipe(
          slug: 'tiramisu',
          title: 'Tiramisu',
          category: 'Dezerty',
          source: 'https://youtu.be/c4-9rR-YxZk',
        ),
      );

      // Mustache HTML-escapes "/" as "&#x2F;", which readers decode.
      final decoded = html.replaceAll('&#x2F;', '/');

      expect(html, contains('<hr'));
      expect(
        decoded,
        contains(
          '<a href="https://youtu.be/c4-9rR-YxZk">https://youtu.be/c4-9rR-YxZk</a>',
        ),
      );
    });

    test('non-URL source renders as plain text', () {
      final html = Renderer.renderRecipe(
        const Recipe(
          slug: 'lassi',
          title: 'Mango lassi',
          category: 'India',
          source: 'Chefparade kurz varenia',
        ),
      );

      expect(html, contains('Zdroj: Chefparade kurz varenia'));
      expect(html, isNot(contains('<a ')));
    });

    test('standalone page inlines the CSS and keeps the recipe content', () {
      const recipe = Recipe(
        slug: 'kolac',
        title: 'Koláč',
        category: 'Koláče',
        ingredients: [Section(name: 'Cesto', items: ['múka'])],
        steps: [Section(items: ['Piecť.'])],
        notes: ['Cez noc.'],
        source: 'Babka',
      );

      final html = Renderer.renderStandaloneRecipe(
        recipe,
        css: 'h1 { color: red; }',
      );

      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<style>'));
      expect(html, contains('h1 { color: red; }'));
      expect(html, isNot(contains('style.css')));
      expect(html, contains('name="viewport"'));
      expect(html, contains('<h1>Koláč</h1>'));
      expect(html, contains('<h3>Cesto</h3>'));
      expect(html, contains('<li>Piecť.</li>'));
      expect(html, contains('<em>Cez noc.</em>'));
      expect(html, contains('Zdroj: Babka'));
    });

    test('named sections render headings and separate step lists', () {
      final html = Renderer.renderRecipe(
        const Recipe(
          slug: 'kolac',
          title: 'Koláč',
          category: 'Koláče',
          ingredients: [
            Section(name: 'Cesto', items: ['múka']),
            Section(name: 'Posýpka', items: ['cukor']),
          ],
          steps: [
            Section(name: 'Cesto', items: ['Vymiešať.']),
            Section(name: 'Pečenie', items: ['Piecť.']),
          ],
        ),
      );

      expect(html, contains('<h3>Posýpka</h3>'));
      expect(html, contains('<h3>Pečenie</h3>'));
      expect('<ol>'.allMatches(html), hasLength(2));
      expect(html.indexOf('<h3>Cesto</h3>'), lessThan(html.indexOf('múka')));
    });
  });
}
