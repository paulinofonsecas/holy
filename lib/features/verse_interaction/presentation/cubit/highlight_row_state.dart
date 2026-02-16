part of 'highlight_row_cubit.dart';

@freezed
class HighlightRowState with _$HighlightRowState {
  const factory HighlightRowState.initial() = _Initial;
  const factory HighlightRowState.isCollapsed() = _IsCollapsed;
  const factory HighlightRowState.isNotCollapsed() = _IsNotCollapsed;
}
