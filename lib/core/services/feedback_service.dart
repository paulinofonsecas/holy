import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FeedbackService {
  final FirebaseStorage _storage;
  final Hub _hub;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  FeedbackService({
    FirebaseStorage? storage,
    Hub? hub,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _hub = hub ?? HubAdapter();

  Future<void> sendFeedback(String text, Uint8List screenshot) async {
    final timestamp = DateTime.now();
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';

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
    } catch (e, stackTrace) {
      await _hub.addBreadcrumb(
        Breadcrumb(
          category: 'feedback.device_info',
          message: 'Failed to collect device metadata',
          data: {'error': e.toString()},
          level: SentryLevel.warning,
        ),
      );
      await _hub.captureException(e, stackTrace: stackTrace);
    }

    String? imageUrl;
    try {
      final fileName = 'feedback/${timestamp.millisecondsSinceEpoch}.png';
      final ref = _storage.ref().child(fileName);
      final uploadTask = await ref.putData(
        screenshot,
        SettableMetadata(contentType: 'image/png'),
      );
      imageUrl = await uploadTask.ref.getDownloadURL();
    } catch (e, stackTrace) {
      await _hub.addBreadcrumb(
        Breadcrumb(
          category: 'feedback.screenshot_upload',
          message: 'Failed to upload feedback screenshot',
          data: {'error': e.toString()},
          level: SentryLevel.warning,
        ),
      );
      await _hub.captureException(e, stackTrace: stackTrace);
    }

    await _hub.captureMessage(
      'User Feedback Report',
      level: SentryLevel.warning,
      withScope: (scope) {
        scope.setTag('feedback_source', 'in_app');
        scope.setTag('app_version', appVersion);
        scope.setContexts('feedback', {
          'text': text,
          'submitted_at': timestamp.toIso8601String(),
          if (imageUrl != null) 'screenshot_url': imageUrl,
        });
        if (deviceData.isNotEmpty) {
          scope.setContexts('device_info', deviceData);
        }
        scope.addAttachment(
          SentryAttachment.fromUint8List(
            screenshot,
            'feedback.png',
            contentType: 'image/png',
          ),
        );
      },
    );
  }
}
