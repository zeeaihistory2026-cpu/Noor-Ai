import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../library/saved_content_screen.dart';
import 'quran_audio_player_screen.dart';
import 'quran_reader_screen.dart';
import 'hifz_mushaf_screen.dart';
import 'hifz_ai_test_screen.dart';
import 'surah_list_screen.dart';

/// Page 11 — Quran Home. Dark emerald header (search, "Quran",
/// bookmark, pill tabs), a cream banner with one brief attributed
/// excerpt, Continue Reading, the Surahs preview list, Listen to
/// Quran, Daily Verse and a dark Quick Actions panel.
class QuranHomeScreen extends StatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  State<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends State<QuranHomeScreen> {
  int _tab = 0;

  void _openReader() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const QuranReaderScreen()));
  void _openList() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const SurahListScreen()));
  void _openPlayer() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const QuranAudioPlayerScreen()));
  void _openSaved() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const SavedContentScreen()));
  void _openMushaf() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const HifzMushafScreen()));
  void _openHifzTest() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const HifzAiTestScreen()));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          NoorDarkHeader(
            title: 'Quran',
            leading: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: _openList),
            actions: [
              IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.white),
                  onPressed: _openSaved),
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page 11 quote banner — illustrated card cropped from
                // the user's own Page 11 (lanterns, mosque silhouettes,
                // brief Al-Isra 17:9 excerpt as drawn in the design).
                Semantics(
                  label:
                      '${SampleData.quranBannerTranslation} ${SampleData.quranBannerSource}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(NoorRadius.card),
                    child: AspectRatio(
                      aspectRatio: 454 / 184,
                      child: Image.asset(NoorAssets.quranBannerVerse,
                          cacheWidth: 1170,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: NoorColors.cream,
                              alignment: Alignment.center,
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(SampleData.quranBannerTranslation,
                                    textAlign: TextAlign.center),
                              ))),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _sectionRow('Continue Reading', onViewAll: _openList),
                const SizedBox(height: 12),
                NoorCard(
                  onTap: _openReader,
                  child: Row(children: [
                    // Calligraphy roundel cropped from Page 01.
                    ClipOval(
                      child: Image.asset(NoorAssets.surahCalligraphy,
                          width: 54,
                          cacheWidth: 162,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 54,
                              height: 54,
                              color: NoorColors.emeraldDark)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(SampleData.continueQuranSurah,
                                style: NoorType.cardTitle),
                            const SizedBox(height: 3),
                            Text(SampleData.continueQuranDetail,
                                style: NoorType.meta.copyWith(color: NoorColors.muted)),
                            const SizedBox(height: 3),
                            Text(SampleData.continueQuranNote,
                                style: NoorType.meta.copyWith(color: NoorColors.muted)),
                          ]),
                    ),
                    FilledButton(
                        onPressed: _openReader, child: const Text('Read Now')),
                  ]),
                ),
                const SizedBox(height: 22),
                _sectionRow('Surahs', onViewAll: _openList),
                const SizedBox(height: 12),
                NoorCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < 5; i++) ...[
                        if (i > 0)
                          const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: NoorColors.hairlineSoft),
                        _surahRow(SampleData.surahs[i],
                            bookmarked: i == 1, onTap: _openReader),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                NoorCard(
                  onTap: _openPlayer,
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(NoorAssets.quranRehal,
                          width: 76,
                          cacheWidth: 228,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 76,
                              height: 76,
                              color: NoorColors.emeraldSoft)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Listen to Quran',
                                style: NoorType.cardTitle),
                            const SizedBox(height: 4),
                            Text(
                                'Listen to beautiful recitations by renowned Qaris.',
                                style: NoorType.meta.copyWith(color: NoorColors.muted,
                                    height: 1.45)),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: _openPlayer,
                              icon: const Icon(Icons.headphones, size: 17),
                              label: const Text('Listen Now'),
                              style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 9)),
                            ),
                          ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                NoorCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionRow('Daily Verse'),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            'وَاذْكُر رَّبَّكَ إِذَا نَسِيتَ',
                            textDirection: TextDirection.rtl,
                            style: NoorType.screenTitle.copyWith(color: NoorColors.emeraldDark),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                            child: Text(SampleData.dailyVerseTranslation,
                                style: NoorType.secondary)),
                        const SizedBox(height: 5),
                        Center(
                            child: Text(SampleData.dailyVerseSource,
                                style: NoorType.meta.copyWith(color: NoorColors.muted))),
                      ]),
                ),
                const SizedBox(height: 16),
                NoorCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionRow('Hifz Mode'),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: OutlinedButton.icon(
                                  onPressed: _openMushaf,
                                  icon: const Icon(Icons.menu_book_outlined,
                                      size: 17),
                                  label: const Text('16-Line Mushaf',
                                      style: NoorType.meta))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: FilledButton.icon(
                                  onPressed: _openHifzTest,
                                  icon: const Icon(Icons.mic_none_outlined,
                                      size: 17),
                                  label: const Text('Hifz AI Test',
                                      style: NoorType.meta))),
                        ]),
                      ]),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      NoorColors.emeraldDark,
                      NoorColors.emeraldMid
                    ]),
                    borderRadius: BorderRadius.circular(NoorRadius.heroCard),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Actions',
                            style: NoorType.cardTitle.copyWith(color: Colors.white)),
                        const SizedBox(height: 14),
                        Row(children: [
                          _quickAction(Icons.search, 'Search', _openList),
                          _quickAction(
                              Icons.bookmark_border, 'Bookmarks', _openSaved),
                          _quickAction(Icons.edit_note, 'Notes', _openSaved),
                          _quickAction(
                              Icons.highlight, 'Highlights', _openSaved),
                        ]),
                      ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionRow(String title, {VoidCallback? onViewAll}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  NoorType.cardTitle),
          if (onViewAll != null)
            Semantics(button: true, child: GestureDetector(
              onTap: onViewAll,
              child: Text('View All',
                  style: NoorType.secondary.copyWith(color: NoorColors.emerald)),
            )),
        ],
      );

  Widget _surahRow((int, String, String, int, int, String) s,
          {required bool bookmarked, required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: NoorColors.emeraldSoft, shape: BoxShape.circle),
              child: Text('${s.$1}',
                  style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(s.$2,
                  style: NoorType.body),
            ),
            Expanded(
              child: Text(s.$3,
                  style:
                      NoorType.meta.copyWith(color: NoorColors.muted)),
            ),
            Text('${s.$4} Verses',
                style: NoorType.meta.copyWith(color: NoorColors.muted)),
            const SizedBox(width: 10),
            Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 19,
                color: bookmarked ? NoorColors.emerald : NoorColors.muted),
          ]),
        ),
      );

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) =>
      Expanded(
        child: Semantics(button: true, child: GestureDetector(
          onTap: onTap,
          child: Column(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 7),
            Text(label,
                style: NoorType.meta.copyWith(color: Colors.white)),
          ]),
        )),
      );
}
