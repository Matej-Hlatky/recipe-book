class Recipe {
  final String slug;
  final String title;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> images;

  const Recipe({
    required this.slug,
    required this.title,
    required this.category,
    this.ingredients = const [],
    required this.steps,
    this.images = const [],
  });

  factory Recipe.fromYaml(String slug, Map yaml) {
    return Recipe(
      slug: slug,
      title: yaml['title'] as String,
      category: yaml['category'] as String,
      ingredients: yaml['ingredients'] != null
          ? List<String>.from(yaml['ingredients'] as List)
          : const [],
      steps: List<String>.from(yaml['steps'] as List),
      images: yaml['images'] != null
          ? List<String>.from(yaml['images'] as List)
          : const [],
    );
  }

  @override
  String toString() {
    return 'Recipe(slug: $slug, title: $title, category: $category)';
  }
}
