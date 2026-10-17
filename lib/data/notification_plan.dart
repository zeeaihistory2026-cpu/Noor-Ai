import 'daily_content_service.dart';
import 'prayer_service.dart';
import 'sample_data.dart';

/// Phase 6 — PURE Dart notification planning for Page 31.
///
/// This file contains only logic: given prayer times and the
/// user's Page 31 toggles, it computes WHAT would be scheduled
/// (the plan). It deliberately does not schedule anything — real
/// scheduling needs `flutter_local_notifications` plus Android/iOS
/// native setup, which cannot be verified in this environment.
/// Notification scheduling is handled via `NotificationService`.
/// Nothing here may be described as "reminders are scheduled"
/// until that wiring exists and is device-tested.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.group,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.prayerName,
  });

  /// Stable id (hash of group+prayer+date) for cancel/replace.
  final int id;
  final String group; // 'Salah' | 'Worship' | 'Daily Content'
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String prayerName;

  @override
  String toString() => 'PlannedNotification($group/$prayerName @ $scheduledAt)';
}

class NotificationPlan {
  NotificationPlan._();

  /// Minutes before each prayer the Salah reminder would fire.
  /// Page 35 shows "Fajr begins in 15 minutes", hence 15.
  static const int salahLeadMinutes = 15;

  /// Builds the Salah plan for one day: one entry per obligatory
  /// prayer whose Page 31 toggle is on, at prayer time minus
  /// [salahLeadMinutes]. Entries already in the past are dropped,
  /// except when [includePast] is set (planning/debug views).
  static List<PlannedNotification> buildSalahPlan({
    required PrayerDay day,
    required Map<String, bool> toggles,
    DateTime? now,
    bool includePast = false,
  }) {
    final n = now ?? DateTime.now();
    final out = <PlannedNotification>[];
    const obligatory = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final name in obligatory) {
      if (toggles[name] == false) continue;
      final at = day.timings[name] ?? (name == 'Dhuhr' ? day.timings['Zuhr'] : null);
      if (at == null) continue;
      final displayName = (name == 'Dhuhr') ? 'Zuhr' : name;
      final when = at.subtract(const Duration(minutes: salahLeadMinutes));
      if (!includePast && when.isBefore(n)) continue;
      out.add(PlannedNotification(
        id: _stableId('salah', name, at),
        group: 'Salah',
        title: '$displayName reminder',
        body: '$displayName begins in $salahLeadMinutes minutes.',
        scheduledAt: when,
        prayerName: name,
      ));
    }
    out.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return out;
  }

  /// Builds Worship + Daily Content entries from Page 31's fixed
  /// clock times (SampleData rows), honouring toggles by label.
  /// Times are placed on [date] (default: today; rolls to tomorrow
  /// if already past and [includePast] is false).
  static List<PlannedNotification> buildFixedPlan({
    required Map<String, bool> toggles,
    DateTime? date,
    DateTime? now,
    bool includePast = false,
  }) {
    final n = now ?? DateTime.now();
    final base = date ?? DateTime(n.year, n.month, n.day);
    final out = <PlannedNotification>[];

    void addGroup(String group, List<(String, String)> rows) {
      for (final r in rows) {
        if (toggles[r.$1] == false) continue;
        final t = _parseClock(r.$2, base);
        if (t == null) continue;
        var when = t;
        if (!includePast && when.isBefore(n)) {
          when = when.add(const Duration(days: 1));
        }
        out.add(PlannedNotification(
          id: _stableId(group, r.$1, when),
          group: group,
          title: r.$1,
          body: switch (r.$1) {
            'Ayat of the Day' =>
              '${DailyContentService.getAyahOfDay(when).title}: ${DailyContentService.getAyahOfDay(when).translation}',
            'Hadith of the Day' =>
              '${DailyContentService.getHadithOfDay(when).title}: ${DailyContentService.getHadithOfDay(when).translation}',
            'Dua of the Day' =>
              '${DailyContentService.getDuaOfDay(when).title}: ${DailyContentService.getDuaOfDay(when).translation}',
            'Daily Zikr & Tasbih' =>
              'Take a mindful pause for dhikr and remembrance of Allah.',
            'Morning Adhkar' =>
              'Start your morning with peace through remembrance of Allah.',
            'Evening Adhkar' =>
              'Evening supplications and adhkar for tranquility.',
            _ => group == 'Worship' ? 'Time for ${r.$1}.' : 'Your ${r.$1} is ready.',
          },
          scheduledAt: when,
          prayerName: r.$1,
        ));
      }
    }

    addGroup('Worship', SampleData.reminderWorship);
    addGroup('Daily Content', SampleData.reminderDaily);
    out.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return out;
  }

  /// Full Page 31 plan for [day]: Salah + fixed groups, sorted.
  ///
  /// When [nextDay] is supplied, its Salah entries are included too.
  /// This matters: without it, a Fajr reminder switched on in the
  /// afternoon can never fire the next morning, because today's Fajr
  /// is already past and gets dropped by [buildSalahPlan].
  static List<PlannedNotification> buildFullPlan({
    required PrayerDay day,
    required Map<String, bool> toggles,
    DateTime? now,
    bool includePast = false,
    PrayerDay? nextDay,
  }) {
    final all = <PlannedNotification>[
      ...buildSalahPlan(
          day: day, toggles: toggles, now: now, includePast: includePast),
      if (nextDay != null)
        ...buildSalahPlan(
            day: nextDay, toggles: toggles, now: now, includePast: includePast),
      ...buildFixedPlan(toggles: toggles, now: now, includePast: includePast),
    ];
    all.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return all;
  }

  // ---- helpers --------------------------------------------------------

  /// Parses '5:07 AM' style labels from SampleData onto [day].
  static DateTime? _parseClock(String label, DateTime day) {
    final match = RegExp(r'(\d+):(\d+)\s*(AM|PM)').firstMatch(label);
    if (match == null) return null;
    var h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final pm = match.group(3) == 'PM';
    if (pm && h != 12) h += 12;
    if (!pm && h == 12) h = 0;
    return DateTime(day.year, day.month, day.day, h, m);
  }

  static int _stableId(String group, String name, DateTime at) {
    final s = '$group|$name|${at.year}-${at.month}-${at.day}';
    var hash = 0;
    for (final code in s.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }
}
