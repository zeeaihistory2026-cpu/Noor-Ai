import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'ai_chat_screen.dart';

/// Page 25 — Compare Madhhab Opinions. Descriptive compare only:
/// one-line recognized-position summaries as drawn, brief attributed
/// references available via View evidence — no original rulings.
class MadhhabCompareScreen extends StatelessWidget {
  const MadhhabCompareScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          Container(
            color: NoorColors.emeraldDark,
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 19),
                  onPressed: () => Navigator.of(context).maybePop()),
              Expanded(
                  child: Column(children: [
                Text('AI Companion',
                    style: NoorType.screenTitle.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text('Islamic Q&A · Sample answers (offline)',
                    style: NoorType.meta.copyWith(color: Colors.white70)),
              ])),
              IconButton(
                  tooltip: 'Compare options',
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  // Phase 16 audit: copies the on-screen comparison
                  // text verbatim; "Ask AI" opens the real chat.
                  onPressed: () => showNoorOverflowSheet(context,
                      title: 'Madhhab compare',
                      info: const [
                        'Descriptive summaries of recognized positions only — not rulings. For personal rulings, consult a scholar.',
                      ],
                      actions: [
                        (
                          Icons.copy_outlined,
                          'Copy comparison',
                          () async {
                            final text = StringBuffer(
                                '${SampleData.madhhabQuestion}\n');
                            for (final r in SampleData.madhhabRows) {
                              text.writeln('\n${r.$1}: ${r.$3}');
                            }
                            await Clipboard.setData(
                                ClipboardData(text: text.toString()));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Comparison copied')));
                            }
                          }
                        ),
                        (
                          Icons.chat_outlined,
                          'Ask AI about this',
                          () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const AiChatScreen()))
                        ),
                      ])),
            ]),
          ),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldSoft,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Text(SampleData.madhhabQuestion,
                        style: NoorType.cardTitle)),
                const SizedBox(height: 16),
                for (final r in SampleData.madhhabRows) ...[
                  Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(NoorRadius.card),
                          border: Border.all(color: NoorColors.hairline)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Text(r.$1,
                                      style: NoorType.cardTitle.copyWith(color: NoorColors.emeraldDark))),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: NoorColors.emeraldSoft,
                                      borderRadius: BorderRadius.circular(999)),
                                  child: Text(r.$2,
                                      style: NoorType.meta.copyWith(color: NoorColors.emeraldDark)))
                            ]),
                            const SizedBox(height: 10),
                            Text(r.$3,
                                style: NoorType.body),
                            const SizedBox(height: 14),
                            Text('View evidence ›',
                                style: NoorType.secondary.copyWith(color: NoorColors.emerald)),
                          ])),
                  const SizedBox(height: 12),
                ],
                Text(
                    'Recognized differences are shown descriptively. For personal rulings, please consult a qualified scholar.',
                    style: NoorType.meta.copyWith(color: NoorColors.mutedDark,
                        height: 1.5)),
              ])),
        ])),
      );
}
