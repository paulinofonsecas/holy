import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:meta/meta.dart';
import 'package:eu_sou/shared/bible_models.dart';

part 'biblia_event.dart';

part 'biblia_state.dart';

class BibliaBloc extends Bloc<BibliaEvent, BibliaState> {
  final IBibleRepository _bibleReposity;

  BibliaBloc(this._bibleReposity) : super(BibliaInitial()) {
    on<GetChapter>(_onGetChapter);
  }

  Future<void> _onGetChapter(
    GetChapter event,
    Emitter<BibliaState> emit,
  ) async {
    if (int.parse(event.chapter) <= 0) {
      return;
    }

    if (state is BibliaLoading) return;
    emit(BibliaLoading());

    try {
      if (state is BibleChapterLoaded &&
          (state as BibleChapterLoaded).chapter.number == event.chapter) {
        return;
      }

      final result = await _bibleReposity.getChapter(
        event.version,
        event.book,
        event.chapter,
      );

      emit(BibleChapterLoaded(result));
    } catch (e) {
      emit(state);
      emit(BibleError(e.toString()));
    }
  }
}
