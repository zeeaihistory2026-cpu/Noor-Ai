import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../data/share_content.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_share_card.dart';
import 'share_export_screen.dart';

/// Page 21 — Animated Card / Reel Creator ("Animate Card").
/// Preview card, Animation style list (Soft Fade selected as
/// drawn), Preview 8-sec Reel button. UI + in-code preview state
/// only: no video is rendered or exported, nothing claims otherwise.
class ReelCreatorScreen extends StatefulWidget {
  const ReelCreatorScreen(
      {super.key, this.item, this.streak, this.initialStyle = 0});

  /// Phase 14: the card chosen in Share Studio (Ayah/Hadith/Dua or
  /// a streak milestone). Defaults to the design's Daily Reminder.
  final ShareContentItem? item;
  final ShareStreakCard? streak;
  final int initialStyle;
  @override
  State<ReelCreatorScreen> createState() => _ReelCreatorScreenState();
}

class _ReelCreatorScreenState extends State<ReelCreatorScreen> {
  int _style = 0;
  bool _previewing = false;
  Timer? _previewTimer;

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  void _togglePreview() {
    _previewTimer?.cancel();
    setState(() => _previewing = !_previewing);
    if (_previewing) {
      // Honest 8-second in-code preview: it stops itself.
      _previewTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) setState(() => _previewing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          NoorPlainHeader(title: 'Animate Card', moreActions: [
            (
              Icons.ios_share,
              'Continue to Share & Export',
              () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ShareExportScreen(
                        item: widget.streak == null ? widget.item : null,
                        streak: widget.streak,
                        initialStyle: widget.initialStyle,
                        format: ShareFormats.storyReel,
                      )))
            ),
          ]),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                AnimatedSlide(
                    offset: _style == 1 && _previewing
                        ? const Offset(0, -0.03)
                        : Offset.zero,
                    duration: const Duration(milliseconds: 700),
                    child: AnimatedScale(
                        scale: _style == 2 && _previewing ? 1.03 : 1,
                        duration: const Duration(milliseconds: 700),
                        child: AnimatedOpacity(
                            opacity: _style == 0 && _previewing ? 0.55 : 1,
                            duration: const Duration(milliseconds: 700),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        NoorRadius.heroCard),
                                    boxShadow: _style == 3 && _previewing
                                        ? const [
                                            BoxShadow(
                                                color: NoorColors.gold,
                                                blurRadius: 28,
                                                spreadRadius: 2)
                                          ]
                                        : null),
                                child: NoorShareCard(
                                    style: widget.initialStyle,
                                    item: widget.streak == null
                                        ? widget.item
                                        : null,
                                    streak: widget.streak,
                                    aspect:
                                        ShareFormats.storyReel.aspectRatio))))),
                const SizedBox(height: 22),
                const Text('Animation style', style: NoorType.cardTitle),
                const SizedBox(height: 12),
                for (var i = 0; i < SampleData.reelStyles.length; i++) ...[
                  Material(
                      color:
                          i == _style ? NoorColors.emeraldDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                          onTap: () => setState(() => _style = i),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 17),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: i == _style
                                      ? null
                                      : Border.all(color: NoorColors.hairline)),
                              child: Text(SampleData.reelStyles[i],
                                  style: NoorType.body.copyWith(
                                      color: i == _style
                                          ? Colors.white
                                          : NoorColors.ink))))),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      icon: Icon(
                          _previewing
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          size: 20),
                      label: Text(_previewing
                          ? 'Previewing 8-sec Reel…'
                          : 'Preview 8-sec Reel'),
                      onPressed: _togglePreview,
                      style: FilledButton.styleFrom(
                          backgroundColor: NoorColors.emeraldDark,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                    )),
                const SizedBox(height: 14),
                SizedBox(
                    height: 52,
                    child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ShareExportScreen(
                                      item: widget.streak == null
                                          ? widget.item
                                          : null,
                                      streak: widget.streak,
                                      initialStyle: widget.initialStyle,
                                      format: ShareFormats.storyReel,
                                    ))),
                        child: const Text('Continue to Share & Export'))),
              ])),
        ])),
      );
}
