import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/noor_store.dart';
import '../../data/notification_plan.dart';
import '../../data/notification_service.dart';
import '../../data/app_state.dart';
import '../../data/prayer_service.dart';
import '../../data/reminder_display.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Page 31 — Prayer & Zikr Reminder Center. Emerald header,
/// Salah / Worship / Daily Content groups, each row a white
/// outlined pill with label, time and a working emerald toggle.
///
/// Phase 8: toggles are persisted in NoorStore and every change
/// re-plans + re-schedules real local notifications
/// (NotificationPlan -> NoorNotifications.zonedSchedule) from the
/// day's prayer times (PrayerService, sample fallback offline).
/// If notification permission is denied, toggles still save and
/// the status line says so honestly with an "Open Settings"
/// button — nothing pretends to be scheduled.
///
/// Phase 16 (Job 6):
/// - Prayer times come from the user's settings (city + calculation
///   method), not the hardcoded Karachi default.
/// - The tomorrow-rollover path still holds: today's + tomorrow's
///   Salah times are planned together, so a Fajr reminder switched
///   on in the afternoon rings tomorrow morning.
/// - Every row's displayed time comes from the computed plan itself
///   (ReminderDisplay), so what you see is what is scheduled.
///   Before the first plan lands, the design's sample times show —
///   identical to the previous static render.
/// - The dedicated Dhikr reminders (Morning Adhkar / Evening Adhkar)
///   plus Dua of the Day, Hadith of the Day and the daily Quran
///   reminder are all wired through the same planner and re-plan
///   logic (see test/phase16_reminders_test.dart).
/// - _reschedule can never fail silently: any error lands in the
///   status line instead of an unhandled exception.
/// - Boot: scheduled notifications are restored by the plugin's
///   ScheduledNotificationBootReceiver (see AndroidManifest);
///   toggles persist in SharedPreferences and re-planning happens
///   on every toggle change and every visit here.
class ReminderCenterScreen extends StatefulWidget {
  const ReminderCenterScreen({super.key});
  @override
  State<ReminderCenterScreen> createState() => _ReminderCenterScreenState();
}

class _ReminderCenterScreenState extends State<ReminderCenterScreen> {
  // Row labels + toggle state only. Times and lead texts are
  // derived from the computed plan (ReminderDisplay) so the
  // display always equals what was scheduled; the design's
  // sample times are the pre-plan fallback.
  late final List<List<(String, bool)>> _groups = [
    [for (final n in ReminderDisplay.salahLabels) (n, true)],
    [for (final r in SampleData.reminderWorship) (r.$1, true)],
    [for (final r in SampleData.reminderDaily) (r.$1, true)],
  ];
  static const _titles = ['Salah', 'Worship', 'Daily Content'];

