import 'dart:convert';
import 'dart:io';

import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/site/site_builder.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;
  late Directory outDir;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('site_');
    outDir = Directory('${tmp.path}/site');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  void build({List<String> slugs = const ['a', 'b']}) {
    SiteBuilder(outDir).build(
      recipes: [
        for (final slug in slugs)
          Recipe(slug: slug, title: 'Recept $slug', category: 'Dezerty'),
      ],
      generatedAt: DateTime(2026, 10, 31, 12),
      commitHash: 'abc1234',
    );
  }

  test('writes the contents page and one page per recipe', () {
    build();

    for (final name in ['index.html', 'a.html', 'b.html']) {
      expect(File('${outDir.path}/$name').existsSync(), isTrue, reason: name);
    }
  });

  test('copies the stylesheet and fonts', () {
    build();

    expect(
      File('${outDir.path}/style.css').readAsStringSync(),
      File('assets/site.css').readAsStringSync(),
    );
    final fonts = Directory('assets/fonts')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((name) => !name.startsWith('.'));
    for (final name in fonts) {
      expect(File('${outDir.path}/fonts/$name').existsSync(), isTrue,
          reason: name);
    }
    for (final name in ['LICENSE-lora.txt', 'LICENSE-caveat.txt']) {
      expect(File('${outDir.path}/fonts/$name').existsSync(), isTrue,
          reason: name);
    }
  });

  test('copies the app manifest and its icons', () {
    build();

    final manifest = jsonDecode(
      File('${outDir.path}/manifest.webmanifest').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(manifest['start_url'], './');
    expect(manifest['scope'], './');
    expect(manifest['display'], 'standalone');
    expect(manifest['lang'], 'sk');
    final icons = manifest['icons'] as List;
    expect(icons, isNotEmpty);
    for (final icon in icons.cast<Map<String, dynamic>>()) {
      expect(File('${outDir.path}/${icon['src']}').existsSync(), isTrue,
          reason: icon['src'] as String);
    }
    expect(
        File('${outDir.path}/icons/apple-touch-icon.png').existsSync(), isTrue);
  });

  test('service worker saves every built file for offline use', () {
    build();

    final js = File('${outDir.path}/sw.js').readAsStringSync();
    final files = outDir
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.substring(outDir.path.length + 1))
        .where((path) => path != 'sw.js');
    for (final path in files) {
      expect(js, contains('"$path"'), reason: path);
    }
    expect(js, contains('"./"'));
    expect(js, isNot(contains('"sw.js"')));
  });

  test('service worker version changes with every build', () {
    build();

    expect(
      File('${outDir.path}/sw.js').readAsStringSync(),
      contains(
        "'recepty-abc1234-${DateTime(2026, 10, 31, 12).millisecondsSinceEpoch}'",
      ),
    );
  });

  test('copies the favicon', () {
    build();

    expect(
      File('${outDir.path}/favicon.svg').readAsStringSync(),
      File('assets/favicon.svg').readAsStringSync(),
    );
  });

  test('removes pages from earlier builds', () {
    outDir.createSync(recursive: true);
    File('${outDir.path}/old.html').writeAsStringSync('old');

    build();

    expect(File('${outDir.path}/old.html').existsSync(), isFalse);
  });
}
