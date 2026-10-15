import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/knowledge_search.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'madhhab_compare_screen.dart';

/// Page 24 — AI Answer + Sources. Emerald header, dark user question
/// bubble, sand AI Explanation card with Sources chip refs (cited by
/// reference only), confidence line, then 4 outline option rows.
class AiAnswerSourcesScreen extends StatefulWidget {
  const AiAnswerSourcesScreen({
    super.key,
    this.question,
    this.results,
    this.summary,
    this.isLive = false,
  });

  /// Phase 14: when opened from a databank search, Page 24 lists
  /// the actual referenced results instead of the design sample.
  final String? question;
  final List<KnowledgeResult>? results;
  final String? summary;
  final bool isLive;
  @override
  State<AiAnswerSourcesScreen> createState() => _AiAnswerSourcesScreenState();
}

class _AiAnswerSourcesScreenState extends State<AiAnswerSourcesScreen> {
  bool _simple = false;
  bool _related = false;
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
                  tooltip: 'Source options',
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  // Phase 16 audit: copies the reference list — the
                  // same refs shown on screen, never invented.
                  onPressed: () => showNoorOverflowSheet(context,
                      title: 'Answer sources',
                      actions: [
                        (
                          Icons.copy_outlined,
                          'Copy references',
                          () async {
                            final refs = widget.results == null
                                ? SampleData.sourcesRefs
                                : widget.results!
                                    .map((r) =>
                                        '${r.reference} (${r.sourceLabel})')
                                    .join('\n');
                            await Clipboard.setData(
                                ClipboardData(text: refs));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('References copied')));
                            }
                          }
                        ),
                      ])),
            ]),
          ),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: const BoxDecoration(
                          color: NoorColors.emeraldDark,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(6),
                              bottomRight: Radius.circular(20))),
                      child: Text(widget.question ?? SampleData.sourcesQuestion,
                          style: NoorType.body
                              .copyWith(color: Colors.white, height: 1.4)),
                    )),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: NoorColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(NoorRadius.card),
                      border: Border.all(color: NoorColors.hairlineSoft)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Explanation',
                            style: NoorType.cardTitle
                                .copyWith(color: NoorColors.emeraldDark)),
                        const SizedBox(height: 10),
                        Text(widget.summary ?? SampleData.sourcesSummary,
                            style: NoorType.secondary.copyWith(height: 1.55)),
                        const SizedBox(height: 18),
                        const Text('Sources', style: NoorType.secondary),
                        const SizedBox(height: 8),
                        if (widget.results == null)
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                  color: NoorColors.emeraldSoft,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(SampleData.sourcesRefs,
                                  style: NoorType.secondary
                                      .copyWith(color: NoorColors.emeraldDark)))
                        else
                          for (final r in widget.results!) ...[
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                    color: NoorColors.emeraldSoft,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 9, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: NoorColors.emeraldDark,
                                                borderRadius:
                                                    BorderRadius.circular(999)),
                                            child: Text(r.reference,
                                                style: NoorType.meta.copyWith(
                                                    color: Colors.white))),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(r.sourceLabel,
                                                style: NoorType.meta.copyWith(
                                                    color:
                                                        NoorColors.mutedDark))),
                                      ]),
                                      const SizedBox(height: 8),
                                      Text(r.briefExcerpt,
                                          style: NoorType.secondary.copyWith(
                                              color: NoorColors.ink,
                                              height: 1.5)),
                                      const SizedBox(height: 6),
                                      Text(r.teaching,
                                          style: NoorType.meta
                                              .copyWith(height: 1.45)),
                                    ])),
                            const SizedBox(height: 8),
                          ],
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.verified_outlined,
                              size: 16, color: NoorColors.emerald),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(
                                  widget.results == null
                                      ? SampleData.sourcesConfidence
                                      : KnowledgeSearchService.scholarNote,
                                  style: NoorType.meta.copyWith(
                                      color: NoorColors.emerald, height: 1.4)))
                        ]),
                      ]),
                ),
                const SizedBox(height: 16),
                _row(context, 'Simple explanation',
                    () => setState(() => _simple = !_simple)),
                if (_simple)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                        'In short: patience is practised through prayer and trust in Allah, as the cited references describe. This is a sample explanation — please read the sources in context.',
                        style: NoorType.secondary),
                  ),
                _row(
                    context,
                    'Scholarly context',
                    () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MadhhabCompareScreen()))),
                _row(context, 'Related Quran & Hadith',
                    () => setState(() => _related = !_related)),
                if (_related)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                        widget.results == null
                            ? SampleData.sourcesRefs
                            : widget.results!
                                .map((r) => r.reference)
                                .join('  •  '),
                        style: NoorType.secondary),
                  ),
                _row(context, 'Ask a follow-up',
                    () => Navigator.of(context).maybePop()),
              ])),
        ])),
      );
  Widget _row(BuildContext c, String t, VoidCallback f) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
              onTap: f,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NoorColors.hairline)),
                  child: Row(children: [
                    Expanded(child: Text(t, style: NoorType.body)),
                    const Icon(Icons.chevron_right,
                        color: NoorColors.muted, size: 20)
                  ])))));
}
