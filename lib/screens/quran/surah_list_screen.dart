import 'package:flutter/material.dart';
import '../../data/quran_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../library/saved_content_screen.dart';
import 'quran_audio_player_screen.dart';
import 'quran_reader_screen.dart';

/// Page 02 — Surah List. Dark emerald header (back, "Quran", search,
/// filter, pill tabs), Continue Reading card, Order/Translation
/// filter row, then numbered surah rows with Arabic calligraphy
/// names, with the mini audio player pinned above the tab bar.
/// Only the first sample surahs are listed; the full 114 come from
/// the Qur'an data source in a later phase.
class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  int _tab = 0;
  String _query = '';
  bool _showSearch = false; // design: search lives behind the app-bar icon
  bool _grid = false;
  bool _ascending = true; // Phase 16 audit: tune icon sorts the list.

  // Null = design's sample list (offline-identical). Replaced in
  // place by the full live/cached list when QuranService returns.
  List<(int, String, String, int, int, String)>? _liveSurahs;
  bool _isLiveList = false;

  @override
  void initState() {
    super.initState();
    _loadLive();
  }

  /// Phase 6: full 114-surah index from AlQuran Cloud with
  /// persisted-cache then sample fallback (QuranService handles
  /// the chain). Layout unchanged — only the rows' data swaps.
  Future<void> _loadLive() async {
    try {
      final list = await QuranService().fetchSurahListOrFallback();
      if (!mounted || list.length <= SampleData.surahs.length) return;
      setState(() {
        _liveSurahs = list.map((s) => s.toSampleTuple()).toList();
        _isLiveList = true;
      });
    } catch (_) {
      // Sample rows already on screen — never break offline.
    }
  }

  /// Phase 16 (Job 7): the tapped surah number travels with the
  /// navigation — the reader opens THAT surah, not always 18.
  void _openReader(int surah) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)));
  void _openSaved() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const SavedContentScreen()));
  void _openPlayer() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const QuranAudioPlayerScreen()));

  @override
  Widget build(BuildContext context) {
    final surahs = (_liveSurahs ?? SampleData.surahs)
        .where((s) => s.$2.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) =>
          _ascending ? a.$1.compareTo(b.$1) : b.$1.compareTo(a.$1));
    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                NoorDarkHeader(
                  title: 'Quran',
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () =>
                            setState(() => _showSearch = !_showSearch)),
                    IconButton(
                        tooltip: 'Sort surahs',
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: () => showNoorOverflowSheet(context,
                            title: 'Sort Surahs',
                            actions: [
                              (
                                Icons.arrow_upward,
                                'Surah order: 1 → 114',
                                () => setState(() => _ascending = true)
                              ),
                              (
                                Icons.arrow_downward,
                                'Surah order: 114 → 1',
                                () => setState(() => _ascending = false)
                              ),
                            ])),
                  ],
                  child: NoorPillTabs(
                    tabs: const ['Surahs', 'Juz', 'Bookmarks', 'Notes'],
                    selected: _tab,
                    onSelect: (i) {
                      if (i >= 2) {
                        _openSaved();
                      } else {
                        setState(() => _tab = i);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(children: [
                    // Continue Reading (Surah Al-Kahf, Ayah 18, 76%).
                    NoorCard(
                      onTap: () => _openReader(18),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Continue Reading',
                                    style: NoorType.meta.copyWith(color: NoorColors.muted)),
                                const SizedBox(height: 6),
                                const Text(SampleData.continueSurah,
                                    style: NoorType.section),
                                const SizedBox(height: 3),
                                Text(SampleData.continueAyah,
                                    style: NoorType.secondary.copyWith(color: NoorColors.muted)),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: const LinearProgressIndicator(
                                          value: SampleData.continueProgress,
                                          minHeight: 6,
                                          color: NoorColors.emerald,
                                          backgroundColor: NoorColors.sand),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('76%',
                                      style: NoorType.meta.copyWith(color: NoorColors.muted)),
                                ]),
                              ]),
                        ),
                        const SizedBox(width: 14),
                        ClipOval(
                          child: Image.asset(NoorAssets.surahCalligraphy,
                              width: 64,
                              cacheWidth: 192,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 64,
                                  color: NoorColors.emeraldDark)),
                        ),
                      ]),
                    ),
                    if (_showSearch) ...[
                      const SizedBox(height: 16),
                      TextField(
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search a Surah...',
                          prefixIcon:
                              const Icon(Icons.search, color: NoorColors.muted),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(NoorRadius.card),
                            borderSide:
                                const BorderSide(color: NoorColors.hairline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(NoorRadius.card),
                            borderSide:
                                const BorderSide(color: NoorColors.emerald),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(children: [
                      _filterBox('Order', 'By Order'),
                      const SizedBox(width: 12),
                      _filterBox('Translation', 'English'),
                      const SizedBox(width: 12),
                      _viewToggle(Icons.view_list, 'List view', !_grid,
                          () => setState(() => _grid = false)),
                      const SizedBox(width: 10),
                      _viewToggle(Icons.grid_view, 'Grid view', _grid,
                          () => setState(() => _grid = true)),
                    ]),
                    const SizedBox(height: 14),
                    NoorCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        for (var i = 0; i < surahs.length; i++) ...[
                          if (i > 0)
                            const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: NoorColors.hairlineSoft),
                          _surahRow(surahs[i]),
                        ],
                        if (surahs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No Surah matches your search.',
                                style: TextStyle(color: NoorColors.muted)),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLiveList
                          ? 'Showing all 114 Surahs from the live '
                              'Qur\'an index.'
                          : 'Showing the first sample Surahs — the full '
                              '114 load from the live Qur\'an index when '
                              'you are online.',
                      textAlign: TextAlign.center,
                      style: NoorType.meta.copyWith(color: NoorColors.muted),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          _miniPlayer(),
        ]),
      ),
    );
  }

  Widget _viewToggle(
          IconData icon, String label, bool selected, VoidCallback onTap) =>
      Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: selected ? NoorColors.emeraldSoft : Colors.white,
          borderRadius: BorderRadius.circular(NoorRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NoorRadius.card),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NoorRadius.card),
                  border: Border.all(color: NoorColors.hairline)),
              child: Icon(icon,
                  color:
                      selected ? NoorColors.emeraldDark : NoorColors.mutedDark),
            ),
          ),
        ),
      );

  Widget _filterBox(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(NoorRadius.card),
              border: Border.all(color: NoorColors.hairline)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: NoorType.meta.copyWith(color: NoorColors.muted)),
            Row(children: [
              Expanded(
                  child: Text(value,
                      style: NoorType.secondary)),
              const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: NoorColors.muted),
            ]),
          ]),
        ),
      );

  Widget _surahRow((int, String, String, int, int, String) s) => InkWell(
        onTap: () => _openReader(s.$1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            // Emerald star-badge number, as drawn on Page 02.
            NoorRosetteBadge(s.$1, size: 34),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$2,
                        style: NoorType.body),
                    const SizedBox(height: 2),
                    Text(s.$3,
                        style: NoorType.meta.copyWith(color: NoorColors.muted)),
                    const SizedBox(height: 2),
                    Text(
                        s.$5 > 0
                            ? '${s.$4} Ayahs • Page ${s.$5}'
                            : '${s.$4} Ayahs',
                        style: NoorType.meta.copyWith(color: NoorColors.muted)),
                  ]),
            ),
            Text(s.$6,
                textDirection: TextDirection.rtl,
                style:
                    NoorType.arabic(size: 18, color: NoorColors.emeraldDark)),
            const Icon(Icons.more_vert, size: 19, color: NoorColors.muted),
          ]),
        ),
      );

  // Mini player strip pinned above the bottom nav (Page 02).
  Widget _miniPlayer() => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [NoorColors.emeraldDark, NoorColors.emeraldMid]),
          borderRadius: BorderRadius.circular(NoorRadius.heroCard),
          boxShadow: NoorShadows.hero,
        ),
        child: Row(children: [
          const CircleAvatar(
              backgroundColor: NoorColors.emeraldSoft,
              backgroundImage: AssetImage(NoorAssets.reciterAvatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Surah Al-Kahf',
                      style: NoorType.secondary.copyWith(color: Colors.white)),
                  Text('Mishary Rashid Alafasy',
                      style: NoorType.meta.copyWith(color: Colors.white70)),
                ]),
          ),
          IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: _openPlayer),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
                icon:
                    const Icon(Icons.play_arrow, color: NoorColors.emeraldDark),
                onPressed: _openPlayer),
          ),
          IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: _openPlayer),
          IconButton(
              icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              onPressed: _openPlayer),
        ]),
      );
}
