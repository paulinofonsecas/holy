import 'package:stacked/stacked.dart';

import '../../../../shared/bible_models.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/selection_bloc.dart';

class RichModalViewModel extends BaseViewModel {
  final List<BibleVerse> verses;
  final String verseReference;
  final HighlightBloc highlightBloc;
  final VerseSelectionBloc selectionBloc;

  RichModalViewModel({
    required this.verses,
    required this.verseReference,
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
    // This is a simplification. Usually we need book and chapter info too.
    // For now, using the reference passed to the model as a base or
    // assuming verses have enough info.
    // In this app, highlights seem to be stored by a string key 'verseRef'.
    return '$verseReference:${verse.number}';
  }

  void clearSelection() {
    selectionBloc.add(ClearSelection());
  }

  // Function to be overridden by the modal caller
  void Function()? onShareText;
}
