import 'package:bloc/bloc.dart';
import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

part 'biblia_event.dart';
part 'biblia_state.dart';

class BibliaBloc extends Bloc<BibliaEvent, BibliaState> {
  final IBibleRepository _bibleReposity;
  final ScrollPersistenceService _scrollPersistenceService;

  BibliaBloc(this._bibleReposity, this._scrollPersistenceService)
      : super(BibliaInitial()) {
    on<GetChapter>(
      _onGetChapter,
      transformer: (events, mapper) => events.switchMap(mapper),
    );
    on<ClearTargetVerse>(_onClearTargetVerse);
    on<UpdateBibleScroll>(
      _onUpdateScroll,
      transformer: (events, mapper) =>
          events.debounce(const Duration(milliseconds: 500)).switchMap(mapper),
    );
    on<ForceScrollRestoration>(_onForceScrollRestoration);
  }

  void _onForceScrollRestoration(
    ForceScrollRestoration event,
    Emitter<BibliaState> emit,
  ) {
    if (state is BibleChapterLoaded) {
      final currentState = state as BibleChapterLoaded;
      final savedOffset = _scrollPersistenceService.getBibleScrollOffset(
        currentState.chapter.bookId,
        currentState.chapter.number,
      );
      emit(BibleChapterLoaded(
        currentState.chapter,
        versionId: currentState.versionId,
        targetVerse: currentState.targetVerse,
        targetVerses: currentState.targetVerses,
        initialScrollOffset: savedOffset,
      ));
    }
  }

  void _onUpdateScroll(
    UpdateBibleScroll event,
    Emitter<BibliaState> emit,
  ) {
    if (state is BibleChapterLoaded) {
      final currentState = state as BibleChapterLoaded;
      _scrollPersistenceService.saveReadingPosition(
        versionId: currentState.versionId,
        bookId: currentState.chapter.bookId,
        chapterNumber: currentState.chapter.number,
        scrollOffset: event.offset,
      );
    }
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
        targetVerses: null,
      ));
    }
  }

  Future<void> _onGetChapter(
    GetChapter event,
    Emitter<BibliaState> emit,
  ) async {
    final parsedChapter = int.tryParse(event.chapter);
    if (parsedChapter == null || parsedChapter <= 0) {
      developer.log(
        'Ignoring invalid chapter restore request: ${event.book} ${event.chapter}',
        name: 'BibliaBloc',
      );
      return;
    }

    // Se já estiver carregado o mesmo capítulo, apenas atualizamos o versículo alvo ou offset se necessário
    if (state is BibleChapterLoaded) {
      final currentState = state as BibleChapterLoaded;
      if (currentState.versionId == event.version &&
          currentState.chapter.number.toString() == event.chapter &&
          currentState.chapter.bookId == event.book) {
        // Se o versículo alvo, targetVerses ou scrollOffset forem diferentes, emitimos o novo estado para disparar o scroll
        if (currentState.targetVerse != event.verse ||
            currentState.targetVerses != event.targetVerses ||
            event.scrollOffset != null) {
          emit(BibleChapterLoaded(
            currentState.chapter,
            versionId: currentState.versionId,
            targetVerse: event.verse,
            targetVerses: event.targetVerses,
            initialScrollOffset: event.scrollOffset ?? currentState.initialScrollOffset,
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
        parsedChapter.toString(),
      );

      await _scrollPersistenceService.saveReadingPosition(
        versionId: event.version,
        bookId: result.bookId,
        chapterNumber: result.number,
      );

      final savedOffset = event.scrollOffset ?? _scrollPersistenceService.getBibleScrollOffset(
        result.bookId,
        result.number,
      );

      emit(BibleChapterLoaded(
        result,
        versionId: event.version,
        targetVerse: event.verse,
        targetVerses: event.targetVerses,
        initialScrollOffset: savedOffset,
      ));

      // Pre-fetch adjacent chapters for smoother navigation
      final currentChapterNum = parsedChapter;
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
