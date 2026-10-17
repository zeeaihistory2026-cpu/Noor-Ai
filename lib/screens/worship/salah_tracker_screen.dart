import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/noor_store.dart';
import '../../data/user_data_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../data/noor_controller.dart';
import '../../data/prayer_service.dart';
import '../home/my_journey_screen.dart';
import 'qibla_finder_screen.dart';
import 'reminder_center_screen.dart';

/// Page 06 — Salah Tracker. Emerald header with the real mosque
/// skyline crop, Today's Prayers (5 columns, Asr highlighted with
/// "1h 16m remaining", check circles tappable), dark Salah Streak
/// card (12 Days, M–S week checks), Monthly Overview 91% / 28 / 3,
/// Insights with the lantern crop, Quick Actions and Learn Salah
/// with the prostration crop — as drawn.
class SalahTrackerScreen extends StatefulWidget {
  const SalahTrackerScreen({super.key});
  @override
  State<SalahTrackerScreen> createState() => _SalahTrackerScreenState();
}

class _SalahTrackerScreenState extends State<SalahTrackerScreen> {
  final List<bool> _done = [true, true, false, false, false];
  static const _prayerIcons = [
    Icons.wb_twilight,
    Icons.wb_sunny_outlined,
    Icons.wb_cloudy_outlined,
    Icons.wb_sunny,
    Icons.nightlight_round,
  ];

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  String get _today =>
      DateTime.now().toIso8601String().split('T').first;

  Future<void> _loadPrayers() async {
    // 1. Instant offline load from local NoorStore
    final local = await NoorStore.getPrayersList(_today);
    if (mounted && local.any((element) => element)) {
      setState(() {
        for (var i = 0; i < 5 && i < local.length; i++) {
          _done[i] = local[i];
        }
      });
    }

    // 2. In background, sync with cloud UserDataService if authenticated
    try {
      final saved = await UserDataService.instance.loadPrayers(_today);
      if (saved != null && mounted) {
        setState(() {
          for (var i = 0; i < 5 && i < saved.length; i++) {
            _done[i] = saved[i];
          }
        });
        await NoorStore.setPrayersList(_today, _done);
      }
    } catch (_) {}
  }

  void _togglePrayer(int i) {
    setState(() => _done[i] = !_done[i]);
    // Save locally first to guarantee zero data loss
    NoorStore.setPrayersList(_today, _done);
    // Push to cloud if logged in
    UserDataService.instance.savePrayers(_today, _done);
  }

