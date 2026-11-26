import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/daily_content_service.dart';
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
      final day = await service.fetchTodayAuto();
      final days = await service.upcomingDays(today: day, count: 7);
      plan =
          NotificationPlan.buildUpcomingPlan(days: days, toggles: _toggleMap());
    } catch (e) {
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
        _status =
            '$count reminders scheduled. Reopen the app weekly to refresh the next seven days. Prayer-time azan sound follows Android notification settings.';
      } else if (NoorNotifications.permissionDenied) {
        _status = 'Notifications are turned off for MuslimGo — your reminders '
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

  void _showTestNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: NoorTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('Test Reminder Notification',
                    style: NoorType.cardTitle),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                    'Trigger a live notification preview on your device:',
                    style: NoorType.secondary),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.volume_up_outlined),
                title: const Text('Test azan sound'),
                subtitle: const Text(
                    'Plays the bundled azan alert using your Android notification settings.'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final sent = await NoorNotifications.showNotification(
                      id: 100,
                      title: 'Azan sound test',
                      body: 'Your prayer-time azan alert.',
                      payload: 'Salah|Fajr',
                      isSalah: true,
                      playAzan: true);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(sent
                            ? 'Azan test sent. Check sound and notification settings if you cannot hear it.'
                            : 'Notification permission is needed to play the azan test.')));
                  }
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: NoorTheme.softSurface(context),
                  child: Icon(Icons.alarm_outlined, color: NoorTheme.accent(context)),
                ),
                title:
                    const Text('Namaz (Salah) Reminder', style: NoorType.body),
                subtitle: const Text(
                    'Fajr begins in 15 minutes. Prepare for prayer.',
                    style: NoorType.meta),
                onTap: () async {
                  Navigator.pop(ctx);
                  final sent = await NoorNotifications.showNotification(
                    id: 101,
                    title: 'Fajr Reminder',
                    body: 'Fajr begins in 15 minutes. Prepare for prayer.',
                    isSalah: true,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(sent
                              ? 'Namaz reminder sent. Check your notification shade.'
                              : 'Notification was not sent. Check permission in Settings.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: NoorTheme.softSurface(context),
                  child: Icon(Icons.fingerprint_rounded, color: NoorTheme.accent(context)),
                ),
                title:
                    const Text('Zikr & Tasbih Reminder', style: NoorType.body),
                subtitle: const Text(
                    'Time for your daily dhikr and mindful remembrance of Allah.',
                    style: NoorType.meta),
                onTap: () async {
                  Navigator.pop(ctx);
                  final sent = await NoorNotifications.showNotification(
                    id: 102,
                    title: 'Daily Zikr & Tasbih',
                    body:
                        'Time for your daily tasbih and remembrance of Allah.',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(sent
                              ? 'Zikr reminder sent!'
                              : 'Notification was not sent. Check permission in Settings.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: NoorTheme.softSurface(context),
                  child: Icon(Icons.auto_stories_outlined, color: NoorTheme.accent(context)),
                ),
                title: const Text('Ayat of the Day', style: NoorType.body),
                subtitle: Text(
                    '"${DailyContentService.getAyahOfDay().translation}" (${DailyContentService.getAyahOfDay().surahReference})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NoorType.meta),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ayah = DailyContentService.getAyahOfDay();
                  final sent = await NoorNotifications.showNotification(
                    id: 103,
                    title: 'Ayat of the Day',
                    body: '“${ayah.translation}” (${ayah.surahReference})',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(sent
                              ? 'Ayat of the Day notification sent!'
                              : 'Notification was not sent. Check permission in Settings.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: NoorTheme.softSurface(context),
                  child: Icon(Icons.bookmark_border_outlined, color: NoorTheme.accent(context)),
                ),
                title: const Text('Hadith of the Day', style: NoorType.body),
                subtitle: Text(
                    '"${DailyContentService.getHadithOfDay().translation}"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NoorType.meta),
                onTap: () async {
                  Navigator.pop(ctx);
                  final hadith = DailyContentService.getHadithOfDay();
                  final sent = await NoorNotifications.showNotification(
                    id: 104,
                    title: 'Hadith of the Day',
                    body: '“${hadith.translation}” (${hadith.source})',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(sent
                              ? 'Hadith notification sent!'
                              : 'Notification was not sent. Check permission in Settings.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: NoorTheme.softSurface(context),
                  child: Icon(Icons.format_quote_rounded, color: NoorTheme.accent(context)),
                ),
                title: const Text('Quote of the Day', style: NoorType.body),
                subtitle: const Text(
                    '“Patience is not the ability to wait, but how you act while waiting.”',
                    style: NoorType.meta),
                onTap: () async {
                  Navigator.pop(ctx);
                  final sent = await NoorNotifications.showNotification(
                    id: 105,
                    title: 'Quote of the Day',
                    body:
                        '“Patience is not the ability to wait, but how you act while waiting.” - Islamic Wisdom',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(sent
                              ? 'Quote of the Day notification sent!'
                              : 'Notification was not sent. Check permission in Settings.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
        body: SafeArea(
            child: Column(children: [
          NoorDarkHeader(
            title: 'Reminder Center',
            actions: [
              IconButton(
                tooltip: 'Test Live Notification',
                icon: const Icon(Icons.notifications_active,
                    color: NoorColors.gold),
                onPressed: _showTestNotificationSheet,
              ),
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
                            (
                              Icons.send_outlined,
                              'Send test reminder notification',
                              () => _showTestNotificationSheet()
                            ),
                          ])),
            ],
          ),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                for (var g = 0; g < _groups.length; g++) ...[
                  Text(_titles[g], style: NoorType.cardTitle),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _groups[g].length; i++) ...[
                    Container(
                        padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
                        decoration: BoxDecoration(
                            color:
                                NoorTheme.surface(context, light: Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NoorTheme.border(context))),
                        child: Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(_groups[g][i].$1, style: NoorType.body),
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
                  const Icon(Icons.schedule_outlined, size: 16, color: null),
                  const SizedBox(width: 7),
                  Expanded(
                      child: Text(
                          'Quiet hours respect sleep and focus periods. Custom reminders can be added for Friday or personal routines.',
                          style:
                              NoorType.meta.copyWith(color: null, height: 1.5)))
                ]),
                if (_status != null) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.notifications_active_outlined,
                        size: 16,
                        color: NoorTheme.foreground(context,
                            light: NoorColors.emerald)),
                    const SizedBox(width: 7),
                    Expanded(
                        child: Text(_status!,
                            style: NoorType.meta
                                .copyWith(color: null, height: 1.5)))
                  ]),
                  if (_showSettingsButton) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.settings_outlined, size: 16),
                        label: const Text('Open Settings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NoorTheme.accent(context),
                          side: BorderSide(color: NoorTheme.border(context)),
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
