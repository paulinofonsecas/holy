import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'highlight_row_state.dart';
part 'highlight_row_cubit.freezed.dart';

class HighlightRowCubit extends Cubit<HighlightRowState> {
  HighlightRowCubit() : super(const HighlightRowState.initial());

  void toggleCollapse() {
    state == const HighlightRowState.isCollapsed()
        ? emit(const HighlightRowState.isNotCollapsed())
        : emit(const HighlightRowState.isCollapsed());
  }
}
