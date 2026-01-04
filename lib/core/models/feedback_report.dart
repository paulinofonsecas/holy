import 'dart:typed_data';

class FeedbackReport {
  final String text;
  final Uint8List screenshot;
  final DateTime timestamp;
  final Map<String, dynamic>? deviceInfo;
  final String? appVersion;
  final String? userId;

  FeedbackReport({
    required this.text,
    required this.screenshot,
    required this.timestamp,
    this.deviceInfo,
    this.appVersion,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
      'userId': userId,
    };
  }
}
