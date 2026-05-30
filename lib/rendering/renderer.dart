import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mustache_template/mustache_template.dart';

import '../models/recipe.dart';

final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

class Renderer {
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

  static String renderCover(
      {required DateTime generatedAt, required String commitHash}) {
    return _cover.renderString({
      'generatedAt': '${_dateFormat.format(generatedAt.toUtc())} UTC',
      'commitHash': commitHash,
    });
  }

  static String renderRecipe(Recipe recipe) {
    return _recipe.renderString({
      'title': recipe.title,
      'ingredients': recipe.ingredients,
      'category': recipe.category,
      'steps': recipe.steps,
    });
  }

  static String renderToc(List<Recipe> recipes) {
    final grouped = <String, List<Map<String, String>>>{};
    for (final r in recipes) {
      grouped
          .putIfAbsent(r.category, () => [])
          .add({'slug': r.slug, 'title': r.title});
    }
    return _toc.renderString({
      'categories': [
        for (final entry in grouped.entries)
          {'name': entry.key, 'recipes': entry.value},
      ],
    });
  }
}
