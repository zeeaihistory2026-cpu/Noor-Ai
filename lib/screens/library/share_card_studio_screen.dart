import 'package:flutter/material.dart';
import '../../data/noor_controller.dart';
import '../../data/share_content.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_share_card.dart';
import 'card_editor_screen.dart';
import 'reel_creator_screen.dart';
import 'share_export_screen.dart';

/// Page 19 — Islamic Share Card Studio. Emerald header, preview
/// card, curated content picker (Ayah / Hadith / Dua / Streaks),
/// platform format chips (Instagram / TikTok / Facebook / Square),
/// template row, Edit / Animate / Export actions. Phase 14: the
/// picker is real — 12 Ayah cards, 12 Hadith cards, Dua cards and
/// state-filled streak cards — and the preview re-frames to the
/// chosen platform canvas before export.
class ShareCardStudioScreen extends StatefulWidget {
  const ShareCardStudioScreen({super.key});
  @override
  State<ShareCardStudioScreen> createState() => _ShareCardStudioScreenState();
}

class _ShareCardStudioScreenState extends State<ShareCardStudioScreen> {
  int _format = 0;
  int _template = 0;
  int _section = 0; // 0 Ayah, 1 Hadith, 2 Dua, 3 Streaks
  ShareContentItem _item = ShareContent.ayahCards.first;
  ShareStreakCard? _streak;

  static const _sections = ['Ayah', 'Hadith', 'Dua', 'Streaks'];

  List<ShareContentItem> get _sectionItems => switch (_section) {
        0 => ShareContent.ayahCards,
        1 => ShareContent.hadithCards,
        2 => ShareContent.duaCards,
        _ => const [],
      };

