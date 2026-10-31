import 'dart:convert';
import 'dart:io';

/// Short hash of the current commit.
String gitCommitHash() {
  final result = Process.runSync(
    'git',
    ['rev-parse', '--short', 'HEAD'],
    stdoutEncoding: utf8,
  );

  return (result.stdout as String).trim();
}
