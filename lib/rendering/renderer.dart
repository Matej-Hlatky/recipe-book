import 'dart:io';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mustache_template/mustache_template.dart';

import '../models/recipe.dart';
import 'typography.dart';

class Renderer {
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  static final _recipeBody = Template(
    File('templates/recipe_body.mustache').readAsStringSync(),
    htmlEscapeValues: true,
  );
  static final _recipe = Template(
    File('templates/recipe.html.mustache').readAsStringSync(),
    htmlEscapeValues: true,
    partialResolver: _resolvePartial,
  );
  static final _siteHead = Template(
    File('templates/site/head.mustache').readAsStringSync(),
    htmlEscapeValues: true,
  );
  static final _siteRecipe = Template(
    File('templates/site/recipe.html.mustache').readAsStringSync(),
    htmlEscapeValues: true,
    partialResolver: _resolvePartial,
  );
  static final _siteIndex = Template(
    File('templates/site/index.html.mustache').readAsStringSync(),
    htmlEscapeValues: true,
    partialResolver: _resolvePartial,
  );
  static final _cover = Template(
    File('templates/cover.html.mustache').readAsStringSync(),
    htmlEscapeValues: true,
  );
  static final _toc = Template(
    File('templates/toc.html.mustache').readAsStringSync(),
    htmlEscapeValues: true,
  );

  static String renderCover() => _cover.renderString({});

  static Template? _resolvePartial(String name) => switch (name) {
        'recipe_body' => _recipeBody,
        'site_head' => _siteHead,
        _ => null,
      };

  /// Anchor id of a category on the contents page and in the NCX.
  static String categoryId(String category) =>
      category.toLowerCase().replaceAll(' ', '-');

  /// Renders an XHTML recipe page for the ePub, linking `style.css`.
  static String renderRecipe(Recipe recipe) {
    final data = _recipeData(recipe);

    return _recipe.renderString(data);
  }

  /// Renders an HTML5 recipe page for the website, linking `style.css`.
  /// Links open in a new tab, so the recipe stays open.
  static String renderSiteRecipe(Recipe recipe) =>
      _siteRecipe.renderString({..._recipeData(recipe), 'newTab': true});

  /// Visible text gets [bindShortWords]; `pageTitle` and `description`
  /// (browser tab, link previews) stay plain.
  static Map<String, Object?> _recipeData(Recipe recipe) => {
        'title': bindShortWords(recipe.title),
        'ingredients': _sectionsData(recipe.ingredients),
        'category': recipe.category,
        'categoryId': categoryId(recipe.category),
        'pageTitle': recipe.title,
        'description': recipe.category,
        'steps': _sectionsData(recipe.steps),
        'hasFooter': recipe.notes.isNotEmpty || recipe.source != null,
        'notes': [
          for (final note in recipe.notes)
            {'parts': _linkParts(bindShortWords(note))},
        ],
        'source': recipe.source,
        'sourceIsUrl': recipe.source?.startsWith('http') ?? false,
        'newTab': false,
      };

  static List<Map<String, Object?>> _sectionsData(List<Section> sections) => [
        for (final s in sections)
          {
            'name': s.name == null ? null : bindShortWords(s.name!),
            'items': s.items.map(bindShortWords).toList(),
          },
      ];

  // Stops before brackets and whitespace; trailing punctuation is trimmed
  // below, so "(https://…/)." links only the URL.
  static final _url = RegExp(r'https?://[^\s()<>]+');
  static final _trailingPunctuation = RegExp(r'[.,;:!?]+$');

  /// Splits [text] into plain-text and URL parts, in order.
  static List<Map<String, Object?>> _linkParts(String text) {
    final parts = <Map<String, Object?>>[];
    var start = 0;
    for (final match in _url.allMatches(text)) {
      final url = match[0]!.replaceFirst(_trailingPunctuation, '');
      if (match.start > start) {
        parts
            .add({'text': text.substring(start, match.start), 'isLink': false});
      }
      parts.add({'text': url, 'isLink': true});
      start = match.start + url.length;
    }
    if (start < text.length) {
      parts.add({'text': text.substring(start), 'isLink': false});
    }

    return parts;
  }

  static String renderToc(
    List<Recipe> recipes, {
    required DateTime generatedAt,
    required String commitHash,
  }) =>
      _toc.renderString(_contentsData(recipes, generatedAt, commitHash));

  /// Renders the HTML5 contents page for the website, linking `style.css`.
  static String renderSiteIndex(
    List<Recipe> recipes, {
    required DateTime generatedAt,
    required String commitHash,
  }) =>
      _siteIndex.renderString({
        ..._contentsData(recipes, generatedAt, commitHash),
        'pageTitle': 'Recepty',
        'description': 'Recepty z našej kuchyne',
      });

  /// Recipes grouped by category, categories sorted by name.
  static Map<String, Object?> _contentsData(
    List<Recipe> recipes,
    DateTime generatedAt,
    String commitHash,
  ) {
    final grouped = groupBy(recipes, (r) => r.category);

    return {
      'generatedAt': '${_dateFormat.format(generatedAt.toUtc())} UTC',
      'commitHash': commitHash,
      'categories': [
        for (final entry in grouped.entries.sortedBy((e) => e.key))
          {
            'name': entry.key,
            'id': categoryId(entry.key),
            'recipes': [
              for (final r in entry.value)
                {'slug': r.slug, 'title': bindShortWords(r.title)},
            ],
          },
      ],
    };
  }
}
