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
          ingredients: [
            Section(items: ['múka'])
          ],
          steps: [
            Section(items: ['Uvariť.'])
          ],
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
      expect(html, contains('<em>Cez noc v chladničke.</em>'));
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

    test('URLs in notes render as links, surrounding text kept', () {
      final html = Renderer.renderRecipe(
        const Recipe(
          slug: 'tiramisu',
          title: 'Tiramisu',
          category: 'Dezerty',
          notes: ['Misa 32×20 & viac (https://www.ikea.com/sk/p/misa/).'],
        ),
      );

      final decoded = html.replaceAll('&#x2F;', '/');

      expect(
        decoded,
        contains(
          '<em>Misa 32×20 &amp; viac '
          '(<a href="https://www.ikea.com/sk/p/misa/">https://www.ikea.com/sk/p/misa/</a>).</em>',
        ),
      );
    });

    test('ePub links stay in the reader (XHTML 1.1 has no target)', () {
      final html = Renderer.renderRecipe(
        const Recipe(
          slug: 'tiramisu',
          title: 'Tiramisu',
          category: 'Dezerty',
          notes: ['Misa (https://www.ikea.com/).'],
          source: 'https://youtu.be/c4-9rR-YxZk',
        ),
      );

      expect(html, isNot(contains('target=')));
    });

    test('ePub recipe page still has exactly one title heading', () {
      const recipe = Recipe(
        slug: 'kolac',
        title: 'Koláč',
        category: 'Koláče',
        ingredients: [
          Section(items: ['múka'])
        ],
        steps: [
          Section(items: ['Piecť.'])
        ],
      );

      final html = Renderer.renderRecipe(recipe);

      expect('<h1>Koláč</h1>'.allMatches(html), hasLength(1));
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

  group('Renderer.categoryId', () {
    test('lowercases and replaces spaces, keeping diacritics', () {
      expect(Renderer.categoryId('Slané pečivo'), 'slané-pečivo');
      expect(Renderer.categoryId('Rakúsko-Uhorská'), 'rakúsko-uhorská');
      expect(Renderer.categoryId('Dezerty'), 'dezerty');
    });
  });

  group('Renderer.renderSiteRecipe', () {
    const recipe = Recipe(
      slug: 'kolac',
      title: 'Koláč',
      category: 'Slané pečivo',
      ingredients: [
        Section(name: 'Cesto', items: ['múka'])
      ],
      steps: [
        Section(items: ['Piecť.'])
      ],
      notes: ['Cez noc.'],
      source: 'Babka',
    );

    test('links in notes and source open in a new tab', () {
      final html = Renderer.renderSiteRecipe(
        const Recipe(
          slug: 'tiramisu',
          title: 'Tiramisu',
          category: 'Dezerty',
          notes: ['Misa (https://www.ikea.com/).', 'Bez odkazu.'],
          source: 'https://youtu.be/c4-9rR-YxZk',
        ),
      );

      expect('target="_blank" rel="noopener"'.allMatches(html), hasLength(2));
      expect(html, contains('<em>Bez odkazu.</em>'));
    });

    test('is an HTML5 page in Slovak for phones', () {
      final html = Renderer.renderSiteRecipe(recipe);

      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('lang="sk"'));
      expect(html, contains('name="viewport"'));
      expect(html, isNot(contains('xml:lang')));
    });

    test('links the shared stylesheet', () {
      final html = Renderer.renderSiteRecipe(recipe);

      expect(html, contains('href="style.css"'));
      expect(html, isNot(contains('<style>')));
    });

    test('links the favicon', () {
      expect(
        Renderer.renderSiteRecipe(recipe),
        contains('<link rel="icon" href="favicon.svg" type="image/svg+xml" />'),
      );
    });

    test('links back to the contents', () {
      final html = Renderer.renderSiteRecipe(recipe);

      expect(html, contains('<a href="index.html">‹ Obsah</a>'));
    });

    test('category tag links to its section on the contents page', () {
      final html = Renderer.renderSiteRecipe(recipe);

      expect(
        html,
        contains(
          '<a class="tag" href="index.html#slané-pečivo">Slané pečivo</a>',
        ),
      );
    });

    test('keeps the shared recipe content', () {
      final html = Renderer.renderSiteRecipe(recipe);

      expect('<h1>Koláč</h1>'.allMatches(html), hasLength(1));
      expect(
        html.indexOf('<h1>Koláč</h1>'),
        lessThan(html.indexOf('<a class="tag"')),
      );
      expect(html, contains('<h3>Cesto</h3>'));
      expect(html, contains('<li>Piecť.</li>'));
      expect(html, contains('<em>Cez noc.</em>'));
      expect(html, contains('Zdroj: Babka'));
    });

    test('uses only relative links', () {
      final html = Renderer.renderSiteRecipe(recipe);

      expect(html, isNot(contains('href="/')));
      expect(html, isNot(contains('http')));
    });

    test('escapes the title everywhere', () {
      final html = Renderer.renderSiteRecipe(
        const Recipe(
          slug: 'chlieb',
          title: 'Chlieb & "maslo"',
          category: 'Pečivo',
          ingredients: [
            Section(items: ['múka'])
          ],
          steps: [
            Section(items: ['Piecť.'])
          ],
        ),
      );

      expect(
        html,
        contains('<title>Chlieb &amp; &quot;maslo&quot;</title>'),
      );
      expect(html, contains('content="Chlieb &amp; &quot;maslo&quot;"'));
      expect(html, isNot(contains('Chlieb & ')));
      expect(html, isNot(contains('"maslo"')));
    });

    test('sets link preview tags', () {
      final html = Renderer.renderSiteRecipe(recipe);

      expect(html, contains('property="og:title" content="Koláč"'));
      expect(
        html,
        contains('property="og:description" content="Slané pečivo"'),
      );
    });
  });

  group('Renderer.renderSiteIndex', () {
    const recipes = [
      Recipe(
        slug: 'kolac-babovka',
        title: 'Bábovka',
        category: 'Koláče',
        ingredients: [
          Section(items: ['múka'])
        ],
        steps: [
          Section(items: ['Upiecť.'])
        ],
      ),
      Recipe(
        slug: 'slane-osie-hniezda',
        title: 'Osie hniezda',
        category: 'Slané pečivo',
        ingredients: [
          Section(items: ['múka'])
        ],
        steps: [
          Section(items: ['Upiecť.'])
        ],
      ),
      Recipe(
        slug: 'dezert-palacinky',
        title: 'Palacinky',
        category: 'Dezerty',
        ingredients: [
          Section(items: ['múka'])
        ],
        steps: [
          Section(items: ['Usmažiť.'])
        ],
      ),
    ];

    String render() => Renderer.renderSiteIndex(
          recipes,
          generatedAt: DateTime.utc(2026, 10, 31, 9, 5),
          commitHash: 'abc1234',
        );

    test('is an HTML5 page titled Recepty', () {
      final html = render();

      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<title>Recepty</title>'));
      expect(html, contains('<h1>Recepty</h1>'));
      expect(html, contains('href="style.css"'));
    });

    test('links every recipe by its file name', () {
      final html = render();

      expect(html, contains('<a href="kolac-babovka.html">Bábovka</a>'));
      expect(
        html,
        contains('<a href="slane-osie-hniezda.html">Osie hniezda</a>'),
      );
      expect(html, contains('<a href="dezert-palacinky.html">Palacinky</a>'));
    });

    test('category tags and headings link to the heading', () {
      final html = render();

      for (final (name, id) in [
        ('Dezerty', 'dezerty'),
        ('Koláče', 'koláče'),
        ('Slané pečivo', 'slané-pečivo'),
      ]) {
        expect(html, contains('<a class="tag" href="#$id">$name</a>'));
        expect(html, contains('<h2 id="$id"><a href="#$id">$name</a></h2>'));
      }
    });

    test('categories are sorted by name', () {
      final html = render();

      final dezerty = html.indexOf('>Dezerty</a></h2>');
      final kolace = html.indexOf('>Koláče</a></h2>');
      final slane = html.indexOf('>Slané pečivo</a></h2>');
      expect(dezerty, isNonNegative);
      expect(dezerty, lessThan(kolace));
      expect(kolace, lessThan(slane));
    });

    test('shows build time and commit', () {
      expect(render(), contains('2026-10-31 09:05 UTC · abc1234'));
    });

    test('uses only relative links', () {
      final html = render();

      expect(html, isNot(contains('href="/')));
      expect(html, isNot(contains('http')));
    });
  });

  group('short words stay with the next word', () {
    const nbsp = ' ';
    const recipe = Recipe(
      slug: 'kolac',
      title: 'Koláč s ovocím',
      category: 'Koláče',
      ingredients: [
        Section(name: 'Na cesto', items: ['múka na posypanie']),
      ],
      steps: [
        Section(items: ['Dať do rúry.']),
      ],
      notes: ['Podávať s cukrom, pozri na https://example.sk/a.'],
    );

    for (final (name, render) in [
      ('ePub', Renderer.renderRecipe),
      ('site', Renderer.renderSiteRecipe),
    ]) {
      test('in the $name recipe page', () {
        final html = render(recipe).replaceAll('&#x2F;', '/');

        expect(html, contains('<h1>Koláč s${nbsp}ovocím</h1>'));
        expect(html, contains('<h3>Na${nbsp}cesto</h3>'));
        expect(html, contains('múka na${nbsp}posypanie'));
        expect(html, contains('Dať do${nbsp}rúry.'));
        expect(
            html,
            contains(
                's${nbsp}cukrom, pozri na$nbsp<a href="https://example.sk/a"'));
        expect(html, isNot(contains('&nbsp;')));
      });
    }

    test('in the contents page', () {
      final html = Renderer.renderSiteIndex(
        [recipe],
        generatedAt: DateTime.utc(2026),
        commitHash: 'abc1234',
      );

      expect(html, contains('<a href="kolac.html">Koláč s${nbsp}ovocím</a>'));
    });

    test('not in the page title and link preview', () {
      final html = Renderer.renderSiteRecipe(recipe);

      expect(html, contains('<title>Koláč s ovocím</title>'));
      expect(html, contains('content="Koláč s ovocím"'));
    });
  });
}