  /// Latest computed plan (future entries only). Null until the
  /// first _reschedule completes; rows then show sample times.
  List<PlannedNotification>? _plan;
  String? _status;
  bool _showSettingsButton = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await NoorStore.getAllReminderToggles();
    if (!mounted) return;
    setState(() {
      for (final group in _groups) {
        for (var i = 0; i < group.length; i++) {
          final v = saved[group[i].$1];
          if (v != null) group[i] = (group[i].$1, v);
        }
      }
    });
    await _reschedule();
  }

  Map<String, bool> _toggleMap() => {
        for (final group in _groups)
          for (final row in group) row.$1: row.$2,
      };

  /// Displayed clock time for a row: the plan entry's actual
  /// scheduled time once planned, the design's sample time before.
  String _timeFor(String label) {
    final plan = _plan;
    if (plan != null) {
      final entry = ReminderDisplay.entryFor(plan, label);
      if (entry != null) return ReminderDisplay.clockLabel(entry.scheduledAt);
    }
    if (ReminderDisplay.isSalahLabel(label)) {
      for (final r in NoorAppState.prayerTimes) {
        if (r.$1 == label) return r.$2;
      }
    }
    for (final r in SampleData.reminderWorship) {
      if (r.$1 == label) return r.$2;
    }
    for (final r in SampleData.reminderDaily) {
      if (r.$1 == label) return r.$2;
    }
    return '';
  }

  /// Displayed lead text for a row, as drawn on Page 31.
  String _leadFor(String label) => ReminderDisplay.isSalahLabel(label)
      ? '${NotificationPlan.salahLeadMinutes} min before'
      : 'At time';

  /// Recompute today's plan from live prayer times (city + method
  /// from settings) + toggles and hand it to the real scheduler.
  /// Never throws: failures land in the status line, never in an
  /// unhandled exception, so a toggle can never fail silently.
  Future<void> _reschedule() async {
    List<PlannedNotification> plan = const [];
    String? error;
    try {
      final service = PrayerService();
      final city = await NoorStore.getCity();
      final country = await NoorStore.getCountry();
      final method = await NoorStore.getCalculationMethod();
      final day = await service.fetchTodayByCity(
        city: city,
        country: country,
        method: method,
      );
      // Also plan tomorrow's Salah times: otherwise a Fajr reminder
      // switched on after today's Fajr has passed would never be
      // scheduled for tomorrow morning (the phone-run step 8 trap).
      // Tomorrow's exact times come from the API; on failure we fall
      // back to today's times shifted by one day (within ~1 minute).
      PrayerDay? nextDay;
      try {
        nextDay = await service.fetchTimingsByCity(
          city: city,
          country: country,
          date: DateTime.now().add(const Duration(days: 1)),
          method: method,
        );
      } catch (_) {
        nextDay = PrayerDay(
          timings: {
            for (final e in day.timings.entries)
              e.key: e.value.add(const Duration(days: 1)),
          },
          hijriDisplay: day.hijriDisplay,
          source: day.source,
        );
      }
      plan = NotificationPlan.buildFullPlan(
        day: day,
        nextDay: nextDay,
        toggles: _toggleMap(),
      );
    } catch (e) {
      // fetchTodayByCity already falls back internally (cache ->
      // sample), so this is defensive only.
      error = 'prayer times unavailable';
    }

    var count = 0;
    if (error == null) {
      count = await NoorNotifications.schedulePlan(plan);
    }
    if (!mounted) return;
    final anyOn = _toggleMap().values.any((v) => v);
    setState(() {
      _plan = plan;
      _showSettingsButton = false;
      if (error != null) {
        _status = 'Couldn\'t refresh prayer times — showing saved times.';
      } else if (!NoorNotifications.isSupported) {
        _status = 'Reminders save here; scheduling needs the phone app.';
      } else if (!anyOn) {
        _status = 'All reminders are off — your choices are still saved.';
      } else if (count > 0) {
        _status = '$count reminders scheduled on this device.';
      } else if (NoorNotifications.permissionDenied) {
        _status = 'Notifications are turned off for NOOR — your reminders '
            'are saved but can\'t ring until you allow them.';
        _showSettingsButton = true;
      } else {
        _status = 'Reminders are off or permission is turned off — '
            'your choices are still saved.';
      }
    });
  }

  Future<void> _openSettings() async {
    if (kIsWeb) return;
    try {
      await AppSettings.openAppSettings();
    } catch (_) {
      /* stay in app; the status text already explains the fix */
    }
  }

  Future<void> _onToggle(List<(String, bool)> group, int i, bool v) async {
    setState(() => group[i] = (group[i].$1, v));
    await NoorStore.setReminderEnabled(group[i].$1, v);
    await _reschedule();
  }

  /// Phase 16 audit: real bulk actions behind the header ⋮.
  Future<void> _setAll(bool v) async {
    for (final group in _groups) {
      for (var i = 0; i < group.length; i++) {
        group[i] = (group[i].$1, v);
        await NoorStore.setReminderEnabled(group[i].$1, v);
      }
    }
    setState(() {
      // _groups already mutated above; this only repaints.
    });
    await _reschedule();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          Container(
            color: NoorColors.emeraldDark,
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 19),
                  onPressed: () => Navigator.of(context).maybePop()),
              Expanded(
                  child: Text('Reminder Center',
                      textAlign: TextAlign.center,
                      style: NoorType.screenTitle.copyWith(color: Colors.white))),
              IconButton(
                  tooltip: 'Reminder options',
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () => showNoorOverflowSheet(context,
                      title: 'Reminder Center',
                      info: const [
                        'Salah reminders fire 15 minutes before each prayer; the rest at their listed times.',
                      ],
                      actions: [
                        (
                          Icons.notifications_active_outlined,
                          'Turn all on',
                          () => _setAll(true)
                        ),
                        (
                          Icons.notifications_off_outlined,
                          'Turn all off',
                          () => _setAll(false)
                        ),
                      ])),
            ]),
          ),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                for (var g = 0; g < _groups.length; g++) ...[
                  Text(_titles[g],
                      style: NoorType.cardTitle),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _groups[g].length; i++) ...[
                    Container(
                        padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NoorColors.hairline)),
                        child: Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(_groups[g][i].$1,
                                    style: NoorType.body),
                                Text(_leadFor(_groups[g][i].$1),
                                    style: NoorType.meta),
                              ])),
                          Text(_timeFor(_groups[g][i].$1),
                              style: NoorType.tabular(NoorType.meta)),
                          const SizedBox(width: 8),
                          Semantics(
                            toggled: _groups[g][i].$2,
                            label: '${_groups[g][i].$1} reminder',
                            child: Switch(
                                value: _groups[g][i].$2,
                                onChanged: (v) => _onToggle(_groups[g], i, v)),
                          ),
                        ])),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 12),
                ],
                Row(children: [
                  const Icon(Icons.schedule_outlined,
                      size: 16, color: NoorColors.muted),
                  const SizedBox(width: 7),
                  Expanded(
                      child: Text(
                          'Quiet hours respect sleep and focus periods. Custom reminders can be added for Friday or personal routines.',
                          style: NoorType.meta.copyWith(color: NoorColors.muted,
                              height: 1.5)))
                ]),
                if (_status != null) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.notifications_active_outlined,
                        size: 16, color: NoorColors.emerald),
                    const SizedBox(width: 7),
                    Expanded(
                        child: Text(_status!,
                            style: NoorType.meta.copyWith(color: NoorColors.muted,
                                height: 1.5)))
                  ]),
                  if (_showSettingsButton) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.settings_outlined, size: 16),
                        label: const Text('Open Settings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NoorColors.emeraldDark,
                          side: const BorderSide(color: NoorColors.hairline),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _openSettings,
                      ),
                    ),
                  ],
                ],
              ])),
        ])),
      );
}
