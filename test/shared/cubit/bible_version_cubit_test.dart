import 'package:eu_sou/core/services/version_persistence_service.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/models/bible_version_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late VersionPersistenceService persistence;

  BibleVersionRef refFor(BibleVersions version) =>
      BibleVersionRef.fromOfficial(version);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    persistence = VersionPersistenceService(prefs);
  });

  group('BibleVersionCubit persistence', () {
    test('falls back to JFAA when nothing was saved', () {
      final cubit = BibleVersionCubit(persistence: persistence);

      expect(cubit.state.version, refFor(BibleVersions.jfaa));
    });

    test('restores the saved active version', () async {
      await persistence.saveActiveVersionId('NVI');

      final cubit = BibleVersionCubit(persistence: persistence);

      expect(cubit.state.version, refFor(BibleVersions.nvi));
    });

    test('falls back to JFAA when the saved id is unknown', () async {
      await persistence.saveActiveVersionId('XXX');

      final cubit = BibleVersionCubit(persistence: persistence);

      expect(cubit.state.version, refFor(BibleVersions.jfaa));
    });

    test('persists the version on every change', () async {
      final cubit = BibleVersionCubit(persistence: persistence);

      cubit.changeVersion(refFor(BibleVersions.acf));
      await Future<void>.delayed(Duration.zero);
      expect(persistence.getActiveVersionId(), 'ACF');

      cubit.changeVersionById('kja');
      await Future<void>.delayed(Duration.zero);
      expect(persistence.getActiveVersionId(), 'KJA');
    });

    test('does not persist when the version is unchanged', () {
      final cubit = BibleVersionCubit(persistence: persistence);

      cubit.changeVersion(refFor(BibleVersions.jfaa));

      expect(persistence.getActiveVersionId(), isNull);
    });

    test('works without a persistence service', () {
      final cubit = BibleVersionCubit();

      cubit.changeVersion(refFor(BibleVersions.kjf));

      expect(cubit.state.version, refFor(BibleVersions.kjf));
    });
  });

  group('BibleVersionCubit community versions', () {
    test('persists community ids with the community prefix', () async {
      final cubit = BibleVersionCubit(persistence: persistence);

      cubit.changeVersion(
        BibleVersionRef.community(
          id: 'PortugueseNAA',
          title: 'Portuguese NAA',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(persistence.getActiveVersionId(), 'community:PortugueseNAA');
    });

    test('restores a persisted community version as community', () async {
      await persistence.saveActiveVersionId('community:PortugueseNAA');

      final cubit = BibleVersionCubit(persistence: persistence);

      expect(cubit.state.version.id, 'PortugueseNAA');
      expect(cubit.state.version.isCommunity, isTrue);
    });

    test('enriches the active community version when the catalog loads',
        () async {
      await persistence.saveActiveVersionId('community:PortugueseNAA');
      final cubit = BibleVersionCubit(persistence: persistence);

      cubit.registerCommunityVersions([
        BibleVersionRef.community(
          id: 'PortugueseNAA',
          title: 'Portuguese NAA',
          language: 'Português',
          year: 2017,
        ),
      ]);

      expect(cubit.state.version.name, 'Portuguese NAA');
      expect(cubit.state.version.language, 'Português');
      expect(cubit.state.version.year, 2017);
      expect(cubit.state.version.isCommunity, isTrue);
    });

    test('changeVersionById resolves community ids via the registry', () {
      final cubit = BibleVersionCubit();

      cubit.registerCommunityVersions([
        BibleVersionRef.community(id: 'EnglishKJV', title: 'English KJV'),
      ]);
      cubit.changeVersionById('englishkjv');

      expect(cubit.state.version.id, 'EnglishKJV');
      expect(cubit.state.version.name, 'English KJV');
      expect(cubit.state.version.isCommunity, isTrue);
    });
  });

  group('BibleVersions.fromId', () {
    test('is case insensitive and trims the input', () {
      expect(BibleVersions.fromId(' nvi '), BibleVersions.nvi);
      expect(BibleVersions.fromId('kJf'), BibleVersions.kjf);
    });

    test('falls back to JFAA for unknown ids', () {
      expect(BibleVersions.fromId('ARA'), BibleVersions.jfaa);
    });
  });
}
