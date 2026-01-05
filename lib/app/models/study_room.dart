import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_room.freezed.dart';
part 'study_room.g.dart';

/// Custom JSON converter for Map fields coming from Firebase
class MapConverter implements JsonConverter<Map<String, dynamic>, dynamic> {
  const MapConverter();

  @override
  Map<String, dynamic> fromJson(dynamic json) {
    if (json == null) return {};
    if (json is Map<String, dynamic>) return json;
    if (json is Map) {
      return Map<String, dynamic>.from(json);
    }
    return {};
  }

  @override
  dynamic toJson(Map<String, dynamic> object) => object;
}

@freezed
class StudyRoom with _$StudyRoom {
  const factory StudyRoom({
    required String roomId,
    required String title,
    required String hostId,
    @Default(true) bool isPublic,
    @MapConverter() @Default({}) Map<String, dynamic> participants,
    @MapConverter() @Default({}) Map<String, dynamic> metadata,
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
