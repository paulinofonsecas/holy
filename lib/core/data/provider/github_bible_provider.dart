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
    this.dio,
    this.cacheProvider, {
    this.urlLoader = loadBibleFromUrl,
    this.dirLoader = loadBibleFromDirectory,
  });

  final Dio dio;
  final BibleCacheProvider cacheProvider;
  final BibleUrlLoader urlLoader;
  final BibleDirLoader dirLoader;
  final Map<String, Bible> _cache = {};
  final Map<String, List<Book>> _booksCache = {};
  final Map<String, Map<String, Map<int, Chapter>>> _chapterCache = {};
  final List<String> _chapterCacheKeys = [];
  static const int _maxCachedChapters = 50;
  static const String _repoContentsUrl =
      'https://api.github.com/repos/paulinofonsecas/biblias/contents/inst/usx/traducao';

  Future<String> _getBiblesDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final biblesDir = Directory(p.join(appDocDir.path, 'bibles'));
    if (!biblesDir.existsSync()) {
      biblesDir.createSync(recursive: true);
    }
    return biblesDir.path;
  }

  void _addToChapterCache(
      String versionId, String bookId, int chapterNum, Chapter chapter) {
    final key = '$versionId|$bookId|$chapterNum';

    // Remove if already exists to move to end (LRU)
    _chapterCacheKeys.remove(key);

    if (_chapterCacheKeys.length >= _maxCachedChapters) {
      final oldestKey = _chapterCacheKeys.removeAt(0);
      print('Evicting chapter from cache: $oldestKey');
      final parts = oldestKey.split('|');
      if (parts.length == 3) {
        final vId = parts[0];
        final bId = parts[1];
        final cNum = int.tryParse(parts[2]);
        if (cNum != null) {
          _chapterCache[vId]?[bId]?.remove(cNum);
        }
      }
    }

    _chapterCacheKeys.add(key);
    _chapterCache
        .putIfAbsent(versionId, () => {})
        .putIfAbsent(bookId, () => {})[chapterNum] = chapter;
  }

  Future<List<Book>> _getOrLoadBooks(String versionId) async {
    if (_booksCache.containsKey(versionId)) {
      return _booksCache[versionId]!;
    }

    try {
      // 1. Check SQLite Cache
      if (await cacheProvider.isVersionCached(versionId)) {
        final books = await cacheProvider.getBooks(versionId);
        if (books.isNotEmpty) {
          _booksCache[versionId] = books;
          return books;
        }
      }

      // 2. Check local storage (legacy)
      final savedBibleDir = Directory(p.join(await _getBiblesDir(), versionId));
      if (savedBibleDir.existsSync()) {
        final bible = await dirLoader(savedBibleDir.path);
        // Cache it in SQLite for next time
        await cacheProvider.cacheVersion(bible, versionId: versionId);
        _cache[versionId] = bible;
        _booksCache[versionId] = bible.books;
        return bible.books;
      }

      // 3. If not in SQLite or local storage, download from GitHub
      final bible = await urlLoader(versionId);

      // Save to local storage (legacy)
      if (bible.directoryPathSaved != null) {
        final targetDir = Directory(p.join(await _getBiblesDir(), versionId));
        if (targetDir.existsSync()) targetDir.deleteSync(recursive: true);
        targetDir.createSync(recursive: true);

        // Copy files from temp to permanent
        final sourceDir = Directory(bible.directoryPathSaved!);
        for (var file in sourceDir.listSync()) {
          if (file is File) {
            file.copySync(p.join(targetDir.path, p.basename(file.path)));
          }
        }
      }

      // 4. Save to SQLite Cache
      await cacheProvider.cacheVersion(bible, versionId: versionId);

      _cache[versionId] = bible;
      _booksCache[versionId] = bible.books;
      return bible.books;
    } catch (e) {
      throw Exception('Failed to load books for version $versionId: $e');
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
      final books = await _getOrLoadBooks(versionId);
      return books.map((b) => InfoBook(id: b.id, name: b.name)).toList();
    } catch (e) {
      print('Error fetching books for $versionId: $e');
      return [];
    }
  }

  @override
  Future<List<Chapter>> getCapitulos(String versionId, String bookId) async {
    try {
      // For chapters, we still need the book metadata to know how many chapters there are.
      // However, the current Book model in bible_handler seems to store chapters in a list.
      // If we want to know the number of chapters without loading them all, we might need
      // a different approach or just load the book with its chapters if it's small.
      // But the user specifically asked for lazy loading.

      // Let's see if we can get the chapter count from the database.
      final books = await _getOrLoadBooks(versionId);
      final book = books.firstWhere(
        (b) => b.id == bookId || b.abbreviation == bookId,
        orElse: () => throw Exception('Book $bookId not found'),
      );

      // If the book already has chapters (e.g. from a full load), return them.
      if (book.chapters.isNotEmpty) {
        return book.chapters;
      }

      // Otherwise, we need to fetch the chapters.
      // To avoid loading all verses, we can just get the distinct chapter numbers.
      final chapterResults = await cacheProvider.db.rawQuery(
        'SELECT DISTINCT chapter FROM verses_fts WHERE version_id = ? AND book_id = ? ORDER BY chapter',
        [versionId, book.id],
      );

      return chapterResults.map((row) {
        return Chapter(number: row['chapter'] as int, verses: []);
      }).toList();
    } catch (e) {
      print('Error fetching chapters for $versionId, $bookId: $e');
      return [];
    }
  }

  @override
  Future<Chapter> getChapter(
      String versionId, String bookId, String chapterId) async {
    try {
      final chapterNum = int.tryParse(chapterId);
      if (chapterNum == null) {
        throw Exception('Invalid chapter ID: $chapterId');
      }

      // 0. Check Chapter Cache
      if (_chapterCache[versionId]?[bookId]?.containsKey(chapterNum) ?? false) {
        final chapter = _chapterCache[versionId]![bookId]![chapterNum]!;
        // Update order
        _chapterCacheKeys.remove('$versionId|$bookId|$chapterNum');
        _chapterCacheKeys.add('$versionId|$bookId|$chapterNum');
        return chapter;
      }

      // 1. Check if we have the full bible in cache (legacy/fallback)
      if (_cache.containsKey(versionId)) {
        final bible = _cache[versionId]!;
        final book = bible.books.firstWhere(
          (b) => b.id == bookId || b.abbreviation == bookId,
          orElse: () => throw Exception('Book $bookId not found'),
        );
        final chapter = book.chapters.firstWhere(
          (c) => c.number == chapterNum,
          orElse: () => throw Exception('Chapter $chapterId not found'),
        );

        // Cache it
        _addToChapterCache(versionId, bookId, chapterNum, chapter);

        return chapter;
      }

      // 2. Try to load from SQLite Cache lazily
      if (await cacheProvider.isVersionCached(versionId)) {
        final books = await _getOrLoadBooks(versionId);
        final book = books.firstWhere(
          (b) => b.id == bookId || b.abbreviation == bookId,
          orElse: () => throw Exception('Book $bookId not found'),
        );

        final chapter =
            await cacheProvider.getChapter(versionId, book.id, chapterNum);
        if (chapter != null) {
          // Cache it
          _addToChapterCache(versionId, bookId, chapterNum, chapter);
          return chapter;
        }
      }

      // 3. Fallback to full load if not cached or something went wrong
      // This will populate _cache and _booksCache
      final bible = await urlLoader(versionId);
      _cache[versionId] = bible;
      _booksCache[versionId] = bible.books;

      final book = bible.books.firstWhere(
        (b) => b.id == bookId || b.abbreviation == bookId,
        orElse: () => throw Exception('Book $bookId not found'),
      );

      final chapter = book.chapters.firstWhere(
        (c) => c.number == chapterNum,
        orElse: () => throw Exception('Chapter $chapterId not found'),
      );

      // Cache it
      _addToChapterCache(versionId, bookId, chapterNum, chapter);

      return chapter;
    } catch (e) {
      print('Error fetching chapter $chapterId for $versionId, $bookId: $e');
      rethrow;
    }
  }
}
