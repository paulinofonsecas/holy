part of 'marked_verses_bloc.dart';

abstract class MarkedVersesEvent extends Equatable {
  const MarkedVersesEvent();

  @override
  List<Object> get props => [];
}

class LoadMarkedVerses extends MarkedVersesEvent {}
