// Phase 12 — recaptured with the bundled Amiri Quran +
// Noto Nastaliq Urdu fonts loaded (see _loadCaptureFonts).
// Phase 10 — VISUAL PREVIEW CAPTURES (separate from the normal suite;
// run explicitly: flutter test test/previews_test.dart --update-goldens)
// Pumps key NOOR screens at 390x844@2x and writes PNGs to ../previews/
// for side-by-side comparison with the user's design PNGs.
//
// Important capture setup (learned in Phase 10): flutter_test replaces
// fonts with a boxy test font and does not finish decoding asset
// images on its own, which made the first captures useless (text as
// blocks, images as colour bars). So here we (a) load the SDK's real
// Roboto + MaterialIcons fonts and apply Roboto as the capture font
// (the app's Manrope is a runtime Google Font and cannot load in the
// test binding), and (b) precache every NoorAssets image inside
// tester.runAsync before capturing. Layout/artwork comparison stays
// valid; typeface in captures is Roboto, not Manrope.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:noor_ai_companion/app.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';
import 'package:noor_ai_companion/screens/onboarding/splash_screen.dart';
import 'package:noor_ai_companion/screens/onboarding/onboarding_screen.dart';
import 'package:noor_ai_companion/screens/home/my_journey_screen.dart';
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

  await loadApp('AmiriQuran', 'AmiriQuran-Regular.ttf');
  await loadApp('NotoNastaliqUrdu', 'NotoNastaliqUrdu-Regular.ttf');
  await loadApp('NotoNastaliqUrdu', 'NotoNastaliqUrdu-Bold.ttf');
}

const _assetPaths = <String>[
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

  setUpAll(() async {
    await _loadCaptureFonts();
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

      if (entry.key == 'hadith_library15' ||
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
  tester.view.physicalSize = Size(size.width * 2, size.height * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  // Capture theme mirrors NoorTheme's colours/sizes but uses the
  // loaded Roboto (NoorTheme's Manrope is a runtime Google Font and
  // throws in the test binding). Do NOT call NoorTheme.light() here.
  final captureTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: NoorColors.cream,
    // Material button labels need an explicit loaded family in the
    // test capture, otherwise they fall back to the test box font.
    filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w700)))),
    elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w700)))),
    colorScheme: ColorScheme.fromSeed(
      seedColor: NoorColors.emerald,
      primary: NoorColors.emerald,
      secondary: NoorColors.gold,
      surface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: NoorColors.emeraldDark),
      titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: NoorColors.ink),
      titleMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: NoorColors.ink),
      bodyMedium: TextStyle(
          fontFamily: 'Roboto', fontSize: 14, color: NoorColors.ink),
      bodySmall: TextStyle(
          fontFamily: 'Roboto', fontSize: 12, color: NoorColors.muted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: NoorColors.emeraldSoft,
      labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ),
  );

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
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  if (scrollToBottom) {
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../previews/${entry.key}.png'),
  );
}
