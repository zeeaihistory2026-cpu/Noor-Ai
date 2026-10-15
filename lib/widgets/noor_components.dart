import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/noor_theme.dart';

/// Shared NOOR building blocks, drawn to the 42-page design:
/// cream page, 28px headings, white 20px-radius cards with soft
/// shadows, emerald pill primary buttons, outlined pill option rows.

/// Star/rosette number badge as drawn on Pages 02–03: an 8-point
/// star medallion with the number centred. [filled] = dark emerald
/// star with white numeral (Page 02 rows); otherwise a gold-outline
/// rosette with ink numeral (Page 03 ayah marker). Code-drawn with
/// CustomPaint — no artwork file needed (Phase 11).
class NoorRosetteBadge extends StatelessWidget {
  const NoorRosetteBadge(this.number,
      {super.key, this.filled = true, this.size = 36});
  final int number;
  final bool filled;
  final double size;
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _RosettePainter(filled),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text('$number',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.36,
                    color: filled ? Colors.white : NoorColors.ink)),
          ),
        ),
      );
}

class _RosettePainter extends CustomPainter {
  const _RosettePainter(this.filled);
  final bool filled;
  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2 - 1;
    final inner = outer * 0.74;
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 8;
      final p = centre + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    if (filled) {
      canvas.drawPath(path, Paint()..color = NoorColors.emeraldDark);
    } else {
      canvas.drawPath(path, Paint()..color = NoorColors.surfaceWarm);
      canvas.drawPath(
          path,
          Paint()
            ..color = NoorColors.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
    }
  }

  @override
  bool shouldRepaint(covariant _RosettePainter old) => old.filled != filled;
}

class NoorScaffold extends StatelessWidget {
  const NoorScaffold({super.key, required this.child, this.bottom});
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
          child: Column(children: [
            Expanded(child: child),
            if (bottom != null) bottom!,
          ]),
        ),
      );
}

/// Small label used over sections in the design. Phase 12: this is
/// the one eyebrow dialect (NoorType.eyebrow) — previously each
/// screen re-invented size/tracking/casing.
class NoorSectionLabel extends StatelessWidget {
  const NoorSectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: NoorType.eyebrow);
}

/// Emerald pill button as drawn on Pages 36–42 (label centred, 16px).
class NoorPrimaryButton extends StatelessWidget {
  const NoorPrimaryButton(
      {super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: NoorColors.emeraldDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(29)),
              // No textStyle here: overriding it drops the theme's
              // label font (Manrope). Size/weight go on the child.
            ),
            child: Text(label,
                style:
                    NoorType.cardTitle.copyWith(color: Colors.white)),
          ),
        ),
      );
}

/// White card with the design's soft shadow + 20px radius.
class NoorCard extends StatelessWidget {
  const NoorCard({super.key, required this.child, this.padding, this.onTap});
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NoorRadius.card),
          boxShadow: NoorShadows.card),
      padding: padding ?? NoorSpacing.card,
      child: child,
    );
    return onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(NoorRadius.card),
                child: card));
  }
}

/// Selectable option row (Pages 38–40): white pill with soft border,
/// emerald fill when selected. Leading slot takes an icon/initial.
class NoorOptionTile extends StatelessWidget {
  const NoorOptionTile({
    super.key,
    required this.label,
    this.sublabel,
    this.leading,
    this.trailing,
    required this.selected,
    required this.onTap,
    this.labelStyle,
  });
  final String label;
  final TextStyle? labelStyle;
  final String? sublabel;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? NoorColors.emeraldDark : Colors.white,
      borderRadius: BorderRadius.circular(NoorRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NoorRadius.card),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NoorRadius.card),
            border:
                selected ? null : Border.all(color: NoorColors.hairline),
          ),
          child: Row(children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phase 12: labels wrap to two lines at one
                    // locked size. The old FittedBox(scaleDown)
                    // silently shrank long labels and fought the
                    // OS text-size setting (SENIOR_REVIEW §3.5).
                    Text(label,
                        maxLines: 2,
                        style: (labelStyle ?? NoorType.cardTitle).copyWith(
                            color: selected ? Colors.white : NoorColors.ink)),
                    if (sublabel != null)
                      Text(sublabel!,
                          style: NoorType.meta.copyWith(
                              color: selected
                                  ? Colors.white
                                  : NoorColors.mutedDark)),
                  ]),
            ),
            if (trailing != null) trailing!,
          ]),
        ),
      ),
    );
  }
}

