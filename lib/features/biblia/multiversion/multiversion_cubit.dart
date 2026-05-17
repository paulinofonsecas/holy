import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/design_system/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import '../data/repositories/multiversion_session_repository.dart';
import 'multiversion_session.dart';

part 'multiversion_state.dart';

class MultiversionCubit extends Cubit<MultiversionState> {
  final MultiversionSessionRepository _repository;
  int _nextId = 1;
  final _random = Random();

  /// Tracks which colour indices have already been assigned to avoid
  /// consecutive panels sharing the same colour.
  final _usedIndices = <int>{};

  MultiversionCubit(this._repository)
      : super(const MultiversionState(isEnabled: false, panelIds: [])) {
    _loadSessions();
  }

  String _newId() => 'panel_${_nextId++}';

  void _loadSessions() {
    try {
      final sessions = _repository.loadSessions();
      emit(state.copyWith(savedSessions: sessions));
    } catch (_) {}
  }

  Color _parseColor(String hex) {
    try {
      final cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return AppThemeColors.defaultPrimaryColor;
    }
  }

  /// Picks a colour that hasn't been used yet (cycles when exhausted).
  Color _pickDistinctColor() {
    const colors = AppThemeColors.predefinedColors;
    final available = List<int>.generate(colors.length, (i) => i)
        .where((i) => !_usedIndices.contains(i))
        .toList();

    final int idx;
    if (available.isEmpty) {
      _usedIndices.clear();
      idx = _random.nextInt(colors.length);
    } else {
      idx = available[_random.nextInt(available.length)];
    }
    _usedIndices.add(idx);
    return colors[idx];
  }

  /// Returns the max number of panels allowed for the given screen width.
  static int maxPanelsForWidth(double width) {
    if (width >= 1660) return 999; // unlimited
    if (width >= 1024) return 3;
    return 2;
  }

  void enable() {
    if (!state.isEnabled) {
      final id1 = _newId();
      final id2 = _newId();
      emit(MultiversionState(
        isEnabled: true,
        panelIds: [id1, id2],
        panelColors: {
          id1: _pickDistinctColor(),
          id2: _pickDistinctColor(),
        },
        savedSessions: state.savedSessions,
        showSessionsSidebar: state.showSessionsSidebar,
      ));
    }
  }

  void disable() {
    _usedIndices.clear();
    emit(MultiversionState(
      isEnabled: false,
      panelIds: const [],
      savedSessions: state.savedSessions,
      showSessionsSidebar: state.showSessionsSidebar,
    ));
  }

  void toggle() {
    if (state.isEnabled) {
      disable();
    } else {
      enable();
    }
  }

  void addPanel() {
    final id = _newId();
    emit(state.copyWith(
      panelIds: [...state.panelIds, id],
      panelColors: {...state.panelColors, id: _pickDistinctColor()},
    ));
  }

  void removePanel(String id) {
    if (state.panelIds.length <= 1) return;
    final newColors = Map<String, Color>.from(state.panelColors)..remove(id);
    final newConfigs = Map<String, PanelConfig>.from(state.panelConfigs)..remove(id);
    emit(state.copyWith(
      panelIds: state.panelIds.where((p) => p != id).toList(),
      panelColors: newColors,
      panelConfigs: newConfigs,
    ));
  }

  /// Changes the accent colour of a specific panel.
  void changePanelColor(String panelId, Color color) {
    final hexColor = '#${color.value.toRadixString(16).padLeft(8, '0')}';
    final currentConfig = state.panelConfigs[panelId];
    final updatedConfigs = Map<String, PanelConfig>.from(state.panelConfigs);

    if (currentConfig != null) {
      updatedConfigs[panelId] = currentConfig.copyWith(colorHex: hexColor);
    }

    emit(state.copyWith(
      panelColors: {...state.panelColors, panelId: color},
      panelConfigs: updatedConfigs,
    ));
  }

  /// Updates the tracking position/config of a panel.
  void updatePanelPosition({
    required String panelId,
    required String versionId,
    required String bookId,
    required int chapter,
    double scrollOffset = 0.0,
  }) {
    final color = state.panelColors[panelId] ?? AppThemeColors.defaultPrimaryColor;
    final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0')}';

    final config = PanelConfig(
      id: panelId,
      colorHex: colorHex,
      versionId: versionId,
      bookId: bookId,
      chapter: chapter,
      scrollOffset: scrollOffset,
    );

    final updatedConfigs = Map<String, PanelConfig>.from(state.panelConfigs)
      ..[panelId] = config;

    emit(state.copyWith(panelConfigs: updatedConfigs));
  }

  /// Updates only the scroll offset of a panel (e.g. on scroll end)
  void updatePanelScrollOffset(String panelId, double scrollOffset) {
    final currentConfig = state.panelConfigs[panelId];
    if (currentConfig != null) {
      final updatedConfigs = Map<String, PanelConfig>.from(state.panelConfigs)
        ..[panelId] = currentConfig.copyWith(scrollOffset: scrollOffset);
      emit(state.copyWith(panelConfigs: updatedConfigs));
    }
  }

  /// Toggle sidebar visibility.
  void toggleSessionsSidebar() {
    emit(state.copyWith(showSessionsSidebar: !state.showSessionsSidebar));
  }

  /// Saves the current multiversion panels configuration as a new session.
  Future<void> saveCurrentSession(String name) async {
    // Collect active panel configs in the order of panelIds
    final activePanels = <PanelConfig>[];
    for (final id in state.panelIds) {
      final config = state.panelConfigs[id];
      if (config != null) {
        activePanels.add(config);
      } else {
        // Fallback in case a panel has not reported its state yet (e.g. still loading)
        final color = state.panelColors[id] ?? AppThemeColors.defaultPrimaryColor;
        final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0')}';
        activePanels.add(PanelConfig(
          id: id,
          colorHex: colorHex,
          versionId: 'JFAA', // Default fallback version
          bookId: 'GEN', // Default fallback book
          chapter: 1,
          scrollOffset: 0.0,
        ));
      }
    }

    if (activePanels.isEmpty) return;

    final newSession = MultiversionSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      panels: activePanels,
    );

    final updatedSessions = [newSession, ...state.savedSessions];
    await _repository.saveSessions(updatedSessions);
    emit(state.copyWith(savedSessions: updatedSessions));
  }

  /// Deletes a saved session.
  Future<void> deleteSession(String sessionId) async {
    final updatedSessions = state.savedSessions.where((s) => s.id != sessionId).toList();
    await _repository.saveSessions(updatedSessions);
    emit(state.copyWith(savedSessions: updatedSessions));
  }

  /// Loads and applies a saved session.
  void loadSession(MultiversionSession session) {
    if (session.panels.isEmpty) return;

    final newPanelIds = <String>[];
    final newPanelColors = <String, Color>{};
    final newPanelConfigs = <String, PanelConfig>{};

    for (final panel in session.panels) {
      // Re-map IDs to prevent overlap with current panels if loaded
      final freshId = _newId();
      final color = _parseColor(panel.colorHex);

      newPanelIds.add(freshId);
      newPanelColors[freshId] = color;
      newPanelConfigs[freshId] = PanelConfig(
        id: freshId,
        colorHex: panel.colorHex,
        versionId: panel.versionId,
        bookId: panel.bookId,
        chapter: panel.chapter,
        scrollOffset: panel.scrollOffset,
      );
    }

    emit(state.copyWith(
      isEnabled: true,
      panelIds: newPanelIds,
      panelColors: newPanelColors,
      panelConfigs: newPanelConfigs,
    ));
  }
}
