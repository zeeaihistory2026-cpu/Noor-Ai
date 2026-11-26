// Actual Flutter screen captures at 390×844 logical pixels using bundled
// Manrope, Arabic, Urdu and Material icon fonts. Run explicitly with
// flutter test test/previews_test.dart --update-goldens.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_ai_companion/data/noor_store.dart';

import 'package:noor_ai_companion/app.dart';
import 'package:noor_ai_companion/data/offline_quran.dart';
import 'package:noor_ai_companion/data/quran_service.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';
import 'package:noor_ai_companion/screens/onboarding/splash_screen.dart';
import 'package:noor_ai_companion/screens/onboarding/onboarding_screen.dart';
import 'package:noor_ai_companion/screens/home/my_journey_screen.dart';
import 'package:noor_ai_companion/screens/home/home_dashboard_screen.dart';
import 'package:noor_ai_companion/screens/home/profile_screen.dart';
import 'package:noor_ai_companion/screens/home/settings_screen.dart';
import 'package:noor_ai_companion/screens/quran/quran_home_screen.dart';
import 'package:noor_ai_companion/screens/quran/surah_list_screen.dart';
import 'package:noor_ai_companion/screens/quran/quran_reader_screen.dart';
import 'package:noor_ai_companion/screens/quran/quran_audio_player_screen.dart';
import 'package:noor_ai_companion/screens/quran/hifz_ai_test_screen.dart';
import 'package:noor_ai_companion/screens/ai/ai_assistant_home_screen.dart';
import 'package:noor_ai_companion/screens/ai/ai_chat_screen.dart';
import 'package:noor_ai_companion/screens/ai/voice_ai_screen.dart';
import 'package:noor_ai_companion/screens/worship/salah_tracker_screen.dart';
import 'package:noor_ai_companion/screens/worship/zikr_tasbih_screen.dart';
import 'package:noor_ai_companion/screens/worship/qibla_finder_screen.dart';
import 'package:noor_ai_companion/screens/worship/worship_dashboard_screen.dart';
import 'package:noor_ai_companion/screens/library/library_home_screen.dart';
import 'package:noor_ai_companion/screens/library/share_card_studio_screen.dart';
import 'package:noor_ai_companion/screens/quran/hifz_mushaf_screen.dart';
import 'package:noor_ai_companion/screens/quran/hifz_test_results_screen.dart';
import 'package:noor_ai_companion/screens/quran/hifz_revision_planner_screen.dart';
import 'package:noor_ai_companion/screens/quran/hifz_heatmap_screen.dart';
import 'package:noor_ai_companion/screens/home/dua_of_the_day_screen.dart';
import 'package:noor_ai_companion/screens/home/hadith_of_the_day_screen.dart';
import 'package:noor_ai_companion/screens/home/notifications_screen.dart';
import 'package:noor_ai_companion/data/hadith_service.dart';
import 'package:noor_ai_companion/screens/library/hadith_library_screen.dart';
import 'package:noor_ai_companion/screens/library/hadith_chapters_screen.dart';
import 'package:noor_ai_companion/screens/library/hadith_detail_screen.dart';
import 'package:noor_ai_companion/screens/library/dua_library_screen.dart';
import 'package:noor_ai_companion/screens/library/card_editor_screen.dart';
import 'package:noor_ai_companion/screens/library/reel_creator_screen.dart';
import 'package:noor_ai_companion/screens/library/share_export_screen.dart';
import 'package:noor_ai_companion/screens/library/saved_content_screen.dart';
import 'package:noor_ai_companion/screens/ai/ai_answer_sources_screen.dart';
import 'package:noor_ai_companion/screens/ai/madhhab_compare_screen.dart';
import 'package:noor_ai_companion/screens/worship/reminder_center_screen.dart';
import 'package:noor_ai_companion/screens/onboarding/goal_selection_screen.dart';
import 'package:noor_ai_companion/screens/onboarding/language_selection_screen.dart';
import 'package:noor_ai_companion/screens/onboarding/madhhab_preference_screen.dart';
import 'package:noor_ai_companion/screens/auth/create_account_screen.dart';
import 'package:noor_ai_companion/screens/auth/login_screen.dart';

