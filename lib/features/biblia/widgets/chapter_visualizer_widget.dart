import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/features/biblia/widgets/display_single_verse.dart';
import 'package:flutter/material.dart';

class ChapterVisualizerWidget extends StatelessWidget {
  const ChapterVisualizerWidget({
    super.key,
    required this.chapter,
  });

  final BibleChapter chapter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chapter.verses.map((verse) {
          return DisplaySingleVerse(
            key: Key("${verse.number}"),
            verse: verse,
          );
        }).toList(),
      ),
    );
  }
}
