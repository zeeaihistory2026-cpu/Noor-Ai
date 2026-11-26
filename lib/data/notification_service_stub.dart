import 'notification_plan.dart';

/// No-op notifications for platforms without dart:io (web).
/// Scheduling silently reports "not supported" — nothing is ever
/// claimed to be scheduled here.
class NoorNotifications {
  NoorNotifications._();
  static void Function(String?)? onNotificationTap;
  static String? pendingPayload;

  static bool get isSupported => false;

  /// Always false on web: permission/scheduling unsupported here.
  static bool get permissionDenied => false;

  /// Always false on web: permission/scheduling unsupported here.
  static Future<bool> ensureReady({bool requestPermission = true}) async =>
      false;

  /// Returns 0 (nothing scheduled) on web.
  static Future<int> schedulePlan(List<PlannedNotification> plan,
          {bool requestPermission = true}) async =>
      0;

  static Future<bool> scheduleNextPrayerReminder(dynamic next) async => false;

  /// Always false on web: local notifications unsupported.
  static Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isSalah = false,
    bool playAzan = false,
  }) async =>
      false;

  static Future<void> cancelAll() async {}
}
