import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../data/share_content.dart';
import '../theme/noor_theme.dart';
import 'noor_components.dart';

/// Emerald share-card preview used on Pages 19-22, exactly as drawn:
/// DAILY REMINDER (gold), brief Arabic excerpt, short translation,
/// Quran 20:114 (gold), NOOR wordmark. Brief attributed excerpt
/// only — the verified source text stays locked (see Card Editor).
/// [dark] swaps to the near-black template; [cream] to sand/cream.
class NoorShareCard extends StatelessWidget {
  const NoorShareCard(
      {super.key,
      this.style = 0,
      this.height = 330,
      this.aspect,
      this.mini = false,
      this.showWordmark = true,
      this.minimal = false,
      this.emphasis = 0,
      this.item,
      this.streak});
  final int style; // 0 emerald, 1 cream, 2 dark, 3 emerald-mid
  final double height;
  final double? aspect;
  final bool mini;
  final bool showWordmark;
  final bool minimal;
  final int emphasis; // 0 Arabic, 1 English, 2 Nastaliq typeface

  /// Phase 14: the curated card being shown (Ayah/Hadith/Dua).
  /// Null keeps the design's original Daily Reminder card.
  final ShareContentItem? item;

  /// Phase 14: a streak milestone card (takes precedence over
  /// [item]); numbers arrive auto-filled from app state.
  final ShareStreakCard? streak;
  @override
  Widget build(BuildContext context) {
    final bg = [
      NoorColors.emeraldDark,
      NoorColors.cream,
      NoorColors.inkDeep,
      NoorColors.emeraldMid
    ][style];
    final fg = style == 1 ? NoorColors.emeraldDark : Colors.white;
    final sub = style == 1 ? NoorColors.emeraldDark : NoorColors.gold;
    final card = Container(
      height: aspect == null ? height : null,
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(NoorRadius.heroCard),
          boxShadow: NoorShadows.hero),
      padding: EdgeInsets.symmetric(
          horizontal: mini ? 8 : 24, vertical: mini ? 4 : 22),
      child: Column(children: [
        if (!minimal && !mini)
          Text(
              streak != null
                  ? 'STREAK MILESTONE'
                  : (item?.typeLabel ?? 'DAILY REMINDER'),
              style: TextStyle(
                  color: sub,
                  fontSize: mini ? 7 : 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4)),
        const Spacer(),
        if (streak != null) ...[
          Icon(
              streak!.iconName == 'calendar'
                  ? Icons.calendar_month_outlined
                  : Icons.local_fire_department_outlined,
              color: sub,
              size: mini ? 14 : 38),
          SizedBox(height: mini ? 2 : 8),
          Text(streak!.headline,
              style: TextStyle(
                  color: fg,
                  fontSize: mini ? 16 : 64,
                  fontWeight: FontWeight.w800,
                  height: 1)),
          Text(streak!.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: fg,
                  fontSize: mini ? 8 : 16,
                  fontWeight: FontWeight.w700)),
          if (!mini) ...[
            const SizedBox(height: 8),
            Text('${streak!.days} days · ${streak!.caption}',
                textAlign: TextAlign.center,
                style: TextStyle(color: fg, fontSize: 13, height: 1.4)),
          ],
        ] else ...[
          if ((item?.arabicText ?? SampleData.duaArabic).isNotEmpty)
            Text(item?.arabicText ?? SampleData.duaArabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                maxLines: mini ? 1 : null,
                overflow: mini ? TextOverflow.ellipsis : null,
                style: (emphasis == 2
                    ? NoorType.urdu(size: mini ? 11 : 26, color: fg)
                    : NoorType.arabic(
                        size: mini ? 11 : (emphasis == 1 ? 22 : 30),
                        color: fg))),
          if (!mini) ...[
            const SizedBox(height: 14),
            Text(item?.text ?? SampleData.duaTranslation,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: fg,
                    fontSize: emphasis == 1 ? 18 : 15,
                    fontWeight:
                        emphasis == 1 ? FontWeight.w700 : FontWeight.w400)),
          ],
        ],
        const Spacer(),
        Text(
            streak != null
                ? '${streak!.days}-DAY STREAK'
                : (item?.reference ?? SampleData.duaSource),
            style: TextStyle(
                color: sub,
                fontSize: mini ? 8 : 13,
                fontWeight: FontWeight.w800)),
        SizedBox(height: mini ? 2 : 18),
        if (showWordmark && !mini)
          Text('NOOR',
              style: TextStyle(
                  color: fg,
                  fontSize: mini ? 8 : 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2)),
      ]),
    );
    return aspect == null
        ? card
        : AspectRatio(aspectRatio: aspect!, child: card);
  }
}

/// Plain emerald header used by Pages 19-22/32-35 (back, title, ⋮).
///
/// Phase 16 audit: the ⋮ used to be a dead `onPressed: null` on every
/// one of these screens. It now opens [moreActions] — real actions
/// supplied by the owning screen. Screens that pass none keep the
/// drawn icon but visibly dimmed (honestly disabled, not fake-live).
class NoorPlainHeader extends StatelessWidget {
  const NoorPlainHeader({super.key, required this.title, this.moreActions, this.moreInfo});
  final String title;

  /// (icon, label, onTap) entries for the ⋮ overflow sheet.
  final List<(IconData, String, VoidCallback)>? moreActions;

  /// Honest descriptive lines shown above the actions, if any.
  final List<String>? moreInfo;
  @override
  Widget build(BuildContext context) {
    final actions = moreActions;
    return Container(
      color: NoorColors.emeraldDark,
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
      child: Row(children: [
        IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 19),
            onPressed: () => Navigator.of(context).maybePop()),
        Expanded(
            child: Text(title,
                textAlign: TextAlign.center,
                style: NoorType.screenTitle.copyWith(color: Colors.white))),
        actions == null
            ? const Opacity(
                opacity: 0.38,
                child: IconButton(
                    tooltip: 'More options (unavailable)',
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: null))
            : IconButton(
                tooltip: 'More options',
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => showNoorOverflowSheet(context,
                    title: title, info: moreInfo, actions: actions)),
      ]),
    );
  }
}
