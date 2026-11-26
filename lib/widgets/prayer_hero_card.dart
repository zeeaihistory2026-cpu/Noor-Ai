import 'package:flutter/material.dart';
import '../data/prayer_service.dart';
import '../theme/noor_theme.dart';

/// Decorative motion follows a touch without competing with list scrolling.
class PrayerHeroCard extends StatefulWidget {
  const PrayerHeroCard({super.key, required this.next, required this.onTap});

  final NextPrayer next;
  final VoidCallback onTap;

  @override
  State<PrayerHeroCard> createState() => _PrayerHeroCardState();
}

class _PrayerHeroCardState extends State<PrayerHeroCard> {
  Offset _offset = Offset.zero;

  void _follow(Offset position, Size size) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final offset = Offset(
      ((position.dx / size.width) * 2 - 1).clamp(-1, 1) * 6,
      ((position.dy / size.height) * 2 - 1).clamp(-1, 1) * 3,
    );
    if (_offset != offset) setState(() => _offset = offset);
  }

  void _reset() {
    if (_offset != Offset.zero) setState(() => _offset = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(builder: (context, constraints) {
      final artWidth = (constraints.maxWidth * .28).clamp(60.0, 104.0);
      return Material(
        color: NoorColors.emeraldDark,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Listener(
          onPointerDown: (event) => _follow(event.localPosition,
              context.findRenderObject()!.paintBounds.size),
          onPointerMove: (event) => _follow(event.localPosition,
              context.findRenderObject()!.paintBounds.size),
          onPointerUp: (_) => _reset(),
          onPointerCancel: (_) => _reset(),
          child: Stack(children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: -7,
              width: artWidth + 7,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [Colors.transparent, Colors.white],
                      stops: [0, .35],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: TweenAnimationBuilder<Offset>(
                      tween: Tween(end: reducedMotion ? Offset.zero : _offset),
                      duration: reducedMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      builder: (context, offset, child) =>
                          Transform.translate(offset: offset, child: child),
                      child: Image.asset(NoorAssets.nextPrayerMosque,
                          fit: BoxFit.cover, alignment: Alignment.centerRight),
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: widget.onTap,
              child: Padding(
                // Artwork has its own column, even with large accessibility text.
                padding: EdgeInsets.fromLTRB(17, 17, artWidth + 12, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.next.isTomorrow
                          ? 'TOMORROW’S PRAYER'
                          : 'NEXT PRAYER',
                      style: NoorType.eyebrow
                          .copyWith(color: NoorColors.onEmeraldMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(widget.next.displayName,
                            style: NoorType.cardTitle
                                .copyWith(color: Colors.white)),
                        Text(widget.next.timeLabel,
                            style: NoorType.screenTitle
                                .copyWith(color: NoorColors.gold)),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(widget.next.remainingLabel,
                        style: NoorType.meta
                            .copyWith(color: NoorColors.onEmeraldMuted)),
                  ],
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }
}
