import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/daily_content_service.dart';
import 'package:noor_ai_companion/data/hadith_service.dart';
import 'package:noor_ai_companion/data/quran_service.dart';

void main() {
  group('Daily Content Service Tests', () {
    test('contains authentic Ayat collection and rotates with offset', () {
      expect(DailyContentService.totalAyat, greaterThanOrEqualTo(30));
      final a0 = DailyContentService.getAyah(offset: 0);
      final a1 = DailyContentService.getAyah(offset: 1);
      final aWrap = DailyContentService.getAyah(offset: DailyContentService.totalAyat);

      expect(a0.arabic.isNotEmpty, isTrue);
      expect(a0.translation.isNotEmpty, isTrue);
      expect(a0.reference.isNotEmpty, isTrue);
      expect(a1.id, isNot(equals(a0.id)));
      expect(aWrap.id, equals(a0.id));
    });

    test('contains authentic Hadith collection and rotates with offset', () {
      expect(DailyContentService.totalHadiths, greaterThanOrEqualTo(30));
      final h0 = DailyContentService.getHadith(offset: 0);
      final h1 = DailyContentService.getHadith(offset: 1);
      final hWrap = DailyContentService.getHadith(offset: DailyContentService.totalHadiths);

      expect(h0.arabic.isNotEmpty, isTrue);
      expect(h0.translation.isNotEmpty, isTrue);
      expect(h0.reference.isNotEmpty, isTrue);
      expect(h1.id, isNot(equals(h0.id)));
      expect(hWrap.id, equals(h0.id));
    });

    test('contains authentic Dua collection and rotates with offset', () {
      expect(DailyContentService.totalDuas, greaterThanOrEqualTo(30));
      final d0 = DailyContentService.getDua(offset: 0);
      final d1 = DailyContentService.getDua(offset: 1);
      final dWrap = DailyContentService.getDua(offset: DailyContentService.totalDuas);

      expect(d0.arabic.isNotEmpty, isTrue);
      expect(d0.translation.isNotEmpty, isTrue);
      expect(d0.reference.isNotEmpty, isTrue);
      expect(d1.id, isNot(equals(d0.id)));
      expect(dWrap.id, equals(d0.id));
    });
  });

  group('Quran 114 Surahs and 16-Line Mushaf Mapping Tests', () {
    test('has start page mapped for all 114 Surahs', () {
      for (var s = 1; s <= 114; s++) {
        final page = QuranService.surahStartPages[s];
        expect(page, isNotNull, reason: 'Surah $s must have start page');
        expect(page! >= 1 && page <= 604, isTrue);
      }
    });

    test('has metadata for all 114 Surahs in surahInfoMap', () {
      for (var s = 1; s <= 114; s++) {
        final info = QuranService.surahInfoMap[s];
        expect(info, isNotNull, reason: 'Surah $s must have info in map');
        expect(info!.$1.isNotEmpty, isTrue); // English Name
        expect(info.$2.isNotEmpty, isTrue); // Arabic Name
        expect(info.$3 > 0, isTrue); // Ayah count
      }
    });

    test('Juz start pages covers all 30 Juz', () {
      for (var j = 1; j <= 30; j++) {
        final page = QuranService.juzStartPages[j];
        expect(page, isNotNull, reason: 'Juz $j must have start page');
        expect(page! >= 1 && page <= 604, isTrue);
      }
    });
  });

  group('Hadith Databank Tests', () {
    test('defines all 7 canonical books including Nahjul Balagha', () {
      expect(HadithService.books.length, equals(7));
      final ids = HadithService.books.map((b) => b.id).toSet();
      expect(ids.contains('bukhari'), isTrue);
      expect(ids.contains('muslim'), isTrue);
      expect(ids.contains('abudawud'), isTrue);
      expect(ids.contains('tirmidhi'), isTrue);
      expect(ids.contains('nasai'), isTrue);
      expect(ids.contains('ibnmajah'), isTrue);
      expect(ids.contains('nahjulbalagha'), isTrue);
    });

    test('has CDN mirror fallbacks configured', () {
      expect(HadithService.cdnMirrors.length, greaterThanOrEqualTo(2));
      for (final mirror in HadithService.cdnMirrors) {
        expect(mirror.startsWith('https://'), isTrue);
      }
    });
  });
}
