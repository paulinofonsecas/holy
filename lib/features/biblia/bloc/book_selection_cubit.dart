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
    final newExpanded = Set<String>.from(state.expandedBookIds)..add(bookId);

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
    final newExpanded = Set<String>.from(state.expandedBookIds);
    if (newExpanded.contains(bookId)) {
      newExpanded.remove(bookId);
    } else {
      newExpanded.add(bookId);
    }
    emit(state.copyWith(
      expandedBookIds: newExpanded,
      timestamp: DateTime.now(),
    ));
  }

  void setBookExpanded(String bookId, bool expanded) {
    final newExpanded = Set<String>.from(state.expandedBookIds);
    if (expanded) {
      newExpanded.add(bookId);
    } else {
      newExpanded.remove(bookId);
    }
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
