import 'package:eu_sou/core/services/comparison_versions_preferences.dart';
import 'package:eu_sou/features/verse_interaction/application/comparison_controller.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/comparison_request.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/version_comparison_entry.dart';
import 'package:eu_sou/features/verse_interaction/domain/repositories/comparison_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepository implements ComparisonRepository {
  _FakeRepository(this.entries);

  List<VersionComparisonEntry> entries;

  @override
  Future<List<VersionComparisonEntry>> getComparison(
    ComparisonRequest request,
  ) async =>
      entries;
}

VersionComparisonEntry _entry(String id, {bool isSource = false}) {
  return VersionComparisonEntry(
    versionId: id,
    versionName: 'Nome $id',
    verseText: 'texto $id',
    isAvailable: true,
    isSource: isSource,
  );
}

void main() {
  late SharedPreferences prefs;
  late ComparisonVersionsPreferences preferences;

  const request = ComparisonRequest(
    bookId: 'GEN',
    chapterNumber: 1,
    verseNumber: 1,
    sourceVersionId: 'KJA',
    targetVersionIds: ['NVI', 'ACF'],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    preferences = ComparisonVersionsPreferences(prefs);
  });

  ComparisonController build(_FakeRepository repository) {
    return ComparisonController(repository, preferences: preferences);
  }

  test('sem seleção salva, mostra todas as versões', () async {
    final controller = build(
      _FakeRepository([
        _entry('KJA', isSource: true),
        _entry('NVI'),
        _entry('ACF'),
      ]),
    );

    await controller.loadComparison(request);

    expect(controller.hasVersionFilter, isFalse);
    expect(controller.visibleEntries, hasLength(3));
    expect(controller.isSelected(_entry('NVI')), isTrue);
  });

  test('primeiro toggle parte de "todas" e esconde a versão desmarcada',
      () async {
    final controller = build(
      _FakeRepository([
        _entry('KJA', isSource: true),
        _entry('NVI'),
        _entry('ACF'),
      ]),
    );
    await controller.loadComparison(request);

    await controller.toggleVersionSelection('ACF');

    expect(controller.hasVersionFilter, isTrue);
    expect(
      controller.visibleEntries.map((entry) => entry.versionId),
      ['KJA', 'NVI'],
    );
    // Persistido: tudo menos a versão desmarcada.
    expect(preferences.isCustomSelection(), isTrue);
    expect(preferences.getSelectedVersionIds(), {'KJA', 'NVI'});
  });

  test('a versão atual (fonte) permanece visível mesmo fora da seleção',
      () async {
    final controller = build(
      _FakeRepository([
        _entry('KJA', isSource: true),
        _entry('NVI'),
      ]),
    );
    await controller.loadComparison(request);

    // Tenta remover a fonte da seleção persistida...
    await controller.toggleVersionSelection('KJA');

    // ...mas ela continua visível por ser a versão atual.
    expect(controller.isSelected(_entry('KJA', isSource: true)), isTrue);
    expect(
      controller.visibleEntries.map((entry) => entry.versionId),
      contains('KJA'),
    );
  });

  test('desmarcar tudo mantém apenas a versão atual visível', () async {
    final controller = build(
      _FakeRepository([
        _entry('KJA', isSource: true),
        _entry('NVI'),
        _entry('ACF'),
      ]),
    );
    await controller.loadComparison(request);

    await controller.toggleVersionSelection('NVI');
    await controller.toggleVersionSelection('ACF');
    await controller.toggleVersionSelection('KJA');

    expect(controller.hasVersionFilter, isTrue);
    expect(controller.visibleEntries.single.versionId, 'KJA');
  });

  test('clearVersionFilter volta a exibir todas e limpa a persistência',
      () async {
    final controller = build(
      _FakeRepository([
        _entry('KJA', isSource: true),
        _entry('NVI'),
      ]),
    );
    await controller.loadComparison(request);
    await controller.toggleVersionSelection('NVI');
    expect(controller.visibleEntries, hasLength(1));

    await controller.clearVersionFilter();

    expect(controller.hasVersionFilter, isFalse);
    expect(controller.visibleEntries, hasLength(2));
    expect(preferences.isCustomSelection(), isFalse);
  });

  test('seleção persiste entre sessões (novo controlador)', () async {
    final entries = [
      _entry('KJA', isSource: true),
      _entry('NVI'),
      _entry('ACF'),
    ];
    final first = build(_FakeRepository(entries));
    await first.loadComparison(request);
    await first.toggleVersionSelection('ACF');

    final second = build(_FakeRepository(entries));
    await second.loadComparison(request);

    expect(second.hasVersionFilter, isTrue);
    expect(
      second.visibleEntries.map((entry) => entry.versionId),
      ['KJA', 'NVI'],
    );
  });
}
