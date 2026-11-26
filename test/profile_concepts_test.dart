import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';

void main() {
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT'] ??
        'E:/flutter_windows_3.47.0-stable/flutter';
    await (FontLoader('MaterialIcons')
          ..addFont(File(
                  '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
              .readAsBytes()
              .then((bytes) => ByteData.sublistView(bytes))))
        .load();
    await (FontLoader('Manrope')
          ..addFont(rootBundle.load('assets/fonts/Manrope-Variable.ttf')))
        .load();
  });
  for (var design = 1; design <= 4; design++) {
    testWidgets('profile concept $design', (tester) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: NoorTheme.light(),
          home: _Concept(design)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('../previews/profile_option_$design.png'));
    });
  }
}

class _Concept extends StatelessWidget {
  const _Concept(this.design);
  final int design;
  static const green = NoorColors.emeraldDark;
  static const muted = NoorColors.mutedDark;
  Widget text(String value, TextStyle style, [Color? color]) =>
      Text(value, style: style.copyWith(color: color));
  Widget avatar(double size, {bool light = false}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: light
              ? Colors.white.withValues(alpha: .12)
              : NoorColors.emeraldSoft,
          border: Border.all(
              color: light ? NoorColors.gold : Colors.white, width: 3)),
      child: Icon(Icons.person_outline_rounded,
          size: size * .48, color: light ? Colors.white : green));
  Widget header() => Row(children: [
        text('My profile', NoorType.screenTitle),
        const Spacer(),
        const Icon(Icons.settings_outlined, color: green),
        const SizedBox(width: 4)
      ]);
  Widget stat(String label, String value, IconData icon,
          {bool inverse = false}) =>
      Expanded(
          child: Column(children: [
        Icon(icon, color: inverse ? NoorColors.gold : green, size: 22),
        const SizedBox(height: 8),
        text(value, NoorType.screenTitle, inverse ? Colors.white : null),
        const SizedBox(height: 3),
        text(label, NoorType.meta, inverse ? NoorColors.onEmeraldMuted : muted),
      ]));
  Widget stats({bool inverse = false}) => Row(children: [
        stat('Salah days', '0', Icons.mosque_outlined, inverse: inverse),
        stat('Quran days', '0', Icons.menu_book_outlined, inverse: inverse),
        stat('Dhikr days', '0', Icons.spa_outlined, inverse: inverse),
      ]);
  Widget row(IconData icon, String title, String subtitle,
          {bool last = false}) =>
      Column(children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: NoorColors.emeraldSoft,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 20, color: green)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    text(title, NoorType.body),
                    const SizedBox(height: 4),
                    text(subtitle, NoorType.meta, muted)
                  ])),
              const Icon(Icons.chevron_right, color: muted, size: 20),
            ])),
        if (!last) const Divider(height: 1),
      ]);
  Widget box(Widget child,
          {EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 18)}) =>
      Container(
          padding: padding,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: NoorColors.hairlineSoft)),
          child: child);
  Widget preferences() => box(Column(children: [
        row(Icons.bookmark_border, 'Saved content',
            'Your ayahs, hadiths & duas'),
        row(Icons.tune_outlined, 'Prayer preferences',
            'Hanafi · Karachi method'),
        row(Icons.language_outlined, 'Language', 'English', last: true),
      ]));
  Widget signIn({bool compact = false}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!compact) ...[
          text('Make this space yours', NoorType.cardTitle),
          const SizedBox(height: 6),
          text('Sign in to connect your account.', NoorType.secondary, muted),
          const SizedBox(height: 14)
        ],
        FilledButton(
            onPressed: () {}, child: const Text('Sign in / Create account')),
      ]);
  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: design == 4
              ? premium()
              : design == 1
                  ? serenity()
                  : design == 2
                      ? minimal()
                      : journey()));
  Widget premium() =>
      ListView(padding: const EdgeInsets.fromLTRB(22, 20, 22, 26), children: [
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                text('MUSLIMGO',
                    NoorType.brandCaption.copyWith(letterSpacing: 2.8), muted),
                const SizedBox(height: 5),
                text('Your space', NoorType.display, green),
              ])),
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: NoorColors.hairlineSoft)),
              child:
                  const Icon(Icons.settings_outlined, color: green, size: 22))
        ]),
        const SizedBox(height: 22),
        Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                  height: 248,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            NoorColors.emeraldDark,
                            NoorColors.emeraldMid
                          ]),
                      borderRadius: BorderRadius.circular(26)),
                  child: Stack(children: [
                    Positioned.fill(
                        child: CustomPaint(painter: _ArchPattern())),
                    Positioned.fill(
                        child: Column(children: [
                      const SizedBox(height: 25),
                      Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NoorColors.cream,
                              border:
                                  Border.all(color: NoorColors.gold, width: 2)),
                          child: Center(
                              child: text('G', NoorType.display, green))),
                      const SizedBox(height: 13),
                      text('Assalamu Alaikum, Guest', NoorType.cardTitle,
                          Colors.white),
                      const SizedBox(height: 7),
                      text('A little closer, every day.', NoorType.meta,
                          NoorColors.onEmeraldMuted),
                      const SizedBox(height: 14),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      NoorColors.gold.withValues(alpha: .45)),
                              color: Colors.white.withValues(alpha: .04)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.person_outline,
                                color: NoorColors.gold, size: 13),
                            const SizedBox(width: 5),
                            text(
                                'GUEST ACCOUNT',
                                NoorType.brandCaption
                                    .copyWith(letterSpacing: 1),
                                NoorColors.gold)
                          ])),
                    ])),
                  ])),
              Padding(
                  padding: const EdgeInsets.fromLTRB(14, 223, 14, 0),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 17, horizontal: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: NoorColors.hairlineSoft),
                          boxShadow: [
                            BoxShadow(
                                color: green.withValues(alpha: .06),
                                offset: const Offset(0, 8),
                                blurRadius: 22)
                          ]),
                      child: IntrinsicHeight(
                          child: Row(children: [
                        _premiumMetric('0', 'Salah streak'),
                        const VerticalDivider(
                            width: 1, indent: 6, endIndent: 6),
                        _premiumMetric('0', 'Quran streak'),
                        const VerticalDivider(
                            width: 1, indent: 6, endIndent: 6),
                        _premiumMetric('0', 'Dhikr streak'),
                      ])))),
            ]),
        const SizedBox(height: 27),
        Row(children: [
          text('Your essentials', NoorType.cardTitle, green),
          const Spacer(),
          text('View journey', NoorType.meta, muted),
          const SizedBox(width: 3),
          const Icon(Icons.arrow_forward, size: 14, color: muted)
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _premiumAction(Icons.bookmark_border, 'Saved', '0 items'),
          const SizedBox(width: 10),
          _premiumAction(Icons.flag_outlined, 'Goals', 'Set intention'),
          const SizedBox(width: 10),
          _premiumAction(Icons.notifications_none_outlined, 'Reminders',
              'Stay consistent'),
        ]),
        const SizedBox(height: 24),
        box(Column(children: [
          row(Icons.mosque_outlined, 'Prayer preferences',
              'Hanafi · Karachi method'),
          row(Icons.language_outlined, 'Language & appearance',
              'English · Bright mode',
              last: true)
        ])),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sign in / Create account'),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 18)
                ])),
        const SizedBox(height: 10),
        Center(
            child: text(
                'Your journey starts wherever you are.', NoorType.meta, muted)),
      ]);
  Widget _premiumMetric(String value, String label) => Expanded(
          child: Column(children: [
        text(value, NoorType.screenTitle, green),
        const SizedBox(height: 4),
        text(label, NoorType.meta.copyWith(fontSize: 11), muted)
      ]));
  Widget _premiumAction(IconData icon, String label, String detail) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NoorColors.hairlineSoft)),
          child: Column(children: [
            Icon(icon, color: green, size: 24),
            const SizedBox(height: 10),
            text(label, NoorType.secondary, green),
            const SizedBox(height: 3),
            text(detail, NoorType.meta.copyWith(fontSize: 10), muted)
          ])));
  Widget serenity() => ListView(padding: const EdgeInsets.all(22), children: [
        header(),
        const SizedBox(height: 24),
        Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [green, NoorColors.emeraldMid]),
                borderRadius: BorderRadius.circular(26)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                avatar(64, light: true),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      text('Assalamu Alaikum', NoorType.meta,
                          NoorColors.onEmeraldMuted),
                      const SizedBox(height: 4),
                      text('Guest', NoorType.screenTitle, Colors.white),
                      const SizedBox(height: 4),
                      text('Your daily faith companion', NoorType.meta,
                          NoorColors.onEmeraldMuted),
                    ]))
              ]),
              const SizedBox(height: 22),
              Divider(color: Colors.white.withValues(alpha: .2)),
              const SizedBox(height: 18),
              stats(inverse: true),
            ])),
        const SizedBox(height: 26),
        Row(children: [
          text('Your space', NoorType.cardTitle),
          const Spacer(),
          text('Guest account', NoorType.meta, muted)
        ]),
        const SizedBox(height: 12),
        preferences(),
        const SizedBox(height: 24),
        signIn(),
      ]);
  Widget minimal() => ListView(padding: const EdgeInsets.all(24), children: [
        header(),
        const SizedBox(height: 26),
        Center(child: avatar(88)),
        const SizedBox(height: 14),
        Center(child: text('Guest', NoorType.screenTitle)),
        const SizedBox(height: 6),
        Center(
            child: text(
                'A little progress, every day.', NoorType.secondary, muted)),
        const SizedBox(height: 26),
        box(stats(), padding: const EdgeInsets.symmetric(vertical: 20)),
        const SizedBox(height: 28),
        text('ACCOUNT & PREFERENCES', NoorType.eyebrow, muted),
        const SizedBox(height: 8),
        row(Icons.bookmark_border, 'Saved content', '0 saved items'),
        row(Icons.flag_outlined, 'Your goals', 'Set your daily intention'),
        row(Icons.mosque_outlined, 'Prayer preferences',
            'Hanafi · Karachi method'),
        row(Icons.language_outlined, 'Language', 'English', last: true),
        const SizedBox(height: 20),
        signIn(compact: true),
      ]);
  Widget journey() => ListView(padding: EdgeInsets.zero, children: [
        Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            decoration: const BoxDecoration(
                color: green,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                text('My journey', NoorType.screenTitle, Colors.white),
                const Spacer(),
                const Icon(Icons.settings_outlined, color: Colors.white)
              ]),
              const SizedBox(height: 26),
              Row(children: [
                avatar(64, light: true),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      text('Guest', NoorType.screenTitle, Colors.white),
                      const SizedBox(height: 4),
                      text('Every small step counts.', NoorType.secondary,
                          NoorColors.onEmeraldMuted),
                    ]))
              ]),
              const SizedBox(height: 24),
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(18)),
                  child: Row(children: [
                    const Icon(Icons.local_fire_department_outlined,
                        color: NoorColors.gold, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          text('Build your first streak', NoorType.body,
                              Colors.white),
                          const SizedBox(height: 4),
                          text('Start with one prayer today', NoorType.meta,
                              NoorColors.onEmeraldMuted)
                        ])),
                  ])),
            ])),
        Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: box(
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.mosque_outlined,
                                      color: green),
                                  const SizedBox(height: 14),
                                  text('0 / 5', NoorType.screenTitle),
                                  const SizedBox(height: 4),
                                  text('Prayers today', NoorType.meta, muted),
                                ]),
                            padding: const EdgeInsets.all(18))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: box(
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.bookmark_border,
                                      color: green),
                                  const SizedBox(height: 14),
                                  text('0', NoorType.screenTitle),
                                  const SizedBox(height: 4),
                                  text('Saved items', NoorType.meta, muted),
                                ]),
                            padding: const EdgeInsets.all(18)))
                  ]),
                  const SizedBox(height: 24),
                  text('Made for your routine', NoorType.cardTitle),
                  const SizedBox(height: 12),
                  box(Column(children: [
                    row(Icons.flag_outlined, 'Your goals',
                        'Choose your daily focus'),
                    row(Icons.tune_outlined, 'Preferences',
                        'Prayer times, language & theme',
                        last: true)
                  ])),
                  const SizedBox(height: 20),
                  signIn(compact: true),
                ])),
      ]);
}

class _ArchPattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NoorColors.gold.withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    for (final scale in [1.0, 1.14, 1.28]) {
      final cx = size.width / 2,
          top = -42 * scale,
          half = 94 * scale,
          bottom = 320 * scale;
      final path = Path()
        ..moveTo(cx - half, bottom)
        ..lineTo(cx - half, top + 130 * scale)
        ..cubicTo(cx - half, top + 65 * scale, cx - 24 * scale,
            top + 38 * scale, cx, top)
        ..cubicTo(cx + 24 * scale, top + 38 * scale, cx + half,
            top + 65 * scale, cx + half, top + 130 * scale)
        ..lineTo(cx + half, bottom);
      canvas.drawPath(path, paint);
    }
    final dot = Paint()..color = NoorColors.gold.withValues(alpha: .5);
    for (final x in [22.0, size.width - 22]) {
      canvas.drawCircle(Offset(x, 25), 2, dot);
      canvas.drawCircle(Offset(x, 31), .8, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