  void _openLearn(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (_) => const Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Learn Salah — first steps',
                    style:
                        NoorType.cardTitle),
                SizedBox(height: 10),
                Text(
                    '1. Make wudu calmly.\n2. Face the Qibla and set your intention.\n3. Begin with Takbir, hands raised.\n\nFull guided lessons open here as they are added.',
                    style: TextStyle(height: 1.5)),
              ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header with real skyline art (Page 06 crop).
            NoorDarkHeader(
              title: 'Salah Tracker',
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
              actions: [
                IconButton(
                    tooltip: 'About the salah log',
                    icon: const Icon(Icons.calendar_month_outlined,
                        color: Colors.white),
                    // Phase 16 audit: honest — the log is kept for
                    // today only; the sheet links prayer reminders.
                    onPressed: () => showNoorOverflowSheet(context,
                        title: 'Salah log',
                        info: const [
                          'Your log is kept for today in this version — past days are not stored yet.',
                        ],
                        actions: [
                          (
                            Icons.alarm_outlined,
                            'Prayer reminders',
                            () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ReminderCenterScreen()))
                          ),
                        ])),
                IconButton(
                    tooltip: "Today's log options",
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    // Phase 16 audit: real bulk actions on the log.
                    onPressed: () => showNoorOverflowSheet(context,
                        title: "Today's prayers",
                        actions: [
                          (
                            Icons.done_all_outlined,
                            'Mark all as prayed',
                            () => setState(() {
                              for (var i = 0; i < _done.length; i++) {
                                _done[i] = true;
                              }
                            })
                          ),
                          (
                            Icons.restart_alt_outlined,
                            "Clear today's log",
                            () => setState(() {
                              for (var i = 0; i < _done.length; i++) {
                                _done[i] = false;
                              }
                            })
                          ),
                        ])),
              ],
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
                child: Image.asset(NoorAssets.salahHeaderMosque,
                    cacheWidth: 1170,
                    // 98 ≈ the skyline strip's aspect at full
                    // width (Phase 11b); at 84 the side domes
                    // were cropped off.
                    height: 98,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(children: [
                            const Text(NoorAppState.hijriLabel,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                            Text(NoorAppState.gregorianLabel,
                                style: const TextStyle(color: Colors.white70)),
                          ]),
                        )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(NoorAppState.dateLine, style: NoorType.meta),
                    const SizedBox(height: 12),
                    // Today's Prayers
                    NoorCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Today's Prayers",
                                style: NoorType.cardTitle),
                            const SizedBox(height: 14),
                            Builder(builder: (context) {
                              final controller = NoorScope.of(context);
                              final nextPrayer = controller?.nextPrayer;
                              final prayerDay = controller?.prayerDay;

                              int nextIndex = 1; // default to Dhuhr/Zuhr if not known
                              if (nextPrayer != null) {
                                final nameLower = nextPrayer.name.toLowerCase();
                                if (nameLower.contains('fajr')) {
                                  nextIndex = 0;
                                } else if (nameLower.contains('dhuhr') || nameLower.contains('zuhr')) {
                                  nextIndex = 1;
                                } else if (nameLower.contains('asr')) {
                                  nextIndex = 2;
                                } else if (nameLower.contains('maghrib')) {
                                  nextIndex = 3;
                                } else if (nameLower.contains('isha')) {
                                  nextIndex = 4;
                                }
                              }

                              final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
                              final prayerDisplayTimes = List.generate(5, (i) {
                                final name = prayerNames[i];
                                if (prayerDay?.timings[name] != null) {
                                  return PrayerService.formatTime(prayerDay!.timings[name]!);
                                }
                                return NoorAppState.prayerTimes[i].$2;
                              });

                              final countdownText = nextPrayer != null
                                  ? '${nextPrayer.remainingLabel.replaceAll(" remaining", "")}\nremaining'
                                  : '${NoorAppState.nextPrayerCountdown}\nremaining';

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(5, (i) {
                                  final next = i == nextIndex;
                                  return Expanded(
                                    child: InkWell(
                                      onTap: () => _togglePrayer(i),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: next
                                            ? BoxDecoration(
                                                color: NoorColors.emeraldSoft,
                                                borderRadius:
                                                    BorderRadius.circular(14))
                                            : null,
                                        child: Column(children: [
                                          // Solid mosque glyphs as drawn
                                          // (Phase 11 fix; was outline).
                                          Icon(_prayerIcons[i],
                                              size: 24,
                                              color: _done[i] || next
                                                  ? NoorColors.emeraldDark
                                                  : NoorColors.greyDisabled),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(NoorAppState.prayerTimes[i].$1,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: NoorType.meta),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Semantics(
                                            button: true,
                                            checked: _done[i],
                                            label:
                                                '${NoorAppState.prayerTimes[i].$1} prayer, ${_done[i] ? "prayed" : "not prayed"}. Tap to toggle.',
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: Center(
                                                child: Icon(
                                                  _done[i]
                                                      ? Icons.check_circle
                                                      : Icons
                                                          .radio_button_unchecked,
                                                  color: _done[i]
                                                      ? NoorColors.emerald
                                                      : NoorColors.greyDisabled,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(prayerDisplayTimes[i],
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            height: 32,
                                            child: next
                                                ? Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                          countdownText,
                                                          textAlign: TextAlign.center,
                                                          style: NoorType.meta),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ]),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                            // The design card ends at the prayer
                            // times; the tappable checks themselves
                            // show today's progress (Phase 11 fix).
                          ]),
                    ),
                    const SizedBox(height: 16),
                    // Salah Streak (dark)
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          NoorColors.emeraldDark,
                          NoorColors.emeraldMid
                        ]),
                        borderRadius:
                            BorderRadius.circular(NoorRadius.heroCard),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(children: [
                        Row(children: [
                          const Icon(Icons.local_fire_department,
                              color: NoorColors.amber, size: 38),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Salah Streak',
                                      style: NoorType.meta.copyWith(color: Colors.white)),
                                  Text('12 Days',
                                      style: NoorType.screenTitle.copyWith(color: NoorColors.gold)),
                                  Text('Keep it up, ${NoorAppState.userName}!',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: NoorType.meta.copyWith(color: Colors.white70)),
                                ]),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                              .asMap()
                              .entries
                              .map((e) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(e.value,
                                        textAlign: TextAlign.center,
                                        style: NoorType.meta.copyWith(
                                            color: Colors.white70,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Icon(
                                        e.key < 6
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 20,
                                        color: e.key < 6
                                            ? NoorColors.success
                                            : Colors.white38),
                                  ]))
                              .toList(),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    // Monthly Overview
                    NoorCard(
                      child: Column(children: [
                        Row(children: [
                          const Expanded(
                              child: Text('Monthly Overview',
                                  style: NoorType.cardTitle)),
                          Text('View Calendar',
                              style: NoorType.meta.copyWith(color: NoorColors.emerald)),
                        ]),
                        const SizedBox(height: 16),
                        const Row(children: [
                          Expanded(
                              child:
                                  _Stat('91%', 'Completion Rate\nThis Month')),
                          Expanded(child: _Stat('28', 'Days Completed')),
                          Expanded(child: _Stat('3', 'Missed Days')),
                        ]),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                              value: 0.91,
                              minHeight: 6,
                              color: NoorColors.emerald,
                              backgroundColor: NoorColors.sand),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    // Insights with lantern crop
                    NoorCard(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Insights',
                                        style: NoorType.cardTitle),
                                    const SizedBox(height: 10),
                                    Text(
                                      'You are most consistent with Fajr. '
                                      'Try setting a reminder for Isha to '
                                      'improve your night prayer.',
                                      style: NoorType.secondary.copyWith(height: 1.55),
                                    ),
                                  ]),
                            ),
                            const SizedBox(width: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(NoorAssets.salahLantern,
                                  width: 92,
                                  cacheWidth: 276,
                                  height: 76,
                                  // Whole lantern visible as drawn
                                  // (Phase 11 fix; cover cropped it).
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Container(
                                      width: 92,
                                      height: 76,
                                      color: NoorColors.emeraldSoft)),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 20),
                    const NoorSectionLabel('Quick Actions'),
                    const SizedBox(height: 12),
                    Row(children: [
                      _quick(
                          context,
                          Icons.notifications_none,
                          'Prayer\nReminders',
                          () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const ReminderCenterScreen()))),
                      _quick(
                          context,
                          Icons.explore_outlined,
                          'Qibla\nFinder',
                          () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const QiblaFinderScreen()))),
                      _quick(context, Icons.menu_book_outlined, 'Learn\nSalah',
                          () => _openLearn(context)),
                      _quick(
                          context,
                          Icons.bar_chart,
                          'My\nStats',
                          () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const MyJourneyScreen()))),
                    ]),
                    const SizedBox(height: 16),
                    // Learn Salah
                    Container(
                      decoration: BoxDecoration(
                          color: NoorColors.emeraldSoft,
                          borderRadius:
                              BorderRadius.circular(NoorRadius.heroCard)),
                      padding: const EdgeInsets.all(18),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Learn Salah Step by Step',
                                    style: NoorType.cardTitle),
                                const SizedBox(height: 6),
                                Text(
                                    'Interactive lessons with audio and illustrations.',
                                    style: NoorType.meta.copyWith(color: NoorColors.muted,
                                        height: 1.45)),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: () => _openLearn(context),
                                  style: FilledButton.styleFrom(
                                      backgroundColor: NoorColors.emeraldDark),
                                  child: const Text('Start Learning'),
                                ),
                              ]),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(NoorAssets.salahProstration,
                              width: 108,
                              cacheWidth: 324,
                              height: 84,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 108, height: 84, color: Colors.white)),
                        ),
                      ]),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label,
          VoidCallback onTap) =>
      Expanded(
        child: Semantics(button: true, child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NoorColors.hairlineSoft)),
            child: Column(children: [
              Icon(icon, color: NoorColors.emeraldDark, size: 23),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: NoorType.meta.copyWith(height: 1.25)),
            ]),
          ),
        )),
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: NoorType.screenTitle),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
      ]);
}
