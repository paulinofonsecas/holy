import 'package:eu_sou/core/services/share_service.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/highlight_bloc.dart';
import '../bloc/selection_bloc.dart';
import '../rich_modal/rich_verse_action_modal.dart';
import 'color_picker_modal.dart';

class SelectionToolbar extends StatelessWidget {
  final BibleChapter chapter;

  const SelectionToolbar({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerseSelectionBloc, VerseSelectionState>(
      builder: (context, state) {
        if (!state.isInSelectionMode) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '${state.selectedVerses.length} selecionados',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.border_color),
                    onPressed: () {
                      _showHighlightOptions(context, state);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      _showRichModal(context, state);
                    },
                    tooltip: 'Mais opções',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.read<VerseSelectionBloc>().add(ClearSelection());
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareSelectedVerses(BuildContext context, VerseSelectionState state) {
    final versionId = context.read<BibleVersionCubit>().state.version.id;
    ShareService.shareVerses(
      verses: state.selectedVerses.values.toList(),
      bookName: chapter.bookName ?? chapter.bookId,
      chapterNumber: chapter.number,
      versionId: versionId,
    );
    context.read<VerseSelectionBloc>().add(ClearSelection());
  }

  void _showHighlightOptions(BuildContext context, VerseSelectionState state) {
    final versionId = context.read<BibleVersionCubit>().state.version.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => ColorPickerModal(
        verseRef: "multiple", // Special case for multiple
        onColorSelected: (colorHex) {
          for (final verse in state.selectedVerses.values) {
            final verseRef =
                "$versionId:${chapter.bookId}:${chapter.number}:${verse.number}";
            context.read<HighlightBloc>().add(
                  AddHighlight(verseRef: verseRef, colorHex: colorHex),
                );
          }
          context.read<VerseSelectionBloc>().add(ClearSelection());
        },
        onRemoveHighlight: () {
          for (final verse in state.selectedVerses.values) {
            final verseRef =
                "$versionId:${chapter.bookId}:${chapter.number}:${verse.number}";
            context.read<HighlightBloc>().add(
                  RemoveHighlight(verseRef: verseRef),
                );
          }
          context.read<VerseSelectionBloc>().add(ClearSelection());
        },
      ),
    );
  }

  void _showRichModal(BuildContext context, VerseSelectionState state) {
    final verses = state.selectedVerses.values.toList();
    final verseReference = _buildVerseReference(verses);

    RichVerseActionModal.show(
      context: context,
      verses: verses,
      verseReference: verseReference,
      bookId: chapter.bookId,
      bookName: chapter.bookName ?? chapter.bookId,
      chapterNumber: chapter.number,
    );
  }

  String _buildVerseReference(List<BibleVerse> verses) {
    if (verses.isEmpty) return '';

    verses.sort((a, b) => a.number.compareTo(b.number));

    if (verses.length == 1) {
      return '${chapter.bookName ?? chapter.bookId} ${chapter.number}:${verses.first.number}';
    }

    // Check if contiguous
    bool contiguous = true;
    for (int i = 0; i < verses.length - 1; i++) {
      if (verses[i + 1].number != verses[i].number + 1) {
        contiguous = false;
        break;
      }
    }

    if (contiguous) {
      return '${chapter.bookName ?? chapter.bookId} ${chapter.number}:${verses.first.number}-${verses.last.number}';
    } else {
      return '${chapter.bookName ?? chapter.bookId} ${chapter.number}:${verses.map((v) => v.number).join(', ')}';
    }
  }
}
