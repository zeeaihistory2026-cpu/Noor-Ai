import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor_ai_companion/data/hadith_service.dart';
import 'package:noor_ai_companion/data/noor_store.dart';
import 'package:noor_ai_companion/data/prayer_service.dart';
import 'package:noor_ai_companion/data/quran_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrayerService.clearCache();
    QuranService.clearCache();
  });

  group('Phase 6C: NoorStore TTL Caching', () {
    test('cacheJsonWithTtl stores data and cachedJsonWithTtl retrieves it before expiration', () async {
      await NoorStore.cacheJsonWithTtl(
        'test.key',
        '{"foo":"bar"}',
        ttl: const Duration(hours: 1),
      );

      final cached = await NoorStore.cachedJsonWithTtl('test.key');
      expect(cached, equals('{"foo":"bar"}'));
      expect(await NoorStore.isCacheValid('test.key'), isTrue);
    });

    test('cachedJsonWithTtl returns null and isCacheValid returns false after expiration', () async {
      // Store with negative TTL (already expired)
      await NoorStore.cacheJsonWithTtl(
        'test.expired',
        '{"expired":true}',
        ttl: const Duration(seconds: -10),
      );

      final cached = await NoorStore.cachedJsonWithTtl('test.expired');
      expect(cached, isNull);
      expect(await NoorStore.isCacheValid('test.expired'), isFalse);
    });

    test('invalidateCache clears both regular and TTL cache entries', () async {
      await NoorStore.cacheJsonWithTtl('test.to_clear', 'data');
      expect(await NoorStore.isCacheValid('test.to_clear'), isTrue);

      await NoorStore.invalidateCache('test.to_clear');
      expect(await NoorStore.cachedJsonWithTtl('test.to_clear'), isNull);
      expect(await NoorStore.cachedJson('test.to_clear'), anyOf(isNull, isEmpty));
    });
  });

  group('Phase 6C: PrayerService Caching & Single-Flight Coalescing', () {
    const alAdhanSample = '''
{
  "code": 200,
  "status": "OK",
  "data": {
    "timings": {
      "Fajr": "05:12",
      "Sunrise": "06:28",
      "Dhuhr": "12:15",
      "Asr": "15:42",
      "Sunset": "18:02",
      "Maghrib": "18:02",
      "Isha": "19:18",
      "Imsak": "05:02",
      "Midnight": "00:15"
    },
    "date": {
      "readable": "16 Oct 2026",
      "timestamp": "1792080000",
      "hijri": {
        "date": "05-05-1448",
        "day": "05",
        "month": {
          "number": 5,
          "en": "Jumada al-awwal"
        },
        "year": "1448"
      }
    },
    "meta": {
      "method": {
        "id": 5,
        "name": "University of Islamic Sciences, Karachi"
      }
    }
  }
}
''';

    test('PrayerService caches city timings and avoids second network call', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(alAdhanSample, 200, headers: {'content-type': 'application/json'});
      });

      final service = PrayerService(client: mockClient);

      // First call -> hits network
      final day1 = await service.fetchTodayByCity(city: 'Lahore', country: 'Pakistan', method: 5);
      expect(day1.timings['Fajr'], isNotNull);
      expect(callCount, equals(1));

      // Second call without forceRefresh -> served from cache
      final day2 = await service.fetchTodayByCity(city: 'Lahore', country: 'Pakistan', method: 5);
      expect(day2.timings['Fajr'], equals(day1.timings['Fajr']));
      expect(callCount, equals(1)); // NO second network request

      // Third call with forceRefresh -> triggers network fetch
      final day3 = await service.fetchTodayByCity(city: 'Lahore', country: 'Pakistan', method: 5, forceRefresh: true);
      expect(day3.timings['Fajr'], equals(day1.timings['Fajr']));
      expect(callCount, equals(2));
    });

    test('PrayerService coalesces concurrent requests (SingleFlight pattern)', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response(alAdhanSample, 200, headers: {'content-type': 'application/json'});
      });

      final service = PrayerService(client: mockClient);

      // Fire 3 simultaneous requests for the same city
      final results = await Future.wait([
        service.fetchTodayByCity(city: 'Islamabad', country: 'Pakistan', method: 5),
        service.fetchTodayByCity(city: 'Islamabad', country: 'Pakistan', method: 5),
        service.fetchTodayByCity(city: 'Islamabad', country: 'Pakistan', method: 5),
      ]);

      expect(results.length, equals(3));
      expect(results[0].timings['Fajr'], equals(results[1].timings['Fajr']));
      // Must only invoke HTTP once
      expect(callCount, equals(1));
    });

    test('PrayerService caches Hijri date display with TTL', () async {
      const gToHSample = '''
{
  "code": 200,
  "status": "OK",
  "data": {
    "hijri": {
      "date": "05-05-1448",
      "day": "05",
      "month": {
        "number": 5,
        "en": "Jumada al-awwal"
      },
      "year": "1448"
    }
  }
}
''';
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(gToHSample, 200, headers: {'content-type': 'application/json'});
      });

      final service = PrayerService(client: mockClient);
      final hijri1 = await service.fetchHijriDisplay(date: DateTime(2026, 10, 16));
      expect(hijri1, contains('Jumada al-awwal 1448 AH'));
      expect(callCount, equals(1));

      // Second call must return cached string without HTTP call
      final hijri2 = await service.fetchHijriDisplay(date: DateTime(2026, 10, 16));
      expect(hijri2, equals(hijri1));
      expect(callCount, equals(1));
    });

    test('PrayerService caches Qibla bearing', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(
          '{"code":200,"status":"OK","data":{"latitude":24.86,"longitude":67.0,"direction":268.4}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = PrayerService(client: mockClient);
      final bearing1 = await service.fetchQiblaBearing(latitude: 24.86, longitude: 67.0);
      expect(bearing1, closeTo(268.4, 0.1));
      expect(callCount, equals(1));

      // Second call is instant from cache
      final bearing2 = await service.fetchQiblaBearing(latitude: 24.86, longitude: 67.0);
      expect(bearing2, equals(bearing1));
      expect(callCount, equals(1));
    });
  });

  group('Phase 6C: QuranService Caching & Coalescing', () {
    const surahListSample = '''
{
  "code": 200,
  "status": "OK",
  "data": [
    {
      "number": 1,
      "name": "سُورَةُ ٱلْفَاتِحَةِ",
      "englishName": "Al-Faatiha",
      "englishNameTranslation": "The Opening",
      "numberOfAyahs": 7,
      "revelationType": "Meccan"
    },
    {
      "number": 2,
      "name": "سُورَةُ البَقَرَةِ",
      "englishName": "Al-Baqara",
      "englishNameTranslation": "The Cow",
      "numberOfAyahs": 286,
      "revelationType": "Medinan"
    }
  ]
}
''';

    const surahDetailSample = '''
{
  "code": 200,
  "status": "OK",
  "data": {
    "number": 1,
    "name": "سُورَةُ ٱلْفَاتِحَةِ",
    "englishName": "Al-Faatiha",
    "englishNameTranslation": "The Opening",
    "numberOfAyahs": 7,
    "revelationType": "Meccan",
    "ayahs": [
      {
        "number": 1,
        "text": "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
        "numberInSurah": 1,
        "juz": 1,
        "page": 1
      }
    ]
  }
}
''';

    test('QuranService fetchSurahList caches list and avoids second fetch', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(surahListSample, 200, headers: {'content-type': 'application/json'});
      });

      final service = QuranService(client: mockClient);
      final list1 = await service.fetchSurahListOrFallback();
      expect(list1.length, equals(2));
      expect(callCount, equals(1));

      // Second call returns cached list
      final list2 = await service.fetchSurahListOrFallback();
      expect(list2.length, equals(2));
      expect(callCount, equals(1));
    });

    test('QuranService fetchSurah coalesces concurrent requests and caches detail', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return http.Response(surahDetailSample, 200, headers: {'content-type': 'application/json'});
      });

      final service = QuranService(client: mockClient);
      final results = await Future.wait([
        service.fetchSurah(1),
        service.fetchSurah(1),
        service.fetchSurah(1),
      ]);

      expect(results.length, equals(3));
      expect(results[0].ayahs.length, equals(1));
      expect(callCount, equals(1)); // Single-flight coalescing
    });

    test('QuranService search caches results with TTL', () async {
      const searchSample = '''
{
  "code": 200,
  "status": "OK",
  "data": {
    "count": 1,
    "matches": [
      {
        "number": 153,
        "text": "O you who have believed, seek help through patience and prayer.",
        "numberInSurah": 153,
        "surah": {
          "number": 2,
          "englishName": "Al-Baqarah"
        }
      }
    ]
  }
}
''';
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(searchSample, 200, headers: {'content-type': 'application/json'});
      });

      final service = QuranService(client: mockClient);
      final m1 = await service.search('patience');
      expect(m1.length, equals(1));
      expect(m1.first.reference, equals('Quran 2:153'));
      expect(callCount, equals(1));

      // Second search for same keyword is served from cache
      final m2 = await service.search('patience');
      expect(m2.length, equals(1));
      expect(callCount, equals(1));
    });
  });

  group('Phase 6C: HadithService Single-Flight In-Flight Coalescing', () {
    const minJsonSample = '''
{
  "metadata": {
    "name": "Sahih al Bukhari",
    "sections": {"1": "Revelation"}
  },
  "hadiths": [
    {
      "hadithnumber": 1,
      "arabicnumber": 1,
      "text": "Actions are by intention.",
      "grades": [],
      "reference": {"book": 1, "hadith": 1}
    }
  ]
}
''';

    test('HadithService coalesces simultaneous fetchEdition calls into one download', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        await Future<void>.delayed(const Duration(milliseconds: 60));
        return http.Response(minJsonSample, 200, headers: {'content-type': 'application/json'});
      });

      final service = HadithService(client: mockClient);

      // Concurrent fetch for 'bukhari'
      final results = await Future.wait([
        service.fetchEdition('bukhari'),
        service.fetchEdition('bukhari'),
      ]);

      expect(results.length, equals(2));
      expect(results[0].hadiths.first.text, contains('Actions are by intention'));
      expect(callCount, equals(1)); // Only 1 network call made!
    });
  });
}
