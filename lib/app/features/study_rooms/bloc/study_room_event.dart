part of 'study_room_bloc.dart';

abstract class StudyRoomEvent extends Equatable {
  const StudyRoomEvent();

  @override
  List<Object?> get props => [];
}

class JoinRoom extends StudyRoomEvent {
  final String roomId;
  final String userId;
  final String displayName;

  const JoinRoom({
    required this.roomId,
    required this.userId,
    required this.displayName,
  });

  @override
  List<Object?> get props => [roomId, userId, displayName];
}

class LeaveRoom extends StudyRoomEvent {
  final String roomId;
  final String userId;

  const LeaveRoom({required this.roomId, required this.userId});

  @override
  List<Object?> get props => [roomId, userId];
}

class OnEventReceived extends StudyRoomEvent {
  final ShareEvent event;
  const OnEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

class ShareVerse extends StudyRoomEvent {
  final VerseReference verseRef;
  const ShareVerse(this.verseRef);

  @override
  List<Object?> get props => [verseRef];
}

class ToggleFollow extends StudyRoomEvent {}
