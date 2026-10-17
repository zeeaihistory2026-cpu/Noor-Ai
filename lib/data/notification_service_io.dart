import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_plan.dart';
import 'prayer_service.dart';

/// Phase 8 — REAL local notifications (native/desktop only).
///
/// Backed by flutter_local_notifications v22 + timezone +
/// flutter_timezone. Native setup lives in:
///  - android/app/src/main/AndroidManifest.xml (permissions:
///    RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM, POST_NOTIFICATIONS
///    — the latter two also declared by the plugin; receivers:
///    ScheduledNotificationReceiver + ScheduledNotificationBootReceiver)
///  - android/app/build.gradle.kts (core-library desugaring, which
///    the plugin requires for scheduled notifications)
///  - ios/Runner/AppDelegate.swift (UNUserNotificationCenter delegate)
///
/// Behaviour: permission is requested lazily on first use. If the
/// user denies it (or exact alarms are unavailable), scheduling
/// degrades gracefully — exact mode falls back to inexact, denial
/// means "0 scheduled" and the caller can tell the user honestly.
/// Nothing here has been device-tested yet; see SCAFFOLD_STATUS
/// Phase 8 for the killed-app alarm test still owed.
class NoorNotifications {
  NoorNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static bool _denied = false;

  static bool get isSupported => !kIsWeb;

  /// True once a permission request has been denied in this session.
  /// Lets the Reminder Center tell "permission denied" apart from
  /// "every toggle is off" and prompt honestly.
  static bool get permissionDenied => _denied;

  static const String prayerChannelId = 'noor_prayer';
  static const String dailyChannelId = 'noor_daily';

  /// Initialise plugin + timezone db and request permission.
  /// Returns true only when scheduling is actually possible.
  static Future<bool> ensureReady() async {
    if (_ready) return true;
    if (_denied) return false;
    try {
      tz_data.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (e) {
        debugPrint('NoorNotifications: Timezone initialization failed, falling back to UTC: $e');
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxInit =
          LinuxInitializationSettings(defaultActionName: 'Open NOOR');
      const settings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: iosInit,
        linux: linuxInit,
      );
      await _plugin.initialize(settings: settings);

      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await android?.requestNotificationsPermission();
        if (granted == false) {
          _denied = true;
          return false;
        }
        // Exact prayer-time alarms need a separate user grant on
        // Android 14+. Ask once; if refused we fall back to inexact.
        try {
          final canExact = await android?.canScheduleExactNotifications();
          if (canExact == false) {
            await android?.requestExactAlarmsPermission();
          }
        } catch (e) {
          debugPrint('NoorNotifications: Exact alarm permission request error: $e');
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted == false) {
          _denied = true;
          return false;
        }
      }

      _ready = true;
      return true;
    } catch (e, st) {
      debugPrint('NoorNotifications: Initialization failed: $e\n$st');
      return false;
    }
  }

  /// Replaces whatever NOOR previously scheduled with [plan]
  /// (from NotificationPlan.buildFullPlan) and returns how many
  /// entries were actually scheduled. Past entries are skipped.
  static Future<int> schedulePlan(List<PlannedNotification> plan) async {
    if (!await ensureReady()) return 0;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NoorNotifications: cancelAll failed: $e');
    }
    var scheduled = 0;
    final now = tz.TZDateTime.now(tz.local);
    for (final entry in plan) {
      final when = tz.TZDateTime.from(entry.scheduledAt, tz.local);
      if (when.isBefore(now)) continue;
      final details = _detailsFor(entry);
      try {
        await _plugin.zonedSchedule(
          id: entry.id,
          title: entry.title,
          body: entry.body,
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: '${entry.group}|${entry.prayerName}',
        );
        scheduled++;
      } catch (e) {
        // Exact alarms denied/revoked between check and schedule:
        // retry inexact rather than dropping the reminder silently.
        try {
          await _plugin.zonedSchedule(
            id: entry.id,
            title: entry.title,
            body: entry.body,
            scheduledDate: when,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: '${entry.group}|${entry.prayerName}',
          );
          scheduled++;
        } catch (err) {
          debugPrint('NoorNotifications: Failed scheduling notification ${entry.id}: $err');
        }
      }
    }
    return scheduled;
  }

  /// Specifically schedules alerts for the upcoming next namaz (both lead-time and prayer time).
  static Future<bool> scheduleNextPrayerReminder(NextPrayer next) async {
    if (!await ensureReady()) return false;
    try {
      final name = next.displayName;
      final when = tz.TZDateTime.from(next.time, tz.local);
      final now = tz.TZDateTime.now(tz.local);
      if (when.isBefore(now)) return false;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          prayerChannelId,
          'Prayer reminders',
          channelDescription: 'A short reminder before each prayer time',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // 1. Alert at prayer time
      await _plugin.zonedSchedule(
        id: 9991,
        title: 'Time for $name',
        body: 'It is now time for $name (${next.timeLabel}). Hayya ‘ala-s-Salah.',
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'Salah|$name',
      );

      // 2. Alert 15 minutes before if still in future
      final leadWhen = when.subtract(const Duration(minutes: 15));
      if (leadWhen.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: 9992,
          title: '$name reminder',
          body: '$name begins in 15 minutes (${next.timeLabel}). Prepare for prayer.',
          scheduledDate: leadWhen,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'Salah|$name',
        );
      }
      return true;
    } catch (e) {
      debugPrint('NoorNotifications: scheduleNextPrayerReminder failed: $e');
      return false;
    }
  }

  /// Shows an immediate local notification (used for testing and instant alerts).
  static Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isSalah = false,
  }) async {
    if (!await ensureReady()) return false;
    try {
      final android = AndroidNotificationDetails(
        isSalah ? prayerChannelId : dailyChannelId,
        isSalah ? 'Prayer reminders' : 'Daily NOOR reminders',
        channelDescription: isSalah
            ? 'A short reminder before each prayer time'
            : 'Adhkar, Dua, Hadith, Ayah and Quote reminders',
        importance: isSalah ? Importance.high : Importance.defaultImportance,
        priority: isSalah ? Priority.high : Priority.defaultPriority,
      );
      const ios = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(android: android, iOS: ios, macOS: ios);
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
      return true;
    } catch (e, st) {
      debugPrint('NoorNotifications: showNotification failed: $e\n$st');
      return false;
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NoorNotifications: cancelAll failed: $e');
    }
  }

  static NotificationDetails _detailsFor(PlannedNotification entry) {
    final isSalah = entry.group == 'Salah';
    final android = AndroidNotificationDetails(
      isSalah ? prayerChannelId : dailyChannelId,
      isSalah ? 'Prayer reminders' : 'Daily NOOR reminders',
      channelDescription: isSalah
          ? 'A short reminder before each prayer time'
          : 'Adhkar, Dua and Hadith reminders',
      importance: isSalah ? Importance.high : Importance.defaultImportance,
      priority: isSalah ? Priority.high : Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: android, iOS: ios, macOS: ios);
  }
}
