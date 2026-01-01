import 'package:eu_sou/core/design_system/app_colors/app_colors.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DisplaySingleVerse extends StatelessWidget {
  const DisplaySingleVerse({
    super.key,
    required this.verse,
    required this.chapter,
  });

  final BibleVerse verse;
  final BibleChapter chapter;

  @override
  Widget build(BuildContext context) {
    final versionId = context.read<BibleVersionCubit>().state.version.id;
    final verseRef =
        "$versionId:${chapter.bookId}:${chapter.number}:${verse.number}";

    return BlocBuilder<HighlightBloc, HighlightState>(
      builder: (context, highlightState) {
        return BlocBuilder<VerseSelectionBloc, VerseSelectionState>(
          builder: (context, selectionState) {
            final isSelected =
                selectionState.selectedVerses.containsKey(verse.number);

            Color? backgroundColor;
            if (isSelected) {
              backgroundColor = Theme.of(context).colorScheme.primaryContainer;
            } else if (highlightState is HighlightsLoaded) {
              final highlight = highlightState.highlights[verseRef];
              if (highlight != null) {
                backgroundColor =
                    Color(int.parse(highlight.colorHex, radix: 16));
              }
            }

            final style = TextStyle(
              fontSize: 18,
              color: AppColor.textPrimary,
            );

            return GestureDetector(
              onTap: () {
                if (selectionState.isInSelectionMode) {
                  context
                      .read<VerseSelectionBloc>()
                      .add(ToggleVerseSelection(verse));
                }
              },
              onLongPress: () {
                if (!selectionState.isInSelectionMode) {
                  context
                      .read<VerseSelectionBloc>()
                      .add(ToggleVerseSelection(verse));
                } else {
                  // If already in selection mode, maybe show options for the whole selection?
                  // For now, let's just keep it simple.
                }
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: verse.number.toString() + " ",
                          style: style.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextSpan(
                          text: verse.text,
                          style: style.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
