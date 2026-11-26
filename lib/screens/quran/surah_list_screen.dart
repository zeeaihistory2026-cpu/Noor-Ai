import 'package:flutter/material.dart';
import '../../data/noor_store.dart';
import '../../data/offline_quran.dart';
import '../../data/quran_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/quran_resume_card.dart';
import '../library/saved_content_screen.dart';
import 'quran_audio_player_screen.dart';
import 'quran_reader_screen.dart';

/// Page 02 ? Surah List & Offline Quran Search.
class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  int _tab = 0;
  String _query = '';
  bool _showSearch = false;
  bool _grid = false;
  bool _ascending = true; // Phase 16 audit: tune icon sorts the list.
  int _languageMode = 1; // 0 Arabic, 1 English, 2 Urdu
  (int, int)? _readingPos;
  List<OfflineQuranMatch> _verseMatches = const [];
  bool _searchingVerses = false;
  int _searchSeq = 0;

  List<(int, String, String, int, int, String)>? _liveSurahs;
  bool _isLiveList = false;

  @override
  void initState() {
    super.initState();
    NoorStore.progressRevision.addListener(_refreshReadingPos);
    _loadLive();
    _refreshReadingPos();
    _loadLanguage();
  }

  @override
  void dispose() {
    NoorStore.progressRevision.removeListener(_refreshReadingPos);
    super.dispose();
  }

  Future<void> _loadLanguage() async {
    final lang = await NoorStore.getLanguage();
    if (!mounted) return;
    setState(() {
      _languageMode = switch (lang) {
        'Arabic' => 0,
        'Urdu' => 2,
        _ => 1,
      };
    });
  }

  Future<void> _refreshReadingPos() async {
    final pos = await NoorStore.getReadingPosition();
    if (!mounted) return;
    setState(() => _readingPos = pos);
  }

  Future<void> _loadLive() async {
    try {
      final list = await QuranService().fetchSurahListOrFallback();
      if (!mounted || list.length <= SampleData.surahs.length) return;
      setState(() {
        _liveSurahs = list.map((s) => s.toSampleTuple()).toList();
        _isLiveList = true;
      });
    } catch (_) {
      // Sample rows already on screen ? never break offline.
    }
  }

  void _onSearchChanged(String raw) {
    final q = raw.trim();
    final seq = ++_searchSeq;
    setState(() {
      _query = raw;
      if (q.length < 2) {
        _verseMatches = const [];
        _searchingVerses = false;
      } else {
        _searchingVerses = true;
      }
    });
    if (q.length < 2) return;
    final edition = _languageMode == 2 ? 'ur.jalandhry' : 'en.sahih';
    OfflineQuran.search(q, translationEdition: edition, limit: 15).then((res) {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _verseMatches = res;
        _searchingVerses = false;
      });
    });
  }

  void _openSortSheet() => showNoorOverflowSheet(context,
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
          ]);

  void _showTranslationSheet() {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: NoorTheme.surface(context),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (c) {
          const options = [
            'Arabic only',
            'English (Sahih)',
            'Urdu (Jalandhry)'
          ];
          const values = ['Arabic', 'English', 'Urdu'];
          return SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child:
                    Text('Translation Language', style: NoorType.cardTitle)),
            for (var i = 0; i < options.length; i++)
              ListTile(
                title: Text(options[i]),
                trailing: _languageMode == i
                    ? Icon(Icons.check, color: NoorTheme.accent(c))
                    : null,
                onTap: () {
                  setState(() => _languageMode = i);
                  NoorStore.setLanguage(values[i]);
                  Navigator.pop(c);
                  if (_query.trim().length >= 2) _onSearchChanged(_query);
                },
              ),
          ]));
        });
  }

  void _openReader(int surah, {int ayah = 1}) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => QuranReaderScreen(surah: surah, initialAyah: ayah)));
  void _openSaved() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const SavedContentScreen()));
  void _openPlayer([int? surah]) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          QuranAudioPlayerScreen(surah: surah ?? _readingPos?.$1 ?? 18)));

  (int, String, String, int, int, String) _surahMeta(int surahNum) {
    final all = _liveSurahs ?? SampleData.surahs;
    return all.firstWhere((s) => s.$1 == surahNum, orElse: () => all.first);
  }

  @override
  Widget build(BuildContext context) {
    final qLower = _query.trim().toLowerCase();
    final surahs = (_liveSurahs ?? SampleData.surahs)
        .where((s) =>
            qLower.isEmpty ||
            s.$2.toLowerCase().contains(qLower) ||
            s.$3.toLowerCase().contains(qLower) ||
            '${s.$1}' == qLower)
        .toList()
      ..sort(
          (a, b) => _ascending ? a.$1.compareTo(b.$1) : b.$1.compareTo(a.$1));
    final cols = MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 1 : 2;

    return Scaffold(
      backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
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
                        tooltip: 'Search Quran',
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () =>
                            setState(() => _showSearch = !_showSearch)),
                    IconButton(
                        tooltip: 'Sort surahs',
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: _openSortSheet),
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
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const QuranResumeCard(compact: true),
                        if (_showSearch) ...[
                          const SizedBox(height: 16),
                          TextField(
                            autofocus: true,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText:
                                  'Search Surah, Arabic, translation, or 2:255...',
                              prefixIcon: Icon(Icons.search,
                                  color: NoorTheme.muted(context)),
                              filled: true,
                              fillColor: NoorTheme.surface(context),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(NoorRadius.card),
                                borderSide: BorderSide(
                                    color: NoorTheme.border(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(NoorRadius.card),
                                borderSide: BorderSide(
                                    color: NoorTheme.accent(context)),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(children: [
                          _filterBox(
                              'Order',
                              _ascending ? '1 → 114' : '114 → 1',
                              _openSortSheet),
                          const SizedBox(width: 12),
                          _filterBox(
                              'Translation',
                              const ['Arabic', 'English', 'Urdu'][_languageMode],
                              _showTranslationSheet),
                          const SizedBox(width: 12),
                          _viewToggle(Icons.view_list, 'List view', !_grid,
                              () => setState(() => _grid = false)),
                          const SizedBox(width: 10),
                          _viewToggle(Icons.grid_view, 'Grid view', _grid,
                              () => setState(() => _grid = true)),
                        ]),
                        const SizedBox(height: 14),
                        if (_showSearch && _query.trim().length >= 2) ...[
                          Semantics(
                              header: true,
                              child: const Text('Matching Verses',
                                  style: NoorType.cardTitle)),
                          const SizedBox(height: 8),
                          if (_searchingVerses && _verseMatches.isEmpty)
                            const Padding(
                                padding: EdgeInsets.all(16),
                                child:
                                    Center(child: CircularProgressIndicator()))
                          else if (_verseMatches.isEmpty)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text('No matching verses found.',
                                    style: NoorType.meta.copyWith(
                                        color: NoorTheme.muted(context))))
                          else ...[
                            NoorCard(
                              padding: EdgeInsets.zero,
                              child: Column(children: [
                                for (var i = 0;
                                    i < _verseMatches.length;
                                    i++) ...[
                                  if (i > 0)
                                    Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: NoorTheme.border(context)),
                                  InkWell(
                                    onTap: () => _openReader(
                                        _verseMatches[i].surah,
                                        ayah: _verseMatches[i].ayah),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                                '${_verseMatches[i].surahName} • ${_verseMatches[i].reference}',
                                                style: NoorType.meta.copyWith(
                                                    color: NoorTheme.accent(
                                                        context),
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const SizedBox(height: 6),
                                            Text(
                                                _verseMatches[i].arabicText,
                                                textDirection:
                                                    TextDirection.rtl,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: NoorType.arabic(
                                                    size: 18,
                                                    color: NoorTheme.foreground(
                                                        context))),
                                            if (_verseMatches[i]
                                                .translationText
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                  _verseMatches[i]
                                                      .translationText,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textDirection:
                                                      _languageMode == 2
                                                          ? TextDirection.rtl
                                                          : TextDirection.ltr,
                                                  style: _languageMode == 2
                                                      ? NoorType.urdu(
                                                          size: 14,
                                                          color: NoorTheme.muted(
                                                              context))
                                                      : NoorType.secondary
                                                          .copyWith(
                                                              color: NoorTheme
                                                                  .muted(
                                                                      context))),
                                            ],
                                          ]),
                                    ),
                                  ),
                                ],
                              ]),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                        if (!_grid)
                          NoorCard(
                            padding: EdgeInsets.zero,
                            child: Column(children: [
                              for (var i = 0; i < surahs.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                      color: NoorTheme.border(context)),
                                _surahRow(surahs[i]),
                              ],
                              if (surahs.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                      'No Surah matches your search.',
                                      style: NoorType.secondary.copyWith(
                                          color: NoorTheme.muted(context))),
                                ),
                            ]),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: surahs.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: cols == 1 ? 3.2 : 1.35,
                            ),
                            itemBuilder: (_, i) {
                              final s = surahs[i];
                              return NoorCard(
                                onTap: () => _openReader(s.$1),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        NoorRosetteBadge(s.$1, size: 30),
                                        const Spacer(),
                                        Flexible(
                                            child: Text(s.$6,
                                                textDirection:
                                                    TextDirection.rtl,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: NoorType.arabic(
                                                    size: 16,
                                                    color: NoorTheme.accent(
                                                        context)))),
                                      ]),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(s.$2,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: NoorType.cardTitle),
                                            Text('${s.$4} Ayahs',
                                                style: NoorType.meta.copyWith(
                                                    color: NoorTheme.muted(
                                                        context))),
                                          ]),
                                    ]),
                              );
                            },
                          ),
                        const SizedBox(height: 10),
                        Text(
                          _isLiveList
                              ? 'Showing all 114 Surahs from the offline & live Qur\'an index.'
                              : 'Showing the bundled Surahs ? all 6,236 Ayahs remain searchable offline.',
                          textAlign: TextAlign.center,
                          style: NoorType.meta
                              .copyWith(color: NoorTheme.muted(context)),
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
          color: selected
              ? NoorTheme.softSurface(context)
              : NoorTheme.surface(context),
          borderRadius: BorderRadius.circular(NoorRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NoorRadius.card),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NoorRadius.card),
                  border: Border.all(color: NoorTheme.border(context))),
              child: Icon(icon,
                  color: selected
                      ? NoorTheme.accent(context)
                      : NoorTheme.muted(context)),
            ),
          ),
        ),
      );

  Widget _filterBox(String label, String value, VoidCallback onTap) => Expanded(
        child: Material(
          color: NoorTheme.surface(context),
          borderRadius: BorderRadius.circular(NoorRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NoorRadius.card),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NoorRadius.card),
                  border: Border.all(color: NoorTheme.border(context))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label,
                        style: NoorType.meta
                            .copyWith(color: NoorTheme.muted(context))),
                    Row(children: [
                      Expanded(
                          child: Text(value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: NoorType.secondary)),
                      ExcludeSemantics(
                          child: Icon(Icons.keyboard_arrow_down,
                              size: 18, color: NoorTheme.muted(context))),
                    ]),
                  ]),
            ),
          ),
        ),
      );

  Widget _surahRow((int, String, String, int, int, String) s) => InkWell(
        onTap: () => _openReader(s.$1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            NoorRosetteBadge(s.$1, size: 34),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$2, style: NoorType.body),
                    const SizedBox(height: 2),
                    Text(s.$3,
                        style: NoorType.meta
                            .copyWith(color: NoorTheme.muted(context))),
                    const SizedBox(height: 2),
                    Text(
                        s.$5 > 0
                            ? '${s.$4} Ayahs • Page ${s.$5}'
                            : '${s.$4} Ayahs',
                        style: NoorType.meta
                            .copyWith(color: NoorTheme.muted(context))),
                  ]),
            ),
            Text(s.$6,
                textDirection: TextDirection.rtl,
                style:
                    NoorType.arabic(size: 18, color: NoorTheme.accent(context))),
            const SizedBox(width: 6),
            IconButton(
              icon: Icon(Icons.play_circle_fill,
                  color: NoorTheme.accent(context), size: 28),
              tooltip: 'Listen to Surah ${s.$2}',
              onPressed: () => _openPlayer(s.$1),
            ),
          ]),
        ),
      );

  Widget _miniPlayer() {
    final activeNum = _readingPos?.$1 ?? 18;
    final activeMeta = _surahMeta(activeNum);
    final prevNum = activeNum > 1 ? activeNum - 1 : 1;
    final nextNum = activeNum < 114 ? activeNum + 1 : 114;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [NoorColors.emeraldDark, NoorColors.emeraldMid]),
        borderRadius: BorderRadius.circular(NoorRadius.heroCard),
        boxShadow: NoorShadows.hero,
      ),
      child: Row(children: [
        const ExcludeSemantics(
            child: CircleAvatar(
                radius: 18,
                backgroundColor: NoorColors.emeraldSoft,
                backgroundImage: AssetImage(NoorAssets.reciterAvatar))),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Surah ${activeMeta.$2}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NoorType.secondary.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(SampleData.playerReciter,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NoorType.meta.copyWith(color: Colors.white70)),
              ]),
        ),
        IconButton(
            tooltip: 'Previous Surah',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon:
                const Icon(Icons.skip_previous, color: Colors.white, size: 22),
            onPressed: () => _openPlayer(prevNum)),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
              tooltip: 'Open audio player',
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.play_arrow,
                  color: NoorColors.emeraldDark, size: 24),
              onPressed: () => _openPlayer(activeNum)),
        ),
        IconButton(
            tooltip: 'Next Surah',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 22),
            onPressed: () => _openPlayer(nextNum)),
        IconButton(
            tooltip: 'Expand audio player',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.keyboard_arrow_up,
                color: Colors.white, size: 22),
            onPressed: () => _openPlayer(activeNum)),
      ]),
    );
  }
}
