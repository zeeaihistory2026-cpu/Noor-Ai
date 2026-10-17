import 'package:flutter/material.dart';
import '../../data/daily_content_service.dart';
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
  Widget build(BuildContext context) {
    final todayAyah = DailyContentService.getAyahOfDay();
    final todayHadith = DailyContentService.getHadithOfDay();
    final todayDua = DailyContentService.getDuaOfDay();

    final notifToday = [
      ('Fajr reminder', 'Fajr begins in 15 minutes. Prepare for prayer.', 'F'),
      ('Ayat of the Day', '“${todayAyah.translation}” (${todayAyah.surahReference})', 'A'),
      ('Daily Zikr', 'Take a peaceful moment for SubhanAllah, Alhamdulillah & Allahu Akbar.', 'Z'),
      ('Daily Dua', '“${todayDua.transliteration}” - ${todayDua.translation}', 'D'),
      ('Hadith of the Day', '“${todayHadith.translation}” (${todayHadith.source})', 'H'),
      ('Quote of the Day', '“Patience is not the ability to wait, but how you act while waiting.”', 'Q'),
      ('Quran', 'Continue Surah Al-Kahf from Ayah 18.', 'Q'),
    ];

    return Scaffold(
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
                for (var i = 0; i < notifToday.length; i++)
                  _row(
                    notifToday[i],
                    time: _timeForIndex(i),
                    unread: i < 2,
                  ),
                const SizedBox(height: 20),
                const Text('Earlier',
                    style:
                        NoorType.cardTitle),
                const SizedBox(height: 12),
                for (var i = 0; i < SampleData.notifEarlier.length; i++)
                  _row(
                    SampleData.notifEarlier[i],
                    time: _earlierTimeForIndex(i),
                  ),
              ])),
        ])),
      );
  }

  static String _timeForIndex(int i) {
    const times = [
      '5:21 AM',
      '6:00 AM',
      '7:15 AM',
      '8:00 AM',
      '12:00 PM',
      '4:00 PM',
      '6:30 PM',
    ];
    return i < times.length ? times[i] : 'Today';
  }

  static String _earlierTimeForIndex(int i) {
    const times = ['Yesterday', 'Yesterday', '2 days ago', '3 days ago'];
    return i < times.length ? times[i] : 'Earlier';
  }

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
      'Fajr reminder' ||
      'Dhuhr reminder' ||
      'Asr reminder' ||
      'Maghrib reminder' ||
      'Isha reminder' =>
        Icons.alarm_outlined,
      'Ayat of the Day' => Icons.auto_stories_outlined,
      'Daily Zikr' || 'Daily Zikr & Tasbih' => Icons.fingerprint_rounded,
      'Daily Dua' || 'Dua of the Day' => Icons.pan_tool_outlined,
      'Quran' => Icons.menu_book_outlined,
      'Hifz plan' => Icons.school_outlined,
      'Hadith' || 'Hadith of the Day' => Icons.bookmark_border_outlined,
      'Quote of the Day' => Icons.format_quote_rounded,
      _ => Icons.lightbulb_outline,
    };
