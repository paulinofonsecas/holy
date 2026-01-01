import 'package:eu_sou/shared/bible_models.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareVerses({
    required List<BibleVerse> verses,
    required String bookName,
    required int chapterNumber,
    required String versionId,
  }) async {
    if (verses.isEmpty) return;

    // Sort verses by number
    verses.sort((a, b) => a.number.compareTo(b.number));

    final StringBuffer buffer = StringBuffer();

    // Format: "Book Chapter:Verse1-VerseN (Version)"
    String reference = "$bookName $chapterNumber:";
    if (verses.length == 1) {
      reference += "${verses.first.number}";
    } else {
      // Check if they are contiguous
      bool contiguous = true;
      for (int i = 0; i < verses.length - 1; i++) {
        if (verses[i + 1].number != verses[i].number + 1) {
          contiguous = false;
          break;
        }
      }

      if (contiguous) {
        reference += "${verses.first.number}-${verses.last.number}";
      } else {
        reference += verses.map((v) => v.number).join(', ');
      }
    }

    buffer.writeln("$reference ($versionId)");
    buffer.writeln();

    for (final verse in verses) {
      buffer.writeln("${verse.number}. ${verse.text}");
    }

    await Share.share(buffer.toString());
  }
}
