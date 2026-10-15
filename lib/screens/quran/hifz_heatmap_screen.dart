import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'hifz_revision_planner_screen.dart';

/// Page 30 — Hifz Progress / Weak-Page Heatmap. Juz 1 page
/// strength grid (30 pages): deep emerald = strong, sage = medium,
/// amber = needs review, rust = weak — colours read off the PNG.
/// Tapping a page selects it and updates the insight card.
class HifzHeatmapScreen extends StatefulWidget {
  const HifzHeatmapScreen({super.key});
  @override
  State<HifzHeatmapScreen> createState() => _HifzHeatmapScreenState();
}

class _HifzHeatmapScreenState extends State<HifzHeatmapScreen> {
  int _selected = 0; // 0 = nothing tapped yet (design shows no outline)
  // 0 strong, 1 medium, 2 review, 3 weak — pattern as drawn.
  // Page 5 is WEAK (3): the insight card has always said it caused
  // errors in 3 recent tests — the tile now agrees with the text
  // (Phase 12 data-honesty fix; it previously coloured it strong).
  static const _pattern = [
    0,
    3,
    2,
    1,
    3,
    3,
    2,
    1,
    0,
    3,
    2,
    1,
    0,
    3,
    2,
    1,
    0,
    3,
    2,
    1,
    0,
    3,
    2,
    1,
    0,
    3,
    2,
    1,
    0,
    3
  ];
  static const _legend = ['Strong', 'Medium', 'Review', 'Weak'];
  static const _colors = [
    NoorColors.emeraldDark,
    NoorColors.heatMid,
    NoorColors.gold,
    NoorColors.heatWeak
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          _noorHeader(context),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                const Text('Juz 1 • Page Strength',
                    style:
                        NoorType.section),
                const SizedBox(height: 10),
                // Legend (Phase 12): strength was colour-only with no key.
                Wrap(spacing: 12, runSpacing: 6, children: [
                  for (var k = 0; k < 4; k++)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                              color: _colors[k],
                              borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 5),
                      Text(_legend[k], style: NoorType.meta),
                    ]),
                ]),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  itemCount: 30,
                  itemBuilder: (_, i) => Semantics(
                    button: true,
                    selected: _selected == i + 1,
                    label: 'Page ${i + 1}, ${_legend[_pattern[i]]}',
                    child: Material(
                      color: _colors[_pattern[i]],
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setState(() => _selected = i + 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: _selected > 0 && _selected == i + 1
                                    ? Border.all(
                                        color: NoorColors.ink, width: 2)
                                    : null),
                            child: Text('${i + 1}',
                                style: NoorType.secondary.copyWith(color: _pattern[i] == 0
                                        ? Colors.white
                                        : NoorColors.ink))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: NoorColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(NoorRadius.card)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weak-page insight',
                              style: NoorType.secondary.copyWith(color: NoorColors.goldDeep)),
                          const SizedBox(height: 8),
                          Text(
                              _selected == 0 || _selected == 5
                                  ? SampleData.heatmapInsight
                                  : 'Page $_selected is in your revision queue.',
                              style:
                                  NoorType.secondary.copyWith(height: 1.45)),
                          const SizedBox(height: 8),
                          Text(
                              'Review Page ${_selected == 0 ? 5 : _selected} ›',
                              style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
                        ])),
              ])),
        ])),
      );
}

/// Emerald sub-page header as drawn on this page of the design.
///
/// Phase 16 audit: the ⋮ explains the heatmap honestly and links
/// the revision planner — both real.
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
          Text('Hifz Progress',
              textAlign: TextAlign.center,
              style: NoorType.screenTitle.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text(SampleData.hifzRangeSurah,
              style: NoorType.meta.copyWith(color: Colors.white70)),
        ])),
        IconButton(
            tooltip: 'Heatmap options',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => showNoorOverflowSheet(context,
                title: 'Page strength',
                info: const [
                  'Deep emerald = strong, sage = medium, amber = needs review, rust = weak.',
                  'Tap any page to see its insight. Strengths update as you log revision.',
                ],
                actions: [
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
