import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../data/location_service.dart';
import '../../data/noor_controller.dart';
import '../../data/noor_store.dart';
import '../../data/prayer_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 10 P1/P2 — Ramadan & Fasting Tracker:
/// Live Suhoor/Iftar timings from PrayerDay, Ramadan countdown, persisted
/// daily fasting log, Qada fasts counter, Sunnah fasts guide, and Duas.
class FastingRamadanScreen extends StatefulWidget {
  const FastingRamadanScreen({super.key});

  @override
  State<FastingRamadanScreen> createState() => _FastingRamadanScreenState();
}

class _FastingRamadanScreenState extends State<FastingRamadanScreen> {
  Set<String> _fastedDates = <String>{};
  int _qadaFasts = 0;
  int _hijriOffset = 0;

  String get _todayKey => DateTime.now().toIso8601String().split('T').first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await NoorStore.getFastingDates();
    final qada = await NoorStore.getQadaFasts();
    final offset = await NoorStore.getHijriOffsetDays();
    if (mounted) {
      setState(() {
        _fastedDates = dates;
        _qadaFasts = qada;
        _hijriOffset = offset;
      });
    }
  }

  Future<void> _toggleToday() async {
    await NoorStore.toggleFastingDate(_todayKey);
    await _load();
  }

  Future<void> _adjustQada(int delta) async {
    final next = (_qadaFasts + delta).clamp(0, 999);
    setState(() => _qadaFasts = next);
    await NoorStore.setQadaFasts(next);
  }

  int _daysUntilRamadan(DateTime base) {
    final adjusted = base.add(Duration(days: _hijriOffset));
    final h = HijriCalendar.fromDate(adjusted);
    if (h.hMonth == 9) return 0;
    for (var i = 1; i <= 360; i++) {
      final candidate = HijriCalendar.fromDate(adjusted.add(Duration(days: i)));
      if (candidate.hMonth == 9 && candidate.hDay == 1) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final loc = controller?.currentLocation ?? LocationModel.defaultLocation;
    final day = controller?.activeDay ??
        PrayerService.calculateOffline(
          location: loc,
          date: PrayerService.nowInLocation(loc),
        );
    final fajr = day.timings['Fajr'];
    final maghrib = day.timings['Maghrib'];
    final now = PrayerService.nowInLocation(loc);
    final adjusted = now.add(Duration(days: _hijriOffset));
    final hijri = HijriCalendar.fromDate(adjusted);
    final isRamadan = hijri.hMonth == 9;
    final daysToRamadan = _daysUntilRamadan(now);
    final fastedToday = _fastedDates.contains(_todayKey);
    final isWhiteDay = hijri.hDay >= 13 && hijri.hDay <= 15;
    final isSunnahDay = now.weekday == DateTime.monday ||
        now.weekday == DateTime.thursday ||
        isWhiteDay;

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            NoorDarkHeader(
              title: 'Ramadan & Fasting',
              subtitle:
                  '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH • ${loc.label}',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  NoorCard(
                    color: NoorColors.emeraldDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRamadan
                              ? 'RAMADAN MUBARAK'
                              : 'RAMADAN COUNTDOWN',
                          style: NoorType.eyebrow
                              .copyWith(color: NoorColors.onEmeraldMuted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isRamadan
                              ? 'Day ${hijri.hDay} of Ramadan'
                              : '$daysToRamadan days remaining',
                          style: NoorType.tabular(NoorType.screenTitle
                              .copyWith(color: NoorColors.gold)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isRamadan
                              ? (hijri.hDay >= 21
                                  ? 'Last ten nights — seek Laylat al-Qadr in odd nights.'
                                  : 'Make intention before Fajr and keep daily Quran & dua goals.')
                              : isWhiteDay
                                  ? 'Today is one of the White Days (13–15 ${hijri.longMonthName}) — Sunnah fasting recommended.'
                                  : isSunnahDay
                                      ? 'Monday/Thursday Sunnah fasting day.'
                                      : 'Dates reflect your Hijri calendar offset (${_hijriOffset >= 0 ? '+$_hijriOffset' : '$_hijriOffset'}d).',
                          style: NoorType.secondary
                              .copyWith(color: NoorColors.onEmeraldMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: NoorCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SUHOOR ENDS',
                                  style: NoorType.eyebrow.copyWith(
                                      color: NoorTheme.muted(context))),
                              const SizedBox(height: 6),
                              Text(
                                fajr == null
                                    ? 'Unavailable'
                                    : PrayerService.formatTime(fajr),
                                style: NoorType.tabular(NoorType.screenTitle),
                              ),
                              const SizedBox(height: 4),
                              Text('Fajr time',
                                  style: NoorType.meta.copyWith(
                                      color: NoorTheme.muted(context))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NoorCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('IFTAR TIME',
                                  style: NoorType.eyebrow.copyWith(
                                      color: NoorTheme.muted(context))),
                              const SizedBox(height: 6),
                              Text(
                                maghrib == null
                                    ? 'Unavailable'
                                    : PrayerService.formatTime(maghrib),
                                style: NoorType.tabular(NoorType.screenTitle),
                              ),
                              const SizedBox(height: 4),
                              Text('Maghrib time',
                                  style: NoorType.meta.copyWith(
                                      color: NoorTheme.muted(context))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Today’s Fast',
                                      style: NoorType.cardTitle),
                                  const SizedBox(height: 4),
                                  Text(
                                    fastedToday
                                        ? 'Marked complete for today (${_fastedDates.length} total logged).'
                                        : 'Log today’s Ramadan or Sunnah fast (${_fastedDates.length} logged).',
                                    style: NoorType.meta.copyWith(
                                        color: NoorTheme.muted(context)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _toggleToday,
                              icon: Icon(fastedToday
                                  ? Icons.check_circle
                                  : Icons.add_circle_outline),
                              label: Text(fastedToday ? 'Fasted' : 'Log Fast'),
                            ),
                          ],
                        ),
                        Divider(
                            height: 24, color: NoorTheme.softBorder(context)),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Missed Fasts (Qada)',
                                      style: NoorType.cardTitle),
                                  const SizedBox(height: 2),
                                  Text('Track days remaining to make up.',
                                      style: NoorType.meta.copyWith(
                                          color: NoorTheme.muted(context))),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Decrease missed fasts',
                              onPressed: _qadaFasts > 0
                                  ? () => _adjustQada(-1)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$_qadaFasts',
                                textAlign: TextAlign.center,
                                style: NoorType.tabular(NoorType.cardTitle),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Increase missed fasts',
                              onPressed: () => _adjustQada(1),
                              icon: Icon(Icons.add_circle_outline,
                                  color: NoorTheme.accent(context)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    color: NoorTheme.warmSurface(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DUA AT IFTAR',
                            style: NoorType.eyebrow
                                .copyWith(color: NoorTheme.accent(context))),
                        const SizedBox(height: 10),
                        Text(
                          'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ',
                          textDirection: TextDirection.rtl,
                          style: NoorType.arabic(
                            size: 21,
                            color: NoorTheme.foreground(context,
                                light: NoorColors.emeraldDark),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '"The thirst is gone, the veins are moistened, and the reward is confirmed, if Allah wills."',
                          style: NoorType.body,
                        ),
                        const SizedBox(height: 4),
                        Text('Sunan Abi Dawud 2357',
                            style: NoorType.meta
                                .copyWith(color: NoorTheme.accent(context))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Recommended Sunnah Fasts'),
                        const SizedBox(height: 10),
                        _sunnahRow(context, 'Mondays & Thursdays',
                            'Weekly Sunnah days when deeds are presented.'),
                        Divider(
                            height: 18, color: NoorTheme.softBorder(context)),
                        _sunnahRow(context, 'White Days (13, 14, 15 Hijri)',
                            'Three bright-moon days every lunar month.'),
                        Divider(
                            height: 18, color: NoorTheme.softBorder(context)),
                        _sunnahRow(context, 'Six Days of Shawwal',
                            'Six voluntary fasts after Eid al-Fitr.'),
                        Divider(
                            height: 18, color: NoorTheme.softBorder(context)),
                        _sunnahRow(context, 'Day of Arafah & Ashura',
                            '9 Dhul-Hijjah and 9–10 Muharram.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sunnahRow(BuildContext context, String title, String detail) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: NoorType.cardTitle),
          const SizedBox(height: 2),
          Text(detail,
              style: NoorType.meta.copyWith(color: NoorTheme.muted(context))),
        ],
      );
}

