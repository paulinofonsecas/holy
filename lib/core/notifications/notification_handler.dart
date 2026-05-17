import 'package:flutter/foundation.dart';

import 'services/fcm_service.dart';
import 'services/local_notification_service.dart';

// Singleton NotificationHandler for app-wide notification management
class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  final LocalNotificationService localNotificationService =
      LocalNotificationService();
  FCMService? _fcmService;

  Future<void> initialize() async {
    if (!kIsWeb) {
      try {
        await localNotificationService.initialize();
      } catch (e) {
        debugPrint('Warning: LocalNotificationService initialization failed: $e');
      }
    }
    _fcmService = FCMService(localNotificationService);
    try {
      await _fcmService?.initialize();
    } catch (e) {
      // FCM is an optional capability. Browsers that do not support the
      // Web Push API (e.g. iOS Safari in browser mode, not as a PWA) will
      // throw here. We catch and log so the app still boots.
      debugPrint('Warning: FCM initialization skipped: $e');
    }
  }

  void addOnNotificationTapListener(Function(String?) listener) {
    localNotificationService.addOnNotificationTapListener(listener);
  }

  void removeOnNotificationTapListener(Function(String?) listener) {
    localNotificationService.removeOnNotificationTapListener(listener);
  }
}

final notificationHandler = NotificationHandler();
