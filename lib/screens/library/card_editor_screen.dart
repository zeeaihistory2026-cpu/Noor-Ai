import 'package:flutter/material.dart';
import '../../data/share_content.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_share_card.dart';
import 'share_export_screen.dart';

/// Page 20 — Card Editor. Preview card (Phase 14: any curated
/// Ayah/Hadith/Dua card, or an auto-filled streak card), then
/// Background / Typography / Layout / Branding groups exactly as
/// drawn. Selections update the preview live; source text and
/// reference are locked and not editable.
class CardEditorScreen extends StatefulWidget {
  const CardEditorScreen({
    super.key,
    this.item,
    this.streak,
    this.initialStyle = 0,
    this.format,
  });

  final ShareContentItem? item;
  final ShareStreakCard? streak;
  final int initialStyle;
  final ShareFormatOption? format;

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends State<CardEditorScreen> {
  late ShareContentItem _item;
  late ShareStreakCard? _streak;
  int _bg = 1; // Green as drawn
  int _type = 0;
  int _layout = 0;
  bool _brand = true;
  static const _bgNames = ['Cream', 'Green', 'Dark'];

  @override
  void initState() {
    super.initState();
    _item = widget.item ?? ShareContent.ayahCards.first;
    _streak = widget.streak;
    _bg = widget.initialStyle == 1
        ? 0
        : widget.initialStyle == 2
            ? 2
            : 1;
  }

  Future<void> _pickContent() async {
    final picked = await showModalBottomSheet<ShareContentItem>(
      context: context,
      backgroundColor: NoorColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            const Text('Choose card content', style: NoorType.cardTitle),
            const SizedBox(height: 6),
            Text(
                'Brief, referenced sample cards. Streak cards are under Share Studio → Streaks.',
                style: NoorType.meta.copyWith(color: NoorColors.muted)),
            for (final group in const [
              ('Ayah cards', ShareContent.ayahCards),
              ('Hadith cards', ShareContent.hadithCards),
              ('Dua cards', ShareContent.duaCards),
            ]) ...[
              const SizedBox(height: 18),
              Text(group.$1, style: NoorType.secondary),
              const SizedBox(height: 8),
              for (final item in group.$2)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: NoorColors.emeraldSoft,
                    child: Text(item.typeLabel.substring(0, 1),
                        style: NoorType.meta
                            .copyWith(color: NoorColors.emeraldDark)),
                  ),
                  title: Text(item.title, style: NoorType.secondary),
                  subtitle: Text(item.reference,
                      style: NoorType.meta.copyWith(color: NoorColors.muted)),
                  trailing: _item.id == item.id && _streak == null
                      ? const Icon(Icons.check_circle,
                          color: NoorColors.emerald)
                      : const Icon(Icons.chevron_right,
                          color: NoorColors.muted, size: 18),
                  onTap: () => Navigator.of(ctx).pop(item),
                ),
            ],
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _item = picked;
        _streak = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          NoorPlainHeader(title: 'Card Editor', moreActions: [
            (
              Icons.restart_alt_outlined,
              'Reset edits',
              () => setState(() {
                _bg = 1;
                _type = 0;
                _layout = 0;
                _brand = true;
              })
            ),
            (
              Icons.ios_share,
              'Continue to Share & Export',
              () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ShareExportScreen(
                        item: _streak == null ? _item : null,
                        streak: _streak,
                        initialStyle:
                            _bg == 0 ? 1 : _bg == 2 ? 2 : 3,
                        format:
                            widget.format ?? ShareFormats.instagramPost,
                      )))
            ),
          ]),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                NoorShareCard(
                    style: _bg == 0
                        ? 1
                        : _bg == 2
                            ? 2
                            : 3,
                    item: _streak == null ? _item : null,
                    streak: _streak,
                    aspect: widget.format?.aspectRatio,
                    showWordmark: _brand,
                    minimal: _layout == 1,
                    emphasis: _type),
                const SizedBox(height: 18),
                Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                        onTap: _pickContent,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: NoorColors.hairline)),
                            child: Row(children: [
                              const Icon(Icons.library_books_outlined,
                                  color: NoorColors.emeraldDark, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                        _streak == null
                                            ? _item.title
                                            : _streak!.label,
                                        style: NoorType.secondary),
                                    Text(
                                        _streak == null
                                            ? _item.reference
                                            : '${_streak!.days}-day streak',
                                        style: NoorType.meta
                                            .copyWith(color: NoorColors.muted)),
                                  ])),
                              const Text('Change', style: NoorType.meta),
                              const Icon(Icons.chevron_right,
                                  color: NoorColors.muted, size: 18),
                            ])))),
                const SizedBox(height: 22),
                _group('Background', _bgNames, _bg,
                    (v) => setState(() => _bg = v)),
                _group('Typography', const ['Arabic', 'English', 'Urdu'], _type,
                    (v) => setState(() => _type = v)),
                _group('Layout', const ['Classic', 'Minimal', 'Centered'],
                    _layout, (v) => setState(() => _layout = v)),
                const Text('Branding', style: NoorType.cardTitle),
                const SizedBox(height: 10),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 8, 10, 8),
                    decoration: BoxDecoration(
                        color: NoorColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      const Expanded(
                          child: Text('NOOR watermark', style: NoorType.body)),
                      Text(_brand ? 'On' : 'Off',
                          style: NoorType.secondary
                              .copyWith(color: NoorColors.muted)),
                      Semantics(
                          label: 'Show NOOR branding',
                          toggled: _brand,
                          child: Switch(
                              value: _brand,
                              activeTrackColor: NoorColors.emeraldDark,
                              activeThumbColor: Colors.white,
                              onChanged: (v) => setState(() => _brand = v))),
                    ])),
                const SizedBox(height: 16),
                Row(children: [
                  const Icon(Icons.lock_outline,
                      size: 15, color: NoorColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(
                          'Locked source: Quran/Hadith text and reference cannot be altered. Reset restores the original template.',
                          style:
                              NoorType.meta.copyWith(color: NoorColors.muted)))
                ]),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                      child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                              onPressed: () => setState(() {
                                    _bg = 1;
                                    _type = 0;
                                    _layout = 0;
                                    _brand = true;
                                  }),
                              child: const Text('Reset')))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: SizedBox(
                          height: 52,
                          child: FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => ShareExportScreen(
                                            item:
                                                _streak == null ? _item : null,
                                            streak: _streak,
                                            initialStyle: _bg == 0
                                                ? 1
                                                : _bg == 2
                                                    ? 2
                                                    : 3,
                                            format: widget.format ??
                                                ShareFormats.instagramPost,
                                          ))),
                              style: FilledButton.styleFrom(
                                  backgroundColor: NoorColors.emeraldDark,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16))),
                              child: const Text('Done')))),
                ]),
              ])),
        ])),
      );

  Widget _group(
          String title, List<String> opts, int sel, ValueChanged<int> f) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: NoorType.cardTitle),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
                color: NoorColors.surfaceWarm,
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              for (var i = 0; i < opts.length; i++) ...[
                Semantics(
                    button: true,
                    selected: i == sel,
                    label: '$title ${opts[i]}',
                    child: InkWell(
                        onTap: () => f(i),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Text(opts[i],
                                style: NoorType.secondary.copyWith(
                                    fontWeight: i == sel
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: i == sel
                                        ? NoorColors.emeraldDark
                                        : NoorColors.ink))))),
                if (i < opts.length - 1) const SizedBox(width: 8),
              ],
            ])),
        const SizedBox(height: 18),
      ]);
}