Future<void> _loadCaptureFonts() async {
  final sdk = Platform.environment['FLUTTER_ROOT'] ??
      '${Platform.environment['HOME']}/workspace/flutter-sdk';
  final fontsDir = '$sdk/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, String file) async {
    final bytes = await File('$fontsDir/$file').readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  // NOTE: Roboto-Medium.ttf's internal family is "Roboto Medium", so
  // registering it as 'Roboto' breaks bold text (falls back to the
  // boxy test font). Regular + Bold share the internal 'Roboto'
  // family (400/700); w800 synthesises from Bold.
  await load('Roboto', 'Roboto-Regular.ttf');
  await load('Roboto', 'Roboto-Bold.ttf');
  await load('MaterialIcons', 'MaterialIcons-Regular.otf');

  // Phase 12: load the app's bundled Qur'an / Urdu fonts so Arabic
  // and Nastaliq render as real glyphs in captures (previously the
  // test font drew boxes and hid every Arabic defect).
  Future<void> loadApp(String family, String file) async {
    final bytes = await File('assets/fonts/$file').readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  await loadApp('IndopakNastaleeq', 'IndopakNastaleeq-Regular.ttf');
  await loadApp('Manrope', 'Manrope-Variable.ttf');
  await loadApp('AmiriQuran', 'AmiriQuran-Regular.ttf');
  await loadApp('NotoNastaliqUrdu', 'NotoNastaliqUrdu-Regular.ttf');
  await loadApp('NotoNastaliqUrdu', 'NotoNastaliqUrdu-Bold.ttf');
}

const _assetPaths = <String>[
  'assets/images/app_logo.png',
  NoorAssets.nextPrayerMosque,
  NoorAssets.aiHeaderMosque,
  NoorAssets.splashMotif,
  NoorAssets.lantern,
  NoorAssets.duaHands,
  NoorAssets.quranRehal,
  NoorAssets.surahCalligraphy,
  NoorAssets.playerArch,
  NoorAssets.reciterAvatar,
  NoorAssets.quranBannerVerse,
  NoorAssets.duaMedallion,
  NoorAssets.hadithDayMedallion,
  NoorAssets.hadithCoverBukhari,
  NoorAssets.hadithCoverMuslim,
  NoorAssets.hadithCoverTirmidhi,
  NoorAssets.hadithCoverDawud,
  NoorAssets.salahHeaderMosque,
  NoorAssets.salahLantern,
  NoorAssets.salahProstration,
  NoorAssets.qiblaKaaba,
  NoorAssets.qiblaMosque,
  NoorAssets.worshipHeaderSkyline,
  NoorAssets.hadithLibraryHeader,
  NoorAssets.hadithBooksLantern,
  NoorAssets.hadithBookCover,
  NoorAssets.settingsLanterns,
];

/// Phase 16 — deterministic golden captures for screens whose
/// display now renders live-computed data:
/// - reminders31: the Reminder Center shows the computed
///   notification plan, so a fast network would bake live,
///   date-shifting prayer times into the golden. Failing HTTP at
///   client creation forces the honest offline/error path (the
///   design's sample times + the "couldn't refresh" status line),
///   which renders identically on any machine, any day.
/// - reader03: the ayah card shows the runtime API response when it
///   wins the capture race; failing HTTP keeps the designed
///   offline fallback text, so only the intended new nav row
///   changes the golden.
/// - audio05: same race for the surah fetch (plus its 15s request
///   timeout timer, which otherwise fails the test as "pending" on
///   slow networks); the golden is the designed offline state.
/// - qibla10: the bearing fetch races the capture; the golden is
///   the designed demo state.
class _NoNetworkForGoldens extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw const SocketException('network disabled for golden capture');
}

