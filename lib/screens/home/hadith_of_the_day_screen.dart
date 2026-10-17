import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../data/daily_content_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../library/hadith_library_screen.dart';
import '../library/share_card_studio_screen.dart';

/// Page 09 — Hadith of the Day. Dark emerald header with skyline
/// (real crop) + dates, overlapping white card: calligraphy
/// roundel, brief Arabic excerpt, short translation as drawn,
/// Sahih al-Bukhari 1, Listen/Save/Share/Copy, About, Reflection,
/// Share & Earn Reward, More Hadiths. Brief attributed excerpt
/// only; full text from the licensed source at runtime.
class HadithOfTheDayScreen extends StatefulWidget {
  const HadithOfTheDayScreen({super.key});
  @override
  State<HadithOfTheDayScreen> createState() => _HadithOfTheDayScreenState();
}

class _HadithOfTheDayScreenState extends State<HadithOfTheDayScreen> {
  bool _saved = false;
  @override
  Widget build(BuildContext context) {
    final hadith = DailyContentService.getHadithOfDay();

    return Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: ListView(padding: EdgeInsets.zero, children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
                height: 190,
                color: NoorColors.emeraldDark,
                child: Stack(children: [
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Image.asset(NoorAssets.hadithLibraryHeader,
                          cacheWidth: 1170,
                          height: 76,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink())),
                  Column(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
                        child: Row(children: [
                          IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 19),
                              onPressed: () =>
                                  Navigator.of(context).maybePop()),
                          Expanded(
                              child: Text('Hadith of the Day',
                                  textAlign: TextAlign.center,
                                  style: NoorType.screenTitle.copyWith(color: Colors.white))),
                          IconButton(
                              icon: const Icon(Icons.bookmark_border,
                                  color: Colors.white, size: 20),
                              onPressed: () =>
                                  setState(() => _saved = !_saved)),
                          IconButton(
                              tooltip: 'More options',
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              onPressed: () => showNoorOverflowSheet(context,
                                  title: 'Hadith of the Day',
                                  actions: [
                                    (
                                      Icons.copy_outlined,
                                      'Copy hadith text',
                                      _copyHadith
                                    ),
                                    (
                                      _saved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      _saved ? 'Unsave' : 'Save',
                                      () => setState(() => _saved = !_saved)
                                    ),
                                    (
                                      Icons.ios_share,
                                      'Open in Share Studio',
                                      () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ShareCardStudioScreen()))
                                    ),
                                  ])),
                        ])),
                    Text(NoorAppState.hijriLabel,
                        style: NoorType.secondary.copyWith(color: Colors.white)),
                    const SizedBox(height: 3),
                    Text(NoorAppState.gregorianLabel,
                        style:
                            NoorType.meta.copyWith(color: Colors.white70)),
                  ]),
                ])),
            Positioned(
                left: 20,
                right: 20,
                bottom: -6,
                child: Container(
                    height: 26,
                    decoration: BoxDecoration(
                        color: NoorColors.cream,
                        borderRadius: BorderRadius.circular(20)))),
          ]),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NoorCard(
                        child: Column(children: [
                      ClipOval(
                          child: Image.asset(NoorAssets.hadithDayMedallion,
                              width: 88,
                              cacheWidth: 264,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 88,
                                  height: 88,
                                  color: NoorColors.emeraldDark,
                                  child: const Icon(Icons.mosque,
                                      color: NoorColors.gold)))),
                      const SizedBox(height: 14),
                      const Text('Prophet Muhammad (peace be upon him) said:',
                          textAlign: TextAlign.center,
                          style: NoorType.secondary),
                      const SizedBox(height: 14),
                      Text(hadith.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: NoorType.arabic(
                              size: 27, color: NoorColors.emeraldDark)),
                      const SizedBox(height: 10),
                      Container(
                          width: 110, height: 1.4, color: NoorColors.goldSoft),
                      const SizedBox(height: 12),
                      Text(
                          '"${hadith.translation}"',
                          textAlign: TextAlign.center,
                          style: NoorType.body.copyWith(height: 1.55)),
                      const SizedBox(height: 10),
                      Text(hadith.source,
                          style: NoorType.secondary.copyWith(color: NoorColors.emerald)),
                      const SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _action(Icons.volume_up_outlined, 'Listen', null),
                            _action(
                                _saved ? Icons.bookmark : Icons.bookmark_border,
                                'Save',
                                () => setState(() => _saved = !_saved)),
                            _action(
                                Icons.ios_share,
                                'Share',
                                () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ShareCardStudioScreen()))),
                            _action(Icons.copy_outlined, 'Copy', _copyHadith),
                          ]),
                    ])),
                    const SizedBox(height: 20),
                    const Text('About this Hadith',
                        style: NoorType.cardTitle),
                    const SizedBox(height: 7),
                    Text(
                        hadith.about,
                        style: NoorType.secondary.copyWith(color: NoorColors.mutedDark,
                            height: 1.55)),
                    const SizedBox(height: 16),
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: NoorColors.surfaceWarm,
                            borderRadius:
                                BorderRadius.circular(NoorRadius.card)),
                        child: Row(children: [
                          const Icon(Icons.psychology_outlined,
                              color: NoorColors.emeraldDark, size: 26),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                const Text('Reflection',
                                    style: NoorType.body),
                                const SizedBox(height: 4),
                                Text(
                                    hadith.reflection,
                                    style: NoorType.meta.copyWith(color: NoorColors.muted,
                                        height: 1.5)),
                              ])),
                        ])),
                    const SizedBox(height: 12),
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: NoorColors.emeraldSoft,
                            borderRadius:
                                BorderRadius.circular(NoorRadius.card)),
                        child: Row(children: [
                          Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                  color: NoorColors.emeraldDark,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.card_giftcard,
                                  color: Colors.white, size: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                const Text('Share & Earn Reward',
                                    style: NoorType.body),
                                const SizedBox(height: 3),
                                Text(
                                    'Share this hadith with others and spread the knowledge.',
                                    style: NoorType.meta.copyWith(color: NoorColors.muted)),
                              ])),
                          FilledButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ShareCardStudioScreen())),
                              style: FilledButton.styleFrom(
                                  backgroundColor: NoorColors.emeraldDark,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: const Text('Share Now',
                                  style: NoorType.meta)),
                        ])),
                    const SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('More Hadiths for You',
                              style: NoorType.cardTitle),
                          TextButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const HadithLibraryScreen())),
                              style: TextButton.styleFrom(
                                  minimumSize: const Size(44, 44)),
                              child: Text('View All',
                                  style: NoorType.secondary.copyWith(color: NoorColors.emerald))),
                        ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      for (final h in [
                        ('Sahih Muslim 1907', 'Character'),
                        ('Sahih al-Bukhari 1', 'Intentions'),
                        ('Sahih Muslim 1718', 'Deeds')
                      ]) ...[
                        Expanded(
                            child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 96),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: NoorShadows.card),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(h.$2,
                                          style: NoorType.meta),
                                      const SizedBox(height: 6),
                                      Text(h.$1,
                                          style: NoorType.meta.copyWith(color: NoorColors.muted)),
                                      const Align(
                                          alignment: Alignment.centerRight,
                                          child: Icon(Icons.bookmark_border,
                                              size: 15,
                                              color: NoorColors.muted))
                                    ]))),
                        const SizedBox(width: 10),
                      ],
                    ]),
                  ])),
        ])),
      );
  }

  Future<void> _copyHadith() async {
    final hadith = DailyContentService.getHadithOfDay();
    await Clipboard.setData(ClipboardData(
        text: '${hadith.source}: "${hadith.translation}"'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied - paste anywhere to share')));
    }
  }

  Widget _action(IconData i, String l, VoidCallback? f) => Semantics(
      button: f != null,
      enabled: f != null,
      label: l,
      child: InkWell(
          onTap: f,
          borderRadius: BorderRadius.circular(26),
          child: Column(children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: f == null ? NoorColors.sand : NoorColors.emeraldSoft,
                    shape: BoxShape.circle),
                child: Icon(i,
                    color: f == null
                        ? NoorColors.mutedDark
                        : NoorColors.emeraldDark,
                    size: 21)),
            const SizedBox(height: 7),
            Text(l,
                style:
                    NoorType.meta),
          ])));
}
