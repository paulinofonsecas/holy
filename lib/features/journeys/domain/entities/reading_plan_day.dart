import 'package:equatable/equatable.dart';

class ReadingPlanDay extends Equatable {
  final String id;
  final String planId;
  final int day;
  final List<String> readings;
  final String? devotionalText;
  final String? prayer;

  const ReadingPlanDay({
    required this.id,
    required this.planId,
    required this.day,
    required this.readings,
    this.devotionalText,
    this.prayer,
  });

  @override
  List<Object?> get props => [id, planId, day, readings, devotionalText, prayer];

  factory ReadingPlanDay.fromJson(Map<String, dynamic> json) {
    return ReadingPlanDay(
      id: json['id'] as String,
      planId: json['planId'] as String,
      day: json['day'] as int,
      readings: List<String>.from(json['readings'] ?? []),
      devotionalText: json['devotionalText'] as String?,
      prayer: json['prayer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'day': day,
      'readings': readings,
      'devotionalText': devotionalText,
      'prayer': prayer,
    };
  }
}
