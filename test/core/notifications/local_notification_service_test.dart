import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:eu_sou/core/notifications/services/local_notification_service.dart';
import 'package:eu_sou/core/notifications/models/push_notification_model.dart';

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  group('LocalNotificationService', () {
    late MockFlutterLocalNotificationsPlugin mockPlugin;
    late LocalNotificationService service;

    setUp(() {
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      service = LocalNotificationService(mockPlugin);
    });

    test('showNotification calls plugin.show', () async {
      final notification = PushNotificationModel(
        title: 'Test',
        body: 'Body',
        payload: '{"type":"test"}',
      );
      when(() => mockPlugin.show(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            notificationDetails: any(named: 'notificationDetails'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async => true);
      await service.showNotification(notification);
      verify(() => mockPlugin.show(
            id: any(named: 'id'),
            title: 'Test',
            body: 'Body',
            notificationDetails: any(named: 'notificationDetails'),
            payload: '{"type":"test"}',
          )).called(1);
    });

    test('addOnNotificationTapListener and removeOnNotificationTapListener', () {
      void listener(String? payload) {}
      service.addOnNotificationTapListener(listener);
      expect(() => service.removeOnNotificationTapListener(listener), returnsNormally);
    });

    test('sendTestNotification does not throw', () async {
      when(() => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            payload: any(named: 'payload'),
            // Removed uiLocalNotificationDateInterpretation for compatibility
          )).thenAnswer((_) async => true);
      await service.sendTestNotification();
      verify(() => mockPlugin.zonedSchedule(
            id: 9999,
            title: 'Test Notification',
            body: 'This is a test notification.',
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: '{"type":"test"}',
            // Removed uiLocalNotificationDateInterpretation for compatibility
          )).called(1);
    });
  });
}