  void _pickSection(int i) {
    setState(() {
      _section = i;
      if (i == 3) {
        _streak ??= ShareContent.streakCards(NoorScope.read(context))[0];
      } else {
        _streak = null;
        _item = _sectionItems.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final streaks = ShareContent.streakCards(controller);
    final format = ShareFormats.all[_format];
    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
          child: Column(children: [
        NoorPlainHeader(title: 'Share Card Studio', moreActions: [
          (
            Icons.play_circle_outline,
            'Animate',
            () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ReelCreatorScreen(
                      item: _streak == null ? _item : null,
                      streak: _streak,
                      initialStyle: _template,
                    )))
          ),
          (
            Icons.ios_share,
            'Export',
            () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ShareExportScreen(
                      item: _streak == null ? _item : null,
                      streak: _streak,
                      initialStyle: _template,
                      format: format,
                    )))
          ),
        ]),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
              NoorShareCard(
                style: _template,
                item: _streak == null ? _item : null,
                streak: _streak,
                aspect: format.aspectRatio,
              ),
              const SizedBox(height: 22),
              const Text('Choose content', style: NoorType.cardTitle),
              const SizedBox(height: 12),
              Row(children: [
                for (var i = 0; i < _sections.length; i++) ...[
                  Expanded(
                      child: Semantics(
                          button: true,
                          selected: i == _section,
                          label: '${_sections[i]} cards',
                          child: Material(
                              color: i == _section
                                  ? NoorColors.emeraldDark
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                  onTap: () => _pickSection(i),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: i == _section
                                              ? null
                                              : Border.all(
                                                  color: NoorColors.hairline)),
                                      child: Text(_sections[i],
                                          textAlign: TextAlign.center,
                                          style: NoorType.meta.copyWith(
                                              color: i == _section
                                                  ? Colors.white
                                                  : NoorColors.ink))))))),
                  if (i < _sections.length - 1) const SizedBox(width: 8),
                ],
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      _section == 3 ? streaks.length : _sectionItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    if (_section == 3) {
                      final s = streaks[i];
                      final selected = _streak?.id == s.id;
                      return _pickerCard(
                        selected: selected,
                        onTap: () => setState(() => _streak = s),
                        child: NoorShareCard(
                            style: _template, streak: s, mini: true),
                        label: s.label,
                        ref: '${s.days} days',
                      );
                    }
                    final item = _sectionItems[i];
                    final selected = _streak == null && _item.id == item.id;
                    return _pickerCard(
                      selected: selected,
                      onTap: () => setState(() {
                        _item = item;
                        _streak = null;
                      }),
                      child: NoorShareCard(
                          style: _template, item: item, mini: true),
                      label: item.title,
                      ref: item.reference,
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              const Text('Choose format', style: NoorType.cardTitle),
              const SizedBox(height: 6),
              Text(
                  'Preview re-frames to the platform canvas; export renders ${format.sizeLabel}.',
                  style: NoorType.meta.copyWith(color: NoorColors.muted)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (var i = 0; i < ShareFormats.all.length; i++)
                  Semantics(
                      button: true,
                      selected: i == _format,
                      label:
                          'Format ${ShareFormats.all[i].label} ${ShareFormats.all[i].detail}',
                      child: Material(
                          color: i == _format
                              ? NoorColors.emeraldDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                              onTap: () => setState(() => _format = i),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: i == _format
                                          ? null
                                          : Border.all(
                                              color: NoorColors.hairline)),
                                  child: Text(
                                      '${ShareFormats.all[i].label} · ${ShareFormats.all[i].detail}',
                                      style: NoorType.meta.copyWith(
                                          color: i == _format
                                              ? Colors.white
                                              : NoorColors.ink)))))),
              ]),
              const SizedBox(height: 22),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Templates', style: NoorType.cardTitle),
                Text('View all',
                    style:
                        NoorType.secondary.copyWith(color: NoorColors.emerald)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                for (var i = 0; i < 4; i++) ...[
                  Expanded(
                      child: Semantics(
                          button: true,
                          selected: i == _template,
                          label: 'Template ${i + 1}',
                          child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                  onTap: () => setState(() => _template = i),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: i == _template
                                                  ? NoorColors.gold
                                                  : NoorColors.hairline,
                                              width: i == _template ? 2 : 1)),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: NoorShareCard(
                                              style: i,
                                              height: 92,
                                              item: _streak == null
                                                  ? _item
                                                  : null,
                                              streak: _streak,
                                              mini: true))))))),
                  if (i < 3) const SizedBox(width: 10),
                ],
              ]),
              const SizedBox(height: 14),
              Row(children: [
                const Icon(Icons.lock_outline,
                    size: 15, color: NoorColors.muted),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(
                        'Verified content lock: source text and reference cannot be edited.',
                        style: NoorType.meta.copyWith(color: NoorColors.muted)))
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: _btn(
                        context,
                        'Edit Card',
                        Icons.edit_outlined,
                        () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => CardEditorScreen(
                                  item: _streak?.asItem(),
                                  streak: _streak,
                                  initialStyle: _template,
                                  format: format,
                                ))))),
                const SizedBox(width: 10),
                Expanded(
                    child: _btn(
                        context,
                        'Animate',
                        Icons.play_circle_outline,
                        () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ReelCreatorScreen(
                                  item: _streak == null ? _item : null,
                                  streak: _streak,
                                  initialStyle: _template,
                                ))))),
                const SizedBox(width: 10),
                Expanded(
                    child: _btn(
                        context,
                        'Export',
                        Icons.ios_share,
                        () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ShareExportScreen(
                                  item: _streak == null ? _item : null,
                                  streak: _streak,
                                  initialStyle: _template,
                                  format: format,
                                ))))),
              ]),
            ])),
      ])),
    );
  }

  Widget _pickerCard({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
    required String label,
    required String ref,
  }) =>
      Semantics(
          button: true,
          selected: selected,
          label: '$label, $ref',
          child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                      width: 112,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: selected
                                  ? NoorColors.gold
                                  : NoorColors.hairline,
                              width: selected ? 2 : 1)),
                      child: Column(children: [
                        Expanded(
                            child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: child)),
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: NoorType.meta),
                                Text(ref,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: NoorType.meta
                                        .copyWith(color: NoorColors.muted)),
                              ]),
                        ),
                      ])))));

  Widget _btn(BuildContext c, String l, IconData i, VoidCallback f) => SizedBox(
      height: 50,
      child: FilledButton.icon(
          icon: Icon(i, size: 16, color: Colors.white),
          label: FittedBox(
              fit: BoxFit.scaleDown,
              child:
                  Text(l, maxLines: 1, softWrap: false, style: NoorType.meta.copyWith(color: Colors.white))),
          onPressed: f,
          style: FilledButton.styleFrom(
              backgroundColor: NoorColors.emeraldDark,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)))));
}
