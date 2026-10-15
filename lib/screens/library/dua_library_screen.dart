import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../worship/zikr_tasbih_screen.dart';

/// Page 18 — Dua & Adhkar Library. Daily Adhkar progress card,
/// search, All/Morning/Evening/Situations chips and numbered
/// category rows. Category names/counts only — full dua text is
/// loaded from the authenticated source at runtime.
class DuaLibraryScreen extends StatefulWidget {
  const DuaLibraryScreen({super.key});
  @override
  State<DuaLibraryScreen> createState() => _DuaLibraryScreenState();
}

class _DuaLibraryScreenState extends State<DuaLibraryScreen> {
  int _chip = 0;
  String _q = '';
  static const _chips = ['All', 'Morning', 'Evening', 'Situations'];
  @override
  Widget build(BuildContext context) {
    final rows = SampleData.duaCategories
        .where((c) =>
            (_chip == 0 || c.$3 == _chips[_chip]) &&
            c.$1.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          _noorHeader(context,
              chips: _chips,
              onPickCategory: (i) => setState(() => _chip = i)),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldSoft,
                        borderRadius: BorderRadius.circular(NoorRadius.card)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Adhkar',
                              textScaler: const TextScaler.linear(1.0),
                              style: NoorType.section.copyWith(color: NoorColors.emeraldDark)),
                          const SizedBox(height: 6),
                          Text('Morning set • 8 of 15 completed',
                              textScaler: const TextScaler.linear(1.0),
                              style: NoorType.meta.copyWith(color: NoorColors.muted)),
                          const SizedBox(height: 12),
                          const ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(99)),
                              child: LinearProgressIndicator(
                                  value: 8 / 15,
                                  minHeight: 7,
                                  backgroundColor: Colors.white,
                                  color: NoorColors.emeraldDark)),
                        ])),
                const SizedBox(height: 14),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NoorColors.hairline)),
                    child: TextField(
                        onChanged: (v) => setState(() => _q = v),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search...',
                            hintStyle: NoorType.secondary.copyWith(color: NoorColors.muted),
                            suffixIcon: const Icon(Icons.search,
                                size: 19, color: NoorColors.emeraldDark)))),
                const SizedBox(height: 14),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (var i = 0; i < _chips.length; i++) ...[
                        Semantics(button: true, child: GestureDetector(
                            onTap: () => setState(() => _chip = i),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                    color: _chip == i
                                        ? NoorColors.emeraldDark
                                        : NoorColors.emeraldSoft,
                                    borderRadius: BorderRadius.circular(99)),
                                child: Text(_chips[i],
                                    style: NoorType.meta.copyWith(color: _chip == i
                                            ? Colors.white
                                            : NoorColors.ink))))),
                        const SizedBox(width: 8),
                      ]
                    ])),
                const SizedBox(height: 14),
                for (var i = 0; i < rows.length; i++) ...[
                  Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ZikrTasbihScreen())),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: NoorColors.hairline)),
                              child: Row(children: [
                                Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                        color: NoorColors.emeraldSoft,
                                        shape: BoxShape.circle),
                                    child: Text('${i + 1}',
                                        style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark))),
                                const SizedBox(width: 13),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(rows[i].$1,
                                          textScaler: const TextScaler.linear(1.0),
                                          style: NoorType.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 3),
                                      Text(rows[i].$2,
                                          textScaler: const TextScaler.linear(1.0),
                                          style: NoorType.meta.copyWith(color: NoorColors.muted),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)
                                    ])),
                                const Icon(Icons.chevron_right,
                                    size: 19, color: NoorColors.muted),
                              ])))),
                  const SizedBox(height: 10),
                ],
                if (rows.isEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                          child: Text('No categories match your search.',
                              style: NoorType.secondary.copyWith(color: NoorColors.muted)))),
              ])),
        ])));
  }
}

/// Emerald sub-page header as drawn on this page of the design.
///
/// Phase 16 audit: the ⋮ jumps to the real category filters.
Widget _noorHeader(BuildContext context,
        {required void Function(int) onPickCategory,
        required List<String> chips}) =>
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
          Text('Dua & Adhkar Library',
              textScaler: const TextScaler.linear(1.0),
              textAlign: TextAlign.center,
              style: NoorType.screenTitle.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text('Authentic duas & daily adhkar',
              textScaler: const TextScaler.linear(1.0),
              style: NoorType.meta.copyWith(color: Colors.white70)),
        ])),
        IconButton(
            tooltip: 'Jump to category',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => showNoorOverflowSheet(context,
                title: 'Dua categories',
                actions: [
                  for (var i = 0; i < chips.length; i++)
                    (
                      Icons.label_outline,
                      chips[i],
                      () => onPickCategory(i)
                    ),
                ])),
      ]),
    );
