import 'dart:io';

import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/core/data/provider/github_bible_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:path/path.dart' as p;

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

void main() {
  late GithubBibleProvider provider;
  late MockDio mockDio;
  late Directory tempDownloadDir;
  late Directory appDocsDir;

  setUp(() async {
    appDocsDir = await Directory.systemTemp.createTemp('app_docs');
    PathProviderPlatform.instance = MockPathProviderPlatform(appDocsDir.path);
    mockDio = MockDio();
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

  test('should load bible from url and save to local storage, then load from storage', () async {
    final bible = Bible(
      name: 'Test Bible',
      abbreviation: 'TB',
      books: [],
    )..directoryPathSaved = tempDownloadDir.path;

    // Create a dummy file in tempDownloadDir to simulate downloaded content
    File(p.join(tempDownloadDir.path, 'metadata.xml')).createSync();
    File(p.join(tempDownloadDir.path, 'book.usx')).createSync();

    bool urlLoaderCalled = false;
    bool dirLoaderCalled = false;

    provider = GithubBibleProvider(
      mockDio,
      urlLoader: (version) async {
        urlLoaderCalled = true;
        return bible;
      },
      dirLoader: (path) async {
        dirLoaderCalled = true;
        return bible;
      },
    );

    // 1. First call: Should use urlLoader
    await provider.getLivros('test_version');

    expect(urlLoaderCalled, isTrue);
    expect(dirLoaderCalled, isFalse);

    // Verify files were copied to appDocsDir
    final savedBibleDir = Directory(p.join(appDocsDir.path, 'bibles', 'test_version'));
    expect(savedBibleDir.existsSync(), isTrue);
    expect(File(p.join(savedBibleDir.path, 'metadata.xml')).existsSync(), isTrue);
    expect(File(p.join(savedBibleDir.path, 'book.usx')).existsSync(), isTrue);

    // 2. Second call (new instance): Should use dirLoader
    urlLoaderCalled = false;
    dirLoaderCalled = false;

    final newProvider = GithubBibleProvider(
      mockDio,
      urlLoader: (version) async {
        urlLoaderCalled = true;
        return bible;
      },
      dirLoader: (path) async {
        dirLoaderCalled = true;
        return bible;
      },
    );

    await newProvider.getLivros('test_version');

    expect(urlLoaderCalled, isFalse);
    expect(dirLoaderCalled, isTrue);
  });
}
