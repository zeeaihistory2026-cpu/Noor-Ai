import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'hifz_heatmap_screen.dart';

/// Page 29 — Hifz Revision Planner. Today's Hifz Plan with New
/// lesson / Recent revision / Old revision progress cards and an
/// AI Scheduling note. Tapping a card toggles its done state.
class HifzRevisionPlannerScreen extends StatefulWidget {
  const HifzRevisionPlannerScreen({super.key});
  @override
  State<HifzRevisionPlannerScreen> createState() =>
      _HifzRevisionPlannerScreenState();
}

class _HifzRevisionPlannerScreenState extends State<HifzRevisionPlannerScreen> {
  final _done = <int>{};
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
        body: SafeArea(
            child: Column(children: [
          _noorHeader(context,
              onMarkAll: () => setState(() => _done.addAll(
                  List.generate(SampleData.revisionRows.length, (i) => i))),
              onClear: () => setState(() => _done.clear())),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                const Text("Today's Hifz Plan", style: NoorType.screenTitle),
                const SizedBox(height: 14),
                for (var i = 0; i < SampleData.revisionRows.length; i++) ...[
                  Semantics(
                      button: true,
                      checked: _done.contains(i),
                      label:
                          '${SampleData.revisionRows[i].$1}, ${SampleData.revisionRows[i].$2}',
                      child: Material(
                          color: NoorTheme.surface(context),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                        onTap: () => setState(() =>
                            _done.contains(i) ? _done.remove(i) : _done.add(i)),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: NoorTheme.border(context))),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                        child: Text(
                                            SampleData.revisionRows[i].$1,
                                            style: NoorType.body)),
                                    Text('${SampleData.revisionRows[i].$3} min',
                                        style: NoorType.meta),
                                    if (_done.contains(i)) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.check_circle,
                                          size: 18, color: NoorTheme.accent(context))
                                    ],
                                  ]),
                                  const SizedBox(height: 7),
                                  Text(SampleData.revisionRows[i].$2,
                                      style: NoorType.meta.copyWith(color: NoorTheme.muted(context))),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: LinearProgressIndicator(
                                          value: _done.contains(i)
                                              ? 1
                                              : SampleData.revisionRows[i].$4,
                                          minHeight: 8,
                                          backgroundColor: NoorTheme.softSurface(context),
                                          color: NoorTheme.accent(context))),
                                  const SizedBox(height: 6),
                                  Text(
                                      _done.contains(i)
                                          ? '100% · Done'
                                          : '${(SampleData.revisionRows[i].$4 * 100).round()}% planned',
                                      style: NoorType.meta),
                                ])),
                      ))),
                  const SizedBox(height: 12),
                ],
                Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: NoorTheme.softSurface(context),
                        borderRadius: BorderRadius.circular(NoorRadius.card)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scheduling note (sample)',
                              style: NoorType.secondary.copyWith(
                                  color: NoorTheme.accent(context))),
                          const SizedBox(height: 8),
                          Text(
                              'Based on your history, morning revision has the highest accuracy.',
                              style: NoorType.secondary.copyWith(height: 1.45)),
                        ])),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const HifzHeatmapScreen())),
                    child: const Text('View Page Strength')),
              ])),
        ])),
      );
}

/// Emerald sub-page header as drawn on this page of the design.
///
/// Phase 16 audit: the ⋮ runs real bulk actions on today's plan.
Widget _noorHeader(BuildContext context,
        {required VoidCallback onMarkAll, required VoidCallback onClear}) =>
    Container(
      color: NoorColors.emeraldDark,
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
      child: Row(children: [
        IconButton(tooltip: 'Back', 
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 19),
            onPressed: () => Navigator.of(context).maybePop()),
        Expanded(
            child: Column(children: [
          Text('Revision Planner',
              textAlign: TextAlign.center,
              style: NoorType.screenTitle.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text(SampleData.hifzRangeSurah,
              style: NoorType.meta.copyWith(color: Colors.white70)),
        ])),
        IconButton(
            tooltip: 'Plan options',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            // Phase 16 audit: real bulk actions on today's plan.
            onPressed: () =>
                showNoorOverflowSheet(context, title: "Today's plan", actions: [
                  (Icons.done_all_outlined, 'Mark all done', onMarkAll),
                  (Icons.restart_alt_outlined, 'Clear all', onClear),
                ])),
      ]),
    );