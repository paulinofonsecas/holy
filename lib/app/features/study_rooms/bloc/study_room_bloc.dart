import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/verse_resolver.dart';
import '../../../models/sync_models.dart';
import '../../../services/study_room_service.dart';

part 'study_room_event.dart';
part 'study_room_state.dart';

class StudyRoomBloc extends Bloc<StudyRoomEvent, StudyRoomState> {
  final StudyRoomService _service;
  StreamSubscription<ShareEvent>? _eventSubscription;

  StudyRoomBloc(this._service) : super(StudyRoomInitial()) {
    on<JoinRoom>(_onJoinRoom);
    on<LeaveRoom>(_onLeaveRoom);
    on<OnEventReceived>(_onEventReceived);
    on<ShareVerse>(_onShareVerse);
    on<ToggleFollow>(_onToggleFollow);
  }

  Future<void> _onJoinRoom(JoinRoom event, Emitter<StudyRoomState> emit) async {
    emit(StudyRoomLoading());
    try {
      final room = await _service.getRoomDetails(event.roomId);
      await _service.joinRoom(event.roomId, event.userId, event.displayName);

      _eventSubscription?.cancel();
      _eventSubscription = _service.events.listen((event) {
        add(OnEventReceived(event));
      });

      emit(StudyRoomJoined(
        roomId: event.roomId,
        userId: event.userId,
        hostId: room.hostId,
        status: SyncStatus.following,
      ));
    } catch (e) {
      emit(StudyRoomError(e.toString()));
    }
  }

  Future<void> _onLeaveRoom(
      LeaveRoom event, Emitter<StudyRoomState> emit) async {
    await _service.leaveRoom(event.roomId, event.userId);
    _eventSubscription?.cancel();
    emit(StudyRoomInitial());
  }

  void _onEventReceived(OnEventReceived event, Emitter<StudyRoomState> emit) {
    if (state is StudyRoomJoined) {
      final currentState = state as StudyRoomJoined;
      if (currentState.status == SyncStatus.following) {
        emit(currentState.copyWith(lastEvent: event.event));
      }
    }
  }

  Future<void> _onShareVerse(
      ShareVerse event, Emitter<StudyRoomState> emit) async {
    if (state is StudyRoomJoined) {
      final currentState = state as StudyRoomJoined;
      if (!currentState.isHost) {
        emit(const StudyRoomError('Apenas o host pode compartilhar versículos'));
        return;
      }
      final shareEvent = ShareEvent(
        eventId: '', // Will be set by service
        sessionId: currentState.roomId,
        type: ShareEventType.shareVerse,
        verseRef: event.verseRef,
        authorId: currentState.userId,
        createdAt: 0, // Will be set by service
      );
      await _service.publishEvent(currentState.roomId, shareEvent);
    }
  }

  void _onToggleFollow(ToggleFollow event, Emitter<StudyRoomState> emit) {
    if (state is StudyRoomJoined) {
      final currentState = state as StudyRoomJoined;
      final newStatus = currentState.status == SyncStatus.following
          ? SyncStatus.detached
          : SyncStatus.following;
      emit(currentState.copyWith(status: newStatus));
    }
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}
