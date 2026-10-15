import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/noor_store.dart';
import '../../data/quran_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'quran_audio_player_screen.dart';

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
  const QuranReaderScreen({super.key, this.surah = 18});

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
    _ayah = widget.surah == 18 ? SampleData.readerAyahNumber : 1;
    _loadLive();
    _loadBookmark();
  }

  Future<void> _loadLive() async {
    final surah = widget.surah;
    try {
      final map = await QuranService().fetchSurahEditions(surah);
      if (map.isNotEmpty && mounted) {
        setState(() {
          _live = map;
          final arabic = map[QuranService.editionArabic];
          if (arabic != null && arabic.ayahs.isNotEmpty) {
            _ayahCount = arabic.ayahs.length;
            _ayah = _ayah.clamp(1, _ayahCount);
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
      final textEn = _liveText('en.asad') ?? _liveText('en.sahih') ?? '$_surahTitle, Ayah $_ayah';
      final cleanText = textEn.replaceAll('\n', ' ').trim();
      final snippet = cleanText.length > 80 ? '${cleanText.substring(0, 80)}...' : cleanText;
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
    _loadBookmark();
  }

  /// Surah-level navigation: replaces this screen with the previous
  /// or next surah (wraps 1<->114). Ayah resets to the new surah's
  /// start, except the drawn Al-Kahf view (surah 18 -> ayah 18).
  void _goSurah(int next) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => QuranReaderScreen(surah: next)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorColors.cream,
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
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 19),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(children: [
                  Text(_surahTitle,
                      style: NoorType.screenTitle.copyWith(color: Colors.white)),
                  Text('$_surahMeaning  •  Ayah $_ayah',
                      style:
                          NoorType.meta.copyWith(color: Colors.white70)),
                ]),
              ),
              IconButton(
                icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white),
                onPressed: _toggleBookmarkCurrentAyah,
              ),
              // Prominent audio play button — directly visible, not buried in menu.
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow,
                      color: NoorColors.emeraldDark, size: 22),
                  tooltip: 'Play audio',
                  onPressed: () {
                    final surah = widget.surah;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => QuranAudioPlayerScreen(surah: surah)));
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
                        builder: (_) => QuranAudioPlayerScreen(surah: surah)));
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(NoorRadius.chip),
                        border: Border.all(color: NoorColors.hairline),
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
                                  onTap: () => setState(() => _mode = i),
                                  borderRadius:
                                      BorderRadius.circular(NoorRadius.chip),
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 44),
                                    alignment: Alignment.center,
                                    child: Text(labels[i],
                                        textAlign: TextAlign.center,
                                        style: NoorType.secondary.copyWith(color: on
                                                ? Colors.white
                                                : NoorColors.ink)),
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
                      color: Colors.white,
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
                              border: Border.all(color: NoorColors.hairline)),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.text_fields,
                                    size: 17, color: NoorColors.emeraldDark),
                                SizedBox(width: 6),
                                Text('Text Size',
                                    style: NoorType.secondary),
                              ]),
                        ),
                      ),
                    ),
                  ),
                ]),
                if (_showSize)
                  Slider(
                    value: _textSize,
                    min: 16,
                    max: 28,
                    activeColor: NoorColors.emerald,
                    onChanged: (v) => setState(() => _textSize = v),
                  ),
                // Full surah — every ayah as its own card, scrollable.
                // (Was single-ayah with prev/next; user asked for whole surah.)
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
                        _liveTextFor(QuranService.editionArabic, a) ??
                            'Ayah text loads from the verified source.',
                        textDirection:
                            _liveTextFor(QuranService.editionArabic, a) == null
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: _liveTextFor(QuranService.editionArabic, a) == null
                            ? NoorType.body
                            : NoorType.arabic(
                                size: (_textSize + 2).clamp(18, 34).toDouble()),
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.auto_awesome,
                          size: 16, color: NoorColors.goldSoft),
                      const SizedBox(height: 12),
                      if (_mode != 2) ...[
                        Text(
                          _liveTextFor(QuranService.editionEnglish, a) ??
                              'Translation loads with the Ayah text.',
                          textAlign: TextAlign.center,
                          style: NoorType.body.copyWith(
                              fontSize: (_textSize - 2).clamp(13, 20).toDouble(),
                              height: 1.55),
                        ),
                        const SizedBox(height: 8),
                        Text('— ${SampleData.readerSourceEn}',
                            style: NoorType.meta.copyWith(color: NoorColors.emerald)),
                        const SizedBox(height: 14),
                      ],
                      if (_mode != 1) ...[
                        Text(
                          _liveTextFor(QuranService.editionUrdu, a) ??
                              'Translation loads with the Ayah text.',
                          textDirection:
                              _liveTextFor(QuranService.editionUrdu, a) == null
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: _liveTextFor(QuranService.editionUrdu, a) == null
                              ? NoorType.body
                              : NoorType.urdu(
                                  size: (_textSize - 1).clamp(14, 22).toDouble()),
                        ),
                        const SizedBox(height: 8),
                        Text('— ${SampleData.readerSourceUr}',
                            style: NoorType.meta.copyWith(color: NoorColors.emerald)),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
                // Quick Tools — Tafsir / Word by Word / Listen / Share / Copy.
                NoorCard(
                  child: Column(children: [
                    Row(children: [
                      const Expanded(
                          child: Text('Quick Tools',
                              style: NoorType.cardTitle)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(NoorRadius.chip),
                            border: Border.all(color: NoorColors.hairline)),
                        child: const Text('Customize',
                            style: NoorType.meta),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _tool(Icons.menu_book, 'Tafsir',
                            onTap: () => _showSourceState('Tafsir')),
                        _tool(Icons.search, 'Word by\nWord',
                            onTap: () => _showSourceState('Word by Word')),
                        _tool(Icons.volume_up_outlined, 'Listen', onTap: () {
                          final surah = widget.surah;
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  QuranAudioPlayerScreen(surah: surah)));
                        }),
                        _tool(Icons.share_outlined, 'Share Ayah',
                            onTap: _copyCurrent),
                        _tool(Icons.copy_outlined, 'Copy', onTap: _copyCurrent),
                      ],
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Tafsir preview — one-line app copy, not a
                // reproduction of any tafsir text.
                NoorCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Expanded(
                              child: Text('Tafsir (Ibn Kathir)',
                                  style: NoorType.secondary)),
                          Icon(Icons.chevron_right,
                              size: 20, color: NoorColors.muted),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'Tafsir opens when the verified source is '
                          'connected.',
                          style: NoorType.secondary.copyWith(height: 1.55),
                        ),
                        const SizedBox(height: 10),
                        Text('Read More',
                            style: NoorType.secondary.copyWith(color: NoorColors.emerald)),
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
                      () => _goSurah(
                          QuranService.nextSurahNumber(widget.surah)),
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
                              style: NoorType.secondary.copyWith(color: NoorColors.muted)),
                          const SizedBox(height: 6),
                          Text(
                              _ayah >= _ayahCount
                                  ? 'End of Surah'
                                  : '${_ayah + 1}  •  …',
                              style: NoorType.body),
                        ])),
                    const Icon(Icons.chevron_right, color: NoorColors.muted),
                  ]),
                ),
                if (_isLive) ...[
                  const SizedBox(height: 10),
                  Text('Live text • AlQuran Cloud',
                      textAlign: TextAlign.center,
                      style: NoorType.meta.copyWith(color: NoorColors.muted)),
                ],
              ],
            ),
          ),
          // Sticky bottom audio mini player (Page 03).
          Container(
            color: Colors.white,
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
                      const Text('Audio Player',
                          style: NoorType.secondary),
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
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: NoorColors.emeraldDark, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    final surah = widget.surah;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => QuranAudioPlayerScreen(surah: surah)));
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

  void _showSourceState(String feature) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Text('$feature opens when the verified source is connected.',
            style: NoorType.body),
      ),
    );
  }

  Future<void> _copyCurrent() async {
    final text = _liveText(QuranService.editionEnglish) ??
        _liveText(QuranService.editionArabic) ??
        '$_surahTitle · Ayah $_ayah';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied — paste anywhere to share')));
    }
  }

  /// Slim outlined surah-navigation pill in the design's language.
  Widget _surahNavButton(String label, VoidCallback onTap) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NoorColors.hairline)),
              child: Text(label,
                  style: NoorType.secondary
                      .copyWith(color: NoorColors.emeraldDark)),
            ),
          ),
        ),
      );

  Widget _tool(IconData icon, String label, {VoidCallback? onTap}) => Semantics(
        button: true,
        label: label.replaceAll('\n', ' '),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: NoorColors.emeraldSoft,
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: NoorColors.emeraldDark, size: 21),
            ),
            const SizedBox(height: 7),
            Text(label,
                textAlign: TextAlign.center,
                style: NoorType.meta.copyWith(height: 1.2)),
          ]),
        ),
      );
}
