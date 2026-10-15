import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/notification_plan.dart';
import 'package:noor_ai_companion/data/prayer_service.dart';
import 'package:noor_ai_companion/data/reminder_display.dart';

// Phase 16, Job 6 — reminders must work perfectly.
//
// Covers: the five daily prayers from prayer times (incl. the
// tomorrow-rollover fix from PHONE_RUN_FAJR_FIX.md, which must keep
// holding), the dedicated Dhikr/Zikr daily reminders (Morning +
// Evening Adhkar), Dua/Hadith/Quran daily reminders, and the
// plan -> displayed-label mapping (ReminderDisplay) the Reminder
// Center renders through.
//
// Ayah counts and clock times only — no religious text in tests.
//
// HONEST LIMIT (also noted in code): whether a notification really
// rings with the app killed or after a reboot is only provable on
// the user's phone. These tests prove the plan is correct; the
// device proves the ringing.

/// Fixed prayer day: Fajr 5:12 AM, Dhuhr 12:24 PM, Asr 4:11 PM,
/// Maghrib 6:52 PM, Isha 8:18 PM.
PrayerDay _day(int year, int month, int day) => PrayerDay(
      timings: {
        'Fajr': DateTime(year, month, day, 5, 12),
        'Sunrise': DateTime(year, month, day, 6, 36),
        'Dhuhr': DateTime(year, month, day, 12, 24),
        'Asr': DateTime(year, month, day, 16, 11),
        'Maghrib': DateTime(year, month, day, 18, 52),
        'Isha': DateTime(year, month, day, 20, 18),
      },
      hijriDisplay: 'test',
      source: PrayerSource.sample,
    );

/// All toggles on (an absent key means "on", matching the app).
const Map<String, bool> _allOn = {};

