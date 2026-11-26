import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';
import 'package:noor_ai_companion/widgets/signature_arch.dart';

void main() {
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT'] ??
        'E:/flutter_windows_3.47.0-stable/flutter';
    for (final item in [
      ('Manrope', 'assets/fonts/Manrope-Variable.ttf'),
      ('AmiriQuran', 'assets/fonts/AmiriQuran-Regular.ttf'),
      (
        'MaterialIcons',
        '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf'
      )
    ]) {
      final bytes = await File(item.$2).readAsBytes();
      await (FontLoader(item.$1)
            ..addFont(Future.value(ByteData.sublistView(bytes))))
          .load();
    }
  });
  for (int i = 1; i <= 3; i++) {
    testWidgets('Home concept $i', (tester) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: NoorTheme.light(),
          home: _HomeConcept(i)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('../previews/home_option_$i.png'));
    });
  }
}

class _HomeConcept extends StatelessWidget {
  const _HomeConcept(this.design);
  final int design;
  static const green = NoorColors.emeraldDark;
  static const muted = NoorColors.mutedDark;
  Widget t(String text, TextStyle style, [Color? color]) =>
      Text(text, style: style.copyWith(color: color));
  Widget surface(Widget child,
          {EdgeInsets padding = const EdgeInsets.all(16),
          Color color = Colors.white,
          double radius = 18}) =>
      Container(
          padding: padding,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: NoorColors.hairlineSoft)),
          child: child);
  Widget header({bool inverse = false}) => Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          t('Assalamu Alaikum', NoorType.secondary,
              inverse ? NoorColors.onEmeraldMuted : muted),
          const SizedBox(height: 4),
          t('Guest', NoorType.screenTitle, inverse ? Colors.white : green),
        ])),
        Icon(Icons.notifications_none_outlined,
            color: inverse ? Colors.white : green),
        const SizedBox(width: 16),
        CircleAvatar(
            radius: 21,
            backgroundColor: inverse
                ? Colors.white.withValues(alpha: .12)
                : NoorColors.emeraldSoft,
            child: t('G', NoorType.cardTitle, inverse ? Colors.white : green))
      ]);
  Widget location({bool inverse = false}) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: [
        Icon(Icons.location_on_outlined,
            size: 14, color: inverse ? NoorColors.onEmeraldMuted : muted),
        const SizedBox(width: 4),
        t('Karachi · 24 Jumada al-Awwal', NoorType.meta,
            inverse ? NoorColors.onEmeraldMuted : muted)
      ]));
  Widget prayer({bool outline = false}) => Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
          color: outline ? Colors.white : green,
          borderRadius: BorderRadius.circular(20),
          border: outline ? Border.all(color: NoorColors.hairlineSoft) : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: t('NEXT PRAYER', NoorType.eyebrow,
                  outline ? muted : NoorColors.onEmeraldMuted)),
          Icon(Icons.mosque_outlined,
              size: 20, color: outline ? green : NoorColors.gold)
        ]),
        const SizedBox(height: 9),
        Row(children: [
          t('Asr', NoorType.screenTitle, outline ? green : Colors.white),
          const Spacer(),
          t('4:14 PM', NoorType.screenTitle, outline ? green : NoorColors.gold)
        ]),
        const SizedBox(height: 8),
        t('2h 03m remaining', NoorType.meta,
            outline ? muted : NoorColors.onEmeraldMuted),
      ]));
  Widget tool(IconData icon, String name) => Expanded(
      child: surface(
          Column(children: [
            Icon(icon, color: green, size: 24),
            const SizedBox(height: 7),
            t(name, NoorType.meta, green)
          ]),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          radius: 16));
  Widget tools() => Row(children: [
        tool(Icons.menu_book_outlined, 'Quran'),
        const SizedBox(width: 9),
        tool(Icons.spa_outlined, 'Zikr'),
        const SizedBox(width: 9),
        tool(Icons.mosque_outlined, 'Salah')
      ]);
  Widget ayah({bool dark = false, bool compact = false}) => surface(
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(Icons.menu_book_outlined,
              size: 17, color: dark ? NoorColors.gold : green),
          const SizedBox(width: 8),
          Expanded(
              child: t('AYAT OF THE DAY', NoorType.eyebrow,
                  dark ? NoorColors.gold : green)),
          Icon(Icons.bookmark_border,
              size: 18, color: dark ? Colors.white : green)
        ]),
        const SizedBox(height: 14),
        Text('رَبِّ زِدْنِي عِلْمًا',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style:
                NoorType.arabic(size: 29, color: dark ? Colors.white : green)),
        const SizedBox(height: 7),
        Text('My Lord, increase me in knowledge.',
            textAlign: TextAlign.center,
            style: NoorType.secondary
                .copyWith(color: dark ? Colors.white : NoorColors.ink)),
        const SizedBox(height: 7),
        Center(
            child: t(
                'Quran 20:114', NoorType.meta, dark ? NoorColors.gold : muted)),
        const SizedBox(height: 13),
        Row(children: [
          Icon(Icons.play_circle_outline,
              size: 23, color: dark ? NoorColors.gold : green),
          const SizedBox(width: 6),
          t('Listen', NoorType.meta, dark ? Colors.white : green),
          const Spacer(),
          Icon(Icons.ios_share_rounded,
              size: 20, color: dark ? Colors.white : green),
          const SizedBox(width: 17),
          Icon(Icons.arrow_forward_rounded,
              size: 20, color: dark ? Colors.white : green)
        ]),
      ]),
      padding: const EdgeInsets.all(17),
      color: dark ? green : Colors.white,
      radius: 20);
  Widget dailyRow(IconData icon, String title, String copy, String reference) =>
      surface(
          Row(children: [
            Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                    color: NoorColors.emeraldSoft,
                    borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: green, size: 20)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  t(title, NoorType.meta, green),
                  const SizedBox(height: 4),
                  Text(copy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NoorType.secondary),
                  const SizedBox(height: 3),
                  t(reference, NoorType.eyebrow, muted)
                ])),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: muted, size: 19)
          ]),
          padding: const EdgeInsets.all(13));
  Widget nav() =>
      NavigationBar(selectedIndex: 0, height: 68, destinations: const [
        NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.menu_book_outlined), label: 'Quran'),
        NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined), label: 'AI'),
        NavigationDestination(
            icon: Icon(Icons.mosque_outlined), label: 'Worship'),
        NavigationDestination(
            icon: Icon(Icons.library_books_outlined), label: 'Library')
      ]);
  @override
  Widget build(BuildContext context) => Scaffold(
      bottomNavigationBar: nav(),
      body: SafeArea(
          child: design == 1
              ? daily()
              : design == 2
                  ? reading()
                  : courtyard()));
  Widget daily() =>
      ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 20), children: [
        header(),
        location(),
        const SizedBox(height: 17),
        prayer(),
        const SizedBox(height: 13),
        tools(),
        const SizedBox(height: 21),
        Row(children: [
          t('Daily inspiration', NoorType.cardTitle, green),
          const Spacer(),
          t('Explore →', NoorType.meta, muted)
        ]),
        const SizedBox(height: 12),
        ayah(),
        const SizedBox(height: 12),
        dailyRow(Icons.auto_stories_outlined, 'HADITH',
            'Actions are judged by intentions.', 'Sahih al-Bukhari 1'),
        const SizedBox(height: 10),
        dailyRow(Icons.spa_outlined, 'DAILY DUA',
            'Our Lord, accept this from us.', 'Quran 2:127'),
      ]);
  Widget reading() =>
      ListView(padding: const EdgeInsets.fromLTRB(22, 20, 22, 20), children: [
        Row(children: [
          t('MUSLIMGO', NoorType.brandCaption.copyWith(letterSpacing: 2.5),
              green),
          const Spacer(),
          const Icon(Icons.notifications_none_outlined, color: green)
        ]),
        const SizedBox(height: 17),
        t('Begin with Bismillah', NoorType.screenTitle, green),
        const SizedBox(height: 5),
        t('A quiet moment for your faith.', NoorType.secondary, muted),
        const SizedBox(height: 18),
        prayer(outline: true),
        const SizedBox(height: 18),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final item in [
            (Icons.menu_book_outlined, 'Quran'),
            (Icons.spa_outlined, 'Zikr'),
            (Icons.explore_outlined, 'Qibla'),
            (Icons.auto_stories_outlined, 'Hadith')
          ])
            SizedBox(
                width: 76,
                child: Column(children: [
                  Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: NoorColors.emeraldSoft,
                          borderRadius: BorderRadius.circular(15)),
                      child: Icon(item.$1, color: green, size: 22)),
                  const SizedBox(height: 7),
                  t(item.$2, NoorType.meta, green)
                ]))
        ]),
        const SizedBox(height: 26),
        Row(children: [
          t('Your daily reading', NoorType.cardTitle, green),
          const Spacer(),
          const Icon(Icons.shuffle_rounded, size: 19, color: muted)
        ]),
        const SizedBox(height: 14),
        Row(children: [
          for (final label in ['Ayat', 'Hadith', 'Dua']) ...[
            Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: label == 'Ayat' ? green : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NoorColors.hairlineSoft)),
                    child: Center(
                        child: t(label, NoorType.meta,
                            label == 'Ayat' ? Colors.white : green)))),
            if (label != 'Dua') const SizedBox(width: 8)
          ]
        ]),
        const SizedBox(height: 12),
        ayah(),
        const SizedBox(height: 16),
        surface(Row(children: [
          const Icon(Icons.bookmark_border, color: green),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                t('Your saved reflections', NoorType.secondary, green),
                const SizedBox(height: 4),
                t('Ayahs, hadiths and duas in one place', NoorType.meta, muted)
              ])),
          const Icon(Icons.arrow_forward, size: 18, color: green)
        ])),
      ]);
  Widget mini(String title, String arabic, String reference) => Expanded(
      child: surface(
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            t(title, NoorType.eyebrow, green),
            const SizedBox(height: 12),
            Text(arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: NoorType.arabic(size: 24, color: green)),
            const SizedBox(height: 8),
            Center(child: t(reference, NoorType.meta, muted)),
            const SizedBox(height: 13),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.play_circle_outline, size: 22, color: green),
                  Icon(Icons.arrow_forward_rounded, size: 19, color: green)
                ])
          ]),
          padding: const EdgeInsets.all(14),
          radius: 18));
  Widget courtyard() => ListView(padding: EdgeInsets.zero, children: [
        Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
                color: green,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28))),
            child: Stack(children: [
              const Positioned.fill(
                  child: CustomPaint(painter: SignatureArchPainter())),
              Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 23),
                  child: Column(children: [
                    header(inverse: true),
                    location(inverse: true),
                    const SizedBox(height: 23),
                    Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            t('NEXT · ASR', NoorType.eyebrow,
                                NoorColors.onEmeraldMuted),
                            const SizedBox(height: 5),
                            t('4:14 PM', NoorType.screenTitle, NoorColors.gold)
                          ])),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            t('2h 03m', NoorType.cardTitle, Colors.white),
                            const SizedBox(height: 5),
                            t('until prayer', NoorType.meta,
                                NoorColors.onEmeraldMuted)
                          ])
                    ])
                  ]))
            ])),
        Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    for (final item in [
                      (Icons.menu_book_outlined, 'Quran'),
                      (Icons.spa_outlined, 'Zikr'),
                      (Icons.explore_outlined, 'Qibla'),
                      (Icons.notifications_none_outlined, 'Alerts')
                    ])
                      Expanded(
                          child: Column(children: [
                        Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border:
                                    Border.all(color: NoorColors.hairlineSoft)),
                            child: Icon(item.$1, color: green, size: 22)),
                        const SizedBox(height: 7),
                        t(item.$2, NoorType.meta, green)
                      ]))
                  ]),
                  const SizedBox(height: 24),
                  Row(children: [
                    t('Carry a reminder', NoorType.cardTitle, green),
                    const Spacer(),
                    t('Today', NoorType.meta, muted)
                  ]),
                  const SizedBox(height: 13),
                  IntrinsicHeight(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        mini('AYAT OF THE DAY', 'رَبِّ زِدْنِي عِلْمًا',
                            'Quran 20:114'),
                        const SizedBox(width: 12),
                        mini('DUA OF THE DAY', 'رَبَّنَا تَقَبَّلْ مِنَّا',
                            'Quran 2:127')
                      ])),
                  const SizedBox(height: 14),
                  dailyRow(
                      Icons.auto_stories_outlined,
                      'HADITH OF THE DAY',
                      'Actions are judged by intentions.',
                      'Sahih al-Bukhari 1'),
                  const SizedBox(height: 18),
                  surface(Row(children: [
                    const Icon(Icons.mosque_outlined, color: green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          t('Salah tracker', NoorType.secondary, green),
                          const SizedBox(height: 4),
                          t('Mark your prayers for today', NoorType.meta, muted)
                        ])),
                    const Icon(Icons.arrow_forward, size: 18, color: green)
                  ])),
                ])),
      ]);
}
