import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_ai_companion/data/daily_content_actions.dart';
import 'package:noor_ai_companion/data/daily_content_service.dart';
import 'package:noor_ai_companion/data/location_service.dart';
import 'package:noor_ai_companion/data/male_narration.dart';
import 'package:noor_ai_companion/data/noor_controller.dart';
import 'package:noor_ai_companion/data/noor_store.dart';
import 'package:noor_ai_companion/data/prayer_service.dart';
import 'package:noor_ai_companion/screens/home/home_dashboard_screen.dart';
import 'package:noor_ai_companion/screens/home/profile_screen.dart';
import 'package:noor_ai_companion/screens/home/ayat_of_the_day_screen.dart';
import 'package:noor_ai_companion/screens/home/hadith_of_the_day_screen.dart';
import 'package:noor_ai_companion/screens/home/dua_of_the_day_screen.dart';
import 'package:noor_ai_companion/screens/worship/salah_tracker_screen.dart';
import 'package:noor_ai_companion/screens/worship/zikr_tasbih_screen.dart';
import 'package:noor_ai_companion/screens/quran/quran_home_screen.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';
import 'package:noor_ai_companion/screens/home/settings_screen.dart';
import 'package:noor_ai_companion/screens/onboarding/language_selection_screen.dart';
import 'package:noor_ai_companion/screens/quran/quran_reader_screen.dart';
import 'package:noor_ai_companion/screens/library/share_card_studio_screen.dart';
import 'package:noor_ai_companion/data/quran_service.dart';
import 'package:noor_ai_companion/data/offline_quran.dart';
import 'package:noor_ai_companion/widgets/prayer_hero_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  List<Map<String, String>> voices = [];
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await NoorStore.init();
    calls.clear();
    voices = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'),
            (call) async {
      calls.add(call);
      if (call.method == 'getVoices') return voices;
      if (call.method == 'isLanguageAvailable') return true;
      return 1;
    });
  });
  Widget host(Widget child, {bool dark = false, double scale = 1}) {
    final controller = NoorController(autoInit: false);
    addTearDown(controller.dispose);
    return NoorScope(
        controller: controller,
        child: MaterialApp(
            theme: dark ? NoorTheme.dark() : NoorTheme.light(),
            home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Scaffold(body: child))));
  }

  test('new installations use bright mode even at night', () async {
    final controller = NoorController(autoInit: false);
    addTearDown(controller.dispose);
    await controller.loadThemePreference();
    expect(await NoorStore.getThemePreference(), 'light');
    expect(controller.themeMode, ThemeMode.light);
    expect(controller.activeDay.source, PrayerSource.calculated);
  });
  testWidgets('hero touch moves only artwork and releases to list scrolling',
      (tester) async {
    await tester.pumpWidget(host(const HomeDashboardScreen()));
    await tester.pumpAndSettle();
    final hero = find.byType(PrayerHeroCard);
    final artwork = find.descendant(of: hero, matching: find.byType(Transform));
    final beforeScroll = tester.getTopLeft(hero).dy;
    final start = tester.getBottomRight(hero) - const Offset(12, 12);
    final touch = await tester.startGesture(start);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.widget<Transform>(artwork).transform.storage[12],
        greaterThan(0));
    await touch.moveBy(const Offset(0, -40));
    await tester.pump();
    await touch.moveBy(const Offset(0, -80));
    await touch.up();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(hero).dy, lessThan(beforeScroll - 10));
    expect(tester.takeException(), isNull);
  });
  testWidgets('reduced motion keeps hero artwork still and text separate',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: NoorTheme.light(),
        home: MediaQuery(
            data: const MediaQueryData(
                disableAnimations: true, textScaler: TextScaler.linear(2)),
            child: Scaffold(
                body: SizedBox(
                    width: 280,
                    child: PrayerHeroCard(
                        next: NextPrayer(
                            name: 'Maghrib',
                            time: DateTime(2026, 11, 5, 17, 49),
                            remaining: const Duration(hours: 9),
                            isTomorrow: true),
                        onTap: () {}))))));
    await tester.pumpAndSettle();
    final hero = find.byType(PrayerHeroCard);
    final artwork = find.descendant(of: hero, matching: find.byType(Transform));
    final touch = await tester
        .startGesture(tester.getBottomRight(hero) - const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.widget<Transform>(artwork).transform.storage[12], 0);
    final image = find.descendant(of: hero, matching: find.byType(Image));
    expect(tester.getBottomRight(find.text('Maghrib')).dx,
        lessThan(tester.getTopLeft(image).dx));
    await touch.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  test('after Isha uses next date Fajr rather than copying today', () {
    final today = PrayerService.calculateOffline(
        location: LocationModel.defaultLocation, date: DateTime(2026, 11, 4));
    final tomorrow = PrayerService.calculateOffline(
        location: LocationModel.defaultLocation, date: DateTime(2026, 11, 5));
    final instant = DateTime.utc(2026, 11, 4, 17); // 22:00 Karachi
    final next = today.nextPrayer(now: instant, nextDay: tomorrow);
    expect(next.isTomorrow, isTrue);
    expect(next.time, tomorrow.timings['Fajr']);
    expect(next.remaining, tomorrow.timings['Fajr']!.difference(instant));
  });
  test('prayer calculation follows city, timezone and Asr convention', () {
    final lahore =
        LocationService.popularCities.firstWhere((c) => c.city == 'Lahore');
    final karachi = PrayerService.calculateOffline(
        location: LocationModel.defaultLocation, date: DateTime(2026, 11, 4));
    final hanafi = PrayerService.calculateOffline(
        location: lahore, date: DateTime(2026, 11, 4), school: 1);
    final standard = PrayerService.calculateOffline(
        location: lahore, date: DateTime(2026, 11, 4), school: 0);
    expect(hanafi.timings['Asr']!.isAfter(standard.timings['Asr']!), isTrue);
    expect(hanafi.timings['Fajr'], isNot(karachi.timings['Fajr']));
    expect(hanafi.timings['Fajr']!.timeZoneOffset, const Duration(hours: 5));
  });
  test('device location preserves coordinates, timezone and accuracy',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('com.noorai.com/location'),
            (_) async => {
                  'city': 'Lahore',
                  'country': 'Pakistan',
                  'latitude': 31.52,
                  'longitude': 74.35,
                  'timeZone': 'Asia/Karachi',
                  'locationSource': 'device',
                  'accuracyMeters': 25.0,
                  'isLive': true
                });
    final value = await LocationService().fetchDeviceLocation();
    final saved = await LocationService().getSavedLocation();
    expect(value.latitude, 31.52);
    expect(saved.locationSource, 'device');
    expect(saved.accuracyMeters, 25);
    expect(saved.timeZone, 'Asia/Karachi');
  });
  test('female voices and opaque IDs are never auto-classified as male', () {
    expect(MaleNarration.explicitlyMale({'name': 'Female Arabic'}), isFalse);
    expect(
        MaleNarration.explicitlyMale({'name': 'ar-xa-x-ard-local'}), isFalse);
    expect(MaleNarration.explicitlyMale({'name': 'Male', 'gender': 'female'}),
        isFalse);
    expect(MaleNarration.explicitlyMale({'name': 'Arabic Male'}), isTrue);
    expect(MaleNarration.explicitlyMale({'name': 'Arabic', 'gender': 'male'}),
        isTrue);
  });
  testWidgets(
      'marked male voice is selected and applied before Hadith narration',
      (tester) async {
    voices = [
      {'name': 'Arabic female', 'locale': 'ar-SA', 'gender': 'female'},
      {'name': 'Arabic male', 'locale': 'ar-SA', 'gender': 'male'}
    ];
    final playback = DailyContentPlayback();
    addTearDown(playback.dispose);
    late BuildContext context;
    await tester.pumpWidget(host(Builder(builder: (c) {
      context = c;
      return const SizedBox();
    })));
    final item = DailyContentService.getHadith();
    await playback.toggle(item, context: context);
    expect(calls.firstWhere((c) => c.method == 'setVoice').arguments,
        {'name': 'Arabic male', 'locale': 'ar-SA'});
    expect(calls.last.method, 'speak');
    expect(calls.last.arguments, item.arabic);
    expect(await NoorStore.getMaleNarrator('ar'),
        {'name': 'Arabic male', 'locale': 'ar-SA'});
  });
  testWidgets('unmarked voices need preview and explicit male confirmation',
      (tester) async {
    voices = [
      {'name': 'ar-xa-opaque', 'locale': 'ar-SA'}
    ];
    late BuildContext context;
    await tester.pumpWidget(host(Builder(builder: (c) {
      context = c;
      return const SizedBox();
    })));
    final pending = MaleNarration.choose(context, FlutterTts(), 'ar');
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Use this male voice'))
            .onPressed,
        isNull);
    expect(await NoorStore.getMaleNarrator('ar'), isNull);
    await tester.tap(find.text('Arabic voice 1'));
    await tester.pumpAndSettle();
    expect(calls.any((c) => c.method == 'speak'), isTrue);
    await tester.tap(find.text('Use this male voice'));
    await tester.pumpAndSettle();
    expect((await pending)?['name'], 'ar-xa-opaque');
    expect((await NoorStore.getMaleNarrator('ar'))?['name'], 'ar-xa-opaque');
  });
  for (final route in [
    ('Salah', const SalahTrackerScreen()),
    ('Zikr', const ZikrTasbihScreen()),
    ('Quran', const QuranHomeScreen())
  ]) {
    testWidgets('Home ${route.$1} card opens its real feature', (tester) async {
      await tester.pumpWidget(host(const HomeDashboardScreen()));
      await tester.pumpAndSettle();
      final target = find.byKey(ValueKey('home-${route.$1.toLowerCase()}'));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(find.byType(route.$2.runtimeType), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final route in [
    ('ayah', const AyatOfTheDayScreen()),
    ('hadith', const HadithOfTheDayScreen()),
    ('dua', const DuaOfTheDayScreen())
  ]) {
    testWidgets('Home ${route.$1} card opens the full selected daily item',
        (tester) async {
      await tester.pumpWidget(host(const HomeDashboardScreen()));
      await tester.pumpAndSettle();
      final target = find.byKey(ValueKey('home-${route.$1}-card'));
      await tester.scrollUntilVisible(target, 400,
          scrollable: find.byType(Scrollable).first);
      final button = find.descendant(
          of: target, matching: find.byTooltip('Read full ${route.$1}'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(route.$2.runtimeType), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('recommended Dua opens the selected item', (tester) async {
    await tester.pumpWidget(host(const DuaOfTheDayScreen()));
    await tester.pumpAndSettle();
    final suggestion = find.byKey(const ValueKey('daily-dua-suggestion-1'));
    await tester.scrollUntilVisible(suggestion, 400,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(suggestion);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<DuaOfTheDayScreen>(find.byType(DuaOfTheDayScreen))
            .initialOffset,
        1);
  });
  for (final dark in [false, true]) {
    testWidgets(
        'Signature profile works at 200% text on a narrow ${dark ? 'dark' : 'bright'} screen',
        (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await NoorStore.setUserName('Muhammad Abdul Rahman Al Mahmood');
      await tester
          .pumpWidget(host(const ProfileScreen(), dark: dark, scale: 2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('Your essentials'), 220,
          scrollable: find.byType(Scrollable).first);
      final rich = tester.widget<RichText>(find.descendant(
          of: find.text('Your essentials'), matching: find.byType(RichText)));
      expect(rich.text.style!.color!.computeLuminance(),
          dark ? greaterThan(.7) : lessThan(.2));
      expect(tester.takeException(), isNull);
    });
  }
  for (final entry in [
    ('Home', const HomeDashboardScreen()),
    ('Ayat', const AyatOfTheDayScreen()),
    ('Hadith', const HadithOfTheDayScreen()),
    ('Dua', const DuaOfTheDayScreen()),
    ('Zikr', const ZikrTasbihScreen()),
    ('Salah', const SalahTrackerScreen()),
    ('Settings', const SettingsScreen()),
    ('Language', const LanguageSelectionScreen(editing: true)),
  ]) {
    testWidgets(
        '${entry.$1} remains readable while scrolling at 200% text on 320px',
        (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(entry.$2, dark: true, scale: 2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (int i = 0; i < 50; i++) {
        final scroll =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        if (scroll.position.pixels >= scroll.position.maxScrollExtent - .5) {
          break;
        }
        await tester.drag(find.byType(ListView).first, const Offset(0, -750));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
  testWidgets(
      'Profile retains its top gear and language opens only its own picker',
      (tester) async {
    await tester.pumpWidget(host(const ProfileScreen()));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Open Settings'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Reading language'), 220,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Reading language'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.text('Your space'), findsNothing);
    await tester.tap(find.text('اردو'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save language'));
    await tester.pumpAndSettle();
    expect(await NoorStore.getLanguage(), 'Urdu');
    expect(find.byType(ProfileScreen), findsOneWidget);
    await tester.scrollUntilVisible(find.byTooltip('Open Settings'), -250,
        scrollable: find.byType(Scrollable).first);
    expect(find.byTooltip('Open Settings'), findsOneWidget);
  });
  test('app text-size preference persists and updates reactive state',
      () async {
    final controller = NoorController(autoInit: false);
    addTearDown(controller.dispose);
    await controller.setTextScale(1.15);
    expect(controller.textScale, 1.15);
    expect(await NoorStore.getTextScale(), 1.15);
    final restored = NoorController(autoInit: false);
    addTearDown(restored.dispose);
    await restored.loadTextScale();
    expect(restored.textScale, 1.15);
  });
  testWidgets(
      'Quran quick tools have equal widths, aligned tops, and share the selected verse',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() => QuranService().fetchSurahEditions(1));
    await tester.pumpWidget(host(const QuranReaderScreen(surah: 1)));
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('reader-quick-tools'));
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    final rects = <Rect>[];
    final labelTops = <double>[];
    for (final name in ['Listen', 'Save', 'Share ayah', 'Copy', '16-line']) {
      final tile = find.descendant(
          of: card,
          matching: find.byWidgetPredicate((widget) =>
              widget is Semantics && widget.properties.label == name));
      expect(tile, findsOneWidget);
      rects.add(tester.getRect(tile));
      labelTops.add(tester
          .getTopLeft(find.descendant(of: card, matching: find.text(name)))
          .dy);
    }
    for (final rect in rects) {
      expect(rect.top, closeTo(rects.first.top, 1));
      expect(rect.width, closeTo(rects.first.width, 1));
    }
    for (final top in labelTops) {
      expect(top, closeTo(labelTops.first, 1));
    }
    await tester
        .tap(find.descendant(of: card, matching: find.text('Share ayah')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<ShareCardStudioScreen>(find.byType(ShareCardStudioScreen))
            .initialItem
            ?.reference,
        'Quran 1:1');
  });
  test(
      '16-line quick tool finds the selected verse rather than a different surah',
      () async {
    final page = await OfflineQuran.pageForVerse(114, 6);
    final data = await OfflineQuran.mushafPage(page);
    expect(
        (data['verses'] as List).any((entry) => entry['verse_key'] == '114:6'),
        isTrue);
  });
}
