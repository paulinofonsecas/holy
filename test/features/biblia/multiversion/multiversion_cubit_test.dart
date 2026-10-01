import 'package:eu_sou/features/biblia/data/repositories/multiversion_session_repository.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_cubit.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockMultiversionSessionRepository extends Mock
    implements MultiversionSessionRepository {}

void main() {
  group('MultiversionCubit.maxPanelsFor', () {
    test('vertical/narrow viewport allows at most 2 panels', () {
      expect(MultiversionCubit.maxPanelsFor(const Size(400, 800)), 2);
      expect(MultiversionCubit.maxPanelsFor(const Size(719, 900)), 2);
    });

    test('landscape follows the width-based breakpoints', () {
      expect(MultiversionCubit.maxPanelsFor(const Size(900, 600)), 2);
      expect(MultiversionCubit.maxPanelsFor(const Size(1024, 600)), 3);
      expect(MultiversionCubit.maxPanelsFor(const Size(1660, 600)), 999);
    });

    test('maxPanelsForWidth keeps the width-only behaviour', () {
      expect(MultiversionCubit.maxPanelsForWidth(400), 2);
      expect(MultiversionCubit.maxPanelsForWidth(1024), 3);
      expect(MultiversionCubit.maxPanelsForWidth(1660), 999);
    });
  });

  group('MultiversionCubit flex', () {
    late MultiversionCubit cubit;

    setUp(() {
      final repo = _MockMultiversionSessionRepository();
      when(() => repo.loadSessions()).thenReturn([]);
      cubit = MultiversionCubit(repo);
    });

    test('updatePanelFlex persists the layout weight once the panel reports', () {
      cubit.enable();
      final ids = cubit.state.panelIds;

      // Sem config ainda (painel não carregou): flex ignorado gracefully
      cubit.updatePanelFlex(ids[0], 1.5);
      expect(cubit.state.panelConfigs[ids[0]], isNull);

      // Painel reporta posição -> config criada; flex preservado depois disso
      cubit.updatePanelPosition(
        panelId: ids[0],
        versionId: 'JFAA',
        bookId: 'GEN',
        chapter: 1,
      );
      cubit.updatePanelFlex(ids[0], 1.5);
      expect(cubit.state.panelConfigs[ids[0]]?.flex, 1.5);

      // Recarregar capítulo não reseta o flex ajustado pelo divisor
      cubit.updatePanelPosition(
        panelId: ids[0],
        versionId: 'JFAA',
        bookId: 'GEN',
        chapter: 2,
      );
      expect(cubit.state.panelConfigs[ids[0]]?.flex, 1.5);
    });

    test('updatePanelFlex is ignored for unknown panels', () {
      cubit.enable();
      cubit.updatePanelFlex('unknown', 3.0);
      expect(cubit.state.panelConfigs.containsKey('unknown'), isFalse);
    });
  });

  group('PanelConfig flex', () {
    test('roundtrips through json', () {
      const config = PanelConfig(
        id: 'panel_1',
        colorHex: '#FF0000',
        versionId: 'JFAA',
        bookId: 'GEN',
        chapter: 1,
        scrollOffset: 120.0,
        flex: 1.75,
      );

      final restored = PanelConfig.fromJson(config.toJson());
      expect(restored.flex, 1.75);
      expect(restored, config);
    });

    test('missing flex in json defaults to 1.0 (backwards compatible)', () {
      final restored = PanelConfig.fromJson(const {
        'id': 'panel_1',
        'colorHex': '#FF0000',
        'versionId': 'JFAA',
        'bookId': 'GEN',
        'chapter': 1,
        'scrollOffset': 0,
      });
      expect(restored.flex, 1.0);
    });
  });

  test('saved sessions roundtrip preserves flex', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = MultiversionSessionRepository(
      await SharedPreferences.getInstance(),
    );

    final session = MultiversionSession(
      id: '1',
      name: 'Estudo',
      createdAt: DateTime.parse('2026-01-01'),
      panels: [
        const PanelConfig(
          id: 'panel_1',
          colorHex: '#FF0000',
          versionId: 'JFAA',
          bookId: 'GEN',
          chapter: 1,
          flex: 1.4,
        ),
      ],
    );
    await repo.saveSessions([session]);

    final loaded = repo.loadSessions();
    expect(loaded.single.panels.single.flex, 1.4);
  });
}
