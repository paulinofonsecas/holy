import 'package:eu_sou/core/design_system/app_colors/app_colors.dart';
import 'package:eu_sou/features/biblia/bloc/reading_settings_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/reading_settings_state.dart';
import 'package:eu_sou/features/biblia/bloc/verse_filter_cubit.dart';
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

    return BlocBuilder<VerseFilterCubit, VerseFilterState>(
      builder: (context, filterState) {
        final versionId = context.read<BibleVersionCubit>().state.version.id;
        final keywords = filterState.isVersionActive(versionId)
            ? filterState.keywords
            : const <String>[];
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
                      backgroundColor = getVerseBackgroudColor(context);
                    } else if (highlightState is HighlightsLoaded) {
                      final highlight = highlightState.highlights[verseRef];
                      if (highlight != null) {
                        backgroundColor = Theme.brightnessOf(context) ==
                                Brightness.light
                            ? Color(int.parse(highlight.colorHex, radix: 16))
                                .withValues(alpha: .8)
                            : Color(int.parse(highlight.colorHex, radix: 16))
                                .withValues(alpha: .3);
                      }
                    }

                    final bgTextColor =
                        settingsState.readingBackground.textColor;
                    final normalTextColor = bgTextColor ??
                        (Theme.brightnessOf(context) == Brightness.light
                            ? Colors.black
                            : Colors.white);
                    final highlightedTextColor = _resolveHighlightedTextColor(
                      context: context,
                      settingsState: settingsState,
                      highlightBackgroundColor: backgroundColor,
                      fallbackColor: normalTextColor,
                    );
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
                      color: bgTextColor ?? AppColor.textPrimary,
                    );

                    final style = settingsState.isGoogleFont
                        ? GoogleFonts.getFont(settingsState.fontFamily,
                            textStyle: baseStyle)
                        : baseStyle.copyWith(
                            fontFamily: settingsState.fontFamily);

                    final numberStyle = style.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: isSelected ? TextDecoration.underline : null,
                      decorationStyle: TextDecorationStyle.dashed,
                      decorationColor: Theme.of(context).colorScheme.primary,
                      color: !isHighlighted
                          ? normalTextColor
                          : highlightedTextColor,
                    );

                    final bodyBaseStyle = style.copyWith(
                      decoration: isSelected ? TextDecoration.underline : null,
                      decorationStyle: TextDecorationStyle.dashed,
                      decorationColor: Theme.of(context).colorScheme.onSurface,
                      color: !isHighlighted
                          ? normalTextColor
                          : highlightedTextColor,
                    );

                    return GestureDetector(
                      onTap: () {
                        context
                            .read<VerseSelectionBloc>()
                            .add(ToggleVerseSelection(verse));
                      },
                      onLongPress: () {
                        context
                            .read<VerseSelectionBloc>()
                            .add(ToggleVerseSelection(verse));
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
                                    text: "${verse.number}",
                                    style: numberStyle,
                                  ),
                                  TextSpan(
                                    text: '- ',
                                    style: numberStyle,
                                  ),
                                  ..._buildFilteredTextSpans(
                                    verse.text,
                                    keywords,
                                    bodyBaseStyle,
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
      },
    );
  }

  bool alreadyHighlighted(BuildContext context) {
    final versionId = context.read<BibleVersionCubit>().state.version.id;
    final verseRef =
        "$versionId:${chapter.bookId}:${chapter.number}:${verse.number}";

    final highlightState = context.watch<HighlightBloc>().state;
    if (highlightState is HighlightsLoaded) {
      return highlightState.highlights.containsKey(verseRef);
    }
    return false;
  }

  String getVerseHighlightColor(BuildContext context) {
    final versionId = context.read<BibleVersionCubit>().state.version.id;
    final verseRef =
        "$versionId:${chapter.bookId}:${chapter.number}:${verse.number}";

    final highlightState = context.watch<HighlightBloc>().state;
    if (highlightState is HighlightsLoaded) {
      final highlight = highlightState.highlights[verseRef];
      if (highlight != null) {
        return highlight.colorHex;
      }
    }
    return 'FFDE64'; // Cor padrão para destaque
  }

  Color getVerseBackgroudColor(BuildContext context) {
    if (alreadyHighlighted(context)) {
      final highlightColorHex = getVerseHighlightColor(context);
      return Theme.brightnessOf(context) == Brightness.light
          ? Color(int.parse(highlightColorHex, radix: 16)).withValues(alpha: .2)
          : Color(int.parse(highlightColorHex, radix: 16))
              .withValues(alpha: .2);
    }

    return Theme.brightnessOf(context) == Brightness.light
        ? Theme.of(context).colorScheme.primary.withValues(alpha: .2)
        : Theme.of(context).colorScheme.primary.withValues(alpha: .2);
  }

  Color _resolveHighlightedTextColor({
    required BuildContext context,
    required ReadingSettingsState settingsState,
    required Color? highlightBackgroundColor,
    required Color fallbackColor,
  }) {
    final themedColor = settingsState.readingBackground.highlightTextColor;
    if (themedColor != null) {
      return themedColor;
    }

    if (highlightBackgroundColor == null) {
      return fallbackColor;
    }

    final isLightBackground = highlightBackgroundColor.computeLuminance() > 0.5;
    return isLightBackground ? Colors.black : Colors.white;
  }
}

// ── Helper: split text into highlighted + normal spans ──────────────────────

/// Splits [text] into a list of [TextSpan]s, wrapping every occurrence of any
/// keyword with a bright yellow background so individual words are highlighted.
List<TextSpan> _buildFilteredTextSpans(
  String text,
  List<String> keywords,
  TextStyle baseStyle,
) {
  if (keywords.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  final pattern = keywords.map(RegExp.escape).join('|');
  final regex = RegExp(pattern, caseSensitive: false);

  final spans = <TextSpan>[];
  int lastEnd = 0;

  for (final match in regex.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: baseStyle,
      ));
    }
    spans.add(TextSpan(
      text: text.substring(match.start, match.end),
      style: baseStyle.copyWith(
        backgroundColor: const Color(0xFFFFF176),
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ));
    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
  }

  return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
}
