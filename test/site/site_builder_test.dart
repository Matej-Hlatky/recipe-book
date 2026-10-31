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

  test('removes pages from earlier builds', () {
    outDir.createSync(recursive: true);
    File('${outDir.path}/old.html').writeAsStringSync('old');

    build();

    expect(File('${outDir.path}/old.html').existsSync(), isFalse);
  });
}
