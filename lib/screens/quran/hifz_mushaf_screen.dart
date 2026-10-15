import 'package:flutter/material.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'quran_reader_screen.dart';
import 'hifz_ai_test_screen.dart';
import 'hifz_heatmap_screen.dart';
import 'quran_audio_player_screen.dart';

/// Page 04 — Hifz Mushaf (16-Line). Emerald Al-Baqarah header,
/// 16-Line Page View strip, ornate framed Mushaf page with a FIXED
/// 16-line layout. Brief excerpt only: full Mushaf text must come
/// from a licensed/API source at runtime (TODO live) — the lines
/// below carry the design's opening fragment and ruled line slots,
/// never a reproduced page of text.
class HifzMushafScreen extends StatefulWidget {
  const HifzMushafScreen({super.key});
  @override
  State<HifzMushafScreen> createState() => _HifzMushafScreenState();
}

class _HifzMushafScreenState extends State<HifzMushafScreen> {
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    NoorStore.isBookmarked(_bookmarkId).then((v) {
      if (mounted) setState(() => _bookmarked = v);
    });
  }

  static const _bookmarkId = 'mushaf:al-baqarah:page2';

  Future<void> _toggleBookmark() async {
    final now = await NoorStore.toggleBookmark(_bookmarkId);
    if (!mounted) return;
    setState(() => _bookmarked = now);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(now ? 'Bookmarked · Al-Baqarah page 2' : 'Bookmark removed')));
  }

  void _openOptions() => showNoorOverflowSheet(context,
      title: 'Mushaf options',
      info: const [
        'The 16-line page is the traditional Hifz layout: 15 lines of text plus the surah header.',
      ],
      actions: [
        (
          Icons.school_outlined,
          'Test me on this page',
          () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const HifzAiTestScreen()))
        ),
        (
          Icons.track_changes_outlined,
          'Hifz progress',
          () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const HifzHeatmapScreen()))
        ),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          Container(
            color: NoorColors.emeraldDark,
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 14),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 19),
                  onPressed: () => Navigator.of(context).maybePop()),
              Expanded(
                  child: Column(children: [
                Text('Al-Baqarah',
                    style: NoorType.screenTitle.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text('Juz 1 • Page 2',
                    style: NoorType.meta.copyWith(color: Colors.white70)),
              ])),
              IconButton(
                  tooltip: _bookmarked ? 'Bookmarked' : 'Bookmark this page',
                  icon: Icon(
                      _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white),
                  onPressed: _toggleBookmark),
              IconButton(
                  tooltip: 'Mushaf options',
                  icon: const Icon(Icons.settings_outlined,
                      color: Colors.white),
                  onPressed: _openOptions),
            ]),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: NoorShadows.card),
            child: Row(children: [
              const Icon(Icons.menu_book_outlined,
                  size: 18, color: NoorColors.emeraldDark),
              const SizedBox(width: 8),
              Text('16-Line Page View',
                  style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
              const Spacer(),
              const Icon(Icons.info_outline, size: 16, color: NoorColors.muted),
              const SizedBox(width: 5),
              Flexible(
                  child: Text('This is the traditional Hifz layout',
                      style:
                          NoorType.meta.copyWith(color: NoorColors.muted))),
            ]),
          ),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                // Ornate Mushaf frame — drawn in code (gold/emerald double
                // border, page tab). TODO: swap in the licensed Mushaf
                // page rendering; do not paste page text into code.
                Container(
                  decoration: BoxDecoration(
                      color: NoorColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: NoorColors.goldSoft, width: 2)),
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: NoorColors.emerald, width: 1)),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                    child: Column(children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 2),
                          decoration: BoxDecoration(
                              color: NoorColors.sand,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: NoorColors.goldSoft)),
                          child: Text('٢',
                              style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark))),
                      const SizedBox(height: 4),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text('ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ',
                              textDirection: TextDirection.rtl,
                              style: NoorType.section.copyWith(fontFamily: 'AmiriQuran',
                                  height: 1.9,
                                  color: NoorColors.ink))),
                      const SizedBox(height: 12),
                      Container(
                        height: 300,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.menu_book_outlined,
                                  size: 34, color: NoorColors.emeraldDark),
                              const SizedBox(height: 12),
                              const Text('Mushaf page not loaded',
                                  style: NoorType.cardTitle),
                              const SizedBox(height: 8),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 28),
                                  child: Text(
                                      'The full 16-line page loads from the licensed Mushaf source when connected. Only the brief opening excerpt above is shown here.',
                                      textAlign: TextAlign.center,
                                      style: NoorType.meta.copyWith(height: 1.5,
                                          color: NoorColors.mutedDark))),
                            ]),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                    child: Text('Al-Baqarah · Page 2 of 604',
                        style: NoorType.meta.copyWith(color: NoorColors.mutedDark))),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: _navBtn(Icons.keyboard_double_arrow_left,
                          'Previous', 'Page 1')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(children: [
                    const Text('2 / 604',
                        style: NoorType.cardTitle),
                    Text('Juz 1',
                        style:
                            NoorType.meta.copyWith(color: NoorColors.muted))
                  ])),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _navBtn(
                          Icons.keyboard_double_arrow_right, 'Next', 'Page 3',
                          trailing: true)),
                ]),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: NoorShadows.card),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _tool(
                            context,
                            Icons.headphones_outlined,
                            'Listen',
                            // This screen is Al-Baqarah (surah 2): the
                            // player must open surah 2, not the default.
                            () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    const QuranAudioPlayerScreen(surah: 2)))),
                        _tool(context, Icons.repeat, 'Repeat', null),
                        _tool(context, Icons.bookmark_border, 'Bookmark', null),
                        _tool(
                            context,
                            Icons.school_outlined,
                            'Test Me',
                            () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const HifzAiTestScreen()))),
                        _tool(
                            context,
                            Icons.menu_book_outlined,
                            'Read',
                            // This screen is Al-Baqarah (surah 2).
                            () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    const QuranReaderScreen(surah: 2)))),
                        _tool(context, Icons.more_horiz, 'More', null),
                      ]),
                ),
                const SizedBox(height: 12),
                Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const HifzHeatmapScreen())),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: NoorShadows.card),
                          child: Row(children: [
                            const Icon(Icons.track_changes_outlined,
                                color: NoorColors.emeraldDark, size: 20),
                            const SizedBox(width: 10),
                            const Text('Hifz Progress',
                                style: NoorType.secondary),
                            const Spacer(),
                            for (var i = 0; i < 7; i++)
                              Container(
                                  width: 11,
                                  height: 11,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 2.5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i < 4
                                          ? NoorColors.emeraldDark
                                          : (i == 4
                                              ? NoorColors.gold
                                              : NoorColors.sand))),
                            const Icon(Icons.chevron_right,
                                color: NoorColors.muted, size: 19),
                          ])),
                    )),
              ])),
        ])),
      );
  Widget _navBtn(IconData icon, String label, String sub,
          {bool trailing = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: NoorShadows.card),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (!trailing) ...[
            Icon(icon, size: 17, color: NoorColors.emeraldDark),
            const SizedBox(width: 7)
          ],
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: NoorType.meta),
            Text(sub,
                style: NoorType.meta.copyWith(color: NoorColors.muted))
          ]),
          if (trailing) ...[
            const SizedBox(width: 7),
            Icon(icon, size: 17, color: NoorColors.emeraldDark)
          ],
        ]),
      );
  Widget _tool(BuildContext context, IconData icon, String label,
          VoidCallback? onTap) =>
      Semantics(
          button: onTap != null,
          enabled: onTap != null,
          label: label,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                  width: 48,
                  height: 60,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size: 21,
                            color: onTap == null
                                ? NoorColors.mutedDark
                                : NoorColors.emeraldDark),
                        const SizedBox(height: 5),
                        Text(label,
                            style: NoorType.meta.copyWith(color: onTap == null
                                    ? NoorColors.mutedDark
                                    : NoorColors.ink))
                      ]))));
}
