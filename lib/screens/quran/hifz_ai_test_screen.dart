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
        backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
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
                        color: NoorTheme.surface(context, light: NoorColors.emeraldSoft),
                        borderRadius: BorderRadius.circular(NoorRadius.card)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Test range',
                              style: NoorType.secondary
                                  .copyWith(color: null)),
                          const SizedBox(height: 8),
                          const Text(SampleData.hifzRange,
                              style: NoorType.screenTitle),
                          const SizedBox(height: 5),
                          Text(
                              'Self-check: recite aloud, then mark each Ayah yourself. Recitation analysis is not connected.',
                              style: NoorType.meta.copyWith(
                                  color: null, height: 1.45)),
                        ])),
                const SizedBox(height: 26),
                const Center(
                    child: Text('Begin from this cue:', style: NoorType.body)),
                const SizedBox(height: 16),
                Center(
                    child: Text(SampleData.hifzCueArabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: NoorType.arabic(
                            size: 27, color: NoorTheme.accent(context)))),
                const SizedBox(height: 26),
                Center(
                    child: Semantics(
                        button: true,
                        label: _listening
                            ? 'Practising recitation, tap to finish'
                            : 'Recite, tap to begin self-practice',
                        child: Material(
                          color: NoorColors.emeraldDark,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () =>
                                setState(() => _listening = !_listening),
                            child: SizedBox(
                                width: 236,
                                height: 236,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          _listening ? 'PRACTISING' : 'RECITE',
                                          style: NoorType.screenTitle.copyWith(
                                              color: Colors.white,
                                              letterSpacing: 1.2)),
                                      const SizedBox(height: 12),
                                      Text(
                                          _listening
                                              ? 'Tap to finish'
                                              : 'Tap to begin self-practice',
                                          style: NoorType.meta.copyWith(
                                              color: Colors.white70)),
                                    ])),
                          ),
                        ))),
                if (_listening) ...[
                  const SizedBox(height: 18),
                  FilledButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const HifzTestResultsScreen())),
                      child: const Text('View Example Results')),
                ],
                const SizedBox(height: 22),
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: NoorTheme.surface(context, light: NoorColors.surfaceWarm),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NoorTheme.border(context))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Privacy', style: NoorType.secondary),
                          const SizedBox(height: 5),
                          Text('This self-practice screen does not record audio. AI recitation analysis is not connected.',
                              style: NoorType.meta.copyWith(color: NoorTheme.muted(context))),
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
        IconButton(tooltip: 'Back', 
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