import 'services/local_notification_service.dart';
import 'services/fcm_service.dart';

// Singleton NotificationHandler for app-wide notification management
class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  final LocalNotificationService localNotificationService = LocalNotificationService();
  FCMService? _fcmService;

  Future<void> initialize() async {
    await localNotificationService.initialize();
    _fcmService = FCMService(localNotificationService);
    await _fcmService?.initialize();
  }

  void addOnNotificationTapListener(Function(String?) listener) {
    localNotificationService.addOnNotificationTapListener(listener);
  }

  void removeOnNotificationTapListener(Function(String?) listener) {
    localNotificationService.removeOnNotificationTapListener(listener);
  }
}

final notificationHandler = NotificationHandler();
