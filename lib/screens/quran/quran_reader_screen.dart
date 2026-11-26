import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/noor_store.dart';
import '../../data/quran_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'quran_audio_player_screen.dart';
import 'hifz_mushaf_screen.dart';
import '../../data/offline_quran.dart';
import '../../data/share_content.dart';
import '../library/share_card_studio_screen.dart';

/// Page 03 — Quran Reader English/Urdu. Emerald header (Al-Kahf),
/// Arabic / English / Urdu segmented tabs, Text Size, one ayah card,
/// Quick Tools, Tafsir preview, Next Ayah and the audio mini player
/// fixed at the bottom, as drawn.
///
/// The ayah card is wired to QuranService.fetchSurahEditions
/// (AlQuran Cloud: quran-uthmani / en.sahih / ur.jalandhry) for the
/// chosen surah ([surah], default 18 = Al-Kahf as drawn). Full text
/// is only ever the runtime API response; when it has not loaded,
/// the card says so plainly instead of showing an excerpt under
/// the wrong heading (Phase 12 trust fix — the old offline fallback
/// was a mismatched verse).
///
/// Phase 16 (Job 7): the screen takes the surah number as a
/// parameter, so tapping any surah in the list opens that surah —
/// not always 18. Previous/Next Surah buttons wrap 1<->114 (see
/// QuranService.nextSurahNumber); bookmarks stay keyed per
/// (surah, ayah).
class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({super.key, this.surah = 18, this.initialAyah = 1});
  final int initialAyah;

  /// Surah number 1..114. Default 18 (Al-Kahf) preserves the Page 03
  /// design and the existing goldens.
  final int surah;

  /// Bookmark key for a (surah, ayah) pair — keyed by the surah
  /// parameter, never by a hardcoded constant.
  static String bookmarkKeyFor(int surah, int ayah) => 'quran:$surah:$ayah';

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  bool _modeTouched = false;
  int _mode = 0; // 0 Arabic, 1 English, 2 Urdu
  double _textSize = 20;
  bool _showSize = false; // design tucks the slider behind Text Size
  late int _ayah; // 18 for the drawn Al-Kahf view, 1 otherwise
  Map<String, SurahDetail> _live = const {};
  bool _bookmarked = false;

  // Header + stats for the chosen surah. Drawn values for 18
  // (Al-Kahf / The Cave / 110 ayahs); live surah metadata for the
  // rest, so the layout stays identical while the content is true.
  String _surahTitle = 'Al-Kahf';
  String _surahMeaning = 'The Cave';
  int _ayahCount = 110;

  @override
  void initState() {
    super.initState();
    final info = QuranService.surahInfoMap[widget.surah];
    _surahTitle = info?.$1 ?? 'Surah ${widget.surah}';
    _surahMeaning = '';
    _ayahCount = info?.$3 ?? 1;
    _ayah = widget.initialAyah.clamp(1, _ayahCount);
    _loadReadingLanguage();
    _loadLive();
    _loadBookmark();
  }

  Future<void> _loadReadingLanguage() async {
    final language = await NoorStore.getLanguage();
    if (mounted && !_modeTouched) {
      setState(() => _mode = language == 'Urdu'
          ? 2
          : language == 'English'
              ? 1
              : 0);
    }
  }

  Future<void> _loadLive() async {
    final surah = widget.surah;
    try {
      final map = await QuranService().fetchSurahEditions(surah);
      if (map.isNotEmpty && mounted) {
        NoorStore.recordActivity('Quran');
        setState(() {
          _live = map;
          final arabic = map[QuranService.editionArabic];
          if (arabic != null && arabic.ayahs.isNotEmpty) {
            _ayahCount = arabic.ayahs.length;
            _ayah = _ayah.clamp(1, _ayahCount);
            NoorStore.setReadingPosition(widget.surah, _ayah);
          }
        });
      }
    } catch (_) {
      /* sample fallback stays on screen; never break the reader */
    }
    if (surah != 18) {
      // Surah name/meaning/ayah count for the header (18 keeps the
      // drawn strings above). Metadata only — never verse text.
      try {
        final list = await QuranService().fetchSurahListOrFallback();
        if (!mounted) return;
        for (final m in list) {
          if (m.number == surah) {
            setState(() {
              _surahTitle = 'Surah ${m.englishName}';
              _surahMeaning = m.englishNameTranslation;
              if (_live.isEmpty && m.numberOfAyahs > 0) {
                _ayahCount = m.numberOfAyahs;
              }
            });
            break;
          }
        }
      } catch (_) {
        /* drawn-style fallback stays */
      }
    }
  }

  Future<void> _loadBookmark() async {
    final v = await NoorStore.isBookmarked(
        QuranReaderScreen.bookmarkKeyFor(widget.surah, _ayah));
    if (mounted) setState(() => _bookmarked = v);
  }

  String? _liveText(String edition) {
    final detail = _live[edition];
    if (detail == null || detail.ayahs.isEmpty) return null;
    final i = (_ayah - 1).clamp(0, detail.ayahs.length - 1);
    final t = detail.ayahs[i].text;
    return t.isEmpty ? null : t;
  }

  Future<void> _toggleBookmarkCurrentAyah() async {
    final key = QuranReaderScreen.bookmarkKeyFor(widget.surah, _ayah);
    final v = await NoorStore.toggleBookmark(key);
    if (v) {
      final textEn = _liveText('en.asad') ??
          _liveText('en.sahih') ??
          '$_surahTitle, Ayah $_ayah';
      final cleanText = textEn.replaceAll('\n', ' ').trim();
      final snippet = cleanText.length > 80
          ? '${cleanText.substring(0, 80)}...'
          : cleanText;
      await NoorStore.saveRichItem(
        id: key,
        title: '$_surahTitle, Ayah $_ayah',
        subtitle: snippet,
        tag: 'Ayah $_ayah',
      );
    } else {
      await NoorStore.removeRichItem(key);
    }
    if (mounted) setState(() => _bookmarked = v);
  }

  /// Text for a specific ayah number (1-based) — used by the
  /// full-surah scroll view.
  String? _displayArabic(int ayah) {
    final raw = _liveTextFor(QuranService.editionArabic, ayah);
    if (raw == null) return null;
    return OfflineQuran.stripLeadingBismillah(widget.surah, ayah, raw);
  }

  String? _liveTextFor(String edition, int ayahNum) {
    final detail = _live[edition];
    if (detail == null || detail.ayahs.isEmpty) return null;
    final i = (ayahNum - 1).clamp(0, detail.ayahs.length - 1);
    final t = detail.ayahs[i].text;
    return t.isEmpty ? null : t;
  }

  bool get _isLive => _live.isNotEmpty;

  void _goAyah(int next) {
    setState(() => _ayah = next.clamp(1, _ayahCount));
    NoorStore.setReadingPosition(widget.surah, _ayah);
    _loadBookmark();
  }

  /// Surah-level navigation: replaces this screen with the previous
  /// or next surah (wraps 1<->114). Ayah resets to the new surah's
  /// start, except the drawn Al-Kahf view (surah 18 -> ayah 18).
  void _goSurah(int next) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: next)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
      body: SafeArea(
        child: Column(children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [NoorColors.emeraldDark, NoorColors.emeraldMid]),
            ),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
            child: Row(children: [
              IconButton(
                      tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 19),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(children: [
                  Text(_surahTitle,
                      style:
                          NoorType.screenTitle.copyWith(color: Colors.white)),
                  Text(_surahMeaning.isEmpty ? 'Ayah $_ayah' : '$_surahMeaning  •  Ayah $_ayah',
                      style: NoorType.meta.copyWith(color: Colors.white70)),
                ]),
              ),
              IconButton(
                  tooltip: _bookmarked ? 'Remove bookmark' : 'Bookmark this Ayah',
                icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white),
                onPressed: _toggleBookmarkCurrentAyah,
              ),
              // Prominent audio play button — directly visible, not buried in menu.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NoorTheme.surface(context, light: Colors.white),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow, color: null, size: 22),
                  tooltip: 'Play audio',
                  onPressed: () {
                    final surah = widget.surah;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => QuranAudioPlayerScreen(
                            surah: surah, initialAyah: _ayah)));
                  },
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                tooltip: 'Reader options',
                onSelected: (v) async {
                  if (v == 'bookmark') {
                    await _toggleBookmarkCurrentAyah();
                  } else if (v == 'audio') {
                    if (!mounted) return;
                    final surah = widget.surah;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => QuranAudioPlayerScreen(
                            surah: surah, initialAyah: _ayah)));
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'bookmark',
                      child: Text(_bookmarked
                          ? 'Remove bookmark'
                          : 'Bookmark this Ayah')),
                  const PopupMenuItem(
                      value: 'audio', child: Text('Open audio player')),
                ],
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              children: [
                // Arabic / English / Urdu tabs + Text Size (Page 03).
                Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: NoorTheme.surface(context, light: Colors.white),
                        borderRadius: BorderRadius.circular(NoorRadius.chip),
                        border: Border.all(color: NoorTheme.border(context)),
                      ),
                      child: Row(
                        children: List.generate(3, (i) {
                          const labels = ['Arabic', 'English', 'Urdu'];
                          final on = i == _mode;
                          return Expanded(
                            child: Semantics(
                              button: true,
                              selected: on,
                              label: labels[i],
                              child: Material(
                                color: on
                                    ? NoorColors.emeraldDark
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(NoorRadius.chip),
                                child: InkWell(
                                  onTap: () => setState(() {
                                    _modeTouched = true;
                                    _mode = i;
                                  }),
                                  borderRadius:
                                      BorderRadius.circular(NoorRadius.chip),
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 44),
                                    alignment: Alignment.center,
                                    child: Text(labels[i],
                                        textAlign: TextAlign.center,
                                        style: NoorType.secondary.copyWith(
                                            color: NoorTheme.foreground(context,
                                                light: on
                                                    ? Colors.white
                                                    : NoorColors.ink))),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    button: true,
                    label: 'Text Size',
                    child: Material(
                      color: NoorTheme.surface(context, light: Colors.white),
                      borderRadius: BorderRadius.circular(NoorRadius.chip),
                      child: InkWell(
                        onTap: () => setState(() => _showSize = !_showSize),
                        borderRadius: BorderRadius.circular(NoorRadius.chip),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(NoorRadius.chip),
                              border: Border.all(color: NoorTheme.border(context))),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.text_fields, size: 17, color: null),
                                SizedBox(width: 6),
                                Text('Text Size', style: NoorType.secondary),
                              ]),
                        ),
                      ),
                    ),
                  ),
                ]),
                if (_showSize)
                  Semantics(
                    label: 'Quran text size',
                    child: Slider(
                      value: _textSize,
                      min: 16,
                      max: 28,
                      activeColor: NoorTheme.accent(context),
                      label: '${_textSize.round()}',
                      semanticFormatterCallback: (v) =>
                          'Font size ${v.round()}',
                      onChanged: (v) => setState(() => _textSize = v),
                    ),
                  ),
                NoorCard(
                    key: const ValueKey('reader-quick-tools'),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('Quick Tools',
                                    style: NoorType.cardTitle),
                                Text('Ayah $_ayah', style: NoorType.meta)
                              ]),
                          const SizedBox(height: 12),
                          LayoutBuilder(builder: (context, constraints) {
                            final scale =
                                MediaQuery.textScalerOf(context).scale(1);
                            final columns = scale > 1.4
                                ? 2
                                : constraints.maxWidth >= 280
                                    ? 5
                                    : 3;
                            final width =
                                (constraints.maxWidth - (columns - 1) * 8) /
                                    columns;
                            final tools = [
                              _tool(Icons.volume_up_outlined, 'Listen',
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              QuranAudioPlayerScreen(
                                                  surah: widget.surah,
                                                  initialAyah: _ayah)))),
                              _tool(
                                  _bookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  _bookmarked ? 'Saved' : 'Save',
                                  onTap: _toggleBookmarkCurrentAyah),
                              _tool(Icons.ios_share_outlined, 'Share ayah',
                                  onTap: _shareCurrent),
                              _tool(Icons.copy_outlined, 'Copy',
                                  onTap: _copyCurrent),
                              _tool(Icons.menu_book_outlined, '16-line',
                                  onTap: _openMushaf),
                            ];
                            return Wrap(spacing: 8, runSpacing: 8, children: [
                              for (final tool in tools)
                                SizedBox(
                                    width: width,
                                    height: 58 + 30 * scale,
                                    child: tool)
                            ]);
                          }),
                        ])),
                const SizedBox(height: 16),
                // Full surah — every ayah as its own card, scrollable.
                // (Was single-ayah with prev/next; user asked for whole surah.)
                if (_isLive && widget.surah != 1 && widget.surah != 9) ...[
                  NoorCard(
                      child: Column(children: [
                    Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: NoorType.arabic(
                            size: (_textSize + 2).clamp(18, 32).toDouble(),
                            color: NoorTheme.accent(context))),
                    const SizedBox(height: 6),
                    Text(
                        'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                        textAlign: TextAlign.center,
                        style: NoorType.meta
                            .copyWith(color: NoorTheme.muted(context))),
                  ])),
                  const SizedBox(height: 12),
                ],
                for (var a = 1; a <= _ayahCount; a++) ...[
                  NoorCard(
                    child: Column(children: [
                      Row(children: [
                        // Gold rosette ayah marker as drawn (Page 03).
                        NoorRosetteBadge(a, filled: false, size: 36),
                      ]),
                      const SizedBox(height: 12),
                      // Live Arabic from AlQuran Cloud when it lands;
                      // brief design excerpt as the offline fallback.
                      Text(
                        _displayArabic(a) ??
                            'Ayah text loads from the verified source.',
                        textDirection: _displayArabic(a) == null
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: _displayArabic(a) == null
                            ? NoorType.body
                            : NoorType.arabic(
                                size: (_textSize + 2).clamp(18, 34).toDouble()),
                      ),
                      const SizedBox(height: 10),
                      ExcludeSemantics(
                          child: Icon(Icons.auto_awesome,
                              size: 17, color: NoorTheme.accent(context))),
                      const SizedBox(height: 12),
                      if (_mode == 1) ...[
                        Text(
                          _liveTextFor(QuranService.editionEnglish, a) ??
                              'Translation loads with the Ayah text.',
                          textAlign: TextAlign.center,
                          style: NoorType.body.copyWith(
                              fontSize:
                                  (_textSize - 2).clamp(13, 20).toDouble(),
                              height: 1.55),
                        ),
                        const SizedBox(height: 8),
                        Text('— ${SampleData.readerSourceEn}',
                            style: NoorType.meta.copyWith(
                                color: NoorTheme.accent(context))),
                        const SizedBox(height: 14),
                      ],
                      if (_mode == 2) ...[
                        Text(
                          _liveTextFor(QuranService.editionUrdu, a) ??
                              'Translation loads with the Ayah text.',
                          textDirection:
                              _liveTextFor(QuranService.editionUrdu, a) == null
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: _liveTextFor(QuranService.editionUrdu, a) ==
                                  null
                              ? NoorType.body
                              : NoorType.urdu(
                                  size:
                                      (_textSize - 1).clamp(14, 22).toDouble()),
                        ),
                        const SizedBox(height: 8),
                        Text('— ${SampleData.readerSourceUr}',
                            style: NoorType.meta.copyWith(
                                color: NoorTheme.accent(context))),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
                // Tafsir preview — one-line app copy, not a
                // reproduction of any tafsir text.
                NoorCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tafsir (Ibn Kathir)',
                            style: NoorType.secondary),
                        const SizedBox(height: 8),
                        Text(
                          'Tafsir opens when the verified source is '
                          'connected.',
                          style: NoorType.secondary.copyWith(height: 1.55),
                        ),
                        const SizedBox(height: 10),
                      ]),
                ),
                const SizedBox(height: 16),
                // Previous / Next Surah (Phase 16): slim outlined
                // pills in the design's language; wraps 1<->114.
                Row(children: [
                  Expanded(
                    child: _surahNavButton(
                      '‹ Prev Surah',
                      () => _goSurah(
                          QuranService.previousSurahNumber(widget.surah)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _surahNavButton(
                      'Next Surah ›',
                      () =>
                          _goSurah(QuranService.nextSurahNumber(widget.surah)),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                NoorCard(
                  onTap: () => _goAyah(_ayah + 1),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Next Ayah',
                              style: NoorType.secondary.copyWith(color: null)),
                          const SizedBox(height: 6),
                          Text(
                              _ayah >= _ayahCount
                                  ? 'End of Surah'
                                  : '${_ayah + 1}  •  …',
                              style: NoorType.body),
                        ])),
                    const Icon(Icons.chevron_right, color: null),
                  ]),
                ),
                if (_isLive) ...[
                  const SizedBox(height: 10),
                  Text('Offline text • AlQuran Cloud editions',
                      textAlign: TextAlign.center,
                      style: NoorType.meta.copyWith(color: null)),
                ],
              ],
            ),
          ),
          // Sticky bottom audio mini player (Page 03).
          Container(
            color: NoorTheme.surface(context, light: Colors.white),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: NoorColors.emeraldSoft,
                backgroundImage: AssetImage(NoorAssets.reciterAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Audio Player', style: NoorType.secondary),
                      Text('$_surahTitle • Ayah $_ayah',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NoorType.meta),
                      const Text(SampleData.playerReciter,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NoorType.meta),
                    ]),
              ),
              IconButton(
                  icon: const Icon(Icons.skip_previous),
                  tooltip: 'Previous Ayah',
                  onPressed: () => _goAyah(_ayah - 1)),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: NoorColors.emeraldDark, shape: BoxShape.circle),
                child: IconButton(
                  tooltip: 'Play Surah audio',
                  icon: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    final surah = widget.surah;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => QuranAudioPlayerScreen(
                            surah: surah, initialAyah: _ayah)));
                  },
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Next Ayah',
                  onPressed: () => _goAyah(_ayah + 1)),
            ]),
          ),
        ]),
      ),
    );
  }

  String get _selectedReference => 'Quran ${widget.surah}:$_ayah';
  String get _selectedTranslation =>
      _liveText(_mode == 2
          ? QuranService.editionUrdu
          : QuranService.editionEnglish) ??
      '';
  Future<void> _openMushaf() async {
    final page = await OfflineQuran.pageForVerse(widget.surah, _ayah);
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => HifzMushafScreen(initialPage: page)));
    }
  }

  void _shareCurrent() {
    if (!_isLive) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verse text is loading. Please try again.')));
      return;
    }
    final item = ShareContentItem(
        id: 'quran:${widget.surah}:$_ayah',
        type: ShareContentType.ayah,
        title: '$_surahTitle · Ayah $_ayah',
        text: _selectedTranslation,
        arabicText: _liveText(QuranService.editionArabic),
        reference: _selectedReference,
        tags: const ['Quran']);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ShareCardStudioScreen(initialItem: item)));
  }

  Future<void> _copyCurrent() async {
    if (!_isLive) return;
    await Clipboard.setData(ClipboardData(
        text:
            '${_liveText(QuranService.editionArabic)}\n\n$_selectedTranslation\n$_selectedReference'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verse and reference copied')));
    }
  }

  /// Slim outlined surah-navigation pill in the design's language.
  Widget _surahNavButton(String label, VoidCallback onTap) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: NoorTheme.surface(context, light: Colors.white),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NoorTheme.border(context))),
              child:
                  Text(label, style: NoorType.secondary.copyWith(color: null)),
            ),
          ),
        ),
      );

  Widget _tool(IconData icon, String label, {required VoidCallback onTap}) =>
      Semantics(
          button: true,
          label: label,
          child: Material(
              color: Theme.of(context).brightness == Brightness.dark
                  ? NoorColors.darkSurface
                  : NoorColors.emeraldSoft.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  onTap: onTap,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 12),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(icon,
                                size: 23,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 9),
                            Expanded(
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(label,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: NoorType.meta
                                            .copyWith(height: 1.2)))),
                          ])))));
}