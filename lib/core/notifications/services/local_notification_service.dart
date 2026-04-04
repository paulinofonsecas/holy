import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/push_notification_model.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final List<Function(String?)> _onNotificationTapListeners = [];

  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_verse_channel';
  static const String _channelName = 'Daily Verse Notifications';
  static const String _channelDescription = 'Daily Bible verse notifications';
  static const String _iconName = '@drawable/notification_icon';

  NotificationDetails get _notificationDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          icon: _iconName,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings(_iconName),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onTap,
      );

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
        await androidPlugin?.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Failed to initialize LocalNotificationService: $e');
    }
  }

  Future<void> showNotification(PushNotificationModel notification) async {
    try {
      await _plugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: _notificationDetails,
        payload: notification.payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfTime(hour, minute),
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
    }
  }

  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool repeatDailyAtTime = false,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            repeatDailyAtTime ? DateTimeComponents.time : null,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling notification at date: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() {
    return _plugin.pendingNotificationRequests();
  }

  Future<void> cancelNotification(int id) => _plugin.cancel(id: id);

  Future<void> cancelAllNotifications() => _plugin.cancelAll();

  void addOnNotificationTapListener(Function(String?) listener) {
    _onNotificationTapListeners.add(listener);
  }

  void removeOnNotificationTapListener(Function(String?) listener) {
    _onNotificationTapListeners.remove(listener);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  void _onTap(NotificationResponse response) {
    for (final listener in _onNotificationTapListeners) {
      listener(response.payload);
    }
  }
}
