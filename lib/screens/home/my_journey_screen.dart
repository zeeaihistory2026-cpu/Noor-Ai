import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/noor_share_card.dart';
import '../library/share_card_studio_screen.dart';
import '../worship/reminder_center_screen.dart';

/// Page 32 — My Journey / Streak Analytics. Emerald header,
/// "This Week / Strong consistency" emerald hero, Salah 93% /
/// Quran 71% / Dhikr 100% / Learning 60% progress bars with
/// counts, pale AI Insight card. Private progress — no leaderboard.
class MyJourneyScreen extends StatelessWidget {
  const MyJourneyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          NoorPlainHeader(title: 'My Journey', moreActions: [
            (
              Icons.ios_share,
              'Share milestone',
              () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ShareCardStudioScreen()))
            ),
            (
              Icons.alarm_outlined,
              'Prayer reminders',
              () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ReminderCenterScreen()))
            ),
          ]),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldDark,
                        borderRadius:
                            BorderRadius.circular(NoorRadius.heroCard),
                        boxShadow: NoorShadows.hero),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This Week',
                              style: NoorType.secondary.copyWith(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text('Strong consistency',
                              style: NoorType.screenTitle.copyWith(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text('Keep building small, private habits.',
                              style: NoorType.secondary.copyWith(color: Colors.white70)),
                        ])),
                const SizedBox(height: 22),
                for (final r in SampleData.journeyRows) ...[
                  NoorProgressRow(label: r.$1, percent: r.$2, detail: r.$3),
                  const SizedBox(height: 18),
                ],
                Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldSoft,
                        borderRadius: BorderRadius.circular(NoorRadius.card)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Insight (sample)',
                              style: NoorType.body.copyWith(color: NoorColors.emeraldDark)),
                          const SizedBox(height: 7),
                          Text(SampleData.journeyInsight,
                              style: NoorType.secondary.copyWith(height: 1.55)),
                        ])),
                const SizedBox(height: 14),
                Row(children: [
                  const Icon(Icons.lock_outline, size: 15, color: NoorColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(
                          'Private progress only — worship is never turned into a leaderboard or competition.',
                          style: NoorType.meta.copyWith(color: NoorColors.muted)))
                ]),
              ])),
        ])),
      );
}
