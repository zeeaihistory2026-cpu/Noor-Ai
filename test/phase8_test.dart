import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/notification_plan.dart';
import 'package:noor_ai_companion/data/notification_service.dart';
import 'package:noor_ai_companion/data/prayer_service.dart';

void main() {
  test('Phase 8 — NotificationPlan builds Salah reminders at prayer-15min',
      () {
    final day = PrayerDay.sample();
    final plan = NotificationPlan.buildSalahPlan(
      day: day,
      toggles: const {},
      includePast: true,
    );
    expect(plan.length, 5);
    expect(
      plan.first.scheduledAt,
      day.timings['Fajr']!.subtract(const Duration(minutes: 15)),
    );
    expect(plan.first.group, 'Salah');
  });

  test('Phase 8 — full plan rolls Salah reminders into tomorrow', () {
    // Regression test for the phone-run trap: Fajr switched on in the
    // afternoon must still be scheduled for tomorrow morning.
    final today = PrayerDay.sample();
    final tomorrowTimings = {
      for (final e in today.timings.entries)
        e.key: e.value.add(const Duration(days: 1)),
    };
    final tomorrow = PrayerDay(
      timings: tomorrowTimings,
      hijriDisplay: today.hijriDisplay,
      source: today.source,
    );
    final lateAfternoon = DateTime(
      today.timings['Fajr']!.year,
      today.timings['Fajr']!.month,
      today.timings['Fajr']!.day,
      16,
    );
    final plan = NotificationPlan.buildFullPlan(
      day: today,
      nextDay: tomorrow,
      toggles: const {},
      now: lateAfternoon,
    );
    final fajrEntries = plan.where((p) => p.prayerName == 'Fajr').toList();
    expect(fajrEntries, hasLength(1));
    expect(
      fajrEntries.single.scheduledAt,
      tomorrowTimings['Fajr']!.subtract(const Duration(minutes: 15)),
    );
    expect(fajrEntries.single.scheduledAt.isAfter(lateAfternoon), isTrue);
  });

  test('Phase 8 — notifications facade degrades gracefully on this host',
      () async {
    // Widget/unit tests run without a device notification service:
    // the facade must never throw, whatever it resolves to here.
    final ready = await NoorNotifications.ensureReady();
    expect(ready, isA<bool>());
    final count = await NoorNotifications.schedulePlan(const []);
    expect(count, 0);
  });
}
