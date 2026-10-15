/// Phase 8 — SUPERSEDED. Real local notifications now live in
/// notification_service.dart (conditional facade) backed by
/// notification_service_io.dart (flutter_local_notifications v22 +
/// timezone). This file is kept only so older references resolve;
/// new code must use NoorNotifications directly.
///
/// What Phase 8 wired (see SCAFFOLD_STATUS.md Phase 8):
/// Android permissions/receivers + desugaring, iOS
/// UNUserNotificationCenter delegate, lazy permission request with
/// graceful denial, NotificationPlan output fed into
/// zonedSchedule (exact -> inexact fallback), cancel-by-replace.
///
/// Still owed before any "reminders work" claim on a real phone:
/// the killed-app Fajr-minus-15 device test (Phase 9).
library;

import 'notification_plan.dart';
import 'notification_service.dart';

/// Deprecated alias kept for backwards compatibility.
@Deprecated('Use NoorNotifications from notification_service.dart')
class NotificationServiceTodo {
  const NotificationServiceTodo();

  /// Delegates to the real Phase 8 scheduler. Returns how many
  /// entries were actually scheduled (0 if unsupported/denied).
  Future<int> schedulePlan(List<PlannedNotification> plan) =>
      NoorNotifications.schedulePlan(plan);
}
