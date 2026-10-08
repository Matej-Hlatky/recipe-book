enum ChangeKind { added, changed, removed }

/// A recipe file changed between two commits.
class RecipeChange {
  final ChangeKind kind;
  final String path;

  /// Previous path of a renamed file.
  final String? oldPath;

  const RecipeChange(this.kind, this.path, {this.oldPath});
}

/// Parses `git diff --name-status` output, keeping only `recipes/*.yaml`.
///
/// Renames count as changes.
List<RecipeChange> parseRecipeChanges(String nameStatus) {
  bool isRecipe(String path) =>
      path.startsWith('recipes/') && path.endsWith('.yaml');

  final changes = <RecipeChange>[];
  for (final line in nameStatus.split('\n')) {
    final parts = line.trim().split('\t');
    if (parts.length < 2) continue;

    final status = parts[0];
    final path = parts.last;
    if (!isRecipe(path)) continue;

    changes.add(switch (status[0]) {
      'A' => RecipeChange(ChangeKind.added, path),
      'D' => RecipeChange(ChangeKind.removed, path),
      'R' => RecipeChange(ChangeKind.changed, path, oldPath: parts[1]),
      _ => RecipeChange(ChangeKind.changed, path),
    });
  }

  return changes;
}

/// Formats release notes in Markdown.
///
/// A title that is both added and removed (a rename git did not detect)
/// is listed as changed.
String formatReleaseNotes({
  required List<String> added,
  required List<String> changed,
  required List<String> removed,
  required List<String> commits,
  String? compareUrl,
}) {
  final renamed = added.toSet().intersection(removed.toSet());
  added = [...added.where((t) => !renamed.contains(t))];
  changed = [...changed, ...renamed];
  removed = [...removed.where((t) => !renamed.contains(t))];

  final out = StringBuffer();

  final recipeLines = [
    if (added.isNotEmpty) '- Pridané: ${added.join(', ')}',
    if (changed.isNotEmpty) '- Zmenené: ${changed.join(', ')}',
    if (removed.isNotEmpty) '- Odstránené: ${removed.join(', ')}',
  ];
  if (recipeLines.isNotEmpty) {
    out
      ..writeln('## Recepty')
      ..writeAll(recipeLines.map((l) => '$l\n'))
      ..writeln();
  }

  out.writeln('## Commity');
  for (final commit in commits) {
    out.writeln('- $commit');
  }

  if (compareUrl != null) {
    out
      ..writeln()
      ..writeln('Celý diff: $compareUrl');
  }

  return out.toString();
}
