import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:mustache_template/mustache_template.dart';
import '../models/recipe.dart';

class EpubPacker {
  static final _opf = Template(
    File('templates/content.opf.mustache').readAsStringSync(),
    htmlEscapeValues: true,
  );

  static final _ncx = Template(
    File('templates/toc.ncx.mustache').readAsStringSync(),
    htmlEscapeValues: true,
  );

  static const _containerXml = '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<container version="1.0" xmlns="urn:oasis:schemas:container">\n'
      '  <rootfiles>\n'
      '    <rootfile full-path="OEBPS/content.opf"'
      ' media-type="application/oebps-package+xml"/>\n'
      '  </rootfiles>\n'
      '</container>\n';

  static void pack(List<Recipe> recipes, String outputPath) {
    final archive = Archive();

    // mimetype must be first and stored uncompressed
    final mimetypeBytes = utf8.encode('application/epub+zip');
    final mimetype = ArchiveFile('mimetype', mimetypeBytes.length, mimetypeBytes);
    mimetype.compress = false;
    archive.addFile(mimetype);

    _addText(archive, 'META-INF/container.xml', _containerXml);

    final recipesData = [
      for (final r in recipes) {'slug': r.slug, 'title': r.title},
    ];
    _addText(archive, 'OEBPS/content.opf', _opf.renderString({'recipes': recipesData}));

    final ncxData = [
      for (var i = 0; i < recipes.length; i++)
        {'slug': recipes[i].slug, 'title': recipes[i].title, 'playOrder': i + 3},
    ];
    _addText(archive, 'OEBPS/toc.ncx', _ncx.renderString({'recipes': ncxData}));

    for (final file in Directory('build').listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      final bytes = file.readAsBytesSync();
      archive.addFile(ArchiveFile('OEBPS/$name', bytes.length, bytes));
    }

    File(outputPath).writeAsBytesSync(ZipEncoder().encode(archive)!);
  }

  static void _addText(Archive archive, String path, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }
}
