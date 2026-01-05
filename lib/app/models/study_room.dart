import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_room.freezed.dart';
part 'study_room.g.dart';

@freezed
class StudyRoom with _$StudyRoom {
  const factory StudyRoom({
    required String roomId,
    required String title,
    required String hostId,
    @Default(true) bool isPublic,
    @Default({}) Map<String, dynamic> participants,
    @Default({}) Map<String, dynamic> metadata,
    DateTime? createdAt,
  }) = _StudyRoom;

  factory StudyRoom.fromJson(Map<String, dynamic> json) =>
      _$StudyRoomFromJson(json);
}

@freezed
class StudyRoomMetadata with _$StudyRoomMetadata {
  const factory StudyRoomMetadata({
    String? description,
    @Default([]) List<String> authorizedControllers,
  }) = _StudyRoomMetadata;

  factory StudyRoomMetadata.fromJson(Map<String, dynamic> json) =>
      _$StudyRoomMetadataFromJson(json);
}
