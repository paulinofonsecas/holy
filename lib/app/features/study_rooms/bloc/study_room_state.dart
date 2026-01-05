part of 'study_room_bloc.dart';

abstract class StudyRoomState extends Equatable {
  const StudyRoomState();

  @override
  List<Object?> get props => [];
}

class StudyRoomInitial extends StudyRoomState {}

class StudyRoomLoading extends StudyRoomState {}

class StudyRoomJoined extends StudyRoomState {
  final String roomId;
  final String userId;
  final SyncStatus status;
  final ShareEvent? lastEvent;

  const StudyRoomJoined({
    required this.roomId,
    required this.userId,
    required this.status,
    this.lastEvent,
  });

  StudyRoomJoined copyWith({
    String? roomId,
    String? userId,
    SyncStatus? status,
    ShareEvent? lastEvent,
  }) {
    return StudyRoomJoined(
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }

  @override
  List<Object?> get props => [roomId, userId, status, lastEvent];
}

class StudyRoomError extends StudyRoomState {
  final String message;
  const StudyRoomError(this.message);

  @override
  List<Object?> get props => [message];
}
