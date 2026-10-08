import 'dart:io';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mustache_template/mustache_template.dart';

import '../models/recipe.dart';

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
  static final _standaloneRecipe = Template(
    File('templates/recipe.standalone.html.mustache').readAsStringSync(),
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

  static Template? _resolvePartial(String name) =>
      name == 'recipe_body' ? _recipeBody : null;

  /// Renders an XHTML recipe page for the ePub, linking `style.css`.
  static String renderRecipe(Recipe recipe) {
    final data = _recipeData(recipe);

    return _recipe.renderString(data);
  }

  /// Renders a self-contained HTML5 recipe page with [css] inlined.
  static String renderStandaloneRecipe(Recipe recipe, {required String css}) {
    final data = {..._recipeData(recipe), 'css': css};

    return _standaloneRecipe.renderString(data);
  }

  static Map<String, Object?> _recipeData(Recipe recipe) => {
        'title': recipe.title,
        'ingredients': _sectionsData(recipe.ingredients),
        'category': recipe.category,
        'steps': _sectionsData(recipe.steps),
        'hasFooter': recipe.notes.isNotEmpty || recipe.source != null,
        'notes': recipe.notes,
        'source': recipe.source,
        'sourceIsUrl': recipe.source?.startsWith('http') ?? false,
      };

  static List<Map<String, Object?>> _sectionsData(List<Section> sections) => [
        for (final s in sections) {'name': s.name, 'items': s.items},
      ];

  static String renderToc(
    List<Recipe> recipes, {
    required DateTime generatedAt,
    required String commitHash,
  }) {
    final grouped = groupBy(recipes, (r) => r.category);

    final data = {
      'generatedAt': '${_dateFormat.format(generatedAt.toUtc())} UTC',
      'commitHash': commitHash,
      'categories': [
        for (final entry in grouped.entries.sortedBy((e) => e.key))
          {
            'name': entry.key,
            'recipes': [
              for (final r in entry.value) {'slug': r.slug, 'title': r.title},
            ],
          },
      ],
    };

    return _toc.renderString(data);
  }
}
