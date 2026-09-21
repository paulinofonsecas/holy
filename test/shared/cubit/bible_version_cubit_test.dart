import 'package:eu_sou/core/services/version_persistence_service.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late VersionPersistenceService persistence;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    persistence = VersionPersistenceService(prefs);
  });

  group('BibleVersionCubit persistence', () {
    test('falls back to JFAA when nothing was saved', () {
      final cubit = BibleVersionCubit(persistence: persistence);

      expect(cubit.state.version, BibleVersions.jfaa);
    });

    test('restores the saved active version', () async {
      await persistence.saveActiveVersionId('NVI');

      final cubit = BibleVersionCubit(persistence: persistence);

      expect(cubit.state.version, BibleVersions.nvi);
    });

    test('falls back to JFAA when the saved id is unknown', () async {
      await persistence.saveActiveVersionId('XXX');

      final cubit = BibleVersionCubit(persistence: persistence);

      expect(cubit.state.version, BibleVersions.jfaa);
    });

    test('persists the version on every change', () async {
      final cubit = BibleVersionCubit(persistence: persistence);

      cubit.changeVersion(BibleVersions.acf);
      await Future<void>.delayed(Duration.zero);
      expect(persistence.getActiveVersionId(), 'ACF');

      cubit.changeVersionById('kja');
      await Future<void>.delayed(Duration.zero);
      expect(persistence.getActiveVersionId(), 'KJA');
    });

    test('does not persist when the version is unchanged', () {
      final cubit = BibleVersionCubit(persistence: persistence);

      cubit.changeVersion(BibleVersions.jfaa);

      expect(persistence.getActiveVersionId(), isNull);
    });

    test('works without a persistence service', () {
      final cubit = BibleVersionCubit();

      cubit.changeVersion(BibleVersions.kjf);

      expect(cubit.state.version, BibleVersions.kjf);
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
