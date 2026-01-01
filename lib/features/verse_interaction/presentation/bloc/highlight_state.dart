part of 'highlight_bloc.dart';

abstract class HighlightState extends Equatable {
  const HighlightState();

  @override
  List<Object?> get props => [];
}

class HighlightInitial extends HighlightState {}

class HighlightLoading extends HighlightState {}

class HighlightsLoaded extends HighlightState {
  final Map<String, Highlight> highlights;

  const HighlightsLoaded({required this.highlights});

  @override
  List<Object?> get props => [highlights];
}

class HighlightError extends HighlightState {
  final String message;

  const HighlightError({required this.message});

  @override
  List<Object?> get props => [message];
}
