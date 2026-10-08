class Section {
  final String? name;
  final List<String> items;

  const Section({this.name, this.items = const []});
}

class Recipe {
  final String slug;
  final String title;
  final String category;
  final List<Section> ingredients;
  final List<Section> steps;
  final List<String> notes;
  final String? source;

  const Recipe({
    required this.slug,
    required this.title,
    required this.category,
    this.ingredients = const [],
    this.steps = const [],
    this.notes = const [],
    this.source,
  });

  factory Recipe.fromYaml(String slug, Map yaml) {
    return Recipe(
      slug: slug,
      title: yaml['title'] as String,
      category: yaml['category'] as String,
      ingredients: _parseSections(slug, 'ingredients', yaml['ingredients']),
      steps: _parseSections(slug, 'steps', yaml['steps']),
      notes: _parseNotes(slug, yaml['notes']),
      source: yaml['source'] as String?,
    );
  }

  static List<String> _parseNotes(String slug, Object? value) {
    if (value == null) return const [];
    if (value is List) return List<String>.from(value);

    throw FormatException('Recipe "$slug": "notes" must be a list.');
  }

  /// Accepts either a flat list (one unnamed section) or a map of
  /// section name to list (named sections, in written order).
  static List<Section> _parseSections(String slug, String field, Object? value) {
    if (value == null) return const [];
    if (value is List) return [Section(items: List<String>.from(value))];
    if (value is Map && value.values.every((it) => it is List)) {
      return [
        for (final entry in value.entries)
          Section(
            name: entry.key as String,
            items: List<String>.from(entry.value as List),
          ),
      ];
    }

    throw FormatException(
      'Recipe "$slug": "$field" must be a list or a map of section name to list.',
    );
  }

  @override
  String toString() {
    return 'Recipe(slug: $slug, title: $title, category: $category)';
  }
}
