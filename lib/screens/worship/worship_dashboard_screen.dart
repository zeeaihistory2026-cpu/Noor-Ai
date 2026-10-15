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
                    Container(
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              NoorColors.emeraldDark,
                              NoorColors.emeraldMid
                            ]),
                            borderRadius:
                                BorderRadius.circular(NoorRadius.heroCard),
                            boxShadow: NoorShadows.hero),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Next Prayer',
                                    style: NoorType.meta.copyWith(color: Colors.white70)),
                                Text('Asr',
                                    style: NoorType.screenTitle.copyWith(color: Colors.white)),
                                Text(NoorAppState.nextPrayerCountdownLabel,
                                    style: NoorType.secondary.copyWith(color: Colors.white)),
                                Text(NoorAppState.nextPrayerTime,
                                    style: NoorType.meta.copyWith(color: Colors.white70)),
                              ])),

                          // No zoom transform (Phase 11b): scale 1.38 pushed
                          // the dome out of the thumb box. Cover anchored
                          // bottom-right keeps dome + minaret inside.
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(NoorAssets.nextPrayerMosque,
                                  width: 84,
                                  cacheWidth: 252,
                                  height: 88,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.bottomRight,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(width: 84, height: 88))),
                          const Icon(Icons.chevron_right,
                              color: Colors.white70, size: 20),
                        ])),
                    const SizedBox(height: 10),
                    NoorCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: Column(children: [
                        for (var i = 0; i < _prayerRows.length; i++)
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(children: [
                                Icon(_prayerIcons[i],
                                    size: 19, color: NoorColors.amber),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(_prayerRows[i].$1,
                                        style: NoorType.body)),
                                Text(_prayerRows[i].$2,
                                    style: NoorType.tabular(NoorType.secondary)),
                                IconButton(
                                    tooltip: _notify[i]
                                        ? 'Reminder on'
                                        : 'Reminder off',
                                    onPressed: () => setState(
                                        () => _notify[i] = !_notify[i]),
                                    icon: Icon(
                                        _notify[i]
                                            ? Icons.notifications
                                            : Icons.notifications_off_outlined,
                                        size: 19,
                                        color: _notify[i]
                                            ? NoorColors.emeraldDark
                                            : NoorColors.greyDisabled)),
                              ])),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SalahTrackerScreen())),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: NoorColors.hairlineSoft)),
                                child: const Row(children: [
                                  Icon(Icons.calendar_month_outlined,
                                      color: NoorColors.emeraldDark, size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                      child: Text('Full Prayer Timings',
                                          style: NoorType.secondary)),
                                  Icon(Icons.chevron_right,
                                      color: NoorColors.muted, size: 19)
                                ])))),
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
                                      } else if (i == 2 || i == 3) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const DuaLibraryScreen()));
                                      } else if (i == 6) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const SalahTrackerScreen()));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    '${SampleData.worshipTools[i]} is coming soon')));
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
}
