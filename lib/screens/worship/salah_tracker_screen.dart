import 'package:flutter/material.dart';
import '../../data/noor_store.dart';
import '../../data/user_data_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../data/noor_controller.dart';
import '../../data/prayer_service.dart';
import '../../data/location_service.dart';
import '../home/my_journey_screen.dart';
import 'qibla_finder_screen.dart';
import 'reminder_center_screen.dart';
import 'prayer_settings_screen.dart';
import '../../widgets/signature_arch.dart';
import 'salah_guide_screen.dart';

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
  final List<bool> _done = [false, false, false, false, false];
  Set<String> _completedDates = {};
  int _streak = 0;
  int _completedMonth = 0;
  double _completion = 0;
  Future<void> _saveQueue = Future.value();
  int _edits = 0;
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
    _loadStats();
  }

  String get _today => DateTime.now().toIso8601String().split('T').first;

  Future<void> _loadPrayers() async {
    // 1. Instant offline load from local NoorStore
    final local = await NoorStore.getPrayersList(_today);
    if (mounted) {
      setState(() {
        for (var i = 0; i < 5 && i < local.length; i++) {
          _done[i] = local[i];
        }
      });
    }

    // 2. In background, sync with cloud UserDataService if authenticated
    try {
      final edits = _edits;
      if ((await NoorStore.getSalahLog()).containsKey(_today)) return;
      final saved = await UserDataService.instance.loadPrayers(_today);
      if (saved != null && mounted && edits == _edits) {
        setState(() {
          for (var i = 0; i < 5 && i < saved.length; i++) {
            _done[i] = saved[i];
          }
        });
        await NoorStore.setPrayersList(_today, _done);
      }
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    final completed = await NoorStore.completedSalahDates();
    final log = await NoorStore.getSalahLog();
    final n = DateTime.now();
    int prayers = 0;
    for (final entry in log.entries) {
      final day = DateTime.tryParse(entry.key);
      if (day == null ||
          day.year != n.year ||
          day.month != n.month ||
          day.day > n.day) {
        continue;
      }
      prayers += ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']
          .where((name) =>
              entry.value[name] == true ||
              entry.value['${name[0].toUpperCase()}${name.substring(1)}'] ==
                  true)
          .length;
    }
    if (!mounted) return;
    setState(() {
      _completedDates = completed;
      _streak = NoorStore.streakForDates(completed);
      _completedMonth = completed
          .where((date) => date
              .startsWith('${n.year}-${n.month.toString().padLeft(2, '0')}'))
          .length;
      _completion = prayers / (n.day * 5);
    });
  }

  void _togglePrayer(int i) {
    _edits++;
    setState(() => _done[i] = !_done[i]);
    final snapshot = List<bool>.from(_done);
    _saveQueue = _saveQueue.then((_) async {
      await NoorStore.setPrayersList(_today, snapshot);
      await _loadStats();
      UserDataService.instance.savePrayers(_today, snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final day = controller?.activeDay ??
        PrayerService.calculateOffline(
            location: LocationModel.defaultLocation,
            date: PrayerService.nowInLocation(LocationModel.defaultLocation));
    final next = controller?.nextPrayer ?? day.nextPrayer();
    final accent = Theme.of(context).colorScheme.primary;
    final completed = _done.where((value) => value).length;
    const names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    return Scaffold(
        appBar: AppBar(title: const Text('Salah Tracker'), actions: [
          IconButton(
              tooltip: 'Prayer settings',
              onPressed: () => open(const PrayerSettingsScreen()),
              icon: const Icon(Icons.tune_outlined)),
        ]),
        body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
              Text(day.hijriDisplay.replaceAll(' (calculated)', ''),
                  style: NoorType.meta),
              const SizedBox(height: 5),
              Text(
                  controller?.locationLabel ??
                      LocationModel.defaultLocation.label,
                  style: NoorType.secondary),
              const SizedBox(height: 18),
              Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        NoorColors.emeraldDark,
                        NoorColors.emeraldMid
                      ]),
                      borderRadius: BorderRadius.circular(22)),
                  child: Stack(children: [
                    const Positioned.fill(
                        child: CustomPaint(painter: SignatureArchPainter())),
                    Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('TODAY’S PRAYERS',
                                    style: NoorType.eyebrow.copyWith(
                                        color: NoorColors.onEmeraldMuted)),
                                const SizedBox(height: 8),
                                Text('$completed of 5 completed',
                                    style: NoorType.screenTitle
                                        .copyWith(color: Colors.white)),
                                const SizedBox(height: 7),
                                Text(
                                    completed == 5
                                        ? 'May Allah accept your prayers.'
                                        : 'One prayer at a time.',
                                    style: NoorType.secondary.copyWith(
                                        color: NoorColors.onEmeraldMuted)),
                              ])),
                          const SizedBox(width: 14),
                          SizedBox(
                              width: 58,
                              height: 58,
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                SizedBox.expand(
                                    child: CircularProgressIndicator(
                                        value: completed / 5,
                                        strokeWidth: 4,
                                        color: NoorColors.gold,
                                        backgroundColor: Colors.white24
                                            .withValues(alpha: .14))),
                                Text('$completed/5',
                                    style: NoorType.body.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ]))
                        ])),
                  ])),
              const SizedBox(height: 18),
              NoorCard(
                  padding: EdgeInsets.zero,
                  radius: 20,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Today’s timetable',
                                      style: NoorType.cardTitle),
                                  const SizedBox(height: 6),
                                  Text(
                                      '${next.isTomorrow ? 'Tomorrow' : 'Next'}: ${next.displayName} · ${next.timeLabel} · ${next.remainingLabel}',
                                      style: NoorType.meta),
                                ])),
                        for (int i = 0; i < names.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          Semantics(
                              button: true,
                              checked: _done[i],
                              label:
                                  '${names[i]} prayer, ${_done[i] ? "prayed" : "not prayed"}. Tap to toggle.',
                              child: InkWell(
                                  key: ValueKey('salah-${names[i]}'),
                                  onTap: () => _togglePrayer(i),
                                  child: Ink(
                                      color: !next.isTomorrow &&
                                              next.name == names[i]
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? NoorColors.darkSurface
                                              : NoorColors.emeraldSoft
                                                  .withValues(alpha: .55))
                                          : Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 13),
                                      child: Row(children: [
                                        Icon(_prayerIcons[i],
                                            size: 21, color: accent),
                                        const SizedBox(width: 12),
                                        Expanded(
                                            child: Text(
                                                names[i] == 'Dhuhr'
                                                    ? 'Dhuhr / Zuhr'
                                                    : names[i],
                                                style: NoorType.body)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(
                                                day.timings[names[i]] == null
                                                    ? 'Unavailable'
                                                    : PrayerService.formatTime(
                                                        day.timings[names[i]]!),
                                                textAlign: TextAlign.end,
                                                style: NoorType.tabular(
                                                    NoorType.secondary.copyWith(
                                                        color: NoorTheme
                                                            .foreground(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w700)))),
                                        const SizedBox(width: 15),
                                        Icon(
                                            _done[i]
                                                ? Icons.check_circle_rounded
                                                : Icons
                                                    .radio_button_unchecked_rounded,
                                            size: 25,
                                            color: _done[i]
                                                ? accent
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .outline),
                                      ])))),
                        ],
                      ])),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _stat('$_streak', 'Day streak')),
                const SizedBox(width: 10),
                Expanded(
                    child:
                        _stat('${(_completion * 100).round()}%', 'This month')),
                const SizedBox(width: 10),
                Expanded(child: _stat('$_completedMonth', 'Complete days'))
              ]),
              const SizedBox(height: 20),
              NoorCard(
                  onTap: () => open(const MyJourneyScreen()),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Your consistency',
                            style: NoorType.cardTitle),
                        const SizedBox(height: 4),
                        const Text('Completed prayer days · last 7 days',
                            style: NoorType.meta),
                        const SizedBox(height: 16),
                        Row(children: [
                          for (int i = 6; i >= 0; i--)
                            Expanded(child: Builder(builder: (_) {
                              final now = DateTime.now();
                              final date =
                                  DateTime(now.year, now.month, now.day - i);
                              final checked = _completedDates.contains(
                                  date.toIso8601String().split('T').first);
                              return Column(children: [
                                Text(
                                    [
                                      'M',
                                      'T',
                                      'W',
                                      'T',
                                      'F',
                                      'S',
                                      'S'
                                    ][date.weekday - 1],
                                    style: NoorType.meta),
                                const SizedBox(height: 8),
                                Icon(
                                    checked
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 21,
                                    color: checked
                                        ? accent
                                        : Theme.of(context).colorScheme.outline)
                              ]);
                            }))
                        ]),
                        const SizedBox(height: 14),
                        const Text('View journey →',
                            textAlign: TextAlign.right, style: NoorType.meta),
                      ])),
              const SizedBox(height: 14),
              Wrap(spacing: 10, runSpacing: 8, children: [
                OutlinedButton.icon(
                    onPressed: () => open(const SalahGuideScreen()),
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: const Text('Salah & Wudu Guide')),
                OutlinedButton.icon(
                    onPressed: () =>
                        open(const SalahGuideScreen(initialTab: 3)),
                    icon: const Icon(Icons.history_toggle_off, size: 18),
                    label: const Text('Qada & Tahajjud')),
                OutlinedButton.icon(
                    onPressed: () => open(const QiblaFinderScreen()),
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: const Text('Qibla')),
                OutlinedButton.icon(
                    onPressed: () => open(const ReminderCenterScreen()),
                    icon:
                        const Icon(Icons.notifications_none_outlined, size: 18),
                    label: const Text('Reminders')),
              ]),
            ])));
  }

  Widget _stat(String value, String label) => NoorCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
      radius: 16,
      child: Column(children: [
        Text(value,
            style: NoorType.cardTitle
                .copyWith(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 5),
        Text(label,
            textAlign: TextAlign.center,
            style: NoorType.eyebrow.copyWith(letterSpacing: 0))
      ]));
}
