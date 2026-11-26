import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../data/daily_content_service.dart';
import '../../data/daily_content_actions.dart';
import '../../data/share_content.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/daily_reflection_card.dart';
import '../worship/reminder_center_screen.dart';
import '../library/share_card_studio_screen.dart';
import '../library/dua_library_screen.dart';

/// Page 08 — Dua of the Day. Cream header (title + Hijri/Greg date),
/// white dua card with mosque badge, brief Arabic excerpt,
/// transliteration, short translation, Quran 20:114, Listen /
/// Save / Share / Copy circles, About, More Duas chips, dark
/// Share Your Card preview (brief excerpt) with Customize -> 19.
class DuaOfTheDayScreen extends StatefulWidget {
  const DuaOfTheDayScreen({super.key, this.initialOffset = 0});

  final int initialOffset;

  @override
  State<DuaOfTheDayScreen> createState() => _DuaOfTheDayScreenState();
}

class _DuaOfTheDayScreenState extends State<DuaOfTheDayScreen> {
  late int _offset;
  bool _saved = false;
  final _playback = DailyContentPlayback();
  bool _isPlayingAudio = false;

  void _audioChanged() {
    if (!mounted) return;
    setState(() => _isPlayingAudio = _playback.playing || _playback.loading);
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
    _checkBookmark();
  }

  void _nextDua() {
    HapticFeedback.selectionClick();
    setState(() => _offset++);
    _playback.stop();
    _checkBookmark();
  }

  void _prevDua() {
    HapticFeedback.selectionClick();
    setState(() => _offset--);
    _playback.stop();
    _checkBookmark();
  }

