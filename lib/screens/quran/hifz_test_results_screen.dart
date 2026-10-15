import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'hifz_ai_test_screen.dart';
import 'hifz_revision_planner_screen.dart';

/// Page 28 — Hifz Test Results. Memorization Accuracy 93% hero,
/// mistake rows with Review/Practice pills, AI suggestion card.
/// Memorization feedback only — no tajweed claims, as drawn.
class HifzTestResultsScreen extends StatelessWidget {
  const HifzTestResultsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          _noorHeader(context),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
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
                          Text('Memorization Accuracy',
                              style: NoorType.secondary.copyWith(color: Colors.white)),
                          const SizedBox(height: 10),
                          Text('${SampleData.hifzAccuracy}%',
                              style: NoorType.tabular(NoorType.display.copyWith(fontSize: 44, color: NoorColors.gold))),
                          const SizedBox(height: 6),
                          Text('Self-check estimate · 3 ayahs flagged below',
                              style: NoorType.meta.copyWith(color: Colors.white70)),
                        ])),
                const SizedBox(height: 16),
                for (final r in SampleData.hifzResultRows) ...[
                  Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    const HifzRevisionPlannerScreen())),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: NoorColors.hairline)),
                            child: Row(children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(r.$1,
                                        style: NoorType.body),
                                    const SizedBox(height: 4),
                                    Text(r.$2,
                                        style: NoorType.meta.copyWith(color: NoorColors.muted))
                                  ])),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: NoorColors.goldPale,
                                      borderRadius: BorderRadius.circular(99)),
                                  child: Text(r.$3,
                                      style: NoorType.meta.copyWith(color: NoorColors.goldDeep))),
                            ])),
                      )),
                  const SizedBox(height: 10),
                ],
                Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldSoft,
                        borderRadius: BorderRadius.circular(NoorRadius.card)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Study suggestion (sample)',
                              style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
                          const SizedBox(height: 8),
                          Text(SampleData.hifzSuggestion,
                              style: NoorType.secondary.copyWith(height: 1.45)),
                        ])),
                const SizedBox(height: 16),
                OutlinedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const HifzAiTestScreen())),
                    child: const Text('Retest Weak Range')),
              ])),
        ])),
      );
}

/// Emerald sub-page header as drawn on this page of the design.
///
/// Phase 16 audit: the ⋮ runs real actions — copy the summary,
/// retake the test, or open the revision planner.
Widget _noorHeader(BuildContext context) => Container(
      color: NoorColors.emeraldDark,
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
      child: Row(children: [
        IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 19),
            onPressed: () => Navigator.of(context).maybePop()),
        Expanded(
            child: Column(children: [
          Text('Hifz Test Results',
              textAlign: TextAlign.center,
              style: NoorType.screenTitle.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text(SampleData.hifzRangeSurah,
              style: NoorType.meta.copyWith(color: Colors.white70)),
        ])),
        IconButton(
            tooltip: 'Result options',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => showNoorOverflowSheet(context,
                title: 'Test results',
                info: const [
                  'Self-check estimate. Memorization feedback only — no tajweed scoring.',
                ],
                actions: [
                  (
                    Icons.copy_outlined,
                    'Copy summary',
                    () async {
                      await Clipboard.setData(const ClipboardData(
                          text:
                              'Hifz self-check: ${SampleData.hifzAccuracy}% accuracy on ${SampleData.hifzRangeSurah}. ${SampleData.hifzSuggestion}'));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Summary copied')));
                      }
                    }
                  ),
                  (
                    Icons.restart_alt_outlined,
                    'Retake test',
                    () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const HifzAiTestScreen()))
                  ),
                  (
                    Icons.calendar_month_outlined,
                    'Open revision planner',
                    () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            const HifzRevisionPlannerScreen()))
                  ),
                ])),
      ]),
    );
