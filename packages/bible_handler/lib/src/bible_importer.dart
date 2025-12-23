import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'models.dart';
import 'parsers/sqlite_parser.dart';
import 'parsers/usx_parser.dart';
import 'sorting/book_sorter.dart';
import 'sorting/canonical_book_sorter.dart';

// --- Strategy Interface ---

/// Abstract class for different Bible loading strategies.
abstract class BibleLoader {
  Future<Bible> load();
}

// --- Concrete Strategies ---

/// Loads a Bible from a directory.
class DirectoryBibleLoader implements BibleLoader {
  final String directoryPath;
  final BookSorter sorter;

  DirectoryBibleLoader(
    this.directoryPath, {
    this.sorter = const CanonicalBookSorter(),
  });

  @override
  Future<Bible> load() async {
    final parser = UsxParser();
    print('Loading Bible from directory: $directoryPath');
    final bible = await parser.parse(directoryPath, sorter: sorter);

    print('Loaded Bible from directory: $directoryPath');

    return bible;
  }
}

/// Loads a Bible from an SQLite file.
class SqliteBibleLoader implements BibleLoader {
  final String filePath;

  SqliteBibleLoader(this.filePath);

  @override
  Future<Bible> load() {
    final parser = SqliteParser();
    return parser.parse(filePath);
  }
}

/// Loads a Bible from a URL.
class UrlBibleLoader implements BibleLoader {
  final String version;
  final BookSorter sorter;

  UrlBibleLoader(this.version, {this.sorter = const CanonicalBookSorter()});

  @override
  Future<Bible> load() async {
    final url =
        'https://github.com/paulinofonsecas/biblias/blob/main/inst/usx/traducao/$version.zip?raw=true';
    final tempDir = await Directory.systemTemp.createTemp(
      'bible_handler_${DateTime.now().millisecondsSinceEpoch}',
    );

    try {
      // Download the zip file
      print('Downloading Bible version: $version from $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download Bible version: $version. Status code: ${response.statusCode}',
        );
      }

      // Unzip the file
      print('Unzipping Bible version: $version');
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      for (final file in archive) {
        final filename = p.join(tempDir.path, file.name);
        if (file.isFile) {
          final outFile = File(filename);
          await Directory(p.dirname(filename)).create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filename).create(recursive: true);
        }
      }

      // Find the correct directory
      var effectivePath = tempDir.path;
      final metadataFile = File(p.join(effectivePath, 'metadata.xml'));
      if (!await metadataFile.exists()) {
        final subDirs = await tempDir
            .list()
            .where((event) => event is Directory)
            .toList();
        if (subDirs.isNotEmpty) {
          final potentialPath = subDirs.first.path;
          final potentialMetadata = File(p.join(potentialPath, 'metadata.xml'));
          if (await potentialMetadata.exists()) {
            effectivePath = potentialPath;
          }
        }
      }

      

      // Use DirectoryBibleLoader for the final step
      final directoryLoader = DirectoryBibleLoader(
        effectivePath,
        sorter: sorter,
      );
      final b = await directoryLoader.load();
      return b..directoryPathSaved = effectivePath;
    } catch (e) {
      print('Error loading bible from url: $e');
      rethrow;
    }
  }
}

// --- Context Class ---

/// The context class that uses a BibleLoader strategy.
class BibleImporter {
  final BibleLoader loader;

  BibleImporter(this.loader);

  Future<Bible> import() {
    return loader.load();
  }
}

// --- Helper functions for easy use ---

/// A top-level function to load a Bible version from a directory.
Future<Bible> loadBibleFromDirectory(
  String directoryPath, {
  BookSorter sorter = const CanonicalBookSorter(),
}) {
  return DirectoryBibleLoader(directoryPath, sorter: sorter).load();
}

/// A top-level function to load a Bible version from an SQLite file.
Future<Bible> loadBibleFromSqlite(String filePath) {
  return SqliteBibleLoader(filePath).load();
}

/// A top-level function to load a Bible version from a URL.
Future<Bible> loadBibleFromUrl(
  String version, {
  BookSorter sorter = const CanonicalBookSorter(),
}) {
  return UrlBibleLoader(version, sorter: sorter).load();
}