  void _shuffleDua() {
    _playback.stop();
    HapticFeedback.mediumImpact();
    setState(() => _offset += 1 + (DateTime.now().microsecond % 5));
    _playback.stop();
    _checkBookmark();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changed to another authentic Dua!'),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }

  Future<void> _checkBookmark() async {
    final item = DailyContentService.getDua(offset: _offset);
    final saved = await DailyBookmarks.isSaved(item, 'dua');
    if (mounted && DailyContentService.getDua(offset: _offset).id == item.id) {
      setState(() => _saved = saved);
    }
  }

  Future<void> _toggleSave() async {
    final item = DailyContentService.getDua(offset: _offset);
    final saved = await DailyBookmarks.toggle(item, 'dua');
    if (!mounted || DailyContentService.getDua(offset: _offset).id != item.id) {
      return;
    }
    setState(() => _saved = saved);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            saved ? 'Saved to your library' : 'Removed from saved items')));
  }

  void _toggleAudio(DailyContentItem item) {
    if (!_isPlayingAudio) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Listening uses your selected male narrator.')));
    }
    _playback.toggle(item, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final dua = DailyContentService.getDua(offset: _offset);

    return Scaffold(
      backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
      body: SafeArea(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
            child: Row(children: [
              IconButton(
                tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_ios_new, size: 19),
                  onPressed: () => Navigator.of(context).maybePop()),
              Expanded(
                  child: Column(children: [
                Text('Dua of the Day',
                    textAlign: TextAlign.center,
                    style: NoorType.screenTitle.copyWith(color: null)),
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
                              () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ReminderCenterScreen()))
                            ),
                          ])),
              IconButton(
                  tooltip: 'More options',
                  icon: const Icon(Icons.more_vert, size: 21),
                  onPressed: () => showNoorOverflowSheet(context,
                          title: 'Dua of the Day',
                          actions: [
                            (Icons.copy_outlined, 'Copy dua text', _copyDua),
                            (
                              Icons.record_voice_over_outlined,
                              'Choose male narrator',
                              () => _playback.selectNarrator(context)
                            ),
                            (
                              _saved ? Icons.bookmark : Icons.bookmark_border,
                              _saved ? 'Unsave' : 'Save',
                              _toggleSave
                            ),
                            (
                              Icons.ios_share,
                              'Open in Share Studio',
                              () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => ShareCardStudioScreen(
                                          initialItem:
                                              ShareContentItem.fromDaily(
                                                  dua, ShareContentType.dua))))
                            ),
                          ])),
            ])),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
              DailyReflectionCard(
                item: dua,
                kind: 'dua',
                expanded: true,
                saved: _saved,
                playing: _playback.playing,
                loading: _playback.loading,
                onListen: () => _toggleAudio(dua),
                onSave: _toggleSave,
                onCopy: _copyDua,
                onPrevious: _prevDua,
                onNext: _nextDua,
                onChange: _shuffleDua,
                onShare: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ShareCardStudioScreen(
                        initialItem: ShareContentItem.fromDaily(
                            dua, ShareContentType.dua)))),
              ),
              const SizedBox(height: 20),
              const Text('About this Dua', style: NoorType.cardTitle),
              const SizedBox(height: 7),
              Text(
                  dua.about.isNotEmpty
                      ? dua.about
                      : 'A sacred supplication asking Allah (${dua.source}).',
                  style: NoorType.secondary.copyWith(
                      color: NoorTheme.muted(context), height: 1.55)),
              const SizedBox(height: 20),
              Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const Text('More Duas for You', style: NoorType.cardTitle),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const DuaLibraryScreen()),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        foregroundColor: NoorTheme.accent(context),
                      ),
                      child: Text('View All',
                          style: NoorType.secondary
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ]),
              const SizedBox(height: 12),
              for (int i = 1; i <= 3; i++) ...[
                NoorCard(
                    key: ValueKey('daily-dua-suggestion-$i'),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            DuaOfTheDayScreen(initialOffset: _offset + i))),
                    child: Row(children: [
                      const Icon(Icons.spa_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                                DailyContentService.getDua(offset: _offset + i)
                                    .title,
                                style: NoorType.body),
                            const SizedBox(height: 5),
                            Text(
                                DailyContentService.getDua(offset: _offset + i)
                                    .reference,
                                style: NoorType.meta),
                          ])),
                      const Icon(Icons.chevron_right),
                    ])),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 22),
              Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const Text('Share Your Card', style: NoorType.cardTitle),
                    OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text('Customize', style: NoorType.meta),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => ShareCardStudioScreen(
                                    initialItem: ShareContentItem.fromDaily(
                                        dua, ShareContentType.dua))))),
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
                        style: NoorType.meta.copyWith(
                            color: NoorColors.gold, letterSpacing: 1.6)),
                    const SizedBox(height: 14),
                    ExcludeSemantics(
                        child: Image.asset(NoorAssets.lantern,
                            cacheWidth: 1170,
                            height: 54,
                            errorBuilder: (_, __, ___) => const Icon(Icons.light,
                                color: NoorColors.gold, size: 30))),
                    const SizedBox(height: 12),
                    Text(dua.arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: NoorType.arabic(size: 25, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(dua.translation,
                        textAlign: TextAlign.center,
                        style:
                            NoorType.secondary.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(dua.reference,
                        style: NoorType.meta.copyWith(color: NoorColors.gold)),
                    const SizedBox(height: 10),
                    Text('MuslimGo',
                        style: NoorType.meta
                            .copyWith(color: Colors.white70, letterSpacing: 2)),
                  ])),
              const SizedBox(height: 16),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => ShareCardStudioScreen(
                                  initialItem: ShareContentItem.fromDaily(
                                      dua, ShareContentType.dua)))),
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Create shareable card'))),
            ])),
      ])),
    );
  }

  Future<void> _copyDua() async {
    final dua = DailyContentService.getDua(offset: _offset);
    final trans = dua.transliteration != null && dua.transliteration!.isNotEmpty
        ? '${dua.transliteration}\n'
        : '';
    await Clipboard.setData(ClipboardData(
        text: '${dua.arabic}\n$trans"${dua.translation}" (${dua.source})'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied - paste anywhere to share')));
    }
  }
}