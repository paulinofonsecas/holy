---
trigger: "Local notifications not triggering for daily growth reminders"
status: "resolved"
goal: "find_and_fix"
---

## Root Cause

**Primary Issue**: Missing boot receiver to reschedule notifications after device restart.

The daily growth reminders are scheduled only when the app starts (in `main.dart` via `_scheduleNotificationsInBackground()`). However, there's no `BroadcastReceiver` in AndroidManifest.xml to restore scheduled notifications after the device reboots. When the device restarts, all scheduled local notifications are cleared and never rescheduled.

**Secondary Issues**:
1. No notification rescheduling on app resume (only cold start)
2. Silent exception handling in `scheduleNotificationAt()` masks permission/initialization failures

## Evidence

### 1. AndroidManifest.xml - No receiver for boot completed
- Missing boot receiver declaration

### 2. main.dart - Only schedules on cold start
- Only runs `_scheduleNotificationsInBackground()` once at app start
- Doesn't handle device reboot or app being killed

### 3. Silent exception swallowing
- Scheduling failures only printed debug output - no visibility

## Fix Applied

### 1. Added boot receiver to AndroidManifest.xml
```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

### 2. Added lifecycle observer in App widget
- Added `WidgetsBindingObserver` to `_AppState` 
- Reschedules notifications when app resumes from background

### 3. Added debug logging
- Added logging to `DailyReminderService.scheduleReminder()`
- Added logging to `LocalNotificationService.scheduleNotificationAt()`
- Added logging in `_rescheduleNotifications()`

## Files Modified

1. `android/app/src/main/AndroidManifest.xml` - Added boot receiver
2. `lib/app/app.dart` - Added lifecycle observer for rescheduling
3. `lib/features/daily_growth/data/services/daily_reminder_service.dart` - Added debug logging
4. `lib/core/notifications/services/local_notification_service.dart` - Added debug logging

## Resolution

**Root cause**: Missing boot receiver to persist scheduled notifications across device restarts + no rescheduling on app resume.

**Fix applied**: 
1. Declared `ScheduledNotificationBootReceiver` in AndroidManifest.xml
2. Added lifecycle-based rescheduling when app resumes
3. Added debug logging for troubleshooting