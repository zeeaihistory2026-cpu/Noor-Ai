import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/noor_store.dart';
import '../../data/offline_quran.dart';
import '../../data/quran_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'quran_reader_screen.dart';
import 'hifz_ai_test_screen.dart';
import 'hifz_heatmap_screen.dart';
import 'quran_audio_player_screen.dart';

/// Page 04 — Hifz Mushaf (16-Line Quran).
///
/// Features authentic 16-line Indo-Pak / Taj Company Mushaf pagination (1..548),
/// word-by-word line coordinate rendering, ornate Islamic frame, line-level
/// ruled layout, script toggle (IndoPak / Uthmani), recitation playback,
/// repetition counter for memorization, and quick page/surah/juz navigation.
class HifzMushafScreen extends StatefulWidget {
  const HifzMushafScreen({super.key, this.initialPage});

  final int? initialPage;

  @override
  State<HifzMushafScreen> createState() => _HifzMushafScreenState();
}

class _HifzMushafScreenState extends State<HifzMushafScreen> {
  int _page = 2;
  bool _isLoading = true;
  String? _error;
  int _request = 0;
  Mushaf16Page? _pageData;

  int _firstAyahOnPage(Mushaf16Page pageData) {
    for (final line in pageData.lines) {
      for (final word in line.words) {
        final parts = word.verseKey.split(':');
        final parsed = int.tryParse(parts.isNotEmpty ? parts.last : '');
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return 1;
  }
  bool _bookmarked = false;
  String _script = 'indopak'; // 'indopak' or 'uthmani'

  // Memorization repetition counter
  final int _repeatTarget = 3;
  int _repeatCount = 0;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    int startPage = widget.initialPage ?? 2;
    if (widget.initialPage == null) {
      try {
        startPage = await NoorStore.getLastMushafPage();
      } catch (_) {
        startPage = 2;
      }
    }
    _page = startPage.clamp(1, QuranService.totalMushaf16Pages);
    _loadPage(_page);
    _checkBookmark();
  }

  String get _bookmarkId => 'mushaf:page:$_page';

  Future<void> _checkBookmark() async {
    final v = await NoorStore.isBookmarked(_bookmarkId);
    if (mounted) setState(() => _bookmarked = v);
  }

  Future<void> _loadPage(int page, {bool forceRefresh = false}) async {
    final request = ++_request;
    final requestedPage = page.clamp(1, QuranService.totalMushaf16Pages);
    setState(() {
      _isLoading = true;
      _error = null;
      _page = requestedPage;
      _pageData = null;
    });
    try {
      final data = await QuranService()
          .fetchMushaf16LinePage(requestedPage, forceRefresh: forceRefresh);
      if (!mounted || request != _request) return;
      setState(() {
        _pageData = data;
        _isLoading = false;
      });
      await NoorStore.setLastMushafPage(requestedPage);
      _checkBookmark();
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _isLoading = false;
        _error = 'This page could not be loaded. Please retry.';
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final now = await NoorStore.toggleBookmark(_bookmarkId);
    final surahName = _pageData?.surahEnglishName ?? 'Surah';
    if (now) {
      await NoorStore.saveRichItem(
        id: _bookmarkId,
        title: 'Mushaf · $surahName (Page $_page)',
        subtitle:
            '16-Line Quran Page $_page • Juz ${_pageData?.juzNumber ?? 1}',
        tag: 'Quran Page',
      );
    } else {
      await NoorStore.removeRichItem(_bookmarkId);
    }
    if (!mounted) return;
    setState(() => _bookmarked = now);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            now ? 'Bookmarked · Page $_page ($surahName)' : 'Bookmark removed'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _nextPage() {
    if (_page < QuranService.totalMushaf16Pages) {
      _loadPage(_page + 1);
    }
  }

  void _prevPage() {
    if (_page > 1) {
      _loadPage(_page - 1);
    }
  }

  void _toggleScript() {
    setState(() {
      _script = _script == 'indopak' ? 'uthmani' : 'indopak';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_script == 'indopak'
            ? 'Script: Indo-Pak (Nastaliq)'
            : 'Script: Uthmani (Madani)'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _cycleRepeat() {
    HapticFeedback.selectionClick();
    setState(() {
      _repeatCount++;
      if (_repeatCount > _repeatTarget) {
        _repeatCount = 1;
      }
    });
    if (_repeatCount == _repeatTarget) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Completed $_repeatTarget repeats on Page $_page! MashaAllah.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openOptions() => showNoorOverflowSheet(
        context,
        title: 'Mushaf options',
        info: const [
          'IndoPak 16-line Mushaf: 548 pages, using the verified Quran Foundation layout. Surah headings and Bismillah occupy their reserved lines.',
        ],
        actions: [
          (
            Icons.school_outlined,
            'Test me on this page',
            () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HifzAiTestScreen()),
                ),
          ),
          (
            Icons.track_changes_outlined,
            'Hifz progress',
            () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HifzHeatmapScreen()),
                ),
          ),
          (
            Icons.font_download_outlined,
            _script == 'indopak'
                ? 'Switch to Uthmani (Madani) Script'
                : 'Switch to Indo-Pak Script',
            _toggleScript,
          ),
          (
            Icons.explore_outlined,
            'Jump to Page / Surah / Juz',
            _openJumpDialog,
          ),
        ],
      );

  void _openJumpDialog() {
    final pageCtrl = TextEditingController(text: '$_page');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NoorTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NoorTheme.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.explore_outlined,
                    color: null),
                const SizedBox(width: 8),
                Text('Jump in 16-Line Mushaf',
                    style: NoorType.section
                        .copyWith(color: null)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Enter Page (1 – 548):',
                style: NoorType.meta.copyWith(color: null)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pageCtrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: NoorType.display
                        .copyWith(fontSize: 22, color: null),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: NoorColors.emeraldMid),
                      ),
                      suffixText: '/ 548',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NoorColors.emeraldDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final target = int.tryParse(pageCtrl.text.trim());
                    if (target != null &&
                        target >= 1 &&
                        target <= QuranService.totalMushaf16Pages) {
                      Navigator.of(ctx).pop();
                      _loadPage(target);
                    }
                  },
                  child: const Text('Go'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Quick Juz Navigation (1 – 30):',
                style: NoorType.meta.copyWith(color: null)),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 30,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final j = i + 1;
                  final isCurrentJuz = _pageData?.juzNumber == j;
                  return ActionChip(
                    label: Text('Juz $j'),
                    backgroundColor: isCurrentJuz
                        ? NoorColors.emeraldDark
                        : NoorTheme.softSurface(ctx),
                    labelStyle: TextStyle(
                      color: isCurrentJuz
                          ? Colors.white
                          : NoorTheme.foreground(ctx),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final target = await OfflineQuran.pageForJuz(j);
                      if (mounted) _loadPage(target);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text('Quick Surah Navigation (1 – 114):',
                style: NoorType.meta.copyWith(color: null)),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 114,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final sNum = i + 1;
                  final sName =
                      QuranService.surahInfoMap[sNum]?.$1 ?? 'Surah $sNum';
                  final isCurrent = _pageData?.surahNumber == sNum;
                  return ActionChip(
                    label: Text('$sNum. $sName'),
                    backgroundColor: isCurrent
                        ? NoorColors.emeraldDark
                        : NoorTheme.softSurface(ctx),
                    labelStyle: TextStyle(
                      color: isCurrent
                          ? Colors.white
                          : NoorTheme.foreground(ctx),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final target = await OfflineQuran.pageForSurah(sNum);
                      if (mounted) _loadPage(target);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAyahDetail(Mushaf16Word word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NoorTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NoorTheme.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: NoorTheme.surface(context, light: NoorColors.emeraldSoft),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ayah ${word.verseKey}',
                    style: NoorType.meta.copyWith(
                        color: null,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                Text('Line ${word.lineNumber} • Page $_page',
                    style: NoorType.meta.copyWith(color: null)),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _script == 'indopak' && word.textIndoPak.isNotEmpty
                    ? word.textIndoPak
                    : word.textUthmani,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily:
                      _script == 'indopak' ? 'IndopakNastaleeq' : 'AmiriQuran',
                  fontSize: 26,
                  color: null,
                ),
              ),
            ),
            if (word.translation != null && word.translation!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                word.translation!,
                style: NoorType.body.copyWith(color: null),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NoorColors.emeraldDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.menu_book, size: 18),
                    label: const Text('Read in Surah View'),
                    onPressed: () {
                      final sNum =
                          int.tryParse(word.verseKey.split(':').first) ??
                              (_pageData?.surahNumber ?? 2);
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => QuranReaderScreen(surah: sNum)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pageData == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('16-Line Quran')),
          body: Center(
              child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                Text(_error ?? 'This page is unavailable.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: () => _loadPage(_page),
                    child: const Text('Retry')),
              ],
            ]),
          )));
    }

    final pageData = _pageData!;
    final surahName = pageData.surahEnglishName;
    final juzNum = pageData.juzNumber;

    return Scaffold(
      backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
      body: SafeArea(
        child: Column(
          children: [
            // Top Emerald Curved App Bar
            Container(
              color: NoorColors.emeraldDark,
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 14),
              child: Row(
                children: [
                  IconButton(tooltip: 'Back', 
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 19),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          surahName,
                          style: NoorType.screenTitle
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Juz $juzNum • Page $_page of ${QuranService.totalMushaf16Pages}',
                          style: NoorType.meta.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Switch script',
                    icon: const Icon(Icons.font_download_outlined,
                        color: Colors.white, size: 20),
                    onPressed: _toggleScript,
                  ),
                  IconButton(
                    tooltip: _bookmarked ? 'Bookmarked' : 'Bookmark this page',
                    icon: Icon(
                      _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                  IconButton(
                    tooltip: 'Mushaf options',
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white),
                    onPressed: _openOptions,
                  ),
                ],
              ),
            ),

            // 16-Line Page View Info Strip
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: NoorTheme.surface(context, light: Colors.white),
                borderRadius: BorderRadius.circular(14),
                boxShadow: NoorShadows.card,
              ),
              child: InkWell(
                onTap: _openJumpDialog,
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined,
                        size: 18, color: null),
                    const SizedBox(width: 8),
                    Text('16-Line Page View',
                        style: NoorType.secondary
                            .copyWith(color: null)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NoorTheme.surface(context, light: NoorColors.sand),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text('Page $_page',
                              style: NoorType.meta.copyWith(
                                  color: null,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 14, color: null),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable / Swipeable Mushaf Page Content
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  // RTL Page navigation: drag left -> next page; drag right -> prev page
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < -200) {
                      _nextPage();
                    } else if (details.primaryVelocity! > 200) {
                      _prevPage();
                    }
                  }
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  children: [
                    // Ornate 16-Line Mushaf Frame
                    _buildOrnateMushafFrame(pageData),

                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        '$surahName · Page $_page of ${QuranService.totalMushaf16Pages}',
                        style:
                            NoorType.meta.copyWith(color: null),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Prev / Page Indicator / Next Bar
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _page > 1 ? _prevPage : null,
                            borderRadius: BorderRadius.circular(14),
                            child: _navBtn(
                              Icons.keyboard_double_arrow_left,
                              'Previous',
                              _page > 1 ? 'Page ${_page - 1}' : 'Start',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: _openJumpDialog,
                            child: Column(
                              children: [
                                Text(
                                    '$_page / ${QuranService.totalMushaf16Pages}',
                                    style: NoorType.cardTitle),
                                Text('Juz $juzNum',
                                    style: NoorType.meta
                                        .copyWith(color: null)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: _page < QuranService.totalMushaf16Pages
                                ? _nextPage
                                : null,
                            borderRadius: BorderRadius.circular(14),
                            child: _navBtn(
                              Icons.keyboard_double_arrow_right,
                              'Next',
                              _page < QuranService.totalMushaf16Pages
                                  ? 'Page ${_page + 1}'
                                  : 'End',
                              trailing: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Bottom Action Tools Bar (Listen, Repeat, Bookmark, Test Me, Read)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: NoorTheme.surface(context, light: Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: NoorShadows.card,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _tool(
                            context,
                            Icons.headphones_outlined,
                            'Listen',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => QuranAudioPlayerScreen(
                                    surah: pageData.surahNumber, initialAyah: _firstAyahOnPage(pageData)),
                              ),
                            ),
                          ),
                          _tool(
                            context,
                            Icons.repeat,
                            _repeatCount > 0
                                ? 'Rep $_repeatCount/$_repeatTarget'
                                : 'Repeat',
                            _cycleRepeat,
                          ),
                          _tool(
                            context,
                            _bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            'Bookmark',
                            _toggleBookmark,
                          ),
                          _tool(
                            context,
                            Icons.school_outlined,
                            'Test Me',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const HifzAiTestScreen()),
                            ),
                          ),
                          _tool(
                            context,
                            Icons.menu_book_outlined,
                            'Read',
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => QuranReaderScreen(
                                    surah: pageData.surahNumber, initialAyah: _firstAyahOnPage(pageData)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Hifz Progress Card
                    Material(
                      color: NoorTheme.surface(context, light: Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const HifzHeatmapScreen()),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: NoorShadows.card,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.track_changes_outlined,
                                  color: null, size: 20),
                              const SizedBox(width: 10),
                              const Expanded(
                                  child: Text('Hifz Progress',
                                      style: NoorType.secondary)),
                              Text(
                                _repeatCount > 0
                                    ? 'Practice $_repeatCount/$_repeatTarget'
                                    : 'Page $_page of 604',
                                style: NoorType.meta.copyWith(
                                    color: NoorTheme.muted(context)),
                              ),
                              const SizedBox(width: 6),
                              ExcludeSemantics(
                                  child: Icon(Icons.chevron_right,
                                      color: NoorTheme.muted(context),
                                      size: 19)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Authentic 16-Line Ornate Golden & Emerald Mushaf Frame
  Widget _buildOrnateMushafFrame(Mushaf16Page pageData) {
    return Container(
      decoration: BoxDecoration(
        color: NoorTheme.surface(context, light: NoorColors.surfaceWarm),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NoorColors.goldSoft, width: 3),
        boxShadow: NoorShadows.card,
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          color: NoorTheme.surface(context, light: NoorColors.surfaceWarm),
          border: Border.all(color: NoorColors.emeraldMid, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          children: [
            // Page Header (Juz, Page number medallion, Surah name)
            _buildPageHeader(pageData),

            const SizedBox(height: 4),
            const Divider(color: NoorColors.goldSoft, thickness: 1, height: 1),
            const SizedBox(height: 4),

            // Loading state or 16 Lines
            if (_isLoading) ...[
              const SizedBox(height: 60),
              const Center(
                child: CircularProgressIndicator(color: NoorColors.emeraldDark),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Loading 16-Line Page $_page...',
                  style: NoorType.meta.copyWith(color: null),
                ),
              ),
              const SizedBox(height: 60),
            ] else ...[
              // The 16 Ruled Lines
              for (final line in pageData.lines) ...[
                _buildMushafLine(line),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// Page Top Header Strip: Juz, Page Medallion, Surah Title
  Widget _buildPageHeader(Mushaf16Page pageData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الجزء ${pageData.juzNumber}',
            style: const TextStyle(
              fontFamily: 'AmiriQuran',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: null,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: NoorTheme.surface(context, light: NoorColors.sand),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: NoorColors.goldSoft),
            ),
            child: Text(
              '$_page',
              style: NoorType.tabular(
                NoorType.secondary.copyWith(
                  color: null,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Text(
            pageData.surahArabicName,
            style: const TextStyle(
              fontFamily: 'AmiriQuran',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: null,
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Line Renderer (Handles Surah Banner, Bismillah, or Ruled Text Line)
  Widget _buildMushafLine(Mushaf16Line line) {
    // 1. Surah Header Banner Line
    if (line.isSurahHeader) {
      return Container(
        constraints: const BoxConstraints(minHeight: 34),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              NoorColors.emeraldDark,
              NoorColors.emeraldMid,
              NoorColors.emeraldDark
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NoorColors.gold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: NoorColors.emeraldDark.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: NoorColors.gold, size: 12),
            const SizedBox(width: 8),
            Text(
              line.surahName ?? 'سُورَةُ',
              style: const TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.star, color: NoorColors.gold, size: 12),
          ],
        ),
      );
    }

    // 2. Bismillah Line
    if (line.isBismillah) {
      return Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(vertical: 2),
        margin: const EdgeInsets.symmetric(vertical: 2),
        alignment: Alignment.center,
        child: Text(
          'بِسۡمِ اللهِ الرَّحۡمٰنِ الرَّحِيۡمِ',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily:
                _script == 'indopak' ? 'IndopakNastaleeq' : 'AmiriQuran',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: NoorTheme.foreground(context),
          ),
        ),
      );
    }

    // 3. Regular Text Line with Ruled Border
    final hasWords = line.words.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: NoorTheme.border(context),
            width: 0.6,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      alignment: Alignment.center,
      child: hasWords
          ? Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                textDirection: TextDirection.rtl,
                spacing: 4,
                runSpacing: 4,
                children: line.words.map((w) {
                  final isEnd = w.isAyahEnd;
                  final text =
                      _script == 'indopak' && w.textIndoPak.isNotEmpty
                          ? w.textIndoPak
                          : w.textUthmani;

                  return InkWell(
                    onTap: () => _showAyahDetail(w),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 2),
                      child: isEnd
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: NoorTheme.accent(context),
                                    width: 1),
                                color: NoorTheme.softSurface(context),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontFamily: _script == 'indopak'
                                      ? 'IndopakNastaleeq'
                                      : 'AmiriQuran',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: NoorTheme.accent(context),
                                ),
                              ),
                            )
                          : Text(
                              text,
                              style: TextStyle(
                                fontFamily: _script == 'indopak'
                                    ? 'IndopakNastaleeq'
                                    : 'AmiriQuran',
                                fontSize: 16.5,
                                fontWeight: FontWeight.w600,
                                color: NoorTheme.foreground(context),
                                height: 1.65,
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
            )
          : const SizedBox(
              height: 24), // Empty ruled line slot for introductory pages
    );
  }

  Widget _navBtn(IconData icon, String label, String sub,
          {bool trailing = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: NoorTheme.surface(context, light: Colors.white),
          borderRadius: BorderRadius.circular(14),
          boxShadow: NoorShadows.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!trailing) ...[
              Icon(icon, size: 16, color: NoorTheme.accent(context)),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          NoorType.meta.copyWith(fontWeight: FontWeight.w700)),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NoorType.meta
                          .copyWith(color: NoorTheme.muted(context))),
                ],
              ),
            ),
            if (trailing) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: NoorTheme.accent(context)),
            ],
          ],
        ),
      );

  Widget _tool(BuildContext context, IconData icon, String label,
          VoidCallback? onTap) =>
      Semantics(
        button: onTap != null,
        enabled: onTap != null,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: onTap == null
                        ? NoorTheme.muted(context)
                        : NoorTheme.accent(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: NoorType.compactMeta.copyWith(
                      color: onTap == null
                          ? NoorTheme.muted(context)
                          : NoorTheme.foreground(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}