// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_of_the_day_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseOfTheDaySettings _$VerseOfTheDaySettingsFromJson(
        Map<String, dynamic> json) =>
    VerseOfTheDaySettings(
      isEnabled: json['isEnabled'] as bool,
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      versionId: json['versionId'] as String,
      bookIds:
          (json['bookIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$VerseOfTheDaySettingsToJson(
        VerseOfTheDaySettings instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'hour': instance.hour,
      'minute': instance.minute,
      'versionId': instance.versionId,
      'bookIds': instance.bookIds,
    };
