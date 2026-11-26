import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../data/app_state.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 11 P1/P2 — Islamic Calendar, Moon-Sighting Adjustment (-2..+2),
/// Hijri ↔ Gregorian Date Converter, White Days, and Live Occasion Countdowns.
class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  int _offsetDays = 0;
  DateTime _selectedGregorian = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadOffset();
  }

  Future<void> _loadOffset() async {
    final offset = await NoorStore.getHijriOffsetDays();
    if (mounted) setState(() => _offsetDays = offset);
  }

  Future<void> _setOffset(int days) async {
    final clamped = days.clamp(-2, 2);
    setState(() => _offsetDays = clamped);
    await NoorStore.setHijriOffsetDays(clamped);
  }

  HijriCalendar _hijriFor(DateTime gregorian) =>
      HijriCalendar.fromDate(gregorian.add(Duration(days: _offsetDays)));

  int _daysUntilHijri(int hMonth, int hDay) {
    final base = DateTime.now();
    for (var i = 0; i <= 365; i++) {
      final h = _hijriFor(base.add(Duration(days: i)));
      if (h.hMonth == hMonth && h.hDay == hDay) return i;
    }
    return 0;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedGregorian,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedGregorian = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayHijri = _hijriFor(today);
    final convertedHijri = _hijriFor(_selectedGregorian);
    final isWhiteDay = todayHijri.hDay >= 13 && todayHijri.hDay <= 15;

    final occasions = [
      (1, 1, 'Islamic New Year', '1 Muharram • Beginning of Hijri year'),
      (1, 10, 'Day of Ashura', '10 Muharram • Recommended fast'),
      (8, 15, 'Nisf Sha’ban', '15 Sha’ban • Mid-Sha’ban night'),
      (9, 1, 'First of Ramadan', '1 Ramadan • Month of fasting & Quran'),
      (9, 21, 'Last 10 Nights', '21–29 Ramadan • Seek Laylat al-Qadr'),
      (10, 1, 'Eid al-Fitr', '1 Shawwal • Festival of Breaking Fast'),
      (12, 9, 'Day of Arafah', '9 Dhul-Hijjah • Peak day of Hajj'),
      (12, 10, 'Eid al-Adha', '10 Dhul-Hijjah • Festival of Sacrifice'),
    ];

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            NoorDarkHeader(
              title: 'Islamic Calendar',
              subtitle:
                  '${todayHijri.hDay} ${todayHijri.longMonthName} ${todayHijri.hYear} AH',
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
                        Text('TODAY',
                            style: NoorType.eyebrow
                                .copyWith(color: NoorColors.onEmeraldMuted)),
                        const SizedBox(height: 8),
                        Text(
                          '${todayHijri.hDay} ${todayHijri.longMonthName} ${todayHijri.hYear} AH',
                          style: NoorType.tabular(NoorType.screenTitle
                              .copyWith(color: NoorColors.gold)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NoorAppState.formatGregorian(today),
                          style: NoorType.body
                              .copyWith(color: Colors.white),
                        ),
                        if (isWhiteDay) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius:
                                  BorderRadius.circular(NoorRadius.chip),
                            ),
                            child: Text(
                              'White Day (${todayHijri.hDay} ${todayHijri.longMonthName}) — Sunnah fast',
                              style: NoorType.meta.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Moon Sighting Adjustment'),
                        const SizedBox(height: 6),
                        Text(
                          'Shift Hijri dates by -2 to +2 days to match your local Hilal announcement.',
                          style: NoorType.meta
                              .copyWith(color: NoorTheme.muted(context)),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final d in const [-2, -1, 0, 1, 2])
                              ChoiceChip(
                                label: Text(d == 0
                                    ? 'Standard (0d)'
                                    : d > 0
                                        ? '+$d day'
                                        : '$d day'),
                                selected: _offsetDays == d,
                                onSelected: (_) => _setOffset(d),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Date Converter'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    NoorAppState.formatGregorian(
                                        _selectedGregorian),
                                    style: NoorType.cardTitle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${convertedHijri.hDay} ${convertedHijri.longMonthName} ${convertedHijri.hYear} AH',
                                    style: NoorType.tabular(NoorType.secondary
                                        .copyWith(
                                            color: NoorTheme.accent(context))),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined,
                                  size: 18),
                              label: const Text('Pick Date'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const NoorSectionLabel('Upcoming Islamic Occasions'),
                  const SizedBox(height: 10),
                  for (final occ in occasions) ...[
                    Builder(builder: (context) {
                      final daysLeft = _daysUntilHijri(occ.$1, occ.$2);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NoorCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: NoorColors.emeraldDark,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  daysLeft == 0 ? 'Today' : '${daysLeft}d',
                                  style: NoorType.tabular(NoorType.meta
                                      .copyWith(color: NoorColors.gold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(occ.$3, style: NoorType.cardTitle),
                                    const SizedBox(height: 2),
                                    Text(occ.$4,
                                        style: NoorType.meta.copyWith(
                                            color: NoorTheme.muted(context))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

