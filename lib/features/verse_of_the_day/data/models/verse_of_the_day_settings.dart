import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verse_of_the_day_settings.g.dart';

@JsonSerializable()
class VerseOfTheDaySettings extends Equatable {
  final bool isEnabled;
  final int hour;
  final int minute;
  final String versionId;
  final List<String> bookIds;

  const VerseOfTheDaySettings({
    required this.isEnabled,
    required this.hour,
    required this.minute,
    required this.versionId,
    required this.bookIds,
  });

  factory VerseOfTheDaySettings.fromJson(Map<String, dynamic> json) =>
      _$VerseOfTheDaySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$VerseOfTheDaySettingsToJson(this);

  @override
  List<Object?> get props => [isEnabled, hour, minute, versionId, bookIds];

  VerseOfTheDaySettings copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
    String? versionId,
    List<String>? bookIds,
  }) {
    return VerseOfTheDaySettings(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      versionId: versionId ?? this.versionId,
      bookIds: bookIds ?? this.bookIds,
    );
  }
}