/// Same determinism idea, for screens that build their HTTP client
/// in a State field initializer (the hadith screens): throwing at
/// construction would break the widget, so instead every request
/// completes immediately as HTTP 403 — exactly what the sandbox
/// proxy returns for unreachable hosts, so the screens take their
/// documented non-200 / offline paths (the "Offline" pill and
/// offline banner the goldens show). Fails synchronously-ish (an
/// already-completed future): no sockets, no timers, safe under
/// the test binding's FakeAsync.
class _FailingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(const Stream.empty(), 403);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await NoorStore.init();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.noorai.com/compass'),
            (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('com.ryanheise.just_audio.methods'),
            (call) async {
      if (call.method == 'init') {
        throw PlatformException(
            code: 'AUDIO_UNAVAILABLE',
            message: 'Audio hardware is unavailable in a render test');
      }
      return <String, dynamic>{};
    });
  });

  setUpAll(() async {
    await _loadCaptureFonts();
    await OfflineQuran.load('quran-uthmani');
    await OfflineQuran.load('en.sahih');
    await OfflineQuran.load('ur.jalandhry');
    await OfflineQuran.load('mushaf16');
  });

  const size = Size(390, 844);

  final screens = <String, Widget>{
    'splash36': const SplashScreen(),
    'onboarding37': const OnboardingScreen(),
    // Captured inside the real 5-tab shell so the bottom navigation
    // (Home/Quran/AI/Worship/Library) is part of the visual proof.
    'home01': const NoorTabShell(),
    'quran_home11': const QuranHomeScreen(),
    'surah_list02': const SurahListScreen(),
    'reader03': const QuranReaderScreen(),
    'audio05': const QuranAudioPlayerScreen(),
    'ai_home12': const AiAssistantHomeScreen(),
    'ai_chat23': const AiChatScreen(),
    'voice26': const VoiceAiScreen(),
    'salah06': const SalahTrackerScreen(),
    'tasbih07': const ZikrTasbihScreen(),
    'qibla10': const QiblaFinderScreen(),
    'worship14': const WorshipDashboardScreen(),
    'library15': const LibraryHomeScreen(),
    'hifz_test27': const HifzAiTestScreen(),
    'share19': const ShareCardStudioScreen(),
    'journey32': const MyJourneyScreen(),
    'profile34': const ProfileScreen(),
    'settings13': const SettingsScreen(),
    // Second pass (2026-10-07): the remaining 22 design pages, so all
    // 42 pages now have a real app capture for one-pass review.
    'mushaf04': const HifzMushafScreen(),
    'mushaf04_page3': const HifzMushafScreen(initialPage: 3),
    'mushaf04_last': const HifzMushafScreen(initialPage: 548),
    'dua_day08': const DuaOfTheDayScreen(),
    'hadith_day09': const HadithOfTheDayScreen(),
    'hadith_library15': const HadithLibraryScreen(),
    'hadith_chapters16': const HadithChaptersScreen(bookId: 'bukhari'),
    // Detail golden uses a tiny deterministic book so the capture does
    // not depend on the network (companion Arabic fetch fails silently
    // in the test binding; primary text below is a brief excerpt).
    'hadith_detail17': const HadithDetailScreen(
      book: HadithBook(
        id: 'bukhari',
        name: 'Sahih al-Bukhari',
        edition: 'eng-bukhari',
        language: HadithLanguage.eng,
        sections: [
          HadithSection(number: 1, title: 'Revelation', count: 1),
        ],
        hadiths: [
          HadithEntry(
            hadithnumber: 1,
            arabicnumber: 1,
            text: 'Actions are judged by intentions.',
            grades: [],
            sectionNumber: 1,
            hadithInSection: 1,
          ),
        ],
      ),
      sectionNumber: 1,
    ),
    'dua_library18': const DuaLibraryScreen(),
    'card_editor20': const CardEditorScreen(),
    'reel_creator21': const ReelCreatorScreen(),
    'share_export22': const ShareExportScreen(),
    'ai_sources24': const AiAnswerSourcesScreen(),
    'madhhab_compare25': const MadhhabCompareScreen(),
    'hifz_results28': const HifzTestResultsScreen(),
    'hifz_planner29': const HifzRevisionPlannerScreen(),
    'hifz_heatmap30': const HifzHeatmapScreen(),
    'reminders31': const ReminderCenterScreen(),
    'saved33': const SavedContentScreen(),
    'notifications35': const NotificationsScreen(),
    'goal38': const GoalSelectionScreen(),
    'language39': const LanguageSelectionScreen(),
    'madhhab40': const MadhhabPreferenceScreen(),
    'create_account41': const CreateAccountScreen(),
    'login42': const LoginScreen(),
  };

  screens.addAll({
    'home_dark': const HomeDashboardScreen(),
    'home_cards': const HomeDashboardScreen(),
    'home_cards_dark': const HomeDashboardScreen(),
    'audio_nas': const QuranAudioPlayerScreen(surah: 114),
    'quran_dark': const QuranHomeScreen(),
    'profile_dark': const ProfileScreen(),
    'settings_dark': const SettingsScreen(),
    'audio_dark': const QuranAudioPlayerScreen(surah: 1),
    'audio_fatiha': const QuranAudioPlayerScreen(surah: 1),
    'share_dark': const ShareCardStudioScreen(),
    'library_dark': const LibraryHomeScreen(),
    'worship_dark': const WorshipDashboardScreen(),
    'salah_dark': const SalahTrackerScreen(),
    'language_dark': const LanguageSelectionScreen(editing: true),
    'reader_tools': const QuranReaderScreen(surah: 1),
    'reader_dark': const QuranReaderScreen(surah: 1),
    'dua_dark': const DuaOfTheDayScreen(),
    'hadith_dark': const HadithOfTheDayScreen(),
  });
  for (final entry in screens.entries) {
    testWidgets('preview ${entry.key}', (tester) async {
      Future<void> runCapture() async {
        if (entry.key == 'reminders31' ||
            entry.key == 'reader03' ||
            entry.key == 'audio05' ||
            entry.key == 'qibla10') {
          // Deterministic capture (see _NoNetworkForGoldens).
          HttpOverrides.global = _NoNetworkForGoldens();
          addTearDown(() => HttpOverrides.global = null);
        }
        await _capturePreview(tester, entry, size);
      }

      if (entry.key.endsWith('_dark') ||
          (entry.key == 'audio_fatiha' ||
              entry.key == 'audio_nas' ||
              entry.key == 'home_cards' ||
              entry.key == 'reader_tools') ||
          entry.key == 'hadith_library15' ||
          entry.key == 'hadith_chapters16' ||
          entry.key == 'hadith_detail17') {
        // Deterministic capture: package:http's zone client makes
        // every request fail fast as 403 (see _FailingHttpClient).
        // runWithClient must wrap the pumps too, not just the
        // widget build, so late-arriving futures stay in the zone.
        await http.runWithClient(runCapture, _FailingHttpClient.new);
      } else {
        await runCapture();
      }
    });
  }

  testWidgets('preview settings13_bottom', (tester) async {
    await _capturePreview(
      tester,
      const MapEntry('settings13_bottom', SettingsScreen()),
      size,
      scrollToBottom: true,
    );
  });
}

