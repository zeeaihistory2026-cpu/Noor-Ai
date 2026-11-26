import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../data/daily_content_service.dart';
import '../../data/daily_content_actions.dart';
import '../../data/share_content.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/daily_reflection_card.dart';
import '../library/share_card_studio_screen.dart';
import '../quran/quran_reader_screen.dart';
import '../quran/surah_list_screen.dart';

/// Ayat of the Day screen.
///
/// Features authentic Quranic verses with Arabic, English translation,
/// transliteration, Urdu translation, Surah citation, context/reflection,
/// audio listen, bookmarking, and interactive card changing (Prev, Next, Shuffle).
class AyatOfTheDayScreen extends StatefulWidget {
  const AyatOfTheDayScreen({super.key, this.initialOffset = 0});

  final int initialOffset;

  @override
  State<AyatOfTheDayScreen> createState() => _AyatOfTheDayScreenState();
}

class _AyatOfTheDayScreenState extends State<AyatOfTheDayScreen> {
  late int _offset;
  bool _saved = false;
  final _playback = DailyContentPlayback();

  void _audioChanged() {
    if (!mounted) return;
    setState(() {});
    final error = _playback.error;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      _playback.error = null;
    }
  }

  @override
  void dispose() {
    _playback.removeListener(_audioChanged);
    _playback.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
    _playback.addListener(_audioChanged);
    _playback.stop();
    _checkBookmark();
  }

  DailyContentItem get _ayah => DailyContentService.getAyah(offset: _offset);

  String get _bookmarkId => 'ayah:${_ayah.id}';

  Future<void> _checkBookmark() async {
    final v = await NoorStore.isBookmarked(_bookmarkId);
    if (mounted) setState(() => _saved = v);
  }

  Future<void> _toggleSave() async {
    final now = await NoorStore.toggleBookmark(_bookmarkId);
    if (now) {
      await NoorStore.saveRichItem(
        id: _bookmarkId,
        title: '${_ayah.title} (${_ayah.reference})',
        subtitle: _ayah.translation,
        tag: 'Ayat of the Day',
      );
    } else {
      await NoorStore.removeRichItem(_bookmarkId);
    }
    if (mounted) {
      setState(() => _saved = now);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              now ? 'Ayah saved to bookmarks' : 'Ayah removed from bookmarks'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _nextAyah() {
    HapticFeedback.selectionClick();
    setState(() => _offset++);
    _playback.stop();
    _checkBookmark();
  }

  void _prevAyah() {
    HapticFeedback.selectionClick();
    setState(() => _offset--);
    _playback.stop();
    _checkBookmark();
  }

  void _shuffleAyah() {
    _playback.stop();
    HapticFeedback.mediumImpact();
    final nextRandom = (_offset + 1 + (DateTime.now().microsecond % 7));
    setState(() => _offset = nextRandom);
    _checkBookmark();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changed to another inspiring Ayah!'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _copyAyah() async {
    final text =
        '${_ayah.arabic}\n\n"${_ayah.translation}"\n\n— ${_ayah.reference}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayat text copied to clipboard!')),
      );
    }
  }

  void _readVerse() {
    final match = RegExp(r'(\d+):(\d+)').firstMatch(_ayah.reference);
    if (match == null) return;
    _playback.stop();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => QuranReaderScreen(
            surah: int.parse(match[1]!), initialAyah: int.parse(match[2]!))));
  }

  void _toggleAudio() => _playback.toggle(_ayah, quran: true);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ayah = _ayah;

    return Scaffold(
      backgroundColor: isDark ? NoorColors.darkBg : NoorColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    icon: Icon(Icons.arrow_back_ios_new,
                        size: 19,
                        color: isDark
                            ? NoorColors.darkTextPrimary
                            : NoorColors.ink),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Ayat of the Day',
                          textAlign: TextAlign.center,
                          style: NoorType.screenTitle.copyWith(
                            color: isDark
                                ? NoorColors.darkGold
                                : NoorColors.emeraldDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(NoorAppState.dateLine,
                            style: NoorType.meta.copyWith(
                                color: isDark
                                    ? NoorColors.darkTextSecondary
                                    : NoorColors.mutedDark)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Change / Shuffle Ayah',
                    icon: Icon(Icons.shuffle,
                        color: isDark
                            ? NoorColors.darkGold
                            : NoorColors.emeraldDark,
                        size: 21),
                    onPressed: _shuffleAyah,
                  ),
                  IconButton(
                    tooltip: 'More options',
                    icon: Icon(Icons.more_vert,
                        color: isDark
                            ? NoorColors.darkTextPrimary
                            : NoorColors.ink,
                        size: 21),
                    onPressed: () => showNoorOverflowSheet(
                      context,
                      title: 'Ayat Options',
                      actions: [
                        (
                          Icons.copy_outlined,
                          'Copy Ayah text',
                          _copyAyah,
                        ),
                        (
                          _saved ? Icons.bookmark : Icons.bookmark_border,
                          _saved ? 'Unsave' : 'Save to bookmarks',
                          _toggleSave,
                        ),
                        (
                          Icons.ios_share,
                          'Open in Share Studio',
                          () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ShareCardStudioScreen(
                                      initialItem: ShareContentItem.fromDaily(
                                          ayah, ShareContentType.ayah)),
                                ),
                              ),
                        ),
                        (
                          Icons.menu_book,
                          'Open in Quran Reader',
                          _readVerse,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  // Main Ayah Card
                  DailyReflectionCard(
                    item: ayah,
                    kind: 'ayah',
                    expanded: true,
                    saved: _saved,
                    playing: _playback.playing,
                    loading: _playback.loading,
                    onListen: _toggleAudio,
                    onSave: _toggleSave,
                    onCopy: _copyAyah,
                    onPrevious: _prevAyah,
                    onNext: _nextAyah,
                    onChange: _shuffleAyah,
                    onShare: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ShareCardStudioScreen(
                            initialItem: ShareContentItem.fromDaily(
                                ayah, ShareContentType.ayah)))),
                  ),
                  const SizedBox(height: 18),

                  // Reflection / Context Card
                  if (ayah.contextOrReflection != null &&
                      ayah.contextOrReflection!.isNotEmpty) ...[
                    NoorCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: isDark
                                      ? NoorColors.darkGold
                                      : NoorColors.goldDeep,
                                  size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                'Spiritual Reflection',
                                style: NoorType.section.copyWith(
                                  color: isDark
                                      ? NoorColors.darkGold
                                      : NoorColors.emeraldDark,
                                ),
                              )),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ayah.contextOrReflection!,
                            style: NoorType.body.copyWith(
                              height: 1.5,
                              color: isDark
                                  ? NoorColors.darkTextSecondary
                                  : NoorColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Explore More in Quran
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore Quran',
                          style: NoorType.section.copyWith(
                            color: isDark
                                ? NoorColors.darkGold
                                : NoorColors.emeraldDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Recite and contemplate the full Surah in the Quran Reader.',
                          style: NoorType.meta.copyWith(
                            color: isDark
                                ? NoorColors.darkTextSecondary
                                : NoorColors.mutedDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.list_alt, size: 18),
                              label: const Text('Surah List'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const SurahListScreen()),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? NoorColors.darkGold
                                    : NoorColors.emeraldDark,
                                side: BorderSide(
                                  color: isDark
                                      ? NoorColors.darkBorder
                                      : NoorColors.emeraldMid,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.menu_book, size: 18),
                              label: const Text('Read Quran'),
                              onPressed: _readVerse,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NoorColors.emeraldDark,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}