import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../data/daily_content_service.dart';
import '../../data/daily_content_actions.dart';
import '../../data/share_content.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/daily_reflection_card.dart';
import '../library/hadith_library_screen.dart';
import '../library/share_card_studio_screen.dart';

/// Page 09 — Hadith of the Day. Dark emerald header with skyline
/// (real crop) + dates, overlapping white card: calligraphy
/// roundel, brief Arabic excerpt, short translation as drawn,
/// Sahih al-Bukhari 1, Listen/Save/Share/Copy, About, Reflection,
/// Share & Earn Reward, More Hadiths. Brief attributed excerpt
/// only; full text from the licensed source at runtime.
class HadithOfTheDayScreen extends StatefulWidget {
  const HadithOfTheDayScreen({super.key, this.initialOffset = 0});

  final int initialOffset;

  @override
  State<HadithOfTheDayScreen> createState() => _HadithOfTheDayScreenState();
}

class _HadithOfTheDayScreenState extends State<HadithOfTheDayScreen> {
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

  void _nextHadith() {
    HapticFeedback.selectionClick();
    setState(() => _offset++);
    _playback.stop();
    _checkBookmark();
  }

  void _prevHadith() {
    HapticFeedback.selectionClick();
    setState(() => _offset--);
    _playback.stop();
    _checkBookmark();
  }

  void _shuffleHadith() {
    _playback.stop();
    HapticFeedback.mediumImpact();
    setState(() => _offset += 1 + (DateTime.now().microsecond % 5));
    _playback.stop();
    _checkBookmark();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changed to another authentic Hadith!'),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }

  Future<void> _checkBookmark() async {
    final item = DailyContentService.getHadith(offset: _offset);
    final saved = await DailyBookmarks.isSaved(item, 'hadith');
    if (mounted &&
        DailyContentService.getHadith(offset: _offset).id == item.id) {
      setState(() => _saved = saved);
    }
  }

  Future<void> _toggleSave() async {
    final item = DailyContentService.getHadith(offset: _offset);
    final saved = await DailyBookmarks.toggle(item, 'hadith');
    if (!mounted ||
        DailyContentService.getHadith(offset: _offset).id != item.id) {
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
    final hadith = DailyContentService.getHadith(offset: _offset);

    return Scaffold(
      backgroundColor: NoorTheme.background(context, light: NoorColors.cream),
      body: SafeArea(
          child: ListView(padding: EdgeInsets.zero, children: [
        Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
              child: Row(children: [
                IconButton(
                  tooltip: 'Back',
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: NoorTheme.foreground(context,
                            light: NoorColors.emeraldDark),
                        size: 19),
                    onPressed: () => Navigator.of(context).maybePop()),
                Expanded(
                    child: Semantics(header: true, child: Text('Hadith of the Day',
                        textAlign: TextAlign.center,
                        style: NoorType.screenTitle.copyWith(
                            color: NoorTheme.foreground(context,
                                light: NoorColors.emeraldDark))))),
                IconButton(
                  tooltip: _saved ? 'Remove bookmark' : 'Save hadith',
                    icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border,
                        color: NoorTheme.foreground(context,
                            light: NoorColors.emeraldDark),
                        size: 20),
                    onPressed: _toggleSave),
                IconButton(
                    tooltip: 'More options',
                    icon: Icon(Icons.more_vert,
                        color: NoorTheme.foreground(context,
                            light: NoorColors.emeraldDark)),
                    onPressed: () => showNoorOverflowSheet(context,
                            title: 'Hadith of the Day',
                            actions: [
                              (
                                Icons.copy_outlined,
                                'Copy hadith text',
                                _copyHadith
                              ),
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
                                                    hadith,
                                                    ShareContentType.hadith))))
                              ),
                            ])),
              ])),
          Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
              child: Text(NoorAppState.dateLine, style: NoorType.meta))
        ]),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              DailyReflectionCard(
                item: hadith,
                kind: 'hadith',
                expanded: true,
                saved: _saved,
                playing: _playback.playing,
                loading: _playback.loading,
                onListen: () => _toggleAudio(hadith),
                onSave: _toggleSave,
                onCopy: _copyHadith,
                onPrevious: _prevHadith,
                onNext: _nextHadith,
                onChange: _shuffleHadith,
                onShare: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ShareCardStudioScreen(
                        initialItem: ShareContentItem.fromDaily(
                            hadith, ShareContentType.hadith)))),
              ),
              const SizedBox(height: 20),
              const Text('About this Hadith', style: NoorType.cardTitle),
              const SizedBox(height: 7),
              Text(hadith.about,
                  style:
                      NoorType.secondary.copyWith(color: null, height: 1.55)),
              const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: NoorTheme.surface(context,
                          light: NoorColors.surfaceWarm),
                      borderRadius: BorderRadius.circular(NoorRadius.card)),
                  child: Row(children: [
                    const Icon(Icons.psychology_outlined,
                        color: null, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('Reflection', style: NoorType.body),
                          const SizedBox(height: 4),
                          Text(hadith.reflection,
                              style: NoorType.meta
                                  .copyWith(color: null, height: 1.5)),
                        ])),
                  ])),
              const SizedBox(height: 12),
              NoorCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    const Text('Share a reminder', style: NoorType.cardTitle),
                    const SizedBox(height: 8),
                    const Text(
                        'Create a card with this narration and its reference.',
                        style: NoorType.secondary),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => ShareCardStudioScreen(
                                    initialItem: ShareContentItem.fromDaily(
                                        hadith, ShareContentType.hadith)))),
                        icon: const Icon(Icons.ios_share_rounded),
                        label: const Text('Create card')),
                  ])),
              const SizedBox(height: 20),
              Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('More Hadiths for You',
                        style: NoorType.cardTitle),
                    TextButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const HadithLibraryScreen())),
                        style: TextButton.styleFrom(
                            minimumSize: const Size(44, 44)),
                        child: Text('View All',
                            style: NoorType.secondary.copyWith(
                                color: NoorTheme.foreground(context,
                                    light: NoorColors.emerald)))),
                  ]),
              const SizedBox(height: 12),
              for (int i = 1; i <= 2; i++) ...[
                NoorCard(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            HadithOfTheDayScreen(initialOffset: _offset + i))),
                    child: Row(children: [
                      const Icon(Icons.auto_stories_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                                DailyContentService.getHadith(
                                        offset: _offset + i)
                                    .title,
                                style: NoorType.body),
                            const SizedBox(height: 5),
                            Text(
                                DailyContentService.getHadith(
                                        offset: _offset + i)
                                    .reference,
                                style: NoorType.meta),
                          ])),
                      const Icon(Icons.chevron_right),
                    ])),
                const SizedBox(height: 10),
              ],
            ])),
      ])),
    );
  }

  Future<void> _copyHadith() async {
    final hadith = DailyContentService.getHadith(offset: _offset);
    await Clipboard.setData(
        ClipboardData(text: '${hadith.source}: "${hadith.translation}"'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied - paste anywhere to share')));
    }
  }
}