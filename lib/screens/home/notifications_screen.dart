import 'package:flutter/material.dart';
import '../../data/location_service.dart';
import '../../data/noor_controller.dart';
import '../../data/noor_store.dart';
import '../../data/notification_plan.dart';
import '../../data/prayer_service.dart';
import '../../theme/noor_theme.dart';
import '../worship/reminder_center_screen.dart';
import '../worship/salah_tracker_screen.dart';
import '../worship/zikr_tasbih_screen.dart';
import 'ayat_of_the_day_screen.dart';
import 'dua_of_the_day_screen.dart';
import 'hadith_of_the_day_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<PlannedNotification>> _plan;
  @override
  void initState() {
    super.initState();
    _plan = _load();
  }

  Future<List<PlannedNotification>> _load() async {
    final location = await LocationService().getSavedLocation();
    final method = await NoorStore.getCalculationMethod();
    final school = await NoorStore.getMadhhab() == 'Hanafi' ? 1 : 0;
    final day = PrayerService.calculateOffline(
        location: location,
        date: PrayerService.nowInLocation(location),
        method: method,
        school: school);
    final days = await PrayerService().upcomingDays(today: day, count: 2);
    return NotificationPlan.buildUpcomingPlan(
            days: days, toggles: await NoorStore.getAllReminderToggles())
        .take(30)
        .toList();
  }

  void _open(PlannedNotification entry) {
    final Widget page = switch (entry.prayerName) {
      'Ayat of the Day' => const AyatOfTheDayScreen(),
      'Dua of the Day' => const DuaOfTheDayScreen(),
      'Hadith of the Day' => const HadithOfTheDayScreen(),
      'Morning Adhkar' ||
      'Evening Adhkar' =>
        const ZikrTasbihScreen(initialTab: 1),
      'Daily Zikr & Tasbih' => const ZikrTasbihScreen(),
      _ => const SalahTrackerScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifications'), actions: [
          IconButton(
              tooltip: 'Reminder settings',
              icon: const Icon(Icons.tune),
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ReminderCenterScreen()));
                if (mounted) setState(() => _plan = _load());
              })
        ]),
        body: FutureBuilder<List<PlannedNotification>>(
            future: _plan,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: TextButton(
                        onPressed: () => setState(() => _plan = _load()),
                        child: const Text('Couldn’t load reminders. Retry')));
              }
              final entries = snapshot.data ?? [];
              final zone = PrayerService.zoneFor(
                  NoorScope.of(context)?.currentLocation.timeZone);
              return ListView(padding: const EdgeInsets.all(20), children: [
                const Text('Upcoming reminders', style: NoorType.screenTitle),
                const SizedBox(height: 8),
                const Text(
                    'This is your reminder plan. Delivery and sound depend on notification and alarm permissions; review them in Reminder settings.',
                    style: NoorType.secondary),
                const SizedBox(height: 20),
                if (entries.isEmpty)
                  const Text(
                      'All reminders are off. Enable the ones you want in Reminder settings.'),
                for (final entry in entries)
                  Card(
                      child: ListTile(
                    leading: Icon(entry.group == 'Salah'
                        ? Icons.mosque_outlined
                        : Icons.auto_stories_outlined),
                    title: Text(entry.title),
                    subtitle: Text(
                        '${entry.body}\n${entry.scheduledAt.day}/${entry.scheduledAt.month} · ${PrayerService.formatTime(entry.scheduledAt)}${zone == null ? '' : ' · ${zone.name}'}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(entry),
                  )),
              ]);
            }),
      );
}
