import 'package:eu_sou/core/design_system/app_colors/app_colors.dart';
import 'package:eu_sou/features/biblia/bloc/reading_settings_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/reading_settings_state.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class VerseReadWidget extends StatelessWidget {
  const VerseReadWidget({
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

    return BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<HighlightBloc, HighlightState>(
          builder: (context, highlightState) {
            return BlocBuilder<VerseSelectionBloc, VerseSelectionState>(
              builder: (context, selectionState) {
                final isSelected =
                    selectionState.selectedVerses.containsKey(verse.number);
                final isHighlighted = highlightState is HighlightsLoaded &&
                    highlightState.highlights.containsKey(verseRef);

                Color? backgroundColor;
                if (isSelected) {
                  backgroundColor =
                      Theme.brightnessOf(context) == Brightness.light
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .2)
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .2);
                } else if (highlightState is HighlightsLoaded) {
                  final highlight = highlightState.highlights[verseRef];
                  if (highlight != null) {
                    backgroundColor =
                        Theme.brightnessOf(context) == Brightness.light
                            ? Color(int.parse(highlight.colorHex, radix: 16))
                                .withValues(alpha: .8)
                            : Color(int.parse(highlight.colorHex, radix: 16))
                                .withValues(alpha: .3);
                  }
                }

                final baseStyle = TextStyle(
                  fontSize: settingsState.fontSize,
                  height: settingsState.lineHeight,
                  letterSpacing: settingsState.letterSpacing,
                  fontWeight: settingsState.isBold
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontStyle: settingsState.isItalic
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: AppColor.textPrimary,
                );

                final style = settingsState.isGoogleFont
                    ? GoogleFonts.getFont(settingsState.fontFamily,
                        textStyle: baseStyle)
                    : baseStyle.copyWith(fontFamily: settingsState.fontFamily);

                return GestureDetector(
                  onTap: () {
                    context
                        .read<VerseSelectionBloc>()
                        .add(ToggleVerseSelection(verse));
                  },
                  onLongPress: () {
                    if (!selectionState.isInSelectionMode) {
                      context
                          .read<VerseSelectionBloc>()
                          .add(ToggleVerseSelection(verse));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Align(
                      alignment: settingsState.textAlign == TextAlign.center
                          ? Alignment.topCenter
                          : settingsState.textAlign == TextAlign.right
                              ? Alignment.topRight
                              : Alignment.topLeft,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: RichText(
                          textAlign: settingsState.textAlign,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${verse.number} ",
                                style: style.copyWith(
                                  fontWeight: FontWeight.w500,
                                  decoration: isSelected
                                      ? TextDecoration.underline
                                      : null,
                                  decorationStyle: TextDecorationStyle.dashed,
                                  decorationColor:
                                      Theme.of(context).colorScheme.primary,
                                  color: !isHighlighted
                                      ? Theme.brightnessOf(context) ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                ),
                              ),
                              TextSpan(
                                text: verse.text,
                                style: style.copyWith(
                                  decoration: isSelected
                                      ? TextDecoration.underline
                                      : null,
                                  decorationStyle: TextDecorationStyle.dashed,
                                  decorationColor:
                                      Theme.of(context).colorScheme.primary,
                                  color: !isHighlighted
                                      ? Theme.brightnessOf(context) ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
