import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/marked_verse_model.dart';
import '../../domain/repositories/i_marked_verses_repository.dart';

part 'marked_verses_event.dart';
part 'marked_verses_state.dart';

class MarkedVersesBloc extends Bloc<MarkedVersesEvent, MarkedVersesState> {
  final IMarkedVersesRepository _repository;

  MarkedVersesBloc(this._repository) : super(MarkedVersesInitial()) {
    on<LoadMarkedVerses>(_onLoadMarkedVerses);
  }

  Future<void> _onLoadMarkedVerses(
    LoadMarkedVerses event,
    Emitter<MarkedVersesState> emit,
  ) async {
    emit(MarkedVersesLoading());
    try {
      final highlights = await _repository.getMarkedVerses();
      emit(MarkedVersesLoaded(markedVerses: highlights));
    } catch (e) {
      emit(MarkedVersesError(message: e.toString()));
    }
  }
}
