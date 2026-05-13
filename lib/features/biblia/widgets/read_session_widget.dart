import 'package:eu_sou/features/biblia/bloc/reading_settings_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/reading_settings_state.dart';
import 'package:eu_sou/features/biblia/widgets/verse_read_widget.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadSessionWidget extends StatefulWidget {
  const ReadSessionWidget({
    super.key,
    required this.chapter,
    this.verseKeys = const {},
  });

  final BibleChapter chapter;
  final Map<int, GlobalKey> verseKeys;

  @override
  State<ReadSessionWidget> createState() => _ReadSessionWidgetState();
}

class _ReadSessionWidgetState extends State<ReadSessionWidget> {
  final Map<int, TapGestureRecognizer> _recognizers = {};

  @override
  void dispose() {
    for (var recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _getRecognizer(int verseNumber, BibleVerse verse) {
    return _recognizers.putIfAbsent(verseNumber, () {
      return TapGestureRecognizer()
        ..onTap = () {
          context.read<VerseSelectionBloc>().add(ToggleVerseSelection(verse));
        };
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
      builder: (context, settingsState) {
        if (settingsState.isContinuous) {
          return _buildContinuousLayout(context, settingsState);
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: () {
                  final seenNumbers = <int>{};
                  return widget.chapter.verses
                      .where((verse) => seenNumbers.add(verse.number))
                      .map((verse) {
                    final key = widget.verseKeys[verse.number] ??
                        ValueKey(verse.number);
                    return VerseReadWidget(
                      key: key,
                      verse: verse,
                      chapter: widget.chapter,
                    );
                  }).toList();
                }(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinuousLayout(
      BuildContext context, ReadingSettingsState settings) {
    final versionId = context.read<BibleVersionCubit>().state.version.id;

    return BlocBuilder<HighlightBloc, HighlightState>(
      builder: (context, highlightState) {
        return BlocBuilder<VerseSelectionBloc, VerseSelectionState>(
          builder: (context, selectionState) {
            final spans = <InlineSpan>[];

            final _seenVerseNumbers = <int>{};
            final _uniqueVerses = widget.chapter.verses
                .where((v) => _seenVerseNumbers.add(v.number))
                .toList();

            for (var i = 0; i < _uniqueVerses.length; i++) {
              final verse = _uniqueVerses[i];
              final verseRef =
                  "$versionId:${widget.chapter.bookId}:${widget.chapter.number}:${verse.number}";

              final isSelected =
                  selectionState.selectedVerses.containsKey(verse.number);
              final isHighlighted = highlightState is HighlightsLoaded &&
                  highlightState.highlights.containsKey(verseRef);

              Color? backgroundColor;
              if (isSelected) {
                backgroundColor =
                    Theme.of(context).colorScheme.primary.withValues(alpha: .2);
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
                fontSize: settings.fontSize,
                height: settings.lineHeight,
                letterSpacing: settings.letterSpacing,
                fontWeight:
                    settings.isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle:
                    settings.isItalic ? FontStyle.italic : FontStyle.normal,
                color: isHighlighted
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                backgroundColor: backgroundColor,
              );

              final style = settings.isGoogleFont
                  ? GoogleFonts.getFont(settings.fontFamily,
                      textStyle: baseStyle)
                  : baseStyle.copyWith(fontFamily: settings.fontFamily);

              // Verse Number
              spans.add(
                TextSpan(
                  text: "${verse.number} ",
                  style: style.copyWith(
                    fontSize: settings.fontSize * 0.7,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.8),
                    backgroundColor: backgroundColor,
                  ),
                  recognizer: _getRecognizer(verse.number, verse),
                ),
              );

              // Verse Text
              spans.add(
                TextSpan(
                  text: verse.text + (i < _uniqueVerses.length - 1 ? " " : ""),
                  style: style.copyWith(
                    decoration: isSelected ? TextDecoration.underline : null,
                    decorationStyle: TextDecorationStyle.dashed,
                    decorationColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: backgroundColor,
                  ),
                  recognizer: _getRecognizer(verse.number, verse),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                    textAlign: settings.textAlign,
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: spans,
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
