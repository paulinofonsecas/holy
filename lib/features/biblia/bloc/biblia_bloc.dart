import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

part 'biblia_event.dart';
part 'biblia_state.dart';

class BibliaBloc extends Bloc<BibliaEvent, BibliaState> {
  final IBibleRepository _bibleReposity;

  BibliaBloc(this._bibleReposity) : super(BibliaInitial()) {
    on<GetChapter>(
      _onGetChapter,
      transformer: (events, mapper) => events.switchMap(mapper),
    );
    on<ClearTargetVerse>(_onClearTargetVerse);
  }

  void _onClearTargetVerse(
    ClearTargetVerse event,
    Emitter<BibliaState> emit,
  ) {
    if (state is BibleChapterLoaded) {
      final currentState = state as BibleChapterLoaded;
      emit(BibleChapterLoaded(
        currentState.chapter,
        versionId: currentState.versionId,
        targetVerse: null,
      ));
    }
  }

  Future<void> _onGetChapter(
    GetChapter event,
    Emitter<BibliaState> emit,
  ) async {
    if (int.parse(event.chapter) <= 0) {
      return;
    }

    // Se já estiver carregado o mesmo capítulo, apenas atualizamos o versículo alvo se necessário
    if (state is BibleChapterLoaded) {
      final currentState = state as BibleChapterLoaded;
      if (currentState.versionId == event.version &&
          currentState.chapter.number.toString() == event.chapter &&
          currentState.chapter.bookId == event.book) {
        // Se o versículo alvo for diferente, emitimos o novo estado para disparar o scroll
        if (currentState.targetVerse != event.verse) {
          emit(BibleChapterLoaded(
            currentState.chapter,
            versionId: currentState.versionId,
            targetVerse: event.verse,
          ));
        }
        return;
      }
    }

    emit(BibliaLoading(versionId: event.version));

    try {
      final result = await _bibleReposity.getChapter(
        event.version,
        event.book,
        event.chapter,
      );

      emit(BibleChapterLoaded(
        result,
        versionId: event.version,
        targetVerse: event.verse,
      ));

      // Pre-fetch adjacent chapters for smoother navigation
      final currentChapterNum = int.tryParse(event.chapter) ?? 0;
      if (currentChapterNum > 0) {
        // Next chapter
        if (currentChapterNum < result.totalChapters) {
          _bibleReposity
              .getChapter(
                event.version,
                event.book,
                (currentChapterNum + 1).toString(),
              )
              .catchError((_) => null);
        }
        // Previous chapter
        if (currentChapterNum > 1) {
          _bibleReposity
              .getChapter(
                event.version,
                event.book,
                (currentChapterNum - 1).toString(),
              )
              .catchError((_) => null);
        }
      }
    } catch (e) {
      emit(state);
      emit(BibleError(e.toString()));
    }
  }
}
