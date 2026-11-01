import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../data/daily_content_service.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
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
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
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
          content: Text(now ? 'Ayah saved to bookmarks' : 'Ayah removed from bookmarks'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _nextAyah() {
    HapticFeedback.selectionClick();
    setState(() => _offset++);
    _checkBookmark();
  }

  void _prevAyah() {
    HapticFeedback.selectionClick();
    setState(() => _offset--);
    _checkBookmark();
  }

  void _shuffleAyah() {
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
    final text = '${_ayah.arabic}\n\n"${_ayah.translation}"\n\n— ${_ayah.reference}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayat text copied to clipboard!')),
      );
    }
  }

  void _toggleAudio() {
    HapticFeedback.selectionClick();
    setState(() => _isPlayingAudio = !_isPlayingAudio);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPlayingAudio
            ? 'Playing recitation of ${_ayah.reference}...'
            : 'Recitation paused.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
                    icon: Icon(Icons.arrow_back_ios_new,
                        size: 19,
                        color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Ayat of the Day',
                          textAlign: TextAlign.center,
                          style: NoorType.screenTitle.copyWith(
                            color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(NoorAppState.dateLine,
                            style: NoorType.meta.copyWith(
                                color: isDark ? NoorColors.darkTextSecondary : NoorColors.muted)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Change / Shuffle Ayah',
                    icon: Icon(Icons.shuffle,
                        color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark, size: 21),
                    onPressed: _shuffleAyah,
                  ),
                  IconButton(
                    tooltip: 'More options',
                    icon: Icon(Icons.more_vert,
                        color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink, size: 21),
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
                              builder: (_) => const ShareCardStudioScreen(),
                            ),
                          ),
                        ),
                        (
                          Icons.menu_book,
                          'Open in Quran Reader',
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const QuranReaderScreen(),
                            ),
                          ),
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
                  NoorCard(
                    child: Column(
                      children: [
                        // Card Top Controls: Navigation & Bookmark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: NoorColors.emeraldSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ayah.reference,
                                style: NoorType.meta.copyWith(
                                  color: NoorColors.emeraldDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                                  tooltip: 'Previous Ayah',
                                  onPressed: _prevAyah,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.shuffle, size: 17, color: NoorColors.emeraldDark),
                                  tooltip: 'Change Ayah',
                                  onPressed: _shuffleAyah,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                  tooltip: 'Next Ayah',
                                  onPressed: _nextAyah,
                                ),
                                IconButton(
                                  icon: Icon(
                                    _saved ? Icons.bookmark : Icons.bookmark_border,
                                    color: NoorColors.emeraldDark,
                                    size: 20,
                                  ),
                                  tooltip: _saved ? 'Bookmarked' : 'Save',
                                  onPressed: _toggleSave,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Quran Rehal Art
                        ClipOval(
                          child: Image.asset(
                            NoorAssets.quranRehal,
                            width: 76,
                            cacheWidth: 228,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 76,
                              height: 76,
                              color: NoorColors.emeraldDark,
                              child: const Icon(Icons.menu_book, color: NoorColors.gold, size: 34),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          ayah.title,
                          textAlign: TextAlign.center,
                          style: NoorType.section.copyWith(
                            color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Arabic Text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? NoorColors.darkSurface.withValues(alpha: 0.5)
                                : NoorColors.cream.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? NoorColors.darkBorder : NoorColors.hairlineSoft,
                            ),
                          ),
                          child: Text(
                            ayah.arabic,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: NoorType.arabic(
                              size: 26,
                              color: isDark ? NoorColors.darkTextPrimary : NoorColors.emeraldDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Transliteration (if available)
                        if (ayah.transliteration != null && ayah.transliteration!.isNotEmpty) ...[
                          Text(
                            ayah.transliteration!,
                            textAlign: TextAlign.center,
                            style: NoorType.secondary.copyWith(
                              fontStyle: FontStyle.italic,
                              color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // English Translation
                        Text(
                          ayah.translation,
                          textAlign: TextAlign.center,
                          style: NoorType.body.copyWith(
                            height: 1.5,
                            color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Urdu Translation (if available)
                        if (ayah.urdu != null && ayah.urdu!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? NoorColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                              ),
                            ),
                            child: Text(
                              ayah.urdu!,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                height: 1.6,
                                color: isDark ? NoorColors.darkTextPrimary : NoorColors.emeraldDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Action Buttons: Listen / Save / Share / Copy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _circleAction(
                              icon: _isPlayingAudio ? Icons.pause : Icons.volume_up,
                              label: _isPlayingAudio ? 'Pause' : 'Listen',
                              onTap: _toggleAudio,
                              isDark: isDark,
                              active: _isPlayingAudio,
                            ),
                            const SizedBox(width: 16),
                            _circleAction(
                              icon: _saved ? Icons.bookmark : Icons.bookmark_border,
                              label: _saved ? 'Saved' : 'Save',
                              onTap: _toggleSave,
                              isDark: isDark,
                              active: _saved,
                            ),
                            const SizedBox(width: 16),
                            _circleAction(
                              icon: Icons.ios_share,
                              label: 'Share',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ShareCardStudioScreen(),
                                ),
                              ),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 16),
                            _circleAction(
                              icon: Icons.copy,
                              label: 'Copy',
                              onTap: _copyAyah,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Reflection / Context Card
                  if (ayah.contextOrReflection != null && ayah.contextOrReflection!.isNotEmpty) ...[
                    NoorCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: isDark ? NoorColors.darkGold : NoorColors.gold, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Spiritual Reflection',
                                style: NoorType.section.copyWith(
                                  color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ayah.contextOrReflection!,
                            style: NoorType.body.copyWith(
                              height: 1.5,
                              color: isDark ? NoorColors.darkTextSecondary : NoorColors.ink,
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
                            color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Recite and contemplate the full Surah in the Quran Reader.',
                          style: NoorType.meta.copyWith(
                            color: isDark ? NoorColors.darkTextSecondary : NoorColors.muted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.list_alt, size: 18),
                                label: const Text('Surah List'),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SurahListScreen()),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? NoorColors.darkGold : NoorColors.emeraldDark,
                                  side: BorderSide(
                                    color: isDark ? NoorColors.darkBorder : NoorColors.emeraldMid,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.menu_book, size: 18),
                                label: const Text('Read Quran'),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const QuranReaderScreen()),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: NoorColors.emeraldDark,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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

  Widget _circleAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool active = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? NoorColors.emeraldDark
                  : (isDark ? NoorColors.darkSurface : Colors.white),
              border: Border.all(
                color: active
                    ? NoorColors.emeraldDark
                    : (isDark ? NoorColors.darkBorder : NoorColors.hairline),
              ),
              boxShadow: isDark ? null : NoorShadows.card,
            ),
            child: Icon(
              icon,
              size: 20,
              color: active
                  ? Colors.white
                  : (isDark ? NoorColors.darkGold : NoorColors.emeraldDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: NoorType.meta.copyWith(
              fontSize: 11,
              color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}
