import 'notification_plan.dart';

/// Phase 16 — maps [NotificationPlan] output to the exact strings the
/// Reminder Center (Page 31) shows.
///
/// "Scheduled times must equal plan output" holds by construction:
/// the screen renders each row's time through [entryFor] +
/// [clockLabel], never from a second, possibly stale, source.
/// Pure Dart, so the mapping itself is unit-testable
/// (test/phase16_reminders_test.dart).
class ReminderDisplay {
  ReminderDisplay._();

  /// The five Salah row labels, in prayer order.
  static const List<String> salahLabels = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  /// '4:56 AM' — the same 12-hour shape the rest of the app uses
  /// (see PrayerService.formatTime).
  static String clockLabel(DateTime at) {
    final h12 = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final mm = at.minute.toString().padLeft(2, '0');
    return '$h12:$mm ${at.hour >= 12 ? 'PM' : 'AM'}';
  }

  /// Lead text under each row label, as drawn on Page 31:
  /// Salah rows ring [NotificationPlan.salahLeadMinutes] before the
  /// prayer; Worship / Daily Content rows ring at the shown time.
  static String leadLabelFor(PlannedNotification entry) =>
      entry.group == 'Salah'
          ? '${NotificationPlan.salahLeadMinutes} min before'
          : 'At time';

  /// True for the five Salah row labels.
  static bool isSalahLabel(String label) => salahLabels.contains(label);

  /// The plan entry a Page 31 row with [label] actually rings on:
  /// the earliest (plan lists are ascending) entry for that row, or
  /// null when the row is switched off or has no future entry.
  static PlannedNotification? entryFor(
    List<PlannedNotification> plan,
    String label,
  ) {
    for (final e in plan) {
      if (e.group == 'Salah') {
        if (e.prayerName == label) return e;
      } else if (e.title == label) {
        return e;
      }
    }
    return null;
  }
}
