import 'package:flutter/material.dart';
import '../data/daily_content_service.dart';
import '../theme/noor_theme.dart';
import 'noor_components.dart';

/// A reading-first card shared by Home and the full daily-content screens.
class DailyReflectionCard extends StatelessWidget {
  const DailyReflectionCard(
      {super.key,
      required this.item,
      required this.kind,
      required this.saved,
      required this.onListen,
      required this.onSave,
      required this.onShare,
      this.onOpen,
      this.onNext,
      this.onPrevious,
      this.onChange,
      this.onCopy,
      this.playing = false,
      this.loading = false,
      this.expanded = false});
  final DailyContentItem item;
  final String kind;
  final bool saved, playing, loading, expanded;
  final VoidCallback onListen, onSave, onShare;
  final VoidCallback? onOpen, onNext, onPrevious, onChange, onCopy;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final label = kind == 'ayah'
        ? 'Ayat of the Day'
        : kind == 'hadith'
            ? 'Hadith of the Day'
            : 'Dua of the Day';
    return NoorCard(
        radius: expanded ? 24 : 20,
        padding: EdgeInsets.zero,
        onTap: onOpen,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
              padding: EdgeInsets.fromLTRB(18, expanded ? 14 : 6, 8, 0),
              child: Row(children: [
                Icon(
                    kind == 'ayah'
                        ? Icons.menu_book_outlined
                        : kind == 'hadith'
                            ? Icons.auto_stories_outlined
                            : Icons.spa_outlined,
                    size: 20,
                    color: accent),
                const SizedBox(width: 9),
                Expanded(
                    child: Text(label,
                        style: NoorType.eyebrow.copyWith(color: accent))),
                IconButton(
                    tooltip: saved ? 'Remove saved $kind' : 'Save $kind',
                    onPressed: onSave,
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                        size: 21, color: accent)),
              ])),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(item.title,
                  style: expanded
                      ? NoorType.cardTitle
                      : NoorType.body.copyWith(fontWeight: FontWeight.w700))),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Text(item.reference, style: NoorType.meta)),
          Container(
              margin: EdgeInsets.fromLTRB(16, expanded ? 20 : 12, 16, 0),
              padding: EdgeInsets.symmetric(
                  horizontal: 14, vertical: expanded ? 20 : 10),
              decoration: BoxDecoration(
                  color: dark
                      ? NoorColors.darkSurface
                      : NoorColors.cream.withValues(alpha: .7),
                  borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Container(width: 32, height: 2, color: NoorColors.gold),
                SizedBox(height: expanded ? 15 : 7),
                Text(item.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    maxLines: expanded ? null : 2,
                    overflow: expanded ? null : TextOverflow.ellipsis,
                    style: NoorType.arabic(
                        size: expanded ? 28 : 23,
                        color: dark
                            ? NoorColors.darkTextPrimary
                            : NoorColors.emeraldDark)),
              ])),
          Padding(
              padding: EdgeInsets.fromLTRB(
                  18, expanded ? 18 : 10, 18, expanded ? 20 : 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (expanded &&
                        item.transliteration?.isNotEmpty == true) ...[
                      Text(item.transliteration!,
                          textAlign: TextAlign.center,
                          style: NoorType.secondary
                              .copyWith(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 14),
                    ],
                    Text(item.translation,
                        textAlign: TextAlign.center,
                        maxLines: expanded ? null : 2,
                        overflow: expanded ? null : TextOverflow.ellipsis,
                        style: expanded
                            ? NoorType.body.copyWith(height: 1.65)
                            : NoorType.secondary.copyWith(height: 1.5)),
                    if (expanded && item.urdu?.isNotEmpty == true) ...[
                      const SizedBox(height: 18),
                      Text(item.urdu!,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: NoorType.urdu()),
                    ],
                  ])),
          const Divider(height: 1),
          Padding(
              padding: EdgeInsets.fromLTRB(
                  10, expanded ? 8 : 2, 10, expanded ? 8 : 2),
              child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    OutlinedButton.icon(
                        onPressed: onListen,
                        icon: loading
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Icon(
                                playing
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                                size: 20),
                        label: Text(loading
                            ? 'Loading'
                            : playing
                                ? 'Stop'
                                : 'Listen')),
                    Wrap(children: [
                      if (onCopy != null)
                        IconButton(
                            tooltip: 'Copy $kind',
                            onPressed: onCopy,
                            icon: const Icon(Icons.copy_outlined, size: 19)),
                      if (onChange != null)
                        IconButton(
                            tooltip: 'Change $kind',
                            onPressed: onChange,
                            icon: const Icon(Icons.shuffle_rounded, size: 21)),
                      IconButton(
                          tooltip: 'Share $kind card',
                          onPressed: onShare,
                          icon: const Icon(Icons.ios_share_rounded, size: 21)),
                      if (onOpen != null)
                        IconButton(
                            tooltip: 'Read full $kind',
                            onPressed: onOpen,
                            icon: const Icon(Icons.arrow_forward_rounded,
                                size: 21)),
                    ]),
                  ])),
          if (onNext != null || onPrevious != null) ...[
            const Divider(height: 1),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Wrap(alignment: WrapAlignment.spaceBetween, children: [
                  TextButton.icon(
                      onPressed: onPrevious,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous')),
                  TextButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next')),
                ])),
          ],
        ]));
  }
}
