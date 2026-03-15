part of 'marked_verses_bloc.dart';

abstract class MarkedVersesEvent extends Equatable {
  const MarkedVersesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMarkedVerses extends MarkedVersesEvent {
  final int page;
  final int pageSize;
  final String? query;
  final bool isRefresh;

  const LoadMarkedVerses({
    required this.page,
    required this.pageSize,
    this.query,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, pageSize, query, isRefresh];
}
