import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the global verse keyword filter.
class VerseFilterState {
  const VerseFilterState({
    this.keywords = const [],
    this.excludedVersionIds = const {},
    this.matchVerses = const {},
    this.versionWordCounts = const {},
  });

  /// Active lowercase trimmed keywords. Empty = no filter.
  final List<String> keywords;

  /// Version IDs excluded from the filter. Empty = all versions included.
  final Set<String> excludedVersionIds;

  /// Map from version ID → list of matching verses, reported by each panel.
  final Map<String, List<int>> matchVerses;

  /// Per-version per-keyword occurrence totals.
  /// versionId → { keyword → occurrence count }
  final Map<String, Map<String, int>> versionWordCounts;

  bool get isFiltering => keywords.isNotEmpty;

  int get totalMatches => matchVerses.values.fold(0, (s, c) => s + c.length);

  /// How many registered versions have at least one matching verse.
  int get versionsWithMatches => matchVerses.values.where((c) => c.isNotEmpty).length;

  /// Aggregated keyword occurrence counts across all active (non-excluded) versions.
  Map<String, int> get wordCounts {
    final result = <String, int>{};
    for (final entry in versionWordCounts.entries) {
      if (isVersionActive(entry.key)) {
        for (final wEntry in entry.value.entries) {
          result[wEntry.key] = (result[wEntry.key] ?? 0) + wEntry.value;
        }
      }
    }
    return result;
  }

  /// Whether the filter should be applied to [versionId].
  bool isVersionActive(String versionId) =>
      !excludedVersionIds.contains(versionId);

  VerseFilterState copyWith({
    List<String>? keywords,
    Set<String>? excludedVersionIds,
    Map<String, List<int>>? matchVerses,
    Map<String, Map<String, int>>? versionWordCounts,
  }) =>
      VerseFilterState(
        keywords: keywords ?? this.keywords,
        excludedVersionIds: excludedVersionIds ?? this.excludedVersionIds,
        matchVerses: matchVerses ?? this.matchVerses,
        versionWordCounts: versionWordCounts ?? this.versionWordCounts,
      );
}

/// Cubit that manages the active keyword filter and per-version match metrics.
class VerseFilterCubit extends Cubit<VerseFilterState> {
  VerseFilterCubit() : super(const VerseFilterState());

  /// Parses [input] into keywords split by comma and resets match counts.
  void updateFilter(String input) {
    final keywords = input
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    emit(state.copyWith(
      keywords: keywords,
      matchVerses: const {},
      versionWordCounts: const {},
    ));
  }

  void clear() => emit(const VerseFilterState());

  /// Toggles whether [versionId] is excluded from the filter.
  void toggleVersionExclusion(String versionId) {
    final updated = Set<String>.from(state.excludedVersionIds);
    if (updated.contains(versionId)) {
      updated.remove(versionId);
    } else {
      updated.add(versionId);
    }
    emit(state.copyWith(excludedVersionIds: updated));
  }

  /// Called by a reading panel to report which verses match the current
  /// keywords.
  void reportMatches(String versionId, List<int> matches) {
    if (state.matchVerses[versionId] != null &&
        _listEquals(state.matchVerses[versionId]!, matches)) {
      return;
    }
    emit(state.copyWith(
      matchVerses: {...state.matchVerses, versionId: matches},
    ));
  }

  /// Called by a reading panel to report per-keyword occurrence counts.
  /// No-op if counts are unchanged.
  void reportWordCounts(String versionId, Map<String, int> counts) {
    final existing = state.versionWordCounts[versionId];
    if (existing != null && _mapsEqual(existing, counts)) return;
    emit(state.copyWith(
      versionWordCounts: {
        ...state.versionWordCounts,
        versionId: Map.unmodifiable(counts),
      },
    ));
  }

  /// Called when a reading panel is disposed so stale metrics are removed.
  void removeVersion(String versionId) {
    final hasCounts = state.matchVerses.containsKey(versionId);
    final hasExclusion = state.excludedVersionIds.contains(versionId);
    final hasWordCounts = state.versionWordCounts.containsKey(versionId);
    if (!hasCounts && !hasExclusion && !hasWordCounts) return;
    final counts = Map<String, List<int>>.from(state.matchVerses)..remove(versionId);
    final excluded = Set<String>.from(state.excludedVersionIds)
      ..remove(versionId);
    final wordCounts =
        Map<String, Map<String, int>>.from(state.versionWordCounts)
          ..remove(versionId);
    emit(state.copyWith(
      matchVerses: counts,
      excludedVersionIds: excluded,
      versionWordCounts: wordCounts,
    ));
  }

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
