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
                height: 142,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  itemCount:
                      _section == 3 ? streaks.length : _sectionItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    if (_section == 3) {
                      final s = streaks[i];
                      final selected = _streak?.id == s.id;
                      return _pickerCard(
                        selected: selected,
                        onTap: () => setState(() => _streak = s),
                        child: NoorShareCard(
                            style: _template,
                            streak: s,
                            mini: true,
                            borderRadius: BorderRadius.zero,
                            hasShadow: false),
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
                          style: _template,
                          item: item,
                          mini: true,
                          borderRadius: BorderRadius.zero,
                          hasShadow: false),
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
                          child: InkWell(
                              onTap: () => setState(() => _template = i),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: i == _template
                                              ? NoorColors.emeraldDark
                                              : NoorColors.hairline,
                                          width: i == _template ? 2.5 : 1),
                                      boxShadow: i == _template
                                          ? [
                                              BoxShadow(
                                                  color: NoorColors.emeraldDark
                                                      .withValues(alpha: 0.22),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3))
                                            ]
                                          : NoorShadows.card),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: NoorShareCard(
                                          style: i,
                                          height: 96,
                                          item: _streak == null
                                              ? _item
                                              : null,
                                          streak: _streak,
                                          mini: true,
                                          borderRadius: BorderRadius.zero,
                                          hasShadow: false)))))),
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
                                ))),
                        primary: false)),
                const SizedBox(width: 8),
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
                                ))),
                        primary: false)),
                const SizedBox(width: 8),
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
                                ))),
                        primary: true)),
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
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: selected
                                  ? NoorColors.emeraldDark
                                  : NoorColors.hairline,
                              width: selected ? 2.5 : 1),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                      color: NoorColors.emeraldDark
                                          .withValues(alpha: 0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3))
                                ]
                              : NoorShadows.card),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: child),
                            Container(
                              width: double.infinity,
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: NoorType.meta.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(ref,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: NoorType.meta.copyWith(
                                            color: NoorColors.muted,
                                            fontSize: 11)),
                                  ]),
                            ),
                          ],
                        ),
                      )))));

  Widget _btn(BuildContext c, String l, IconData i, VoidCallback f,
          {bool primary = false}) =>
      SizedBox(
          height: 48,
          child: primary
              ? FilledButton.icon(
                  icon: Icon(i, size: 16, color: Colors.white),
                  label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l,
                          maxLines: 1,
                          softWrap: false,
                          style: NoorType.meta.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700))),
                  onPressed: f,
                  style: FilledButton.styleFrom(
                      backgroundColor: NoorColors.emeraldDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                )
              : OutlinedButton.icon(
                  icon: Icon(i, size: 16, color: NoorColors.emeraldDark),
                  label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l,
                          maxLines: 1,
                          softWrap: false,
                          style: NoorType.meta.copyWith(
                              color: NoorColors.emeraldDark,
                              fontWeight: FontWeight.w700))),
                  onPressed: f,
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: NoorColors.emeraldDark,
                      side: const BorderSide(color: NoorColors.hairline),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                ));
}
