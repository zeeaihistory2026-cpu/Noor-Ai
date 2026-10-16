import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_plan.dart';

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
      } catch (_) {
        /* keep tz.local default (UTC) if lookup fails */
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
        } catch (_) {
          /* inexact fallback covers us */
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
    } catch (_) {
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
    } catch (_) {
      /* nothing to cancel yet */
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
      } catch (_) {
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
        } catch (_) {
          /* this entry could not be scheduled; others still were */
        }
      }
    }
    return scheduled;
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
    } catch (_) {
      return false;
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {
      /* plugin not ready; nothing scheduled by us in that case */
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
