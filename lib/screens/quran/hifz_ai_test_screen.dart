import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'hifz_test_results_screen.dart';

/// Page 27 — Hifz AI Test. Emerald header, Test range card, brief
/// cue fragment, large RECITE circle. Tap toggles Listening UI
/// state only — TODO live: microphone + speech recognition +
/// word-tracking in the live phase; audio is never claimed to be
/// analysed yet.
class HifzAiTestScreen extends StatefulWidget {
  const HifzAiTestScreen({super.key});
  @override
  State<HifzAiTestScreen> createState() => _HifzAiTestScreenState();
}

class _HifzAiTestScreenState extends State<HifzAiTestScreen> {
  bool _listening = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          _noorHeader(context,
              onReset: () => setState(() => _listening = false)),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldSoft,
                        borderRadius: BorderRadius.circular(NoorRadius.card)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Test range',
                              style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
                          const SizedBox(height: 8),
                          const Text(SampleData.hifzRange,
                              style: NoorType.screenTitle),
                          const SizedBox(height: 5),
                          Text(
                              'Self-check: recite aloud, then mark each Ayah yourself. Recitation analysis is not connected.',
                              style: NoorType.meta.copyWith(color: NoorColors.mutedDark,
                                  height: 1.45)),
                        ])),
                const SizedBox(height: 26),
                const Center(
                    child: Text('Begin from this cue:',
                        style: NoorType.body)),
                const SizedBox(height: 16),
                Center(
                    child: Text(SampleData.hifzCueArabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: NoorType.arabic(
                            size: 27, color: NoorColors.emeraldDark))),
                const SizedBox(height: 26),
                Center(
                    child: Semantics(button: true, child: GestureDetector(
                  onTap: () => setState(() => _listening = !_listening),
                  child: Container(
                      width: 236,
                      height: 236,
                      decoration: const BoxDecoration(
                          color: NoorColors.emeraldDark,
                          shape: BoxShape.circle,
                          boxShadow: NoorShadows.hero),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_listening ? 'LISTENING' : 'RECITE',
                                style: NoorType.screenTitle.copyWith(color: Colors.white,
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 12),
                            Text(
                                _listening
                                    ? 'Tap to finish'
                                    : 'Tap to start listening',
                                style: NoorType.meta.copyWith(color: Colors.white70)),
                          ])),
                ))),
                if (_listening) ...[
                  const SizedBox(height: 18),
                  FilledButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const HifzTestResultsScreen())),
                      child: const Text('Finish & See Results')),
                ],
                const SizedBox(height: 22),
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: NoorColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NoorColors.hairline)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Privacy',
                              style: NoorType.secondary),
                          const SizedBox(height: 5),
                          Text('Audio can be deleted after analysis.',
                              style: NoorType.meta.copyWith(color: NoorColors.muted)),
                        ])),
              ])),
        ])),
      );
}

/// Emerald sub-page header as drawn on this page of the design.
///
/// Phase 16 audit: the ⋮ opens real actions — [onReset] stops the
/// in-progress test UI; the info lines state the honest limits.
Widget _noorHeader(BuildContext context, {VoidCallback? onReset}) => Container(
      color: NoorColors.emeraldDark,
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
      child: Row(children: [
        IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 19),
            onPressed: () => Navigator.of(context).maybePop()),
        Expanded(
            child: Column(children: [
          Text('Hifz AI Test',
              textAlign: TextAlign.center,
              style: NoorType.screenTitle.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text(SampleData.hifzRangeSurah,
              style: NoorType.meta.copyWith(color: Colors.white70)),
        ])),
        IconButton(
            tooltip: 'Test options',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => showNoorOverflowSheet(context,
                title: 'Hifz AI Test',
                info: const [
                  'Recite the range aloud, then mark each ayah yourself. Recitation analysis is not connected yet.',
                ],
                actions: [
                  if (onReset != null)
                    (Icons.restart_alt_outlined, 'Restart test', onReset),
                ])),
      ]),
    );
