import 'package:stacked/stacked.dart';

import '../../../../shared/bible_models.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/selection_bloc.dart';

class RichModalViewModel extends BaseViewModel {
  final List<BibleVerse> verses;
  final String verseReference;
  final String versionId;
  final String bookId;
  final int chapterNumber;
  final HighlightBloc highlightBloc;
  final VerseSelectionBloc selectionBloc;

  RichModalViewModel({
    required this.verses,
    required this.verseReference,
    required this.versionId,
    required this.bookId,
    required this.chapterNumber,
    required this.highlightBloc,
    required this.selectionBloc,
  });

  void applyHighlight(String colorHex) {
    for (var verse in verses) {
      final ref = _getVerseRef(verse);
      highlightBloc.add(AddHighlight(verseRef: ref, colorHex: colorHex));
    }
    notifyListeners();
  }

  void removeHighlight() {
    for (var verse in verses) {
      final ref = _getVerseRef(verse);
      highlightBloc.add(RemoveHighlight(verseRef: ref));
    }
    notifyListeners();
  }

  String _getVerseRef(BibleVerse verse) {
    // Return structured format: version:book:chapter:verse
    return '$versionId:$bookId:$chapterNumber:${verse.number}';
  }

  void clearSelection() {
    selectionBloc.add(ClearSelection());
  }

  // Function to be overridden by the modal caller
  void Function()? onShareText;
  void Function()? onCompareVersions;
  void shareText() {
    onShareText?.call();
  }

  void compareVersions() {
    onCompareVersions?.call();
  }
}
