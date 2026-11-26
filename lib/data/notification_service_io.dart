import 'dart:async';
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
  static bool _requestedExactPermission = false;
  static void Function(String?)? onNotificationTap;
  static String? pendingPayload;
  static bool _readLaunch = false;
  @visibleForTesting
  static void resetForTesting() {
    _ready = false;
    _denied = false;
    _readLaunch = false;
    _requestedExactPermission = false;
    pendingPayload = null;
    onNotificationTap = null;
  }

  static bool _denied = false;

  static bool get isSupported => !kIsWeb;

  /// True once a permission request has been denied in this session.
  /// Lets the Reminder Center tell "permission denied" apart from
  /// "every toggle is off" and prompt honestly.
  static bool get permissionDenied => _denied;

  static const String prayerChannelId = 'noor_prayer';
  static const String dailyChannelId = 'noor_daily';
  static const String azanChannelId = 'noor_azan_v1';

  /// Initialise plugin + timezone db and request permission.
  /// Returns true only when scheduling is actually possible.
  static Future<bool> ensureReady({bool requestPermission = true}) async {
    if (_ready) {
      if (defaultTargetPlatform != TargetPlatform.android) return true;
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (await android?.areNotificationsEnabled() == true) {
        _denied = false;
        await _requestExactIfNeeded(android, requestPermission);
        return true;
      }
      _ready = false;
    }
    try {
      tz_data.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (e) {
        debugPrint(
            'NoorNotifications: Timezone initialization failed, falling back to UTC: $e');
      }

      const androidInit =
          AndroidInitializationSettings('@drawable/ic_notification');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxInit =
          LinuxInitializationSettings(defaultActionName: 'Open MuslimGo');
      const settings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: iosInit,
        linux: linuxInit,
      );
      await _plugin.initialize(
          settings: settings,
          onDidReceiveNotificationResponse: (response) {
            pendingPayload = response.payload;
            onNotificationTap?.call(response.payload);
          });
      if (!_readLaunch) {
        _readLaunch = true;
        final launch = await _plugin.getNotificationAppLaunchDetails();
        if (launch?.didNotificationLaunchApp == true) {
          pendingPayload = launch?.notificationResponse?.payload;
        }
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = requestPermission
            ? await android?.requestNotificationsPermission()
            : await android?.areNotificationsEnabled();
        if (granted == false) {
          _denied = true;
          return false;
        }
        // Exact prayer-time alarms need a separate user grant on
        // Android 14+. Ask once; if refused we fall back to inexact.
        await _requestExactIfNeeded(android, requestPermission);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = !requestPermission
            ? false
            : await ios?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );
        if (granted == false) {
          _denied = true;
          return false;
        }
      }

      _denied = false;
      _ready = true;
      return true;
    } catch (e, st) {
      debugPrint('NoorNotifications: Initialization failed: $e\n$st');
      return false;
    }
  }

  static Future<void> _requestExactIfNeeded(
      AndroidFlutterLocalNotificationsPlugin? android,
      bool requestPermission) async {
    if (!requestPermission || _requestedExactPermission) return;
    try {
      if (await android?.canScheduleExactNotifications() == false) {
        _requestedExactPermission = true;
        await android?.requestExactAlarmsPermission();
      }
    } catch (error) {
      debugPrint(
          'Exact-alarm access unavailable; inexact fallback remains active: $error');
    }
  }

  /// Replaces whatever MuslimGo previously scheduled with [plan]
  /// (from NotificationPlan.buildFullPlan) and returns how many
  /// entries were actually scheduled. Past entries are skipped.
  static Future<void> _scheduleQueue = Future.value();

  static Future<int> schedulePlan(List<PlannedNotification> plan,
      {bool requestPermission = true}) {
    final completion = Completer<int>();
    _scheduleQueue = _scheduleQueue.catchError((Object _) {}).then((_) async {
      try {
        completion.complete(
            await _schedulePlan(plan, requestPermission: requestPermission));
      } catch (e, st) {
        completion.completeError(e, st);
      }
    });
    return completion.future;
  }

  static Future<int> _schedulePlan(List<PlannedNotification> plan,
      {required bool requestPermission}) async {
    if (!await ensureReady(requestPermission: requestPermission)) return 0;
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
          debugPrint(
              'NoorNotifications: Failed scheduling notification ${entry.id}: $err');
        }
      }
    }
    return scheduled;
  }

  /// Specifically schedules alerts for the upcoming next namaz (both lead-time and prayer time).
  static Future<bool> scheduleNextPrayerReminder(NextPrayer next) async {
    if (!await ensureReady()) return false;
    final when = next.time;
    final now = DateTime.now();
    if (!when.isAfter(now)) return false;
    final entries = <PlannedNotification>[
      PlannedNotification(
          id: 9991,
          title: 'Time for ${next.displayName}',
          body: 'It is now time for ${next.displayName}.',
          group: 'Salah',
          scheduledAt: when,
          prayerName: next.name),
      if (when.subtract(const Duration(minutes: 15)).isAfter(now))
        PlannedNotification(
            id: 9992,
            title: '${next.displayName} reminder',
            body: '${next.displayName} begins in 15 minutes.',
            group: 'Salah',
            scheduledAt: when.subtract(const Duration(minutes: 15)),
            prayerName: next.name),
    ];
    try {
      for (final entry in entries) {
        Future<void> schedule(AndroidScheduleMode mode) =>
            _plugin.zonedSchedule(
                id: entry.id,
                title: entry.title,
                body: entry.body,
                scheduledDate: tz.TZDateTime.from(entry.scheduledAt, tz.local),
                notificationDetails: _detailsFor(entry),
                androidScheduleMode: mode,
                payload: 'Salah|${next.name}');
        try {
          await schedule(AndroidScheduleMode.exactAllowWhileIdle);
        } catch (_) {
          await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
        }
      }
      return true;
    } catch (_) {
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
    bool playAzan = false,
  }) async {
    if (!await ensureReady()) return false;
    try {
      final android = AndroidNotificationDetails(
        isSalah ? prayerChannelId : dailyChannelId,
        isSalah ? 'Prayer reminders' : 'Daily MuslimGo reminders',
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
      final details = playAzan
          ? _detailsFor(PlannedNotification(
              id: id,
              group: 'Salah',
              title: 'Time for Azan',
              body: body,
              scheduledAt: DateTime.now(),
              prayerName: 'Azan'))
          : NotificationDetails(android: android, iOS: ios, macOS: ios);
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
    final isAzan = isSalah && entry.title.startsWith('Time for ');
    final android = AndroidNotificationDetails(
      isAzan
          ? azanChannelId
          : isSalah
              ? prayerChannelId
              : dailyChannelId,
      isAzan
          ? 'Azan at prayer time'
          : isSalah
              ? 'Prayer reminders'
              : 'Daily MuslimGo reminders',
      channelDescription: isSalah
          ? 'A short reminder before each prayer time'
          : 'Adhkar, Dua and Hadith reminders',
      importance: isSalah ? Importance.high : Importance.defaultImportance,
      priority: isSalah ? Priority.high : Priority.defaultPriority,
      sound: isAzan ? const RawResourceAndroidNotificationSound('azan') : null,
      playSound: true,
      audioAttributesUsage: isAzan
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: android, iOS: ios, macOS: ios);
  }
}
