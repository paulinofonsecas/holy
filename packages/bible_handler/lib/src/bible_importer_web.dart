import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'bible_cache_provider.dart';
import 'models.dart';
import 'parsers/beblia_parser.dart';
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

  /// Fluxo para arquivos XML simples (Beblia): baixa o arquivo único e
  /// parseia a string — sem unzip nem parseFromContents.
  Future<Bible> _loadFromBebliaXml(String xmlUrl) async {
    try {
      onProgress?.call(
        const DownloadProgress(
          percent: 0.1,
          downloadedBytes: 0,
          totalBytes: 100,
          status: DownloadStatus.downloading,
          message: 'Downloading version...',
        ),
      );
      final response = await http.get(Uri.parse(xmlUrl));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download Bible $version: ${response.statusCode}',
        );
      }

      final content = utf8.decode(response.bodyBytes, allowMalformed: true);

      onProgress?.call(
        const DownloadProgress(
          percent: 1.0,
          downloadedBytes: 0,
          totalBytes: 0,
          status: DownloadStatus.extracting,
          message: 'Parsing XML...',
        ),
      );

      final bible = await const BebliaXmlParser().parse(
        content,
        versionId: version,
        sorter: sorter,
      );

      if (cacheProvider != null) {
        onProgress?.call(
          const DownloadProgress(
            percent: 1.0,
            downloadedBytes: 0,
            totalBytes: 0,
            status: DownloadStatus.extracting,
            message: 'Caching into SQLite...',
          ),
        );
        await cacheProvider!.cacheVersion(bible, versionId: version);

        // On web, verify the cache was saved
        if (kIsWeb) {
          await Future.delayed(const Duration(milliseconds: 100));
          final isCached = await cacheProvider!.isVersionCached(version);
          if (!isCached) {
            throw Exception(
              'Failed to verify cached version on web after saving',
            );
          }
        }
      }

      onProgress?.call(DownloadProgress.completed());
      return bible;
    } catch (e) {
      onProgress?.call(DownloadProgress.error(e.toString()));
      rethrow;
    }
  }

  /// Fluxo original: zip USX do repositório biblias.
  Future<Bible> _loadFromUsxZip(String zipUrl) async {
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
      final response = await http.get(Uri.parse(zipUrl));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download Bible $version: ${response.statusCode}',
        );
      }

      final bytes = response.bodyBytes;
      // The download is done; from here on the archive is processed locally.
      onProgress?.call(
        const DownloadProgress(
          percent: 1.0,
          downloadedBytes: 0,
          totalBytes: 0,
          status: DownloadStatus.extracting,
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
          percent: 1.0,
          downloadedBytes: 0,
          totalBytes: 0,
          status: DownloadStatus.extracting,
          message: 'Parsing USX...',
        ),
      );
      final parser = UsxParser();
      final bible = await parser.parseFromContents(contents, sorter: sorter);

      // 4. Cache if provider is available
      if (cacheProvider != null) {
        onProgress?.call(
          const DownloadProgress(
            percent: 1.0,
            downloadedBytes: 0,
            totalBytes: 0,
            status: DownloadStatus.extracting,
            message: 'Caching into SQLite...',
          ),
        );
        await cacheProvider!.cacheVersion(bible, versionId: version);

        // On web, verify the cache was saved
        if (kIsWeb) {
          await Future.delayed(const Duration(milliseconds: 100));
          final isCached = await cacheProvider!.isVersionCached(version);
          if (!isCached) {
            throw Exception(
              'Failed to verify cached version on web after saving',
            );
          }
        }
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
  String? url,
  BookSorter sorter = const CanonicalBookSorter(),
  void Function(DownloadProgress)? onProgress,
  BibleCacheProvider? cacheProvider,
}) async {
  final loader = UrlBibleLoader(
    version,
    url: url,
    sorter: sorter,
    onProgress: onProgress,
    cacheProvider: cacheProvider,
  );
  return await loader.load();
}
