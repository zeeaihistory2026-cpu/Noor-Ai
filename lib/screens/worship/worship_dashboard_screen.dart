import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/sample_data.dart';
import '../library/dua_library_screen.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../data/location_service.dart';
import '../../data/noor_controller.dart';
import '../../data/prayer_service.dart';
import '../../data/noor_store.dart';
import 'qibla_finder_screen.dart';
import 'reminder_center_screen.dart';
import 'salah_tracker_screen.dart';
import 'zikr_tasbih_screen.dart';
import '../quran/quran_reader_screen.dart';
import 'fasting_ramadan_screen.dart';
import 'islamic_calendar_screen.dart';
import 'zakat_calculator_screen.dart';

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
  int _prayersToday = 0;
  int _streak = 0;
  int _longest = 0;

  @override
  void initState() {
    super.initState();
    NoorStore.progressRevision.addListener(_loadProgress);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final now = DateTime.now();
    final done =
        await NoorStore.getPrayersList(now.toIso8601String().split('T').first);
    final dates = await NoorStore.completedSalahDates();
    final sorted = dates.map(DateTime.parse).toList()..sort();
    int longest = 0, run = 0;
    DateTime? previous;
    for (final date in sorted) {
      run = previous != null &&
              DateTime.utc(date.year, date.month, date.day)
                      .difference(DateTime.utc(
                          previous.year, previous.month, previous.day))
                      .inDays ==
                  1
          ? run + 1
          : 1;
      if (run > longest) longest = run;
      previous = date;
    }
    if (mounted) {
      setState(() {
        _prayersToday = done.where((v) => v).length;
        _streak = NoorStore.streakForDates(dates);
        _longest = longest;
      });
    }
  }

  @override
  void dispose() {
    NoorStore.progressRevision.removeListener(_loadProgress);
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final prayerDay = controller?.activeDay ??
        PrayerService.calculateOffline(
            location: LocationModel.defaultLocation,
            date: PrayerService.nowInLocation(LocationModel.defaultLocation));
    final nextPrayer = controller?.nextPrayer ?? prayerDay.nextPrayer();
    final locationLabel =
        controller?.locationLabel ?? LocationModel.defaultLocation.label;

    final nextName = nextPrayer.displayName;
    final nextRemaining = nextPrayer.remainingLabel;
    final nextTime = nextPrayer.timeLabel;
    final effectivePrayerRows = [
      for (final name in PrayerService.prayerOrder)
        (
          name,
          prayerDay.timings[name] == null
              ? 'Unavailable'
              : PrayerService.formatTime(prayerDay.timings[name]!)
        ),
    ];

    return Scaffold(
      backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
      body: SafeArea(
          child: ListView(padding: EdgeInsets.zero, children: [
        Stack(children: [
          ExcludeSemantics(
              child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28)),
                  child: Image.asset(NoorAssets.worshipHeaderSkyline,
                  cacheWidth: 1170,
                  height: 168,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 168, color: NoorColors.emeraldDark)))),
          Positioned(
              top: 10,
              right: 14,
              child: IconButton(
                  tooltip: 'Notifications',
                  icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.black38, shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none,
                          color: Colors.white)),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ReminderCenterScreen())))),
          // No code title here: the "Worship" title is already drawn
          // into the Page 14 header artwork itself; adding one in
          // code produced a ghosted double title (Phase 11 fix).
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 118, 20, 0),
              child: NoorCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const QuranReaderScreen(
                          surah: 20, initialAyah: 14))),
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
                              style: NoorType.meta.copyWith(
                                  color: NoorTheme.muted(context))),
                        ])),
                    ExcludeSemantics(
                        child: Icon(Icons.chevron_right,
                            color: NoorTheme.muted(context), size: 19)),
                  ]))),
        ]),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Semantics(
                        header: true,
                        child: const Text('Prayer Times',
                            style: NoorType.cardTitle))),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                      NoorAppState.formatGregorian(PrayerService.nowInLocation(
                          controller?.currentLocation ??
                              LocationModel.defaultLocation)),
                      style: NoorType.meta),
                  Text(prayerDay.hijriDisplay.replaceAll(' (calculated)', ''),
                      style: NoorType.meta
                          .copyWith(color: NoorTheme.muted(context))),
                ]),
                const SizedBox(width: 6),
                const Icon(Icons.calendar_month_outlined,
                    size: 20, color: null),
              ]),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await LocationService.showLocationPicker(
                      context: context);
                  if (picked != null) {
                    await controller?.updateLocation(picked);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: null),
                      const SizedBox(width: 4),
                      Text(locationLabel,
                          style: NoorType.meta.copyWith(
                              color: null, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 16, color: null),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Next Prayer hero — tappable directly to Salah Tracker
              Semantics(
                button: true,
                label:
                    'Next prayer: $nextName at $nextTime, tap to open Salah Tracker',
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
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: NoorColors.gold, width: 1.6)),
                                child: const Icon(Icons.wb_sunny_outlined,
                                    color: NoorColors.gold, size: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(
                                    children: [
                                      Text(
                                          nextPrayer.isTomorrow
                                              ? 'Tomorrow’s Fajr'
                                              : 'Next Prayer',
                                          style: NoorType.meta
                                              .copyWith(color: Colors.white70)),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: NoorTheme.surface(context,
                                                  light: Colors.white)
                                              .withValues(alpha: 0.16),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Log',
                                                style: NoorType.compactMeta
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                            const SizedBox(width: 2),
                                            const Icon(Icons.arrow_forward_ios,
                                                size: 7, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(nextName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: NoorType.screenTitle
                                          .copyWith(color: Colors.white)),
                                  Text(nextRemaining,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: NoorType.secondary
                                          .copyWith(color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text(nextTime,
                                      style: NoorType.meta
                                          .copyWith(color: Colors.white70)),
                                ])),
                            const SizedBox(width: 8),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(NoorAssets.nextPrayerMosque,
                                    width: 68,
                                    cacheWidth: 204,
                                    height: 74,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomRight,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox(width: 68, height: 74))),
                            const SizedBox(width: 4),
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
                      for (var i = 0; i < effectivePrayerRows.length; i++)
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Icon(_prayerIcons[i],
                                  size: 19, color: NoorTheme.accent(context)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(effectivePrayerRows[i].$1,
                                      style: NoorType.body)),
                              Text(effectivePrayerRows[i].$2,
                                  style: NoorType.tabular(NoorType.secondary)),
                              IconButton(
                                tooltip: 'Manage prayer reminders',
                                onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ReminderCenterScreen())),
                                icon: const Icon(Icons.notifications_outlined,
                                    size: 19),
                              ),
                            ])),
                    ]),
                  ),
                  const Divider(
                      height: 1, thickness: 1, color: NoorColors.hairlineSoft),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SalahTrackerScreen())),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(NoorRadius.card)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(children: [
                          Icon(Icons.calendar_month_outlined,
                              color: null, size: 19),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text('Full Prayer Timings & Salah Log',
                                  style: NoorType.secondary)),
                          Icon(Icons.chevron_right, color: null, size: 19),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 22),
              Semantics(header: true, child: const Text('Worship Tools', style: NoorType.cardTitle)),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final cols = textScale > 1.3 ? 2 : 4;
                final ratio = textScale > 1.3
                    ? 1.55
                    : (textScale > 1.15 ? 0.68 : 0.78);
                return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: ratio,
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
                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IslamicCalendarScreen()));
                                  } else if (i == 5) {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FastingRamadanScreen()));
                                  } else if (i == 6) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SalahTrackerScreen()));
                                  } else if (i == 7) {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen()));
                                  }
                                },
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 4),
                                    decoration: BoxDecoration(
                                        color: isDark
                                            ? NoorColors.darkCard
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: isDark
                                                ? NoorColors.darkBorder
                                                : NoorColors.hairlineSoft)),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                  color: isDark
                                                      ? NoorColors.darkSurface
                                                      : NoorColors.emeraldSoft,
                                                  shape: BoxShape.circle),
                                              child: Icon(_toolIcons[i],
                                                  color: isDark
                                                      ? NoorColors.darkGold
                                                      : NoorColors.emeraldDark,
                                                  size: 21)),
                                          const SizedBox(height: 6),
                                          Flexible(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              child: Text(
                                                  SampleData.worshipTools[i],
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: NoorType.meta.copyWith(
                                                      color: NoorTheme
                                                          .foreground(context),
                                                      height: 1.2)),
                                            ),
                                          ),
                                        ])),
                              ),
                            )));
              }),
              const SizedBox(height: 16),
              NoorCard(
                  padding: const EdgeInsets.all(16),
                  radius: NoorRadius.heroCard,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SalahTrackerScreen())),
                  child: Row(children: [
                    Builder(builder: (context) {
                      final ringSize =
                          (62 * MediaQuery.textScalerOf(context).scale(1.0))
                              .clamp(62.0, 82.0);
                      return SizedBox(
                          width: ringSize,
                          height: ringSize,
                          child: Stack(alignment: Alignment.center, children: [
                            CircularProgressIndicator(
                                value: _prayersToday / 5,
                                strokeWidth: 6,
                                color: NoorTheme.accent(context),
                                backgroundColor:
                                    NoorTheme.border(context)),
                            Text('${_prayersToday * 20}%',
                                style: NoorType.secondary),
                          ]));
                    }),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text("Today's Goal",
                              style: NoorType.cardTitle),
                          const SizedBox(height: 4),
                          Text('$_prayersToday of 5 prayers logged today',
                              style: NoorType.meta.copyWith(
                                  color: NoorTheme.muted(context),
                                  height: 1.45)),
                        ])),
                    ExcludeSemantics(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(NoorAssets.quranRehal,
                                width: 74,
                                cacheWidth: 222,
                                height: 68,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox(width: 74, height: 68)))),
                    ExcludeSemantics(
                        child: Icon(Icons.chevron_right,
                            color: NoorTheme.muted(context), size: 19)),
                  ])),
              const SizedBox(height: 16),
              NoorCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SalahTrackerScreen())),
                  child: Row(children: [
                    Expanded(
                        child: Column(children: [
                      Text('Streak',
                          style: NoorType.meta.copyWith(
                              color: NoorTheme.muted(context))),
                      const SizedBox(height: 4),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department,
                                color: NoorTheme.accent(context), size: 19),
                            const SizedBox(width: 4),
                            Text('$_streak', style: NoorType.screenTitle)
                          ]),
                      Text('days',
                          style: NoorType.meta.copyWith(
                              color: NoorTheme.muted(context)))
                    ])),
                    SizedBox(
                        height: 44,
                        child: VerticalDivider(
                            color: NoorTheme.border(context))),
                    Expanded(
                        child: Column(children: [
                      Text('Longest Streak',
                          style: NoorType.meta.copyWith(
                              color: NoorTheme.muted(context))),
                      const SizedBox(height: 4),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events,
                                color: NoorTheme.accent(context), size: 19),
                            const SizedBox(width: 4),
                            Text('$_longest', style: NoorType.screenTitle)
                          ]),
                      Text('days',
                          style: NoorType.meta.copyWith(
                              color: NoorTheme.muted(context)))
                    ])),
                    ExcludeSemantics(
                        child: Icon(Icons.chevron_right,
                            color: NoorTheme.muted(context), size: 19)),
                  ])),
            ])),
      ])),
    );
  }

}
