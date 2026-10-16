import 'notification_plan.dart';

/// No-op notifications for platforms without dart:io (web).
/// Scheduling silently reports "not supported" — nothing is ever
/// claimed to be scheduled here.
class NoorNotifications {
  NoorNotifications._();

  static bool get isSupported => false;

  /// Always false on web: permission/scheduling unsupported here.
  static bool get permissionDenied => false;

  /// Always false on web: permission/scheduling unsupported here.
  static Future<bool> ensureReady() async => false;

  /// Returns 0 (nothing scheduled) on web.
  static Future<int> schedulePlan(List<PlannedNotification> plan) async => 0;

  /// Always false on web: local notifications unsupported.
  static Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isSalah = false,
  }) async => false;

  static Future<void> cancelAll() async {}
}