/// Radio dot used on the Madhhab page (white filled when selected on
/// emerald, emerald ring when not).
class NoorRadioDot extends StatelessWidget {
  const NoorRadioDot({super.key, required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.white : Colors.transparent,
          border: Border.all(
              color: selected ? Colors.white : NoorColors.emerald, width: 2),
        ),
        // Phase 12: a centred emerald dot inside the selected ring.
        // The Phase 11 plain filled disc read as decoration rather
        // than a radio state (SENIOR_REVIEW Page 40).
        child: selected
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: NoorColors.emerald),
                ),
              )
            : null,
      );
}

/// Initial badge in a pale emerald circle (Goal page letters Q/S/D…).
class NoorInitialBadge extends StatelessWidget {
  const NoorInitialBadge(this.letter, {super.key, required this.selected});
  final String letter;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.white24 : NoorColors.emeraldSoft,
        ),
        child: Text(letter,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : NoorColors.emeraldDark)),
      );
}

/// Label + white pill input as drawn on Pages 41/42.
class NoorFormField extends StatelessWidget {
  const NoorFormField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.controller,
    this.suffixIcon,
    this.errorText,
  });
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  NoorType.secondary),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              errorText: errorText,
              hintText: hint,
              hintStyle: NoorType.body.copyWith(color: NoorColors.muted),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NoorRadius.card),
                borderSide: const BorderSide(color: NoorColors.hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NoorRadius.card),
                borderSide: const BorderSide(color: NoorColors.emerald),
              ),
            ),
          ),
        ],
      );
}

/// Dark emerald header used by the Quran screens (Pages 11/02):
/// back/search row, centred title, pill tab strip under it.
class NoorDarkHeader extends StatelessWidget {
  const NoorDarkHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.child,
  });
  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [NoorColors.emeraldDark, NoorColors.emeraldMid],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(children: [
          Row(children: [
            leading ??
                IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 19),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
            Expanded(
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: NoorType.screenTitle.copyWith(color: Colors.white)),
            ),
            ...actions,
          ]),
          if (child != null) ...[const SizedBox(height: 12), child!],
        ]),
      );
}

/// Pill tab strip under a dark header (Surahs / Juz / Bookmarks / Notes).
class NoorPillTabs extends StatelessWidget {
  const NoorPillTabs(
      {super.key,
      required this.tabs,
      required this.selected,
      required this.onSelect});
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(NoorRadius.chip)),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final on = i == selected;
            return Expanded(
              // Phase 12: Material ink + semantics + a >=44dp target
              // (the old GestureDetector tabs were ~36dp, unlabelled,
              // and had no pressed feedback).
              child: Semantics(
                button: true,
                selected: on,
                label: tabs[i],
                child: Material(
                  color: on ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(NoorRadius.chip),
                  child: InkWell(
                    onTap: () => onSelect(i),
                    borderRadius: BorderRadius.circular(NoorRadius.chip),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.center,
                      child: Text(tabs[i],
                          textAlign: TextAlign.center,
                          style: NoorType.secondary.copyWith(color:
                                  on ? NoorColors.emeraldDark : Colors.white)),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
}

/// The one list-row anatomy (Phase 12). Settings, Profile and Saved
/// previously each invented their own row; this row — leading slot,
/// title, optional subtitle, optional right-side value, trailing
/// slot — is now the shared pattern, with a >=48dp touch row and
/// optional ink response.
class NoorListRow extends StatelessWidget {
  const NoorListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.value,
    this.trailing,
    this.onTap,
    this.semanticLabel,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: NoorType.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (subtitle != null)
                  Text(subtitle!,
                      style: NoorType.secondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
              ]),
        ),
        if (value != null) ...[
          Flexible(
            child: Text(value!,
                style: NoorType.meta,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 4),
        ],
        if (trailing != null) trailing!,
      ]),
    );
    final labelled = Semantics(
        button: onTap != null, label: semanticLabel ?? title, child: row);
    return onTap == null
        ? labelled
        : Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap, child: labelled));
  }
}

