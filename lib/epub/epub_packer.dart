import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mustache_template/mustache_template.dart';

import '../models/recipe.dart';
import '../rendering/renderer.dart';

/// ePub packer.
///
/// See: <https://www.w3.org/TR/epub/>
class EpubPacker {
  static final _iso8601 = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
  static const _uuid = '550e8400-e29b-41d4-a716-446655440000';
  static const _title = 'Recepty';
  static const _language = 'sk';

  static final _opf = Template(
    File('templates/content.opf.mustache').readAsStringSync(),
    htmlEscapeValues: true,
  );

  static final _ncx = Template(
    File('templates/toc.ncx.mustache').readAsStringSync(),
    htmlEscapeValues: true,
  );

  static final _containerXml = File(
    'templates/container.xml',
  ).readAsStringSync();

  final File outputFile;
  final _archive = Archive();

  EpubPacker(this.outputFile);

  void pack({
    required List<Recipe> recipes,
    required DateTime modifiedAt,
    required String commitHash,
  }) {
    // mimetype must be first and stored uncompressed
    final mimetypeBytes = utf8.encode('application/epub+zip');
    final mimetype = ArchiveFile(
      'mimetype',
      mimetypeBytes.length,
      mimetypeBytes,
    );
    mimetype.compress = false;
    _archive.addFile(mimetype);

    _addText('META-INF/container.xml', _containerXml);

    {
      final data = {
        'title': _title,
        'language': _language,
        'uuid': _uuid,
        'modifiedAt': _formatDateTime(modifiedAt),
        'recipes': [
          for (final r in recipes)
            {
              'slug': r.slug,
              'title': r.title,
            },
        ],
      };

      _addText('OEBPS/content.opf', _opf.renderString(data));
    }

    {
      final grouped = groupBy(recipes, (r) => r.category);
      var playOrder = 3;
      final data = {
        'categories': [
          for (final entry in grouped.entries.sortedBy((e) => e.key))
            () {
              final categoryPlayOrder = playOrder++;
              return {
                'name': entry.key,
                'categoryId': entry.key.toLowerCase().replaceAll(' ', '-'),
                'playOrder': categoryPlayOrder,
                'recipes': [
                  for (final r in entry.value)
                    {
                      'slug': r.slug,
                      'title': r.title,
                      'playOrder': playOrder++,
                    },
                ],
              };
            }(),
        ],
      };

      _addText('OEBPS/toc.ncx', _ncx.renderString(data));
    }

    _addText('OEBPS/cover.html', Renderer.renderCover());
    _addText(
      'OEBPS/toc.html',
      Renderer.renderToc(recipes,
          generatedAt: modifiedAt, commitHash: commitHash),
    );
    for (final recipe in recipes) {
      _addText('OEBPS/${recipe.slug}.html', Renderer.renderRecipe(recipe));
    }

    _addBytes('OEBPS/style.css', File('assets/style.css').readAsBytesSync());
    _addBytes('OEBPS/cover.png', File('assets/cover.png').readAsBytesSync());

    outputFile.writeAsBytesSync(ZipEncoder().encode(_archive)!);
  }

  void _addText(String path, String content) {
    final bytes = utf8.encode(content);

    _archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  void _addBytes(String path, List<int> bytes) {
    _archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  static String _formatDateTime(DateTime dt) => _iso8601.format(dt.toUtc());
}
