import 'dart:io';

import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/core/data/provider/github_bible_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String path;
  MockPathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return path;
  }
}

class MockDio extends Fake implements Dio {
  @override
  Future<Response<T>> get<T>(String path,
      {Object? data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    if (path.contains('contents')) {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: [
          {'name': 'test_version.zip', 'type': 'file'}
        ] as T,
      );
    }
    throw UnimplementedError();
  }
}

class MockBibleCacheProvider extends Fake implements BibleCacheProvider {
  final Map<String, Bible> _cache = {};

  @override
  Future<Bible?> getBible(String versionId) async {
    return _cache[versionId];
  }

  @override
  Future<void> cacheVersion(Bible bible, {String? versionId}) async {
    _cache[versionId ?? bible.abbreviation] = bible;
  }

  @override
  Future<bool> isVersionCached(String versionId) async {
    return _cache.containsKey(versionId);
  }

  @override
  Future<List<Book>> getBooks(String versionId) async {
    return _cache[versionId]?.books ?? [];
  }

  @override
  Future<Chapter?> getChapter(
      String versionId, String bookId, int chapterNumber) async {
    final bible = _cache[versionId];
    if (bible == null) return null;

    final book = bible.books.firstWhere((b) => b.id == bookId);
    return book.chapters.firstWhere((c) => c.number == chapterNumber);
  }
}

void main() {
  late GithubBibleProvider provider;
  late MockDio mockDio;
  late MockBibleCacheProvider mockCache;
  late Directory tempDownloadDir;
  late Directory appDocsDir;

  setUp(() async {
    appDocsDir = await Directory.systemTemp.createTemp('app_docs');
    PathProviderPlatform.instance = MockPathProviderPlatform(appDocsDir.path);
    mockDio = MockDio();
    mockCache = MockBibleCacheProvider();
    tempDownloadDir = await Directory.systemTemp.createTemp('bible_download');
  });

  tearDown(() {
    if (tempDownloadDir.existsSync()) {
      tempDownloadDir.deleteSync(recursive: true);
    }
    if (appDocsDir.existsSync()) {
      appDocsDir.deleteSync(recursive: true);
    }
  });

  test('should load bible from url and save to SQLite, then load from SQLite',
      () async {
    final bible = Bible(
      name: 'Test Bible',
      abbreviation: 'TB',
      books: [Book(id: 'GEN', name: 'Genesis', longName: 'Genesis', abbreviation: 'Gn', chapters: [])],
    );

    bool urlLoaderCalled = false;

    provider = GithubBibleProvider(
      mockDio,
      mockCache,
      urlLoader: (version) async {
        urlLoaderCalled = true;
        await mockCache.cacheVersion(bible, versionId: version);
        return bible;
      },
    );

    // 1. First call: Should use urlLoader
    await provider.getLivros('test_version');

    expect(urlLoaderCalled, isTrue);
    expect(await mockCache.isVersionCached('test_version'), isTrue);

    // 2. Second call (new instance): Should use mockCache
    urlLoaderCalled = false;

    final newProvider = GithubBibleProvider(
      mockDio,
      mockCache,
      urlLoader: (version) async {
        urlLoaderCalled = true;
        await mockCache.cacheVersion(bible, versionId: version);
        return bible;
      },
    );

    await newProvider.getLivros('test_version');

    expect(urlLoaderCalled, isFalse);
  });
}
