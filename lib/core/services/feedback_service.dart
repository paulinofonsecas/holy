import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FeedbackService {
  final FirebaseStorage _storage;
  final FirebaseCrashlytics _crashlytics;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  FeedbackService({
    FirebaseStorage? storage,
    FirebaseCrashlytics? crashlytics,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  Future<void> sendFeedback(String text, Uint8List screenshot) async {
    final timestamp = DateTime.now();
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = "${packageInfo.version} (${packageInfo.buildNumber})";

    Map<String, dynamic> deviceData = {};
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceData = {
          'browser': webInfo.browserName.name,
          'platform': webInfo.platform,
          'userAgent': webInfo.userAgent,
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData = {
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData = {
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
        };
      }
    } catch (e) {
      _crashlytics.log("Failed to get device info: $e");
    }

    String? imageUrl;
    try {
      final fileName = "feedback/${timestamp.millisecondsSinceEpoch}.png";
      final ref = _storage.ref().child(fileName);
      final uploadTask = await ref.putData(
        screenshot,
        SettableMetadata(contentType: 'image/png'),
      );
      imageUrl = await uploadTask.ref.getDownloadURL();
    } catch (e) {
      _crashlytics.log("Failed to upload feedback screenshot: $e");
    }

    // Log to Crashlytics
    await _crashlytics.setCustomKey("feedback_text", text);
    if (imageUrl != null) {
      await _crashlytics.setCustomKey("feedback_screenshot_url", imageUrl);
    }
    await _crashlytics.setCustomKey("app_version", appVersion);
    deviceData.forEach((key, value) async {
      await _crashlytics.setCustomKey("device_$key", value.toString());
    });

    await _crashlytics.log("User Feedback: $text");

    await _crashlytics.recordError(
      "User Feedback Report",
      null,
      reason: text,
      information: [
        if (imageUrl != null) "Screenshot: $imageUrl",
        "App Version: $appVersion",
        "Device Info: $deviceData",
      ],
      fatal: false,
    );
  }
}
