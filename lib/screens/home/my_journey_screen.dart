import 'package:flutter/material.dart';
import '../../data/noor_controller.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../library/share_card_studio_screen.dart';
import '../worship/salah_tracker_screen.dart';
import '../worship/zikr_tasbih_screen.dart';
import '../quran/quran_home_screen.dart';

class MyJourneyScreen extends StatelessWidget {
  const MyJourneyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final progress = NoorScope.of(context)?.streaks ?? const <String, int>{};
    return Scaffold(
      appBar: AppBar(title: const Text('My Journey')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('Small steps, steady growth', style: NoorType.screenTitle),
        const SizedBox(height: 12),
        const Text(
            'Your progress comes from prayers you mark complete, Quran you read, and dhikr you record. Complete all five prayers for a Salah day; reading and dhikr count as practice days.',
            style: NoorType.body),
        const SizedBox(height: 24),
        for (final kind in ['Salah', 'Quran', 'Dhikr']) ...[
          NoorCard(
              child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(kind, style: NoorType.cardTitle),
            subtitle: Text('${progress[kind] ?? 0} day streak',
                style: NoorType.secondary),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => switch (kind) {
                      'Salah' => const SalahTrackerScreen(),
                      'Quran' => const QuranHomeScreen(),
                      _ => const ZikrTasbihScreen(),
                    })),
          )),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 12),
        const Text(
            'Progress is private. You can continue a streak today even when yesterday was your last practice day.',
            style: NoorType.secondary),
        const SizedBox(height: 24),
        OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ShareCardStudioScreen())),
            icon: const Icon(Icons.ios_share),
            label: const Text('Create a share card')),
      ]),
    );
  }
}
