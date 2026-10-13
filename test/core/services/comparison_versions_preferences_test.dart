import 'package:eu_sou/core/services/comparison_versions_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late ComparisonVersionsPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    preferences = ComparisonVersionsPreferences(prefs);
  });

  test('padrão é "sem seleção customizada"', () {
    expect(preferences.isCustomSelection(), isFalse);
    expect(preferences.getSelectedVersionIds(), isEmpty);
  });

  test('saveSelection persiste os ids em maiúsculas e ativa o filtro',
      () async {
    await preferences.saveSelection({'nvi', 'Acf'});

    expect(preferences.isCustomSelection(), isTrue);
    expect(preferences.getSelectedVersionIds(), {'NVI', 'ACF'});
  });

  test('seleção vazia customizada é preservada (só a versão atual)', () async {
    await preferences.saveSelection(<String>{});

    expect(preferences.isCustomSelection(), isTrue);
    expect(preferences.getSelectedVersionIds(), isEmpty);
  });

  test('clearSelection volta ao padrão', () async {
    await preferences.saveSelection({'NVI'});
    await preferences.clearSelection();

    expect(preferences.isCustomSelection(), isFalse);
    expect(preferences.getSelectedVersionIds(), isEmpty);
  });
}