void main() {
  group('Phase 16 Job 6 — Salah planning', () {
    test('lead time contract: Salah reminders fire 15 minutes before',
        () {
      expect(NotificationPlan.salahLeadMinutes, 15);
    });

    test('afternoon plan rolls Fajr into tomorrow (Fajr fix holds)', () {
      final today = _day(2026, 10, 13);
      final tomorrow = _day(2026, 10, 14);
      final now = DateTime(2026, 10, 13, 16, 0); // 4 PM
      final plan = NotificationPlan.buildFullPlan(
        day: today,
        nextDay: tomorrow,
        toggles: _allOn,
        now: now,
      );
      final fajr = plan.where((p) => p.prayerName == 'Fajr').toList();
      expect(fajr, hasLength(1));
      expect(fajr.single.scheduledAt,
          DateTime(2026, 10, 14, 4, 57)); // tomorrow Fajr - 15 min
      expect(fajr.single.scheduledAt.isAfter(now), isTrue);
    });

    test('midnight rollover: just after midnight plans today\'s Fajr', () {
      final today = _day(2026, 10, 14);
      final tomorrow = _day(2026, 10, 15);
      final now = DateTime(2026, 10, 14, 0, 30);
      final plan = NotificationPlan.buildFullPlan(
        day: today,
        nextDay: tomorrow,
        toggles: _allOn,
        now: now,
      );
      // Nothing may be scheduled in the past.
      expect(plan.every((p) => !p.scheduledAt.isBefore(now)), isTrue);
      // Today's Fajr (the new day's) must be in the plan.
      final fajrToday = plan.where((p) =>
          p.prayerName == 'Fajr' &&
          p.scheduledAt == DateTime(2026, 10, 14, 4, 57));
      expect(fajrToday, hasLength(1));
      // Both days are future at 00:30, so tomorrow's Fajr is planned
      // too — intentional 48h coverage (distinct dates, stable ids),
      // not a duplicate.
      final fajrAll = plan.where((p) => p.prayerName == 'Fajr').toList();
      expect(fajrAll, hasLength(2));
      expect(
        fajrAll.map((p) => p.scheduledAt).toSet(),
        {DateTime(2026, 10, 14, 4, 57), DateTime(2026, 10, 15, 4, 57)},
      );
    });

    test('after Isha the next Salah entry is tomorrow\'s Fajr', () {
      final today = _day(2026, 10, 13);
      final tomorrow = _day(2026, 10, 14);
      final now = DateTime(2026, 10, 13, 23, 0); // after Isha
      final plan = NotificationPlan.buildFullPlan(
        day: today,
        nextDay: tomorrow,
        toggles: _allOn,
        now: now,
      );
      final salah = plan.where((p) => p.group == 'Salah').toList();
      // None of today's (all past) may survive...
      expect(
          salah.every((p) => p.scheduledAt.day == 14), isTrue);
      // ...and tomorrow's full set is there, starting with Fajr.
      final fajr = salah.where((p) => p.prayerName == 'Fajr').toList();
      expect(fajr, hasLength(1));
      expect(fajr.single.scheduledAt, DateTime(2026, 10, 14, 4, 57));
      final dhuhr = salah.where((p) => p.prayerName == 'Dhuhr').toList();
      expect(dhuhr, hasLength(1));
      expect(dhuhr.single.scheduledAt, DateTime(2026, 10, 14, 12, 9));
    });

    test('a switched-off prayer is never planned', () {
      final today = _day(2026, 10, 13);
      final plan = NotificationPlan.buildFullPlan(
        day: today,
        nextDay: _day(2026, 10, 14),
        toggles: const {'Fajr': false},
        now: DateTime(2026, 10, 13, 4, 0),
      );
      expect(plan.where((p) => p.prayerName == 'Fajr'), isEmpty);
      expect(plan.where((p) => p.prayerName == 'Dhuhr'), isNotEmpty);
    });
  });

  group('Phase 16 Job 6 — Dhikr and daily reminders', () {
    test('Morning/Evening Adhkar fire daily and roll to tomorrow', () {
      // 8 PM: both adhkar times are past -> tomorrow's entries.
      final plan = NotificationPlan.buildFixedPlan(
        toggles: _allOn,
        now: DateTime(2026, 10, 13, 20, 0),
      );
      final morning =
          plan.where((p) => p.prayerName == 'Morning Adhkar').toList();
      final evening =
          plan.where((p) => p.prayerName == 'Evening Adhkar').toList();
      expect(morning, hasLength(1));
      expect(evening, hasLength(1));
      expect(morning.single.scheduledAt, DateTime(2026, 10, 14, 7, 0));
      expect(evening.single.scheduledAt, DateTime(2026, 10, 14, 18, 20));
    });

    test('Dua of the Day, Hadith of the Day and Quran fire daily', () {
      final plan = NotificationPlan.buildFixedPlan(
        toggles: _allOn,
        now: DateTime(2026, 10, 13, 20, 0),
      );
      for (final label in ['Dua of the Day', 'Hadith of the Day', 'Quran']) {
        final entries = plan.where((p) => p.prayerName == label).toList();
        expect(entries, hasLength(1), reason: label);
        expect(entries.single.scheduledAt.isAfter(DateTime(2026, 10, 13, 20, 0)),
            isTrue,
            reason: label);
      }
    });

    test('a switched-off daily reminder is never planned', () {
      final plan = NotificationPlan.buildFixedPlan(
        toggles: const {'Morning Adhkar': false},
        now: DateTime(2026, 10, 13, 6, 0),
      );
      expect(plan.where((p) => p.prayerName == 'Morning Adhkar'), isEmpty);
      expect(plan.where((p) => p.prayerName == 'Evening Adhkar'), isNotEmpty);
    });
  });

  group('Phase 16 Job 6 — plan -> displayed labels', () {
    test('Salah entry maps to its actual time + lead text', () {
      final plan = NotificationPlan.buildFullPlan(
        day: _day(2026, 10, 13),
        nextDay: _day(2026, 10, 14),
        toggles: _allOn,
        now: DateTime(2026, 10, 13, 4, 0),
      );
      final entry = ReminderDisplay.entryFor(plan, 'Fajr');
      expect(entry, isNotNull);
      // What the Reminder Center shows must equal the plan output.
      expect(ReminderDisplay.clockLabel(entry!.scheduledAt), '4:57 AM');
      expect(entry.scheduledAt, DateTime(2026, 10, 13, 4, 57));
      expect(ReminderDisplay.leadLabelFor(entry), '15 min before');
    });

    test('Worship entry maps to its actual time + "At time"', () {
      final plan = NotificationPlan.buildFixedPlan(
        toggles: _allOn,
        now: DateTime(2026, 10, 13, 4, 0),
      );
      final entry = ReminderDisplay.entryFor(plan, 'Morning Adhkar');
      expect(entry, isNotNull);
      expect(ReminderDisplay.clockLabel(entry!.scheduledAt), '7:00 AM');
      expect(ReminderDisplay.leadLabelFor(entry), 'At time');
    });

    test('switched-off row has no entry to display', () {
      final plan = NotificationPlan.buildFixedPlan(
        toggles: const {'Dua of the Day': false},
        now: DateTime(2026, 10, 13, 4, 0),
      );
      expect(ReminderDisplay.entryFor(plan, 'Dua of the Day'), isNull);
    });

    test('clockLabel shapes match the app\'s 12-hour style', () {
      expect(ReminderDisplay.clockLabel(DateTime(2026, 1, 1, 0, 5)), '12:05 AM');
      expect(ReminderDisplay.clockLabel(DateTime(2026, 1, 1, 12, 0)), '12:00 PM');
      expect(ReminderDisplay.clockLabel(DateTime(2026, 1, 1, 23, 59)), '11:59 PM');
    });
  });
}