/// The shared preview-capture body (extracted so the hadith goldens
/// can run it inside http.runWithClient's zone).
Future<void> _capturePreview(
  WidgetTester tester,
  MapEntry<String, Widget> entry,
  Size size, {
  bool scrollToBottom = false,
}) async {
  final originalShadows = debugDisableShadows;
  debugDisableShadows = false;
  try {
    tester.view.physicalSize = Size(size.width * 2, size.height * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // Use the actual app themes and bundled fonts for contrast and layout review.
    final captureTheme =
        entry.key.endsWith('_dark') ? NoorTheme.dark() : NoorTheme.light();

    if (entry.value is QuranReaderScreen) {
      await tester.runAsync(() => QuranService()
          .fetchSurahEditions((entry.value as QuranReaderScreen).surah));
    }
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: captureTheme,
      // Tab-root screens rely on the shell's Scaffold for a Material
      // ancestor (TextField/InkWell require it); wrap every capture.
      home: Scaffold(body: entry.value),
    ));

    // Decode asset images for real, then let fallbacks settle.
    final ctx = tester.element(find.byType(MaterialApp));
    await tester.runAsync(() async {
      for (final path in _assetPaths) {
        try {
          await precacheImage(AssetImage(path), ctx);
        } catch (_) {
          // Missing asset on this screen: capture will show it.
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    if (entry.key.startsWith('home_cards')) {
      await tester.scrollUntilVisible(find.text('Ayat of the Day'), 240,
          scrollable: find.byType(Scrollable).first);
      await tester.pump(const Duration(milliseconds: 100));
    }
    if (scrollToBottom) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    if (entry.key == 'audio_fatiha' ||
        entry.key == 'audio_dark' ||
        entry.key == 'audio_nas') {
      final title = tester
          .widget<Text>(find.byKey(const ValueKey('audio-surah-arabic')))
          .data!;
      expect(title.contains('الكَهْف'), isFalse);
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../previews/${entry.key}.png'),
    );
  } finally {
    debugDisableShadows = originalShadows;
  }
}
