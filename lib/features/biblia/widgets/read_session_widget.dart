import 'package:eu_sou/features/biblia/widgets/verse_read_widget.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter/material.dart';

class ReadSessionWidget extends StatelessWidget {
  const ReadSessionWidget({
    super.key,
    required this.chapter,
    this.verseKeys = const {},
  });

  final BibleChapter chapter;
  final Map<int, GlobalKey> verseKeys;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chapter.verses.map((verse) {
              return VerseReadWidget(
                key: verseKeys[verse.number] ?? Key("${verse.number}"),
                verse: verse,
                chapter: chapter,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
