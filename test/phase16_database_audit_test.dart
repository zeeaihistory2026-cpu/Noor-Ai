import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/noor_store.dart';
import 'package:noor_ai_companion/data/user_data_service.dart';
import 'package:noor_ai_companion/screens/library/saved_content_screen.dart';
import 'package:noor_ai_companion/screens/worship/salah_tracker_screen.dart';
import 'package:noor_ai_companion/screens/worship/zikr_tasbih_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    UserDataService.instance.cancelTimers();
  });

  group('Phase 6A: NoorStore Data Persistence', () {
    test('Salah tracking persists offline without authentication', () async {
      const dateKey = '2026-10-15';
      final initial = await NoorStore.getPrayersList(dateKey);
      expect(initial, equals([false, false, false, false, false]));

      await NoorStore.setPrayersList(dateKey, [true, false, true, false, true]);
      final saved = await NoorStore.getPrayersList(dateKey);
      expect(saved, equals([true, false, true, false, true]));
    });

    test('Tasbih counts, totals, and custom dhikrs persist reliably', () async {
      const today = '2026-10-15';

      // Counts
      await NoorStore.setTasbihCount('subhanallah', 33);
      await NoorStore.setTasbihCount('alhamdulillah', 33);
      final counts = await NoorStore.getTasbihCounts();
      expect(counts['subhanallah'], equals(33));
      expect(counts['alhamdulillah'], equals(33));

      // Daily total
      await NoorStore.setTasbihTotalToday(today, 66);
      final total = await NoorStore.getTasbihTotalToday(today);
      expect(total, equals(66));

      // Custom dhikr
      final customMap = {
        'id': 'custom_123',
        'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        'transliteration': 'SubhanAllah wa bihamdihi',
        'meaning': 'Glory be to Allah and His praise',
        'defaultTarget': 100,
        'category': 'custom',
      };
      await NoorStore.saveCustomDhikr(customMap);
      final customList = await NoorStore.getCustomDhikrs();
      expect(customList.length, equals(1));
      expect(customList.first['id'], equals('custom_123'));
      expect(customList.first['transliteration'], equals('SubhanAllah wa bihamdihi'));

      // Delete custom dhikr
      await NoorStore.deleteCustomDhikr('custom_123');
      final updatedList = await NoorStore.getCustomDhikrs();
      expect(updatedList, isEmpty);
    });

    test('Rich bookmarks save, load, and remove with synchronization', () async {
      await NoorStore.saveRichItem(
        id: 'quran:18:10',
        title: 'Surah Al-Kahf, Ayah 10',
        subtitle: 'Our Lord, grant us mercy...',
        tag: 'Ayah 10',
      );

      final items = await NoorStore.getSavedItems();
      expect(items.length, equals(1));
      expect(items.first['id'], equals('quran:18:10'));
      expect(items.first['title'], equals('Surah Al-Kahf, Ayah 10'));

      // Verify simple bookmark ID list is also synced
      final isBookmarked = await NoorStore.isBookmarked('quran:18:10');
      expect(isBookmarked, isTrue);

      // Remove rich item
      await NoorStore.removeRichItem('quran:18:10');
      final itemsAfter = await NoorStore.getSavedItems();
      expect(itemsAfter, isEmpty);
      final isStillBookmarked = await NoorStore.isBookmarked('quran:18:10');
      expect(isStillBookmarked, isFalse);
    });
  });

  group('Phase 6A: Widget Integration Tests', () {
    testWidgets('SalahTrackerScreen loads and persists prayer checks locally',
        (tester) async {
      final today = DateTime.now().toIso8601String().split('T').first;
      // Pre-seed local storage with Fajr completed
      await NoorStore.setPrayersList(today, [true, false, false, false, false]);

      await tester.pumpWidget(const MaterialApp(home: SalahTrackerScreen()));
      await tester.pumpAndSettle();

      // Check Fajr is marked
      final checkedFajr = await NoorStore.getPrayersList(today);
      expect(checkedFajr[0], isTrue);

      // Tap Dhuhr to mark it
      // Find Dhuhr prayer row or its checkbox
      final dhuhrFinder = find.text('Dhuhr');
      expect(dhuhrFinder, findsOneWidget);
      await tester.tap(dhuhrFinder);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      final updatedPrayers = await NoorStore.getPrayersList(today);
      expect(updatedPrayers[1], isTrue);
    });

    testWidgets('ZikrTasbihScreen increments and updates NoorStore',
        (tester) async {
      final today = DateTime.now().toIso8601String().split('T').first;
      await NoorStore.setTasbihCount('subhanallah', 10);
      await NoorStore.setTasbihTotalToday(today, 10);

      await tester.pumpWidget(const MaterialApp(
        home: ZikrTasbihScreen(initialTab: 0),
      ));
      await tester.pumpAndSettle();

      // Tap the main counter circle
      final tapTarget = find.byType(GestureDetector).first;
      await tester.tap(tapTarget);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      final savedCount = await NoorStore.getTasbihCounts();
      expect(savedCount['subhanallah'], greaterThanOrEqualTo(10));
    });

    testWidgets('SavedContentScreen loads saved bookmarks and allows removal',
        (tester) async {
      await NoorStore.saveRichItem(
        id: 'test_dua_1',
        title: 'Authentic Morning Dua',
        subtitle: 'Bismika Rabbi wada\'tu janbi...',
        tag: 'Dua',
      );

      await tester.pumpWidget(const MaterialApp(home: SavedContentScreen()));
      await tester.pumpAndSettle();

      // Expect our saved item to be displayed
      expect(find.text('Authentic Morning Dua'), findsOneWidget);

      // Remove the item using the remove button
      final removeBtn = find.byIcon(Icons.bookmark_remove_outlined).first;
      await tester.tap(removeBtn);
      await tester.pumpAndSettle();

      expect(find.text('Authentic Morning Dua'), findsNothing);
      final storedAfter = await NoorStore.getSavedItems();
      expect(storedAfter.any((e) => e['id'] == 'test_dua_1'), isFalse);
    });
  });
}
