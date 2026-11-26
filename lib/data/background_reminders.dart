import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'noor_store.dart';
import 'notification_plan.dart';
import 'notification_service.dart';
import 'prayer_service.dart';

@pragma('vm:entry-point')
void reminderDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    try {
      final days = await PrayerService().upcomingDays();
      final toggles = await NoorStore.getAllReminderToggles();
      final plan =
          NotificationPlan.buildUpcomingPlan(days: days, toggles: toggles);
      await NoorNotifications.schedulePlan(plan, requestPermission: false);
      return true;
    } catch (_) {
      return false;
    }
  });
}

Future<void> initializeBackgroundReminders() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await Workmanager().initialize(reminderDispatcher);
    await Workmanager().registerPeriodicTask(
      'muslimgo-reminder-refresh',
      'refresh-reminders',
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(hours: 12),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } catch (error) {
    debugPrint('Background reminder setup unavailable: $error');
  }
}
