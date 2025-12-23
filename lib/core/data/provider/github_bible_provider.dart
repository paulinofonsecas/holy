import 'dart:io';

import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/core/data/provider/interfaces/i_bible_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef BibleUrlLoader = Future<Bible> Function(String version);
typedef BibleDirLoader = Future<Bible> Function(String path);

class GithubBibleProvider extends IBibleProvider {
  GithubBibleProvider(
    this.dio, {
    this.urlLoader = loadBibleFromUrl,
    this.dirLoader = loadBibleFromDirectory,
  });

  final Dio dio;
  final BibleUrlLoader urlLoader;
  final BibleDirLoader dirLoader;
  final Map<String, Bible> _cache = {};
  static const String _repoContentsUrl =
      'https://api.github.com/repos/paulinofonsecas/biblias/contents/inst/usx/traducao';

  Future<Bible> _getOrLoadBible(String versionId) async {
    if (_cache.containsKey(versionId)) {
      return _cache[versionId]!;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final bibleDir = Directory(p.join(appDir.path, 'bibles', versionId));

      if (await bibleDir.exists()) {
        if (await File(p.join(bibleDir.path, 'metadata.xml')).exists()) {
          try {
            final bible = await dirLoader(bibleDir.path);
            _cache[versionId] = bible;
            return bible;
          } catch (e) {
            print('Failed to load from local storage: $e');
          }
        }
      }

      // loadBibleFromUrl is a top-level function exported by bible_handler
      final bible = await urlLoader(versionId);

      if (bible.directoryPathSaved != null) {
        final tempDir = Directory(bible.directoryPathSaved!);
        if (await tempDir.exists()) {
          await _copyDirectory(tempDir, bibleDir);
        }
      }

      _cache[versionId] = bible;
      return bible;
    } catch (e) {
      throw Exception('Failed to load bible version $versionId: $e');
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory =
            Directory(p.join(destination.path, p.basename(entity.path)));
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }


  @override
  Future<List<String>> getVersoes() async {
    try {
      final response = await dio.get(_repoContentsUrl);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final versions = data
            .where((item) =>
                item['name'].toString().toLowerCase().endsWith('.zip') &&
                item['type'] == 'file')
            .map((item) {
          final name = item['name'].toString();
          return name.substring(0, name.length - 4); // Remove .zip
        }).toList();

        return versions;
      } else {
        throw Exception('Failed to fetch versions from GitHub');
      }
    } catch (e) {
      // Log error or handle it
      print('Error fetching versions: $e');
      return [];
    }
  }

  @override
  Future<List<InfoBook>> getLivros(String versionId) async {
    try {
      final bible = await _getOrLoadBible(versionId);
      return bible.books
          .map((b) => InfoBook(id: b.id, name: b.name))
          .toList();
    } catch (e) {
      print('Error fetching books for $versionId: $e');
      return [];
    }
  }

  @override
  Future<List<Chapter>> getCapitulos(String versionId, String bookId) async {
    try {
      final bible = await _getOrLoadBible(versionId);
      // Try to find by ID first, then abbreviation
      final book = bible.books.firstWhere(
        (b) => b.id == bookId || b.abbreviation == bookId,
        orElse: () => throw Exception('Book $bookId not found'),
      );
      return book.chapters;
    } catch (e) {
      print('Error fetching chapters for $versionId, $bookId: $e');
      return [];
    }
  }

  @override
  Future<Chapter> getChapter(
      String versionId, String bookId, String chapterId) async {
    try {
      final bible = await _getOrLoadBible(versionId);
      final book = bible.books.firstWhere(
        (b) => b.id == bookId || b.abbreviation == bookId,
        orElse: () => throw Exception('Book $bookId not found'),
      );

      final chapterNum = int.tryParse(chapterId);
      if (chapterNum == null) {
        throw Exception('Invalid chapter ID: $chapterId');
      }

      final chapter = book.chapters.firstWhere(
        (c) => c.number == chapterNum,
        orElse: () => throw Exception('Chapter $chapterId not found'),
      );

      return chapter;
    } catch (e) {
      print('Error fetching chapter $chapterId for $versionId, $bookId: $e');
      rethrow; // Or return empty/null if the interface allowed
    }
  }
}
