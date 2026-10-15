import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/noor_share_card.dart';

/// Page 33 — Bookmarks, Notes & Saved Content ("Saved & Notes").
/// Filter chips (All selected as drawn) with a working filter,
/// saved cards with title / brief note / tag on the right.
class SavedContentScreen extends StatefulWidget {
  const SavedContentScreen({super.key});
  @override
  State<SavedContentScreen> createState() => _SavedContentScreenState();
}

class _SavedContentScreenState extends State<SavedContentScreen> {
  int _filter = 0;
  bool _matches(String tag) {
    final f = SampleData.savedFilters[_filter];
    if (f == 'All') return true;
    if (f == 'Quran') return tag.contains('Ayah') || tag.contains('Quran');
    if (f == 'Hadith') return tag == 'Hadith';
    if (f == 'Duas') return tag == 'Dua';
    return tag == 'AI Note';
  }

  @override
  Widget build(BuildContext context) {
    final rows = SampleData.savedRows.where((r) => _matches(r.$3)).toList();
    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
          child: Column(children: [
        const NoorPlainHeader(
          title: 'Saved & Notes',
          moreInfo: [
            'Bookmarks you save across NOOR — ayahs, hadiths, duas — collect here.',
            'Everything is kept on this device only.',
          ],
        ),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (var i = 0;
                        i < SampleData.savedFilters.length;
                        i++) ...[
                      Semantics(
                          button: true,
                          label: SampleData.savedFilters[i],
                          child: Material(
                              color: i == _filter
                                  ? NoorColors.emeraldDark
                                  : NoorColors.emeraldSoft,
                              borderRadius: BorderRadius.circular(99),
                              child: InkWell(
                                  onTap: () => setState(() => _filter = i),
                                  borderRadius: BorderRadius.circular(99),
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                          color: i == _filter
                                              ? NoorColors.emeraldDark
                                              : NoorColors.emeraldSoft,
                                          borderRadius:
                                              BorderRadius.circular(99)),
                                      child: Text(SampleData.savedFilters[i],
                                          style: NoorType.meta.copyWith(color: i == _filter
                                                  ? Colors.white
                                                  : NoorColors.ink)))))),
                      const SizedBox(width: 6),
                    ],
                  ])),
              const SizedBox(height: 18),
              if (rows.isEmpty)
                const Text('Nothing saved here yet.',
                    style: TextStyle(color: NoorColors.muted)),
              for (final r in rows) ...[
                Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(NoorRadius.card),
                        border: Border.all(color: NoorColors.hairline)),
                    child: NoorListRow(
                        title: r.$1,
                        subtitle: r.$2,
                        semanticLabel: '${r.$1}. ${r.$2}',
                        trailing: Text(r.$3,
                            style: NoorType.meta
                                .copyWith(color: NoorColors.emeraldDark)))),
                const SizedBox(height: 12),
              ],
              if (rows.isNotEmpty)
                Center(
                    child: Text('End of saved items · ${rows.length} shown',
                        style: NoorType.meta)),
            ])),
      ])),
    );
  }
}