/// Label + percentage + progress bar + meta line (Phase 13
/// extraction from My Journey, the audit's NoorProgressRow). One
/// anatomy for every progress display in the app.
class NoorProgressRow extends StatelessWidget {
  const NoorProgressRow({
    super.key,
    required this.label,
    required this.percent,
    required this.detail,
  });
  final String label;
  final int percent;
  final String detail;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$label, $percent percent. $detail',
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: NoorType.cardTitle),
                    Text('$percent%',
                        style: NoorType.tabular(
                            NoorType.body.copyWith(
                                color: NoorColors.emeraldDark))),
                  ]),
              const SizedBox(height: 8),
              ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 11,
                      color: NoorColors.emeraldDark,
                      backgroundColor: NoorColors.hairlineSoft)),
              const SizedBox(height: 6),
              Text(detail, style: NoorType.meta),
            ]),
      );
}

/// The one user avatar (Phase 12). Home previously showed a mosque
/// photograph, Profile a monogram and Settings a mosque icon —
/// three identities for one user. The monogram is canonical now.
/// When no real name is available yet, a neutral person glyph shows
/// instead of placeholder initials.
class NoorAvatar extends StatelessWidget {
  const NoorAvatar({super.key, this.size = 40, this.name});
  final double size;
  final String? name;

  /// True when a real display name is available; otherwise the avatar shows
  /// a neutral person glyph instead of placeholder initials.
  bool get _hasName => (name ?? '').trim().isNotEmpty;

  String get _initials {
    final n = (name ?? '').trim();
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: _hasName ? 'Profile — $name' : 'Profile',
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: NoorColors.emeraldDark),
          child: _hasName
              ? Text(_initials,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: size * 0.36))
              : Icon(Icons.person,
                  color: Colors.white, size: size * 0.55),
        ),
      );
}

/// Phase 16 audit — overflow sheet behind header chrome icons
/// (⋮ / ⋯ / tune / calendar / bookmark / settings).
///
/// Audit contract: every tappable control does something REAL or is
/// visibly disabled. These sheets are the "does something real" side:
/// every [actions] entry runs a genuine app action (navigation,
/// clipboard, persisted toggle, sort, share target). [info] lines are
/// honest descriptive copy (what the feature does / its limits), never
/// a fabricated capability. Entries are `(icon, label, onTap)` records;
/// [actions] may be omitted for an info-only sheet.
Future<void> showNoorOverflowSheet(
  BuildContext context, {
  required String title,
  List<String>? info,
  List<(IconData, String, VoidCallback)>? actions,
}) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: NoorColors.cream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                          color: NoorColors.hairline,
                          borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 14),
              Text(title, style: NoorType.cardTitle),
              if (info != null) ...[
                const SizedBox(height: 10),
                for (final line in info)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(line,
                          style: NoorType.secondary
                              .copyWith(color: NoorColors.mutedDark, height: 1.5))),
              ],
              const SizedBox(height: 6),
              for (final a in actions ?? const <(IconData, String, VoidCallback)>[])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(a.$1, color: NoorColors.emeraldDark, size: 21),
                  title: Text(a.$2, style: NoorType.body),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    a.$3();
                  },
                ),
            ],
          ),
        ),
      ),
    );
