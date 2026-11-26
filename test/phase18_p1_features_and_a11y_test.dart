import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/noor_store.dart';
import 'package:noor_ai_companion/data/offline_quran.dart';
import 'package:noor_ai_companion/screens/library/dua_library_screen.dart';
import 'package:noor_ai_companion/screens/library/hajj_umrah_screen.dart';
import 'package:noor_ai_companion/screens/library/islamic_academy_screen.dart';
import 'package:noor_ai_companion/screens/library/library_home_screen.dart';
import 'package:noor_ai_companion/screens/quran/surah_list_screen.dart';
import 'package:noor_ai_companion/screens/worship/fasting_ramadan_screen.dart';
import 'package:noor_ai_companion/screens/worship/islamic_calendar_screen.dart';
import 'package:noor_ai_companion/screens/worship/salah_guide_screen.dart';
import 'package:noor_ai_companion/screens/worship/zakat_calculator_screen.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Offline Quran Search & Bismillah Handling', () {
    test('OfflineQuran.search supports direct surah:ayah lookup', () async {
      final matches = await OfflineQuran.search('2:255');
      expect(matches, isNotEmpty);
      expect(matches.first.surah, 2);
      expect(matches.first.ayah, 255);
      expect(matches.first.reference, 'Quran 2:255');
      expect(matches.first.translationText.toLowerCase(), contains('allah'));
    });

    test('OfflineQuran.search matches English keywords and normalized Arabic',
        () async {
      final enMatches = await OfflineQuran.search('mercy', limit: 5);
      expect(enMatches, isNotEmpty);
      expect(enMatches.length, lessThanOrEqualTo(5));

      final arMatches = await OfflineQuran.search('\u0627\u0644\u0631\u062d\u0645\u0646', limit: 5);
      expect(arMatches, isNotEmpty);
    });

    test('stripLeadingBismillah strips Surah 2/95/97 while keeping Surah 1:1',
        () {
      const f = '\ufeff\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064e\u0647\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650';
      expect(OfflineQuran.stripLeadingBismillah(1, 1, f),
          contains('\u0628\u0650\u0633\u0652\u0645\u0650'));

      const s2 = '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064e\u0647\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650 \u0627\u0644\u0645';
      expect(OfflineQuran.stripLeadingBismillah(2, 1, s2), '\u0627\u0644\u0645');

      const s95 = '\u0628\u0651\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064e\u0647\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650 \u0648\u064e\u0627\u0644\u062a\u0651\u0650\u064a\u0646\u0650';
      expect(OfflineQuran.stripLeadingBismillah(95, 1, s95),
          '\u0648\u064e\u0627\u0644\u062a\u0651\u0650\u064a\u0646\u0650');
    });
  });

  group('P1 Islamic & Worship Modules', () {
    testWidgets('ZakatCalculatorScreen computes 2.5% Zakat & persists history',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: const ZakatCalculatorScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Silver / g (USD)'), '1');
      await tester.enterText(
          find.widgetWithText(TextField, 'Cash & Bank Savings (USD)'), '10000');
      await tester.pumpAndSettle();

      expect(find.textContaining('250.00'), findsOneWidget);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.text('Save Calculation'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Calculation'));
      await tester.pumpAndSettle();

      final hist = await NoorStore.getZakatHistory();
      expect(hist, isNotEmpty);
    });

    testWidgets('IslamicCalendarScreen displays dates & adjusts Hijri offset',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: const IslamicCalendarScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Islamic Calendar'), findsOneWidget);
      expect(find.text('Pick Date'), findsOneWidget);
      await tester.tap(find.text('+1 day'));
      await tester.pumpAndSettle();

      expect(await NoorStore.getHijriOffsetDays(), 1);
    });

    testWidgets('FastingRamadanScreen renders Suhoor/Iftar and Qada fasts',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: const FastingRamadanScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('SUHOOR ENDS'), findsOneWidget);
      expect(find.text('IFTAR TIME'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Increase missed fasts'));
      await tester.tap(find.byTooltip('Increase missed fasts'));
      await tester.pumpAndSettle();

      expect(await NoorStore.getQadaFasts(), 1);
    });

    testWidgets('SalahGuideScreen switches guides and tracks Qada prayers',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: const SalahGuideScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Step-by-Step Salah Guide'), findsOneWidget);
      await tester.tap(find.text('Wudu'));
      await tester.pumpAndSettle();
      expect(find.text('Step-by-Step Wudu (Ablution)'), findsOneWidget);

      await tester.tap(find.text('Qada & Night'));
      await tester.pumpAndSettle();
      expect(find.text('Qada (Missed Prayer) Tracker'), findsOneWidget);
    });

    testWidgets('IslamicAcademyScreen navigates Pillars, 99 Names & Quiz',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: const IslamicAcademyScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Five Pillars of Islam'), findsOneWidget);
      await tester.tap(find.text('99 Names'));
      await tester.pumpAndSettle();
      expect(find.text('Ar-Rahman'), findsOneWidget);

      await tester.tap(find.text('Quiz'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Question 1'), findsOneWidget);
    });

    testWidgets('HajjUmrahScreen counters increment Tawaf circuits',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: const HajjUmrahScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Counters & Ihram'));
      await tester.pumpAndSettle();
      expect(find.text('Tawaf Counter'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      expect(find.text('1 / 7'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Tawaf Counter: 1 of 7 Circuit completed')),
        findsOneWidget,
      );
    });

    testWidgets(
        'DuaLibraryScreen shows honest 0-based daily progress without fake 8/15',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: const Scaffold(body: DuaLibraryScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('8 of 15'), findsNothing);
      expect(find.textContaining('Today: 0 of'), findsOneWidget);
    });

    testWidgets('SurahListScreen supports Grid toggle without fake 76% text',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: const SurahListScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('76%'), findsNothing);
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('Accessibility Guidelines (Light & Dark)', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('LibraryHomeScreen meets a11y guidelines ($mode)',
          (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(MaterialApp(
            theme: NoorTheme.light(),
            darkTheme: NoorTheme.dark(),
            themeMode: mode,
            home: const LibraryHomeScreen(),
          ));
          await tester.pumpAndSettle();

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        } finally {
          handle.dispose();
        }
      });

      testWidgets('ZakatCalculatorScreen meets a11y guidelines ($mode)',
          (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(MaterialApp(
            theme: NoorTheme.light(),
            darkTheme: NoorTheme.dark(),
            themeMode: mode,
            home: const ZakatCalculatorScreen(),
          ));
          await tester.pumpAndSettle();

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        } finally {
          handle.dispose();
        }
      });

      testWidgets('IslamicAcademyScreen meets a11y guidelines ($mode)',
          (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(MaterialApp(
            theme: NoorTheme.light(),
            darkTheme: NoorTheme.dark(),
            themeMode: mode,
            home: const IslamicAcademyScreen(),
          ));
          await tester.pumpAndSettle();

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        } finally {
          handle.dispose();
        }
      });
    }
  });
}
