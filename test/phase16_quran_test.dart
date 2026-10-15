import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/quran_service.dart';
import 'package:noor_ai_companion/screens/quran/quran_audio_player_screen.dart';
import 'package:noor_ai_companion/screens/quran/quran_reader_screen.dart';
import 'package:noor_ai_companion/screens/quran/surah_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Phase 16, Job 7 — whole-surah Qur'an.
//
// The reader and audio player used to hardcode surah 18, so tapping
// ANY surah in the list opened Al-Kahf. Both screens now take an
// optional `surah` parameter (default 18, preserving the Page 03/05
// design and goldens); the list passes the tapped number.
//
// Ayah counts and surah numbers only — no religious text in tests.

/// A recorded SurahDetail: N ayahs with sequential global numbers,
/// no text content needed for URL-count assertions.
SurahDetail _recordedSurah(int number, int ayahCount) => SurahDetail(
      meta: SurahMeta(
        number: number,
        englishName: 'Test $number',
        englishNameTranslation: 'Test',
        numberOfAyahs: ayahCount,
        arabicName: '',
        revelationType: '',
      ),
      edition: QuranService.editionArabic,
      ayahs: [
        for (var i = 1; i <= ayahCount; i++)
          Ayah(numberInSurah: i, globalNumber: i, text: ''),
      ],
    );

void main() {
  group('Phase 16 Job 7 — surah parameter', () {
    test('reader defaults to surah 18 (Al-Kahf, as drawn)', () {
      expect(const QuranReaderScreen().surah, 18);
    });

    test('audio player defaults to surah 18 (Al-Kahf, as drawn)', () {
      expect(const QuranAudioPlayerScreen().surah, 18);
    });

    test('explicit surah numbers are kept', () {
      expect(const QuranReaderScreen(surah: 2).surah, 2);
      expect(const QuranAudioPlayerScreen(surah: 114).surah, 114);
    });

    test('bookmark keys follow the surah parameter', () {
      expect(QuranReaderScreen.bookmarkKeyFor(18, 5), 'quran:18:5');
      expect(QuranReaderScreen.bookmarkKeyFor(2, 255), 'quran:2:255');
      expect(QuranReaderScreen.bookmarkKeyFor(114, 1), 'quran:114:1');
    });
  });

  group('Phase 16 Job 7 — surah boundary navigation', () {
    test('next/previous wrap 1<->114 (documented choice)', () {
      expect(QuranService.nextSurahNumber(114), 1);
      expect(QuranService.previousSurahNumber(1), 114);
    });

    test('mid-range neighbours', () {
      expect(QuranService.nextSurahNumber(18), 19);
      expect(QuranService.previousSurahNumber(18), 17);
      expect(QuranService.nextSurahNumber(1), 2);
      expect(QuranService.previousSurahNumber(114), 113);
    });

    test('out-of-range input clamps to the nearest end', () {
      expect(QuranService.nextSurahNumber(0), 1);
      expect(QuranService.previousSurahNumber(115), 114);
    });
  });

  group('Phase 16 Job 7 — audio playlist per surah', () {
    test('audio URL count equals ayah count', () {
      final detail = _recordedSurah(2, 286);
      final urls = QuranService.surahAudioUrls(detail);
      expect(urls, hasLength(286));
    });

    test('single-ayah surah builds a one-URL playlist', () {
      final urls = QuranService.surahAudioUrls(_recordedSurah(112, 4));
      expect(urls, hasLength(4));
    });

    test('ayahs without a global number are skipped', () {
      final detail = SurahDetail(
        meta: const SurahMeta(
          number: 1,
          englishName: 'Test',
          englishNameTranslation: 'Test',
          numberOfAyahs: 3,
          arabicName: '',
          revelationType: '',
        ),
        edition: QuranService.editionArabic,
        ayahs: const [
          Ayah(numberInSurah: 1, globalNumber: 1, text: ''),
          Ayah(numberInSurah: 2, globalNumber: 0, text: ''),
          Ayah(numberInSurah: 3, globalNumber: 3, text: ''),
        ],
      );
      expect(QuranService.surahAudioUrls(detail), hasLength(2));
    });
  });

  group('Phase 16 Job 7 — list tap passes the surah number', () {
    testWidgets('tapping Al-Fatihah opens the reader with surah 1',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      // runAsync lets the real service futures settle (network or
      // timeout -> sample fallback); either way the sample rows with
      // 'Al-Fatihah' are on screen.
      await tester.runAsync(() async {
        await tester.pumpWidget(
            const MaterialApp(home: Scaffold(body: SurahListScreen())));
        await tester.pumpAndSettle(const Duration(seconds: 20));
        await tester.tap(find.text('Al-Fatihah'));
        await tester.pumpAndSettle();
      });
      final reader =
          tester.widget<QuranReaderScreen>(find.byType(QuranReaderScreen));
      expect(reader.surah, 1);
    });
  });
}
