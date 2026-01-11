import 'package:bloc/bloc.dart';

import 'book_selection_state.dart';

class BookSelectionCubit extends Cubit<BookSelectionState> {
  BookSelectionCubit() : super(BookSelectionState.initial());

  void updateContext({
    required String translationId,
    required String bookId,
    required int chapterNumber,
    required SelectionSource source,
  }) {
    // Accordion: Only the current book remains expanded
    final newExpanded = {bookId};

    emit(state.copyWith(
      translationId: translationId,
      bookId: bookId,
      chapterNumber: chapterNumber,
      expandedBookIds: newExpanded,
      lastInteractionSource: source,
      timestamp: DateTime.now(),
    ));
  }

  void toggleBookExpansion(String bookId) {
    final isCurrentlyExpanded = state.expandedBookIds.contains(bookId);

    // Accordion: If expanding, clear others and add this one.
    // If collapsing, just clear the set.
    final newExpanded = isCurrentlyExpanded ? <String>{} : {bookId};

    emit(state.copyWith(
      expandedBookIds: newExpanded,
      timestamp: DateTime.now(),
    ));
  }

  void setBookExpanded(String bookId, bool expanded) {
    // Accordion: If expanding, clear others and add this one.
    // If collapsing, just clear the set.
    final newExpanded = expanded ? {bookId} : <String>{};

    emit(state.copyWith(
      expandedBookIds: newExpanded,
      timestamp: DateTime.now(),
    ));
  }

  void setExpandedBooks(Set<String> bookIds) {
    emit(state.copyWith(
      expandedBookIds: bookIds,
      timestamp: DateTime.now(),
    ));
  }

  void updateScrollOffset(double offset) {
    emit(state.copyWith(
      scrollOffset: offset,
      timestamp: DateTime.now(),
    ));
  }

  void reset() {
    emit(BookSelectionState.initial());
  }
}
