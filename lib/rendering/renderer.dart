import 'dart:io';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mustache_template/mustache_template.dart';

import '../models/recipe.dart';

class Renderer {
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  static final _recipe = Template(
    File('templates/recipe.html.mustache').readAsStringSync(),
    htmlEscapeValues: true,
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

  static String renderRecipe(Recipe recipe) {
    final data = {
      'title': recipe.title,
      'ingredients': recipe.ingredients,
      'category': recipe.category,
      'steps': recipe.steps,
    };

    return _recipe.renderString(data);
  }

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
