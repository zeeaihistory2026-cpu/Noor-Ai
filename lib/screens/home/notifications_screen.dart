import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_share_card.dart';
import '../worship/reminder_center_screen.dart';

/// Page 35 — Notifications. Emerald header, Today group
/// (Fajr reminder / Daily Dua / Quran) and Earlier group
/// (Hifz plan / Hadith / AI insight) outline cards with pale
/// initial circles, exactly as drawn.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          NoorPlainHeader(title: 'Notifications', moreActions: [
            (
              Icons.tune,
              'Notification settings',
              () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ReminderCenterScreen()))
            ),
          ]),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                const Text('Today',
                    style:
                        NoorType.cardTitle),
                const SizedBox(height: 12),
                for (var i = 0; i < SampleData.notifToday.length; i++)
                  _row(SampleData.notifToday[i],
                      time: const ['5:21 AM', '6:00 AM', '8:15 AM'][i],
                      unread: i == 0),
                const SizedBox(height: 20),
                const Text('Earlier',
                    style:
                        NoorType.cardTitle),
                const SizedBox(height: 12),
                for (var i = 0; i < SampleData.notifEarlier.length; i++)
                  _row(SampleData.notifEarlier[i],
                      time: const ['Yesterday', 'Yesterday', '2 days ago'][i]),
              ])),
        ])),
      );
  Widget _row((String, String, String) n,
          {String time = '', bool unread = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NoorRadius.card),
                border: Border.all(color: NoorColors.hairline)),
            child: Row(children: [
              CircleAvatar(
                  radius: 21,
                  backgroundColor: NoorColors.emeraldSoft,
                  child: Icon(_iconFor(n.$1),
                      color: NoorColors.emeraldDark, size: 20)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Expanded(
                          child: Text(n.$1,
                              style: NoorType.body)),
                      if (unread)
                        Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: NoorColors.goldDeep,
                                shape: BoxShape.circle))
                    ]),
                    const SizedBox(height: 3),
                    Text(n.$2, style: NoorType.secondary),
                    const SizedBox(height: 4),
                    Text(time, style: NoorType.meta),
                  ])),
            ])),
      );
}

IconData _iconFor(String title) => switch (title) {
      'Fajr reminder' => Icons.alarm_outlined,
      'Daily Dua' => Icons.pan_tool_outlined,
      'Quran' => Icons.menu_book_outlined,
      'Hifz plan' => Icons.school_outlined,
      'Hadith' => Icons.auto_stories_outlined,
      _ => Icons.lightbulb_outline,
    };
