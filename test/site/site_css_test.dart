import 'dart:io';

import 'package:test/test.dart';

void main() {
  final css = File('assets/site.css').readAsStringSync();

  test('every font the stylesheet references exists', () {
    final names = RegExp(r'url\(fonts/([^)]+)\)')
        .allMatches(css)
        .map((m) => m.group(1)!)
        .toList();

    expect(names.length, greaterThanOrEqualTo(8));
    for (final name in names) {
      expect(File('assets/fonts/$name').existsSync(), isTrue, reason: name);
    }
  });

  test('loads nothing from the network', () {
    expect(css, isNot(contains('http')));
    expect(css, isNot(contains('@import')));
  });
}
