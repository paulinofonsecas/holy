import 'package:equatable/equatable.dart';

enum SelectionSource {
  modalTap,
  search,
  readingPlan,
  swipe,
  deepLink,
  external,
}

class BookSelectionState extends Equatable {
  final String translationId;
  final String bookId;
  final int chapterNumber;
  final Set<String> expandedBookIds;
  final double scrollOffset;
  final SelectionSource lastInteractionSource;
  final DateTime timestamp;

  const BookSelectionState({
    required this.translationId,
    required this.bookId,
    required this.chapterNumber,
    required this.expandedBookIds,
    required this.scrollOffset,
    required this.lastInteractionSource,
    required this.timestamp,
  });

  factory BookSelectionState.initial() {
    return BookSelectionState(
      translationId: '',
      bookId: '',
      chapterNumber: 1,
      expandedBookIds: const {},
      scrollOffset: 0.0,
      lastInteractionSource: SelectionSource.external,
      timestamp: DateTime.now(),
    );
  }

  BookSelectionState copyWith({
    String? translationId,
    String? bookId,
    int? chapterNumber,
    Set<String>? expandedBookIds,
    double? scrollOffset,
    SelectionSource? lastInteractionSource,
    DateTime? timestamp,
  }) {
    return BookSelectionState(
      translationId: translationId ?? this.translationId,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      expandedBookIds: expandedBookIds ?? this.expandedBookIds,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      lastInteractionSource:
          lastInteractionSource ?? this.lastInteractionSource,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        translationId,
        bookId,
        chapterNumber,
        expandedBookIds,
        scrollOffset,
        lastInteractionSource,
        timestamp,
      ];
}
