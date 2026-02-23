import 'package:eu_sou/core/services/toast_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/push_notification_model.dart';

/// Service to handle local notifications using flutter_local_notifications plugin
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<Function(String?)> _onNotificationTapListeners = [];

  /// Initialize local notification service
  Future<void> initialize() async {
    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/notification_icon');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      if (defaultTargetPlatform == TargetPlatform.android) {
        // Request permissions for Android 13+
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();

        // Request exact alarm permission for Android 12+
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Failed to initialize LocalNotificationService: $e');
    }
  }

  /// Show a notification
  Future<void> showNotification(PushNotificationModel notification) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'High importance notifications for verses',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: '@drawable/notification_icon',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: platformChannelSpecifics,
        payload: notification.payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
      toastService.showError('Não foi possível exibir a notificação.');
    }
  }

  /// Schedules a notification to repeat daily at a specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'daily_verse_channel',
        'Daily Verse Notifications',
        channelDescription: 'Daily Bible verse notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        scheduledDate: _nextInstanceOfTime(hour, minute),
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
      toastService.showError('Erro ao agendar notificação diária.');
    }
  }

  /// Schedules a notification at a specific date and time
  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'daily_verse_channel',
        'Daily Verse Notifications',
        channelDescription: 'Daily Bible verse notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Scheduled notification $id at $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification at date: $e');
      toastService.showError('Falha ao agendar versículo do dia.');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Handle notification response when tapped
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;

    // Notify listeners
    for (var listener in _onNotificationTapListeners) {
      listener(payload);
    }
  }

  /// Add notification tap listener
  void addOnNotificationTapListener(Function(String?) listener) {
    _onNotificationTapListeners.add(listener);
  }

  /// Remove notification tap listener
  void removeOnNotificationTapListener(Function(String?) listener) {
    _onNotificationTapListeners.remove(listener);
  }

  /// Get pending notification requests
  Future<List<PendingNotificationRequest>>
      getPendingNotificationRequests() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
