import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/bloc/verse_filter_cubit.dart';
import 'package:eu_sou/features/biblia/widgets/count_badge.dart';
import 'package:eu_sou/features/biblia/widgets/filter_metrics_panel.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class VerseFilterBar extends StatefulWidget {
  const VerseFilterBar({super.key});

  @override
  State<VerseFilterBar> createState() => _VerseFilterBarState();
}

class _VerseFilterBarState extends State<VerseFilterBar> {
  final _controller = TextEditingController();
  bool _isExpanded = false;
  int _currentMatchIndex = -1;
  bool _autoScrollToFirst = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToNextMatch(List<int> matches) {
    if (matches.isEmpty) return;
    _autoScrollToFirst = false;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % matches.length;
    });
    _triggerScroll(matches[_currentMatchIndex]);
  }

  void _scrollToPreviousMatch(List<int> matches) {
    if (matches.isEmpty) return;
    _autoScrollToFirst = false;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1) % matches.length;
      if (_currentMatchIndex < 0) _currentMatchIndex += matches.length;
    });
    _triggerScroll(matches[_currentMatchIndex]);
  }

  void _triggerScroll(int verseNumber) {
    final state = context.read<BibliaBloc>().state;
    if (state is BibleChapterLoaded) {
      context.read<BibliaBloc>().add(
            GetChapter(
              state.versionId,
              state.chapter.bookId,
              state.chapter.number.toString(),
              verse: verseNumber,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocConsumer<VerseFilterCubit, VerseFilterState>(
      listener: (context, state) {
        if (_autoScrollToFirst && state.isFiltering) {
          final versionId = context.read<BibleVersionCubit>().state.version.id;
          final matches = state.matchVerses[versionId] ?? [];
          if (matches.isNotEmpty) {
            _autoScrollToFirst = false;
            setState(() => _currentMatchIndex = 0);
            _triggerScroll(matches[0]);
          }
        }
      },
      builder: (context, state) {
        final isFiltering = state.isFiltering;
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Search field + toggle row ───────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText:
                              'Filtrar versículos por palavras-chave. Separe os termos com ,',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 4),
                            child: AppHugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              size: 16,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 36, minHeight: 36),
                          suffixIcon: !isFiltering
                              ? null
                              : IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: AppHugeIcon(
                                    icon: HugeIcons.strokeRoundedCancel01,
                                    size: 16,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {
                                      _isExpanded = false;
                                      _currentMatchIndex = -1;
                                      _autoScrollToFirst = false;
                                    });
                                    context.read<VerseFilterCubit>().clear();
                                  },
                                ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.35),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.35),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _currentMatchIndex = -1;
                            _autoScrollToFirst = true;
                          });
                          context.read<VerseFilterCubit>().updateFilter(value);
                        },
                      ),
                    ),
                    // Metrics badge + expand toggle shown only when filtering
                    if (isFiltering) ...[
                      const SizedBox(width: 4),
                      Builder(
                        builder: (context) {
                          final versionId = context
                              .watch<BibleVersionCubit>()
                              .state
                              .version
                              .id;
                          final matches = state.matchVerses[versionId] ?? [];
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.keyboard_arrow_up,
                                    size: 28),
                                padding: EdgeInsets.zero,
                                onPressed: matches.isEmpty
                                    ? null
                                    : () => _scrollToPreviousMatch(matches),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 28),
                                padding: EdgeInsets.zero,
                                onPressed: matches.isEmpty
                                    ? null
                                    : () => _scrollToNextMatch(matches),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      if (!_isExpanded && state.totalMatches > 0)
                        CountBadge(
                          count: state.totalMatches,
                          colorScheme: colorScheme,
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip:
                            _isExpanded ? 'Recolher métricas' : 'Ver métricas',
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                        onPressed: () =>
                            setState(() => _isExpanded = !_isExpanded),
                      ),
                    ],
                  ],
                ),
                // ── Expanded metrics + version filter panel ─────────────
                if (_isExpanded && isFiltering) ...[
                  const SizedBox(height: 6),
                  FilterMetricsPanel(filterState: state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
