import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/sample_data.dart';
import '../../data/share_content.dart';
import '../../data/share_export_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_share_card.dart';

/// Page 22 — Share & Export. Preview card at the chosen platform
/// format, 2-col quick-share grid (Instagram / TikTok / Facebook /
/// WhatsApp / Save Image / Copy text), Save + Share actions.
/// Phase 13 made PNG export real; Phase 14 exports at the chosen
/// platform pixel size (e.g. Instagram Post 1080×1350, Story/Reel
/// 1080×1920, Facebook 1200×628). Platform tiles open the system
/// share sheet — the device's sheet reaches those apps; NOOR does
/// not post to any platform directly.
class ShareExportScreen extends StatefulWidget {
  const ShareExportScreen({
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
  State<ShareExportScreen> createState() => _ShareExportScreenState();
}

class _ShareExportScreenState extends State<ShareExportScreen> {
  int? _picked;
  final GlobalKey _cardKey = GlobalKey();
  bool _busy = false;
  String? _note;

  ShareContentItem get _item => widget.item ?? ShareContent.ayahCards.first;
  ShareFormatOption get _format => widget.format ?? ShareFormats.instagramPost;

  String get _shareText {
    final s = widget.streak;
    if (s != null) return '${s.label}: ${s.days} days — shared with NOOR';
    return '${_item.text} (${_item.reference}) — shared with NOOR';
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    final ok = await ShareExportService.shareCard(
      _cardKey,
      format: _format,
      text: _shareText,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _note = ok
          ? 'Share sheet opened — pick Instagram, TikTok, Facebook or any app. The source reference stays on the card.'
          : 'Sharing is not available on this device right now.';
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final path = await ShareExportService.saveCard(_cardKey, format: _format);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _note = path != null
          ? 'Saved as a ${_format.sizeLabel} on this device.'
          : 'Saving to this device is not available here — use Share instead.';
    });
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    if (!mounted) return;
    setState(() => _note = 'Card text and reference copied.');
  }

  void _target(int i) {
    setState(() => _picked = i);
    final label = SampleData.shareTargets[i].$2;
    if (label == 'Save Image') {
      _save();
    } else if (label == 'Copy text') {
      _copy();
    } else {
      _share();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          NoorPlainHeader(title: 'Share & Export', moreActions: [
            (Icons.ios_share, 'Share', _share),
            (Icons.download_outlined, 'Save to device', _save),
            (Icons.copy_outlined, 'Copy text', _copy),
          ]),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                RepaintBoundary(
                    key: _cardKey,
                    child: NoorShareCard(
                      style: widget.initialStyle,
                      item: widget.streak == null ? _item : null,
                      streak: widget.streak,
                      aspect: _format.aspectRatio,
                    )),
                const SizedBox(height: 12),
                Text(
                    '${_format.label} · ${_format.detail} · ${_format.sizeLabel}',
                    textAlign: TextAlign.center,
                    style: NoorType.meta.copyWith(color: NoorColors.muted)),
                const SizedBox(height: 22),
                const Text('Ready to share', style: NoorType.cardTitle),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 62,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: SampleData.shareTargets.length,
                  itemBuilder: (_, i) => Semantics(
                      button: true,
                      selected: _picked == i,
                      label:
                          '${SampleData.shareTargets[i].$2}${i < 4 ? ', opens share sheet' : ''}',
                      child: Material(
                          color: _picked == i
                              ? NoorColors.emeraldSoft
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                              onTap: _busy ? null : () => _target(i),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: NoorColors.hairline)),
                                  child: Row(children: [
                                    CircleAvatar(
                                        radius: 17,
                                        backgroundColor: NoorColors.emeraldSoft,
                                        child: Text(
                                            SampleData.shareTargets[i].$1,
                                            style: NoorType.meta.copyWith(
                                                color:
                                                    NoorColors.emeraldDark))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Text(
                                            SampleData.shareTargets[i].$2,
                                            style: NoorType.secondary)),
                                  ]))))),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                      child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                              icon:
                                  const Icon(Icons.download_outlined, size: 18),
                              label: const Text('Save image'),
                              onPressed: _busy ? null : _save))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: SizedBox(
                          height: 50,
                          child: FilledButton.icon(
                              icon: const Icon(Icons.share_outlined, size: 18),
                              label: const Text('Share'),
                              onPressed: _busy ? null : _share,
                              style: FilledButton.styleFrom(
                                  backgroundColor: NoorColors.emeraldDark)))),
                ]),
                if (_note != null) ...[
                  const SizedBox(height: 14),
                  Text(_note!, style: NoorType.meta.copyWith(height: 1.5)),
                ],
              ])),
        ])),
      );
}
