import 'package:eu_sou/features/biblia/bloc/verse_filter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterMetricsPanel extends StatelessWidget {
  const FilterMetricsPanel({super.key, required this.filterState});

  final VerseFilterState filterState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final counts = filterState.matchVerses
        .map((key, value) => MapEntry(key, value.length));
    final excluded = filterState.excludedVersionIds;

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final wordCounts = filterState.wordCounts;
    final sortedWords = wordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Summary ──────────────────────────────────────────────────
          Row(
            children: [
              Text(
                '${filterState.totalMatches} ocorrências',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (sorted.isNotEmpty)
                Text(
                  ' · ${sorted.where((e) => e.value > 0).length} versão(ões)',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),

          // ── Per-version counts ────────────────────────────────────────
          if (sorted.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: sorted.map((entry) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${entry.key.toUpperCase()}: ${entry.value}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // ── Per-keyword occurrence counts ─────────────────────────────
          if (sortedWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Por palavra:',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: sortedWords.map((entry) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF176).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE6C619).withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(
                    '"${entry.key}": ${entry.value}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // ── Version inclusion toggle chips ────────────────────────────
          if (counts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Versões incluídas na pesquisa:',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: counts.keys.map((versionId) {
                final isActive = !excluded.contains(versionId);
                final count = counts[versionId] ?? 0;
                return FilterChip(
                  label: Text(
                    '${versionId.toUpperCase()} ($count)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  selected: isActive,
                  onSelected: (_) => context
                      .read<VerseFilterCubit>()
                      .toggleVersionExclusion(versionId),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  selectedColor: colorScheme.secondaryContainer,
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                  side: BorderSide(
                    color: isActive
                        ? colorScheme.secondary.withValues(alpha: 0.6)
                        : colorScheme.outline.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}