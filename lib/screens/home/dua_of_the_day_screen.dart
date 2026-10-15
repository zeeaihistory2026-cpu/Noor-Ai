import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../worship/reminder_center_screen.dart';
import '../library/share_card_studio_screen.dart';

/// Page 08 — Dua of the Day. Cream header (title + Hijri/Greg date),
/// white dua card with mosque badge, brief Arabic excerpt,
/// transliteration, short translation, Quran 20:114, Listen /
/// Save / Share / Copy circles, About, More Duas chips, dark
/// Share Your Card preview (brief excerpt) with Customize -> 19.
class DuaOfTheDayScreen extends StatefulWidget {
  const DuaOfTheDayScreen({super.key});
  @override
  State<DuaOfTheDayScreen> createState() => _DuaOfTheDayScreenState();
}

class _DuaOfTheDayScreenState extends State<DuaOfTheDayScreen> {
  bool _saved = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
              child: Row(children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 19),
                    onPressed: () => Navigator.of(context).maybePop()),
                Expanded(
                    child: Column(children: [
                  Text('Dua of the Day',
                      textAlign: TextAlign.center,
                      style: NoorType.screenTitle.copyWith(color: NoorColors.emeraldDark)),
                  const SizedBox(height: 3),
                  Text(NoorAppState.dateLine, style: NoorType.meta),
                ])),
                IconButton(
                    tooltip: 'About daily duas',
                    icon: const Icon(Icons.calendar_month_outlined, size: 21),
                    onPressed: () => showNoorOverflowSheet(context,
                        title: 'Daily Dua',
                        info: const [
                          'A new dua appears here every day.',
                          'Want it as a notification? Turn on the Dua of the Day reminder below.',
                        ],
                        actions: [
                          (
                            Icons.alarm_outlined,
                            'Dua reminder settings',
                            () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const ReminderCenterScreen()))
                          ),
                        ])),
                IconButton(
                    tooltip: 'More options',
                    icon: const Icon(Icons.more_vert, size: 21),
                    onPressed: () => showNoorOverflowSheet(context,
                        title: 'Dua of the Day',
                        actions: [
                          (
                            Icons.copy_outlined,
                            'Copy dua text',
                            _copyDua
                          ),
                          (
                            _saved ? Icons.bookmark : Icons.bookmark_border,
                            _saved ? 'Unsave' : 'Save',
                            () => setState(() => _saved = !_saved)
                          ),
                          (
                            Icons.ios_share,
                            'Open in Share Studio',
                            () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    const ShareCardStudioScreen()))
                          ),
                        ])),
              ])),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                NoorCard(
                    child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.bookmark_border,
                            color: NoorColors.emeraldDark, size: 20),
                        Icon(_saved ? Icons.favorite : Icons.favorite_border,
                            color: NoorColors.emeraldDark, size: 20),
                      ]),
                  ClipOval(
                      child: Image.asset(NoorAssets.duaMedallion,
                          width: 76,
                          cacheWidth: 228,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 76,
                              height: 76,
                              color: NoorColors.emeraldDark,
                              child: const Icon(Icons.mosque,
                                  color: NoorColors.gold, size: 34)))),
                  const SizedBox(height: 18),
                  Text(SampleData.duaArabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: NoorType.arabic(
                          size: 30, color: NoorColors.emeraldDark)),
                  const SizedBox(height: 10),
                  Container(
                      width: 110, height: 1.4, color: NoorColors.goldSoft),
                  const SizedBox(height: 12),
                  const Text(SampleData.duaTransliteration,
                      style:
                          NoorType.cardTitle),
                  const SizedBox(height: 8),
                  const Text(SampleData.duaTranslation,
                      textAlign: TextAlign.center,
                      style: NoorType.body),
                  const SizedBox(height: 8),
                  Text(SampleData.duaSource,
                      style: NoorType.secondary.copyWith(color: NoorColors.emerald)),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _action(Icons.volume_up_outlined, 'Listen', null),
                        _action(_saved ? Icons.bookmark : Icons.bookmark_border,
                            'Save', () => setState(() => _saved = !_saved)),
                        _action(
                            Icons.ios_share,
                            'Share',
                            () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    const ShareCardStudioScreen()))),
                        _action(Icons.copy_outlined, 'Copy', _copyDua),
                      ]),
                ])),
                const SizedBox(height: 20),
                const Text('About this Dua',
                    style:
                        NoorType.cardTitle),
                const SizedBox(height: 7),
                // Wording as drawn on Page 08 (brief design copy).
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(
                              'A short Qur\'anic prayer asking Allah for increase in knowledge (${SampleData.duaSource}).',
                              style: NoorType.secondary.copyWith(color: NoorColors.mutedDark,
                                  height: 1.55))),
                      const Icon(Icons.chevron_right,
                          color: NoorColors.muted, size: 19),
                    ]),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('More Duas for You',
                          style: NoorType.cardTitle),
                      Text('View All',
                          style: NoorType.secondary.copyWith(color: NoorColors.emerald))
                    ]),
                const SizedBox(height: 12),
                Row(children: [
                  for (final d in [
                    ('Allahumma ighfir li', 'Forgiveness'),
                    ('Rabbana atina fid dunya', 'Good in this world'),
                    ('Allahumma hdina', 'Guidance')
                  ]) ...[
                    Expanded(
                        child: Container(
                            constraints: const BoxConstraints(minHeight: 96),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: NoorShadows.card),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.$1,
                                      style: NoorType.meta,
                                      maxLines: 2),
                                  const SizedBox(height: 5),
                                  Text(d.$2,
                                      style: NoorType.meta.copyWith(color: NoorColors.muted)),
                                  const Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(Icons.bookmark_border,
                                          size: 15, color: NoorColors.muted))
                                ]))),
                    const SizedBox(width: 10),
                  ],
                ]),
                const SizedBox(height: 22),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Share Your Card',
                          style: NoorType.cardTitle),
                      OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text('Customize',
                              style: NoorType.meta),
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ShareCardStudioScreen()))),
                    ]),
                const SizedBox(height: 12),
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldDark,
                        borderRadius: BorderRadius.circular(NoorRadius.card),
                        boxShadow: NoorShadows.hero),
                    child: Column(children: [
                      Text('DUA OF THE DAY',
                          style: NoorType.meta.copyWith(color: NoorColors.gold,
                              letterSpacing: 1.6)),
                      const SizedBox(height: 14),
                      Image.asset(NoorAssets.lantern,
                          cacheWidth: 1170,
                          height: 54,
                          errorBuilder: (_, __, ___) => const Icon(Icons.light,
                              color: NoorColors.gold, size: 30)),
                      const SizedBox(height: 12),
                      Text(SampleData.duaArabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style:
                              NoorType.arabic(size: 25, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(SampleData.duaTranslation,
                          textAlign: TextAlign.center,
                          style: NoorType.secondary.copyWith(color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(SampleData.duaSource,
                          style: NoorType.meta.copyWith(color: NoorColors.gold)),
                      const SizedBox(height: 10),
                      Text('NOOR',
                          style: NoorType.meta.copyWith(color: Colors.white70,
                              letterSpacing: 2)),
                    ])),
                const SizedBox(height: 16),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (final s in [
                        ('W', 'WhatsApp'),
                        ('I', 'Instagram'),
                        ('T', 'TikTok'),
                        ('F', 'Facebook'),
                        ('…', 'More')
                      ])
                        Column(children: [
                          CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: Text(s.$1,
                                  style: NoorType.meta.copyWith(color: NoorColors.emeraldDark))),
                          const SizedBox(height: 6),
                          Text(s.$2,
                              style: NoorType.meta.copyWith(color: NoorColors.muted))
                        ]),
                    ]),
              ])),
        ])),
      );
  Future<void> _copyDua() async {
    await Clipboard.setData(const ClipboardData(
        text:
            'Rabbi zidni \'ilma - "My Lord, increase me in knowledge." (Quran 20:114)'));
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
