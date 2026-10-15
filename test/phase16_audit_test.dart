import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/screens/home/dua_of_the_day_screen.dart';
import 'package:noor_ai_companion/screens/home/profile_screen.dart';
import 'package:noor_ai_companion/screens/library/hadith_library_screen.dart';
import 'package:noor_ai_companion/screens/quran/hifz_mushaf_screen.dart';
import 'package:noor_ai_companion/screens/quran/surah_list_screen.dart';

/// Phase 16 Job 5 (senior audit) — button-by-button proof.
///
/// Every header chrome icon that used to be a dead `onPressed: null`
/// now opens a real overflow sheet / runs a real action. These widget
/// tests tap the controls and assert the real outcome. Pure widget
/// tests (no goldens); network is never touched.
void main() {
  group('Phase 16 audit — header controls do something real', () {
    testWidgets('dua of the day: calendar opens the daily-dua sheet',
        (tester) async {
      await tester.pumpWidget(
          const MaterialApp(home: DuaOfTheDayScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.calendar_month_outlined).first);
      await tester.pumpAndSettle();
      expect(find.text('Daily Dua'), findsOneWidget);
      expect(find.text('Dua reminder settings'), findsOneWidget);
    });

    testWidgets('dua of the day: overflow offers copy/save/share-studio',
        (tester) async {
      await tester.pumpWidget(
          const MaterialApp(home: DuaOfTheDayScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      expect(find.text('Copy dua text'), findsOneWidget);
      // 'Save' also labels the body's action circle; the sheet adds one.
      expect(find.text('Save'), findsWidgets);
      expect(find.text('Open in Share Studio'), findsOneWidget);
    });

    testWidgets('surah list: tune sorts 114 -> 1 for real', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SurahListScreen()));
      await tester.pumpAndSettle();
      Offset centerOf(String name) =>
          tester.getCenter(find.text(name, findRichText: true).first);
      // Ascending by default: Al-Fatihah's row sits above Yunus'.
      expect(centerOf('Al-Fatihah').dy,
          lessThan(centerOf('Yunus').dy));
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Sort Surahs'), findsOneWidget);
      await tester.tap(find.text('Surah order: 114 → 1'));
      await tester.pumpAndSettle();
      // Descending: Yunus (10) now renders above Al-Fatihah (1).
      expect(centerOf('Yunus').dy,
          lessThan(centerOf('Al-Fatihah').dy));
      // And back up again.
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Surah order: 1 → 114'));
      await tester.pumpAndSettle();
      expect(centerOf('Al-Fatihah').dy,
          lessThan(centerOf('Yunus').dy));
    });

    testWidgets('profile: Privacy/Subscription rows are not tappable',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
          find.text('Privacy'), 120,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      // No chevron on rows without a target.
      final rows = find.text('Privacy');
      expect(rows, findsOneWidget);
      await tester.tap(rows, warnIfMissed: false);
      await tester.pumpAndSettle();
      // Still on Profile — nothing pushed.
      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Subscription'), findsOneWidget);
    });

    testWidgets('hifz mushaf: settings opens real options sheet',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HifzMushafScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Mushaf options'), findsOneWidget);
      expect(find.text('Test me on this page'), findsOneWidget);
      expect(find.text('Hifz progress'), findsOneWidget);
    });

    testWidgets('hadith library: menu_book opens the databank sheet',
        (tester) async {
      await tester.pumpWidget(
          const MaterialApp(home: HadithLibraryScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.menu_book_outlined).first);
      await tester.pumpAndSettle();
      expect(find.text('Hadith databank'), findsOneWidget);
      expect(find.textContaining('hadith-api'), findsOneWidget);
    });
  });
}
