import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/design_system/theme/theme_colors.dart';
import 'package:flutter/material.dart';

part 'multiversion_state.dart';

class MultiversionCubit extends Cubit<MultiversionState> {
  int _nextId = 1;
  final _random = Random();

  /// Tracks which colour indices have already been assigned to avoid
  /// consecutive panels sharing the same colour.
  final _usedIndices = <int>{};

  MultiversionCubit()
      : super(const MultiversionState(isEnabled: false, panelIds: []));

  String _newId() => 'panel_${_nextId++}';

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
      ));
    }
  }

  void disable() {
    _usedIndices.clear();
    emit(const MultiversionState(isEnabled: false, panelIds: []));
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
    emit(state.copyWith(
      panelIds: state.panelIds.where((p) => p != id).toList(),
      panelColors: newColors,
    ));
  }

  /// Changes the accent colour of a specific panel.
  void changePanelColor(String panelId, Color color) {
    emit(state.copyWith(
      panelColors: {...state.panelColors, panelId: color},
    ));
  }
}
