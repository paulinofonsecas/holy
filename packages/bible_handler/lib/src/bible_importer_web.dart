import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

import 'bible_cache_provider.dart';
import 'models.dart';
import 'parsers/usx_parser.dart';
import 'sorting/book_sorter.dart';
import 'sorting/canonical_book_sorter.dart';

abstract class BibleLoader {
  Future<Bible> load();
}

class BibleImporter {
  final BibleLoader loader;
  BibleImporter(this.loader);
  Future<Bible> import() => loader.load();
}

class UrlBibleLoader implements BibleLoader {
  final String version;
  final BookSorter sorter;
  final void Function(DownloadProgress)? onProgress;
  final BibleCacheProvider? cacheProvider;

  UrlBibleLoader(
    this.version, {
    this.sorter = const CanonicalBookSorter(),
    this.onProgress,
    this.cacheProvider,
  });

  @override
  Future<Bible> load() async {
    // Use raw.githubusercontent.com to avoid CORS issues on Web
    final url =
        'https://raw.githubusercontent.com/paulinofonsecas/biblias/main/inst/usx/traducao/$version.zip';

    try {
      // 1. Download the zip file
      onProgress?.call(
        const DownloadProgress(
          percent: 0.1,
          downloadedBytes: 0,
          totalBytes: 100,
          status: DownloadStatus.downloading,
          message: 'Downloading version...',
        ),
      );
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download Bible $version: ${response.statusCode}',
        );
      }

      final bytes = response.bodyBytes;
      onProgress?.call(
        const DownloadProgress(
          percent: 0.5,
          downloadedBytes: 50,
          totalBytes: 100,
          status: DownloadStatus.downloading,
          message: 'Unzipping version...',
        ),
      );

      // 2. Unzip in memory
      final archive = ZipDecoder().decodeBytes(bytes);
      final contents = <String, String>{};

      for (final file in archive) {
        if (file.isFile) {
          contents[file.name] = utf8.decode(
            file.content as List<int>,
            allowMalformed: true,
          );
        }
      }

      // 3. Parse USX using the map of contents
      onProgress?.call(
        const DownloadProgress(
          percent: 0.8,
          downloadedBytes: 80,
          totalBytes: 100,
          status: DownloadStatus.downloading,
          message: 'Parsing USX...',
        ),
      );
      final parser = UsxParser();
      final bible = await parser.parseFromContents(contents, sorter: sorter);

      // 4. Cache if provider is available
      if (cacheProvider != null) {
        onProgress?.call(
          const DownloadProgress(
            percent: 0.9,
            downloadedBytes: 90,
            totalBytes: 100,
            status: DownloadStatus.downloading,
            message: 'Caching into SQLite...',
          ),
        );
        await cacheProvider!.cacheVersion(bible);
      }

      onProgress?.call(DownloadProgress.completed());
      return bible;
    } catch (e) {
      onProgress?.call(DownloadProgress.error(e.toString()));
      rethrow;
    }
  }
}

Future<Bible> loadBibleFromDirectory(
  String path, {
  BookSorter sorter = const CanonicalBookSorter(),
}) {
  throw UnimplementedError('loadBibleFromDirectory is not supported on web');
}

Future<Bible> loadBibleFromSqlite(String path) {
  throw UnimplementedError('loadBibleFromSqlite is not supported on web');
}

Future<Bible> loadBibleFromUrl(
  String version, {
  BookSorter sorter = const CanonicalBookSorter(),
  void Function(DownloadProgress)? onProgress,
  BibleCacheProvider? cacheProvider,
}) async {
  final loader = UrlBibleLoader(
    version,
    sorter: sorter,
    onProgress: onProgress,
    cacheProvider: cacheProvider,
  );
  return await loader.load();
}
