import 'dart:convert';

class DailyReminder {
  final String id;
  final String label;
  final String subtitle;
  final int hour;
  final int minute;
  final bool enabled;
  final String iconEmoji;
  final bool isPreset;

  const DailyReminder({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.iconEmoji,
    this.isPreset = false,
  });

  String get timeLabel {
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    return '${displayHour.toString().padLeft(2, '0')}:$m $period';
  }

  /// Notification ID derived from id hash (stable, fits int range)
  int get notificationId {
    var hash = 0;
    for (final c in id.codeUnits) {
      hash = (hash * 31 + c) & 0x7FFFFFFF;
    }
    return 2000 + (hash % 1000);
  }

  DailyReminder copyWith({
    String? id,
    String? label,
    String? subtitle,
    int? hour,
    int? minute,
    bool? enabled,
    String? iconEmoji,
    bool? isPreset,
  }) {
    return DailyReminder(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isPreset: isPreset ?? this.isPreset,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'subtitle': subtitle,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
        'iconEmoji': iconEmoji,
        'isPreset': isPreset,
      };

  factory DailyReminder.fromJson(Map<String, dynamic> json) => DailyReminder(
        id: json['id'] as String,
        label: json['label'] as String,
        subtitle: json['subtitle'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        enabled: json['enabled'] as bool,
        iconEmoji: json['iconEmoji'] as String,
        isPreset: json['isPreset'] as bool? ?? false,
      );

  static List<DailyReminder> fromJsonList(String raw) {
    final list = jsonDecode(raw) as List;
    return list.map((e) => DailyReminder.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String toJsonList(List<DailyReminder> reminders) =>
      jsonEncode(reminders.map((e) => e.toJson()).toList());
}
