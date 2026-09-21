import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/features/biblia/bloc/bible_versions_cubit.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBibleCacheProvider extends Mock implements BibleCacheProvider {}

void main() {
  test('debug sequence', () async {
    final cacheProvider = MockBibleCacheProvider();
    when(() => cacheProvider.getCachedVersionIds())
        .thenAnswer((_) async => <String>['JFAA']);

    final cubit = BibleVersionsCubit(
      cacheProvider: cacheProvider,
      versionCubit: BibleVersionCubit(),
      loader: (
        versionId, {
        onProgress,
        cacheProvider,
      }) async {
        // ignore: avoid_print
        print('loader start');
        onProgress?.call(DownloadProgress.extracting());
        // ignore: avoid_print
        print('loader emitted extracting');
        return Bible(name: 'X', abbreviation: 'NVI', books: const []);
      },
    );

    final seen = <String>[];
    cubit.stream.listen((state) {
      final nvi = state.versions.firstWhere(
        (e) => e.version.id == 'NVI',
        orElse: () => state.versions.first,
      );
      seen.add('${nvi.version.id}:${nvi.progress?.status}');
    });

    await cubit.load();
    await cubit.download('NVI');
    await Future<void>.delayed(Duration.zero);
    // ignore: avoid_print
    print('SEEN: $seen');
    // ignore: avoid_print
    print('FINAL: ${cubit.state.versions.map((e) => '${e.version.id}:${e.progress?.status}:${e.isDownloaded}')}');

    await cubit.close();
  });
}
