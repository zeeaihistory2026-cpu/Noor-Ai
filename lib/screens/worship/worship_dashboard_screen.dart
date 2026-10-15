import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/sample_data.dart';
import '../library/dua_library_screen.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'qibla_finder_screen.dart';
import 'reminder_center_screen.dart';
import 'salah_tracker_screen.dart';
import 'zikr_tasbih_screen.dart';

/// Page 14 — Worship Dashboard. Dark skyline header (real Page 14
/// crop), quote card overlapping, Prayer Times with Zuhr next-prayer
/// dark card (countdown, short Ta-Ha excerpt as drawn, attributed),
/// 6 prayer rows with mute/bell toggles, Full Prayer Timings,
/// 8 Worship Tools, Today's Goal 75% ring with rehal crop,
/// Streak 12 / Longest 23.
class WorshipDashboardScreen extends StatefulWidget {
  const WorshipDashboardScreen({super.key});
  @override
  State<WorshipDashboardScreen> createState() => _WorshipDashboardScreenState();
}

class _WorshipDashboardScreenState extends State<WorshipDashboardScreen> {
  final List<bool> _notify = [false, false, true, false, false, false];
  static const _prayerRows = [
    ('Fajr', '5:32 AM'),
    ('Sunrise', NoorAppState.sunriseTime),
    ('Dhuhr', '12:45 PM'),
    ('Asr', '3:58 PM'),
    ('Maghrib', '5:56 PM'),
    ('Isha', '7:23 PM'),
  ];
  static const _prayerIcons = [
    Icons.wb_twilight,
    Icons.wb_sunny_outlined,
    Icons.light_mode_outlined,
    Icons.wb_cloudy_outlined,
    Icons.wb_sunny,
    Icons.nightlight_round,
  ];
  static const _toolIcons = [
    Icons.explore_outlined,
    Icons.toll_outlined,
    Icons.pan_tool_outlined,
    Icons.menu_book_outlined,
    Icons.calendar_month_outlined,
    Icons.nightlight_outlined,
    Icons.mosque_outlined,
    Icons.calculate_outlined,
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: ListView(padding: EdgeInsets.zero, children: [
          Stack(children: [
            ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
                child: Image.asset(NoorAssets.worshipHeaderSkyline,
                    cacheWidth: 1170,
                    height: 168,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (_, __, ___) =>
                        Container(height: 168, color: NoorColors.emeraldDark))),
            Positioned(
                top: 10,
                right: 14,
                child: IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ReminderCenterScreen())))),
            // No code title here: the "Worship" title is already drawn
            // into the Page 14 header artwork itself; adding one in
            // code produced a ghosted double title (Phase 11 fix).
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 118, 20, 0),
                child: NoorCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                              color: NoorColors.emeraldDark,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.format_quote,
                              color: Colors.white, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(SampleData.worshipQuote,
                                style: NoorType.secondary.copyWith(height: 1.45)),
                            const SizedBox(height: 3),
                            Text(SampleData.worshipQuoteSource,
                                style: NoorType.meta.copyWith(color: NoorColors.muted)),
                          ])),
                      const Icon(Icons.chevron_right,
                          color: NoorColors.muted, size: 19),
                    ]))),
          ]),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(
                          child: Text('Prayer Times',
                              style: NoorType.cardTitle)),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(NoorAppState.gregorianLabel,
                                style: NoorType.meta),
                            Text(NoorAppState.hijriLabel,
                                style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
                          ]),
                      const SizedBox(width: 6),
                      const Icon(Icons.calendar_month_outlined,
                          size: 20, color: NoorColors.muted),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: NoorColors.muted),
                      const SizedBox(width: 4),
                      Text(NoorAppState.locationLabel,
                          style: NoorType.meta.copyWith(color: NoorColors.mutedDark))
                    ]),
                    const SizedBox(height: 12),
                    // Next Prayer hero — tappable directly to Salah Tracker
                    Semantics(
                      button: true,
                      label: 'Next prayer: Asr at ${NoorAppState.nextPrayerTime}, tap to open Salah Tracker',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(NoorRadius.heroCard),
                          boxShadow: NoorShadows.hero,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(NoorRadius.heroCard),
                          clipBehavior: Clip.antiAlias,
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                NoorColors.emeraldDark,
                                NoorColors.emeraldMid
                              ]),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const SalahTrackerScreen())),
                              splashColor: NoorColors.gold.withValues(alpha: 0.25),
                              highlightColor: Colors.white.withValues(alpha: 0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(children: [
                                  Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: NoorColors.gold, width: 1.6)),
                                      child: const Icon(Icons.wb_sunny_outlined,
                                          color: NoorColors.gold, size: 28)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Row(
                                          children: [
                                            Text('Next Prayer',
                                                style: NoorType.meta.copyWith(
                                                    color: Colors.white70)),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.16),
                                                borderRadius: BorderRadius.circular(99),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Log',
                                                      style: NoorType.meta.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600)),
                                                  const SizedBox(width: 2),
                                                  const Icon(Icons.arrow_forward_ios,
                                                      size: 7, color: Colors.white),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text('Asr',
                                            style: NoorType.screenTitle
                                                .copyWith(color: Colors.white)),
                                        Text(NoorAppState.nextPrayerCountdownLabel,
                                            style: NoorType.secondary
                                                .copyWith(color: Colors.white)),
                                        Text(NoorAppState.nextPrayerTime,
                                            style: NoorType.meta
                                                .copyWith(color: Colors.white70)),
                                      ])),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(NoorAssets.nextPrayerMosque,
                                          width: 84,
                                          cacheWidth: 252,
                                          height: 88,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.bottomRight,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(
                                                  width: 84, height: 88))),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.white70, size: 20),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Unified Prayer Table Card with integrated Full Timings footer
                    NoorCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
                          child: Column(children: [
                            for (var i = 0; i < _prayerRows.length; i++)
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(children: [
                                    Icon(_prayerIcons[i],
                                        size: 19, color: NoorColors.amber),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(_prayerRows[i].$1,
                                            style: NoorType.body)),
                                    Text(_prayerRows[i].$2,
                                        style: NoorType.tabular(
                                            NoorType.secondary)),
                                    IconButton(
                                        tooltip: _notify[i]
                                            ? 'Reminder on'
                                            : 'Reminder off',
                                        onPressed: () => setState(
                                            () => _notify[i] = !_notify[i]),
                                        icon: Icon(
                                            _notify[i]
                                                ? Icons.notifications
                                                : Icons
                                                    .notifications_off_outlined,
                                            size: 19,
                                            color: _notify[i]
                                                ? NoorColors.emeraldDark
                                                : NoorColors.greyDisabled)),
                                  ])),
                          ]),
                        ),
                        const Divider(
                            height: 1,
                            thickness: 1,
                            color: NoorColors.hairlineSoft),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SalahTrackerScreen())),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(NoorRadius.card)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(children: [
                                Icon(Icons.calendar_month_outlined,
                                    color: NoorColors.emeraldDark, size: 19),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Text('Full Prayer Timings & Salah Log',
                                        style: NoorType.secondary)),
                                Icon(Icons.chevron_right,
                                    color: NoorColors.muted, size: 19),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 22),
                    const Text('Worship Tools',
                        style: NoorType.cardTitle),
                    const SizedBox(height: 12),
                    GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.75,
                        children: List.generate(
                            8,
                            (i) => Semantics(
                                  button: true,
                                  label: SampleData.worshipTools[i],
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      if (i == 0) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const QiblaFinderScreen()));
                                      } else if (i == 1) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ZikrTasbihScreen()));
                                      } else if (i == 2) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const DuaLibraryScreen()));
                                      } else if (i == 3) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ZikrTasbihScreen(
                                                        initialTab: 1)));
                                      } else if (i == 4) {
                                        _openIslamicCalendar(context);
                                      } else if (i == 5) {
                                        _openFastingTracker(context);
                                      } else if (i == 6) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const SalahTrackerScreen()));
                                      } else if (i == 7) {
                                        _openZakatCalculator(context);
                                      }
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color:
                                                    NoorColors.hairlineSoft)),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color:
                                                              NoorColors
                                                                  .emeraldSoft,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: Icon(_toolIcons[i],
                                                      color: NoorColors
                                                          .emeraldDark,
                                                      size: 21)),
                                              const SizedBox(height: 7),
                                              Text(SampleData.worshipTools[i],
                                                  textAlign: TextAlign.center,
                                                  style: NoorType.meta.copyWith(height: 1.2)),
                                            ])),
                                  ),
                                ))),
                    const SizedBox(height: 16),
                    GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SalahTrackerScreen())),
                        child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: NoorColors.hairlineSoft,
                            borderRadius:
                                BorderRadius.circular(NoorRadius.heroCard)),
                        child: Row(children: [
                          const SizedBox(
                              width: 62,
                              height: 62,
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                CircularProgressIndicator(
                                    value: 0.4,
                                    strokeWidth: 6,
                                    color: NoorColors.emerald,
                                    backgroundColor: NoorColors.hairlineSoft),
                                Text('40%',
                                    style: NoorType.secondary),
                              ])),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                const Text("Today's Goal",
                                    style: NoorType.cardTitle),
                                const SizedBox(height: 4),
                                Text('Keep going.\n2 of 5 prayers logged today',
                                    style: NoorType.meta.copyWith(color: NoorColors.mutedDark,
                                        height: 1.45)),
                              ])),
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(NoorAssets.quranRehal,
                                  width: 74,
                                  cacheWidth: 222,
                                  height: 68,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(width: 74, height: 68))),
                          const Icon(Icons.chevron_right,
                              color: NoorColors.muted, size: 19),
                        ]))),
                    const SizedBox(height: 16),
                    GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SalahTrackerScreen())),
                        child: Row(children: [
                      Expanded(
                          child: Column(children: [
                        Text('Streak',
                            style: NoorType.meta.copyWith(color: NoorColors.muted)),
                        const SizedBox(height: 4),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_fire_department,
                                  color: NoorColors.amber, size: 19),
                              SizedBox(width: 4),
                              Text('12',
                                  style: NoorType.screenTitle)
                            ]),
                        Text('days',
                            style: NoorType.meta.copyWith(color: NoorColors.muted))
                      ])),
                      const SizedBox(
                          height: 44,
                          child: VerticalDivider(color: NoorColors.hairlineSoft)),
                      Expanded(
                          child: Column(children: [
                        Text('Longest Streak',
                            style: NoorType.meta.copyWith(color: NoorColors.muted)),
                        const SizedBox(height: 4),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emoji_events,
                                  color: NoorColors.goldSoft, size: 19),
                              SizedBox(width: 4),
                              Text('23',
                                  style: NoorType.screenTitle)
                            ]),
                        Text('days',
                            style: NoorType.meta.copyWith(color: NoorColors.muted))
                      ])),
                      const Icon(Icons.chevron_right,
                          color: NoorColors.muted, size: 19),
                    ])),
                  ])),
        ])),
      );

  void _openIslamicCalendar(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NoorColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                  child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                          color: NoorColors.hairline,
                          borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: NoorColors.emeraldSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_month,
                        color: NoorColors.emeraldDark, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Islamic Calendar',
                            style: NoorType.cardTitle),
                        Text(NoorAppState.hijriLabel,
                            style: NoorType.meta
                                .copyWith(color: NoorColors.emeraldDark)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('KEY ISLAMIC OBSERVANCES & DATES',
                  style: NoorType.eyebrow),
              const SizedBox(height: 10),
              _calendarEventTile('15 Sha\'ban', 'Nisf Sha\'ban',
                  'Night of forgiveness and spiritual preparation for Ramadan.'),
              _calendarEventTile('1 Ramadan', 'Beginning of Ramadan',
                  'First day of the holy month of fasting and revelation.'),
              _calendarEventTile('21–29 Ramadan', 'The Last 10 Nights',
                  'Search for Laylatul Qadr (Night of Decree), better than 1,000 months.'),
              _calendarEventTile('1 Shawwal', 'Eid al-Fitr',
                  'Celebration of the completion of Ramadan fasting.'),
              _calendarEventTile('9 Dhul-Hijjah', 'Day of Arafah',
                  'The greatest day of Hajj; fasting expiates sins of two years.'),
              _calendarEventTile('10 Dhul-Hijjah', 'Eid al-Adha',
                  'Festival of Sacrifice commemorating Prophet Ibrahim’s faith.'),
              _calendarEventTile('10 Muharram', 'Day of Ashura',
                  'Fasting commemorates Allah saving Musa (AS) and Bani Israel.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarEventTile(String date, String title, String description) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NoorColors.hairlineSoft),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: NoorColors.emeraldDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: NoorType.meta.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: NoorType.cardTitle.copyWith(fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: NoorType.secondary
                          .copyWith(color: NoorColors.mutedDark, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );

  void _openFastingTracker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NoorColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                            color: NoorColors.hairline,
                            borderRadius: BorderRadius.circular(99)))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: NoorColors.emeraldSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.nightlight_round,
                          color: NoorColors.emeraldDark, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fasting Tracker',
                              style: NoorType.cardTitle),
                          Text('Suhoor & Iftar Timings',
                              style: NoorType.meta),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: NoorColors.hairlineSoft),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SUHOOR ENDS',
                                style: NoorType.eyebrow
                                    .copyWith(color: NoorColors.mutedDark)),
                            const SizedBox(height: 6),
                            const Text('05:32 AM',
                                style: NoorType.screenTitle),
                            const SizedBox(height: 2),
                            Text('Fajr Prayer',
                                style: NoorType.meta
                                    .copyWith(color: NoorColors.emeraldDark)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: NoorColors.hairlineSoft),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('IFTAR TIME',
                                style: NoorType.eyebrow
                                    .copyWith(color: NoorColors.mutedDark)),
                            const SizedBox(height: 6),
                            const Text('05:56 PM',
                                style: NoorType.screenTitle),
                            const SizedBox(height: 2),
                            Text('Maghrib Prayer',
                                style: NoorType.meta
                                    .copyWith(color: NoorColors.emeraldDark)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: NoorColors.surfaceWarm,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: NoorColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DUA AT IFTAR', style: NoorType.eyebrow.copyWith(color: NoorColors.goldDeep)),
                      const SizedBox(height: 6),
                      Text(
                        'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ',
                        textDirection: TextDirection.rtl,
                        style: NoorType.arabic(size: 18, color: NoorColors.ink),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"The thirst is gone, the veins are moistened, and the reward is confirmed, if Allah wills." (Abu Dawud)',
                        style: NoorType.secondary.copyWith(color: NoorColors.mutedDark, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openZakatCalculator(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NoorColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          double cash = 10000;
          double gold = 5000;
          double business = 2000;
          double total = cash + gold + business;
          double zakat = total * 0.025;

          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                              color: NoorColors.hairline,
                              borderRadius: BorderRadius.circular(99)))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: NoorColors.emeraldSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calculate,
                            color: NoorColors.emeraldDark, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Zakat Calculator',
                                style: NoorType.cardTitle),
                            Text('2.5% on qualifying wealth above Nisab',
                                style: NoorType.meta),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [NoorColors.emeraldDark, NoorColors.emeraldMid]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text('ESTIMATED ZAKAT DUE (2.5%)',
                            style: NoorType.eyebrow
                                .copyWith(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('\$${zakat.toStringAsFixed(2)}',
                            style: NoorType.display
                                .copyWith(fontSize: 34, color: NoorColors.gold)),
                        const SizedBox(height: 4),
                        Text('Based on \$${total.toStringAsFixed(2)} net zakatable assets',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('NISAB THRESHOLD BENCHMARK', style: NoorType.eyebrow),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: NoorColors.hairlineSoft),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: NoorColors.emerald, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nisab is the minimum wealth threshold (equal to 87.48 grams of gold or 612.36 grams of silver) held for one full lunar year (Hawl).',
                            style: NoorType.secondary
                                .copyWith(color: NoorColors.mutedDark, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
