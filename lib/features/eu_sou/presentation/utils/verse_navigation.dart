import 'package:flutter/material.dart';

import '../../../deep_understanding/presentation/widgets/deep_understanding_actions.dart';

/// Helpers de navegação para versículos a partir das páginas EU Sou.
class VerseNavigation {
  VerseNavigation._();

  /// Abre o versículo referenciado na página da Bíblia.
  ///
  /// Aceita referências no formato gerado pelo AI:
  ///   "João 3:16", "Salmos 23:1", "1 Coríntios 13:4-7", etc.
  ///
  /// Reutiliza [DeepUnderstandingActions.handleBibleLink] que já faz:
  ///  • Lookup do livro via BibleBooks.byName()
  ///  • BibliaBloc.add(GetChapter(...))
  ///  • Navigator.push(BibliaPage)
  static void openInBible(BuildContext context, String verseReference) {
    if (verseReference.isEmpty) return;
    try {
      final trimmed = verseReference.trim();
      // Separa pelo último espaço antes do chapter:verse
      // e.g. "1 Coríntios 13:4" → book="1 Coríntios", ref="13:4"
      final lastSpace = trimmed.lastIndexOf(' ');
      if (lastSpace < 0) return;

      final bookName = trimmed.substring(0, lastSpace).trim();
      final refPart = trimmed.substring(lastSpace + 1).trim(); // "13:4" ou "13:4-7"

      if (bookName.isEmpty || !refPart.contains(':')) return;

      final colonIdx = refPart.indexOf(':');
      final chapter = refPart.substring(0, colonIdx);
      final verse = refPart.substring(colonIdx + 1); // pode ser "4", "4-7" ou "4,5"

      // Constrói bible:// URL — o DeepUnderstandingActions já lida com ranges
      final href =
          'bible://${Uri.encodeComponent(bookName)}/$chapter/$verse';

      DeepUnderstandingActions.handleBibleLink(context, href);
    } catch (_) {
      // Referência não reconhecida — silenciosamente ignora
    }
  }

  /// Indica se uma referência parece válida (tem format "Book X:Y")
  static bool isNavigable(String verseReference) {
    if (verseReference.isEmpty) return false;
    final lastSpace = verseReference.lastIndexOf(' ');
    if (lastSpace < 0) return false;
    final ref = verseReference.substring(lastSpace + 1);
    return ref.contains(':');
  }
}
