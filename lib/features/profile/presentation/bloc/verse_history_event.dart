part of 'verse_history_bloc.dart';

abstract class VerseHistoryEvent extends Equatable {
  const VerseHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadVerseHistory extends VerseHistoryEvent {}

class AddVerseToHistory extends VerseHistoryEvent {
  final String verseRef;
  final String versionId;

  const AddVerseToHistory({required this.verseRef, required this.versionId});

  @override
  List<Object?> get props => [verseRef, versionId];
}

class ClearVerseHistory extends VerseHistoryEvent {}
