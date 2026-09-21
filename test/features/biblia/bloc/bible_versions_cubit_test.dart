import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/features/biblia/bloc/bible_versions_cubit.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/models/bible_version_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBibleCacheProvider extends Mock implements BibleCacheProvider {}

void main() {
  late MockBibleCacheProvider cacheProvider;
  late BibleVersionCubit versionCubit;

  setUp(() {
    cacheProvider = MockBibleCacheProvider();
    versionCubit = BibleVersionCubit();

    when(() => cacheProvider.getCachedVersionIds())
        .thenAnswer((_) async => <String>['JFAA']);
    when(() => cacheProvider.removeVersion(any())).thenAnswer((_) async {});
  });

  BibleVersionsCubit build({BibleVersionLoader? loader}) {
    return BibleVersionsCubit(
      cacheProvider: cacheProvider,
      versionCubit: versionCubit,
      loader: loader,
    );
  }

  BibleVersionInfo entryFor(BibleVersionsCubit cubit, String id) {
    return cubit.state.versions.firstWhere((e) => e.version.id == id);
  }

  /// Loader falso que emite download → extração e conclui.
  BibleVersionLoader fakeLoader({List<DownloadProgress>? recorded}) {
    return (
      versionId, {
      onProgress,
      cacheProvider,
    }) async {
      const downloading = DownloadProgress(
        percent: 0.42,
        downloadedBytes: 42,
        totalBytes: 100,
        status: DownloadStatus.downloading,
      );
      onProgress?.call(downloading);

      final extracting = DownloadProgress.extracting();
      onProgress?.call(extracting);

      if (recorded != null) {
        recorded.add(downloading);
        recorded.add(extracting);
      }

      return Bible(name: 'Nova Versão Internacional', abbreviation: 'NVI', books: const []);
    };
  }

  /// Loader que reporta apenas a fase de extração.
  BibleVersionLoader extractingOnlyLoader() {
    return (
      versionId, {
      onProgress,
      cacheProvider,
    }) async {
      onProgress?.call(DownloadProgress.extracting());
      return Bible(name: 'Nova Versão Internacional', abbreviation: 'NVI', books: const []);
    };
  }

  group('load', () {
    test('lists every translation split into downloaded and available',
        () async {
      final cubit = build();

      await cubit.load();

      expect(cubit.state.status, BibleVersionsStatus.ready);
      expect(cubit.state.versions.length, BibleVersions.values.length);
      expect(cubit.state.downloadedCount, 1);
      expect(entryFor(cubit, 'JFAA').isDownloaded, isTrue);
      expect(entryFor(cubit, 'JFAA').isActive, isTrue);
      expect(entryFor(cubit, 'ACF').isDownloaded, isFalse);
      expect(cubit.state.available.length, BibleVersions.values.length - 1);

      await cubit.close();
    });

    test('emits error state when the cache query fails', () async {
      when(() => cacheProvider.getCachedVersionIds())
          .thenThrow(Exception('db down'));
      final cubit = build();

      await cubit.load();

      expect(cubit.state.status, BibleVersionsStatus.error);
      expect(cubit.state.errorMessage, isNotNull);

      await cubit.close();
    });
  });

  group('download', () {
    test('completes and clears progress, recording the extracting phase',
        () async {
      final recorded = <DownloadProgress>[];
      final cubit = build(loader: fakeLoader(recorded: recorded));
      await cubit.load();

      await cubit.download('NVI');

      final nvi = entryFor(cubit, 'NVI');
      expect(nvi.isDownloaded, isTrue);
      expect(nvi.progress, isNull);
      expect(
        recorded.map((p) => p.status),
        [DownloadStatus.downloading, DownloadStatus.extracting],
      );

      await cubit.close();
    });

    test('exposes the extracting status while the archive is processed',
        () async {
      final statuses = <DownloadStatus>[];
      final cubit = build(loader: extractingOnlyLoader());
      await cubit.load();

      final subscription = cubit.stream.listen((state) {
        final entry = state.versions.firstWhere(
          (e) => e.version.id == 'NVI',
        );
        final progress = entry.progress;
        if (progress != null) statuses.add(progress.status);
      });

      await cubit.download('NVI');
      await subscription.cancel();

      expect(statuses, contains(DownloadStatus.extracting));

      await cubit.close();
    });

    test('keeps isDownloading true during the extracting phase', () async {
      final extractingEntries = <BibleVersionInfo>[];
      final cubit = build(loader: extractingOnlyLoader());
      await cubit.load();

      final subscription = cubit.stream.listen((state) {
        for (final entry in state.versions) {
          if (entry.isExtracting) extractingEntries.add(entry);
        }
      });

      await cubit.download('NVI');
      await subscription.cancel();

      expect(extractingEntries, isNotEmpty);
      expect(
        extractingEntries.every((e) => e.isDownloading),
        isTrue,
        reason: 'extração continua contando como download em andamento',
      );
      expect(extractingEntries.every((e) => !e.isDownloaded), isTrue);

      await cubit.close();
    });

    test('ignores concurrent downloads of the same version', () async {
      var calls = 0;
      final cubit = build(
        loader: (
          versionId, {
          onProgress,
          cacheProvider,
        }) async {
          calls++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return Bible(name: 'Nova Versão Internacional', abbreviation: 'NVI', books: const []);
        },
      );
      await cubit.load();

      await Future.wait([
        cubit.download('NVI'),
        cubit.download('NVI'),
      ]);

      expect(calls, 1);

      await cubit.close();
    });

    test('captures loader failures as an error progress', () async {
      final cubit = build(
        loader: (
          versionId, {
          onProgress,
          cacheProvider,
        }) async {
          throw Exception('network down');
        },
      );
      await cubit.load();

      await cubit.download('NVI');

      final nvi = entryFor(cubit, 'NVI');
      expect(nvi.isDownloaded, isFalse);
      expect(nvi.hasError, isTrue);

      await cubit.close();
    });
  });

  group('delete', () {
    test('removes a downloaded version and its cache entry', () async {
      when(() => cacheProvider.getCachedVersionIds())
          .thenAnswer((_) async => <String>['JFAA', 'NVI']);
      final cubit = build();
      await cubit.load();

      final removed = await cubit.delete('NVI');

      expect(removed, isTrue);
      expect(entryFor(cubit, 'NVI').isDownloaded, isFalse);
      verify(() => cacheProvider.removeVersion('NVI')).called(1);

      await cubit.close();
    });

    test('refuses to remove the active version', () async {
      final cubit = build();
      await cubit.load();

      final removed = await cubit.delete('JFAA');

      expect(removed, isFalse);
      expect(entryFor(cubit, 'JFAA').isDownloaded, isTrue);
      verifyNever(() => cacheProvider.removeVersion('JFAA'));

      await cubit.close();
    });
  });

  group('select', () {
    test('changes the active version and syncs isActive flags', () async {
      when(() => cacheProvider.getCachedVersionIds())
          .thenAnswer((_) async => <String>['JFAA', 'ACF']);
      final cubit = build();
      await cubit.load();

      cubit.select('ACF');

      expect(versionCubit.state.version, BibleVersions.acf);
      expect(entryFor(cubit, 'ACF').isActive, isTrue);
      expect(entryFor(cubit, 'JFAA').isActive, isFalse);

      await cubit.close();
    });
  });
}
