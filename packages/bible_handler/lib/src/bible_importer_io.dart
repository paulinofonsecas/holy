import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'bible_cache_provider.dart';
import 'models.dart';
import 'parsers/beblia_parser.dart';
import 'parsers/sqlite_parser.dart';
import 'parsers/usx_parser.dart';
import 'services/download_service.dart';
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
  final String? url;
  final BookSorter sorter;
  final void Function(DownloadProgress)? onProgress;
  final BibleCacheProvider? cacheProvider;

  /// [url] permite baixar de uma fonte customizada (ex.: um arquivo XML
  /// simples do repositório Beblia). Quando null, usa o zip USX padrão.
  UrlBibleLoader(
    this.version, {
    this.url,
    this.sorter = const CanonicalBookSorter(),
    this.onProgress,
    this.cacheProvider,
  });

  @override
  Future<Bible> load() async {
    final effectiveUrl = url ??
        'https://raw.githubusercontent.com/paulinofonsecas/biblias/main/inst/usx/traducao/$version.zip';

    if (looksLikeBebliaXmlUrl(effectiveUrl)) {
      return _loadFromBebliaXml(effectiveUrl);
    }

    return _loadFromUsxZip(effectiveUrl);
  }

  /// Fluxo para arquivos XML simples (Beblia): baixa o arquivo único,
  /// parseia a string e opcionalmente cacheia.
  Future<Bible> _loadFromBebliaXml(String xmlUrl) async {
    final tempDir = await Directory.systemTemp.createTemp(
      'bible_handler_${DateTime.now().millisecondsSinceEpoch}',
    );
    final xmlFile = File(p.join(tempDir.path, '$version.xml'));

    try {
      print('Downloading Bible version: $version from $xmlUrl');

      final downloadService = DownloadService();
      await for (final progress in downloadService.download(
        xmlUrl,
        xmlFile.path,
      )) {
        onProgress?.call(progress);
        if (progress.status == DownloadStatus.error) {
          throw Exception(progress.message);
        }
      }

      onProgress?.call(DownloadProgress.extracting());

      final content = await xmlFile.readAsString();
      final bible = await const BebliaXmlParser().parse(
        content,
        versionId: version,
        sorter: sorter,
      );

      if (cacheProvider != null) {
        await cacheProvider!.cacheVersion(bible, versionId: version);
      }

      return bible;
    } catch (e) {
      print('Error loading bible from beblia xml: $e');
      rethrow;
    } finally {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  /// Fluxo original: zip USX do repositório biblias.
  Future<Bible> _loadFromUsxZip(String zipUrl) async {
    final tempDir = await Directory.systemTemp.createTemp(
      'bible_handler_${DateTime.now().millisecondsSinceEpoch}',
    );
    final zipFile = File(p.join(tempDir.path, '$version.zip'));

    try {
      // Download the zip file
      print('Downloading Bible version: $version from $zipUrl');

      final downloadService = DownloadService();
      await for (final progress in downloadService.download(
        zipUrl,
        zipFile.path,
      )) {
        onProgress?.call(progress);
        if (progress.status == DownloadStatus.error) {
          throw Exception(progress.message);
        }
      }

      // The download is done; from here on the archive is processed locally.
      onProgress?.call(DownloadProgress.extracting());

      // Unzip the file
      print('Unzipping Bible version: $version');
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
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
        final subDirs =
            await tempDir.list().where((event) => event is Directory).toList();
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

      // If a cache provider is provided, cache the version
      if (cacheProvider != null) {
        await cacheProvider!.cacheVersion(b, versionId: version);
      }

      return b;
    } catch (e) {
      print('Error loading bible from url: $e');
      rethrow;
    } finally {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
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
///
/// [url] permite baixar de uma fonte customizada (ex.: um arquivo XML
/// simples do repositório Beblia). Quando null, usa o zip USX padrão.
Future<Bible> loadBibleFromUrl(
  String version, {
  String? url,
  BookSorter sorter = const CanonicalBookSorter(),
  void Function(DownloadProgress)? onProgress,
  BibleCacheProvider? cacheProvider,
}) {
  return UrlBibleLoader(
    version,
    url: url,
    sorter: sorter,
    onProgress: onProgress,
    cacheProvider: cacheProvider,
  ).load();
}
