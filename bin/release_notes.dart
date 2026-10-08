import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:recipe_book/release_notes.dart';
import 'package:yaml/yaml.dart';

/// Prints Markdown release notes for the changes between two commits.
///
/// Usage: `dart run bin/release_notes.dart <from> <to> [repoUrl]`
void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Usage: dart run bin/release_notes.dart <from> <to> [repoUrl]');
    exit(64);
  }
  final [from, to, ...rest] = args;
  final repoUrl = rest.firstOrNull;

  final changes = parseRecipeChanges(
    _git(['diff', '--name-status', '-M', from, to, '--', 'recipes/']),
  );
  List<String> titles(ChangeKind kind, String rev) => [
        for (final c in changes.where((c) => c.kind == kind))
          _recipeTitle(rev, c.path),
      ];

  final commits = _git(['log', '--format=%h %s', '$from..$to'])
      .split('\n')
      .where((it) => it.isNotEmpty)
      .toList();

  final notes = formatReleaseNotes(
    added: titles(ChangeKind.added, to),
    changed: titles(ChangeKind.changed, to),
    removed: titles(ChangeKind.removed, from),
    commits: commits,
    compareUrl: repoUrl == null
        ? null
        : '$repoUrl/compare/${_shortSha(from)}...${_shortSha(to)}',
  );
  stdout
    ..encoding = utf8
    ..write(notes);
}

/// Reads the recipe title at [rev], falling back to the file name.
String _recipeTitle(String rev, String path) {
  try {
    final yaml = loadYaml(_git(['show', '$rev:$path'])) as Map;

    return yaml['title'] as String;
  } on Object {
    return p.basenameWithoutExtension(path);
  }
}

String _shortSha(String rev) => _git(['rev-parse', '--short', rev]).trim();

String _git(List<String> args) {
  final result = Process.runSync('git', args, stdoutEncoding: utf8);
  if (result.exitCode != 0) {
    throw ProcessException('git', args, result.stderr as String, result.exitCode);
  }

  return result.stdout as String;
}
