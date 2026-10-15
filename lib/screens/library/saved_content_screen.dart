import 'package:flutter/material.dart';
import '../../data/noor_store.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/noor_share_card.dart';

class _SavedItemEntry {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final bool isSample;

  const _SavedItemEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    this.isSample = false,
  });
}

/// Page 33 — Bookmarks, Notes & Saved Content ("Saved & Notes").
/// Dynamically connects to [NoorStore] for offline-first bookmarks,
/// with filter chips, un-bookmarking, and dark-mode support.
class SavedContentScreen extends StatefulWidget {
  const SavedContentScreen({super.key});

  @override
  State<SavedContentScreen> createState() => _SavedContentScreenState();
}

class _SavedContentScreenState extends State<SavedContentScreen> {
  int _filter = 0;
  bool _isLoading = true;
  List<_SavedItemEntry> _items = [];

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  Future<void> _loadSavedItems() async {
    final stored = await NoorStore.getSavedItems();
    final List<_SavedItemEntry> result = [];

    // User-saved bookmarks first
    for (final m in stored) {
      result.add(_SavedItemEntry(
        id: m['id']?.toString() ?? '',
        title: m['title']?.toString() ?? '',
        subtitle: m['subtitle']?.toString() ?? '',
        tag: m['tag']?.toString() ?? 'Saved',
        isSample: false,
      ));
    }

    // Default sample entries to give starter inspiration if not already added
    for (var i = 0; i < SampleData.savedRows.length; i++) {
      final sample = SampleData.savedRows[i];
      if (!result.any((item) => item.title == sample.$1)) {
        result.add(_SavedItemEntry(
          id: 'sample_$i',
          title: sample.$1,
          subtitle: sample.$2,
          tag: sample.$3,
          isSample: true,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _items = result;
        _isLoading = false;
      });
    }
  }

  bool _matches(String tag) {
    final f = SampleData.savedFilters[_filter];
    if (f == 'All') return true;
    if (f == 'Quran') return tag.contains('Ayah') || tag.contains('Quran');
    if (f == 'Hadith') return tag == 'Hadith';
    if (f == 'Duas') return tag.contains('Dua');
    return tag == 'AI Note' || tag.contains('Note');
  }

  Future<void> _removeItem(_SavedItemEntry item) async {
    setState(() {
      _items.removeWhere((x) => x.id == item.id);
    });
    if (!item.isSample) {
      await NoorStore.removeRichItem(item.id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed "${item.title}"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredRows = _items.where((r) => _matches(r.tag)).toList();

    return Scaffold(
      backgroundColor: isDark ? NoorColors.darkBg : NoorColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const NoorPlainHeader(
              title: 'Saved & Notes',
              moreInfo: [
                'Bookmarks you save across NOOR — ayahs, hadiths, duas — collect here.',
                'Everything is kept on this device only.',
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                color: NoorColors.emeraldDark,
                onRefresh: _loadSavedItems,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < SampleData.savedFilters.length; i++) ...[
                            Semantics(
                              button: true,
                              label: SampleData.savedFilters[i],
                              child: Material(
                                color: i == _filter
                                    ? (isDark ? NoorColors.darkGold : NoorColors.emeraldDark)
                                    : (isDark ? NoorColors.darkCard : NoorColors.emeraldSoft),
                                borderRadius: BorderRadius.circular(99),
                                child: InkWell(
                                  onTap: () => setState(() => _filter = i),
                                  borderRadius: BorderRadius.circular(99),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: i == _filter
                                          ? (isDark ? NoorColors.darkGold : NoorColors.emeraldDark)
                                          : (isDark ? NoorColors.darkCard : NoorColors.emeraldSoft),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      SampleData.savedFilters[i],
                                      style: NoorType.meta.copyWith(
                                        color: i == _filter
                                            ? Colors.white
                                            : (isDark ? NoorColors.darkTextPrimary : NoorColors.ink),
                                        fontWeight: i == _filter ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: NoorColors.emeraldDark),
                        ),
                      )
                    else if (filteredRows.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(28),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? NoorColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(NoorRadius.card),
                          border: Border.all(
                            color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.bookmark_border, size: 40, color: isDark ? NoorColors.darkTextSecondary : NoorColors.muted),
                            const SizedBox(height: 8),
                            Text(
                              'Nothing saved here yet.',
                              style: NoorType.body.copyWith(
                                color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (final r in filteredRows) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? NoorColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(NoorRadius.card),
                            border: Border.all(
                              color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                            ),
                            boxShadow: isDark ? null : NoorShadows.card,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NoorListRow(
                                  title: r.title,
                                  subtitle: r.subtitle,
                                  semanticLabel: '${r.title}. ${r.subtitle}',
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? NoorColors.darkSurface : NoorColors.emeraldSoft,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      r.tag,
                                      style: NoorType.meta.copyWith(
                                        color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.bookmark_remove_outlined,
                                  size: 20,
                                  color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark,
                                ),
                                tooltip: 'Remove bookmark',
                                onPressed: () => _removeItem(r),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    if (filteredRows.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'End of saved items · ${filteredRows.length} shown',
                          style: NoorType.meta.copyWith(
                            color: isDark ? NoorColors.darkTextSecondary : NoorColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
