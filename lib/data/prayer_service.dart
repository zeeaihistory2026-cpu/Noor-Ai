import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import 'noor_store.dart';
import 'sample_data.dart';

/// Phase 6 — live prayer data from the AlAdhan API.
///
/// AlAdhan (https://aladhan.com/prayer-times-api) is free and needs
/// no API key. Documented endpoints used here (kept as constants so
/// they can be audited against the public docs in one place):
///   GET /v1/timingsByCity/{DD-MM-YYYY}?city=&country=&method=
///   GET /v1/timings/{DD-MM-YYYY}?latitude=&longitude=&method=
///   GET /v1/gToH/{DD-MM-YYYY}                 (Gregorian -> Hijri)
///   GET /v1/qibla/{latitude}/{longitude}     (Qibla bearing)
///
/// Everything degrades gracefully: network -> in-memory cache ->
/// persisted cache -> [PrayerDay.sample] (the design's sample
/// times), so screens never break offline. Phase 7 (2026-10-06):
/// live-tested from the shell — timingsByCity, gToH and qibla all
/// returned HTTP 200 with the documented shape (data.timings,
/// data.date.hijri.month.en, data.direction numeric); the parser
/// below needs no change for those responses.
class PrayerService {
  PrayerService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String baseUrl = 'https://api.aladhan.com/v1';

  /// Calculation method 5 = University of Islamic Sciences, Karachi.
  /// Default for the Asia/Karachi user; also a [NoorStore] setting.
  static const int defaultMethod = 5;
  static const String defaultCity = 'Karachi';
  static const String defaultCountry = 'Pakistan';

  /// Makkah coordinates used for the Qibla bearing (Page 10).
  static const double makkahLat = 21.4225;
  static const double makkahLng = 39.8262;

  static const List<String> prayerOrder = <String>[
    'Fajr',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static PrayerDay? _memoryCache;

  // ---- Public API -----------------------------------------------------

  /// Today's prayer times for a city, with cache + sample fallback.
  Future<PrayerDay> fetchTodayByCity({
    String city = defaultCity,
    String country = defaultCountry,
    int? method,
  }) async {
    try {
      final day = await fetchTimingsByCity(
        city: city,
        country: country,
        method: method ?? await NoorStore.getCalculationMethod(),
        date: DateTime.now(),
      );
      _memoryCache = day;
      return day;
    } catch (_) {
      return _memoryCache ?? await _persistedCache() ?? PrayerDay.sample();
    }
  }

  /// Raw AlAdhan timings-by-city call. Throws on HTTP/parse failure;
  /// prefer [fetchTodayByCity] from UI code.
  Future<PrayerDay> fetchTimingsByCity({
    required String city,
    required String country,
    int method = defaultMethod,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final uri = Uri.parse(
      '$baseUrl/timingsByCity/${_dateKey(d)}'
      '?city=${Uri.encodeQueryComponent(city)}'
      '&country=${Uri.encodeQueryComponent(country)}'
      '&method=$method',
    );
    final res = await _client.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw PrayerServiceException('AlAdhan timingsByCity '
          'HTTP ${res.statusCode}');
    }
    final day = PrayerDay.fromAlAdhanJson(
      jsonDecode(res.body) as Map<String, dynamic>,
      source: PrayerSource.live,
    );
    await NoorStore.cacheJson('prayer.last', res.body);
    return day;
  }

  /// Raw AlAdhan timings-by-coordinates call (latitude/longitude).
  Future<PrayerDay> fetchTimingsByCoordinates({
    required double latitude,
    required double longitude,
    int method = defaultMethod,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final uri = Uri.parse(
      '$baseUrl/timings/${_dateKey(d)}'
      '?latitude=$latitude&longitude=$longitude&method=$method',
    );
    final res = await _client.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw PrayerServiceException('AlAdhan timings '
          'HTTP ${res.statusCode}');
    }
    final day = PrayerDay.fromAlAdhanJson(
      jsonDecode(res.body) as Map<String, dynamic>,
      source: PrayerSource.live,
    );
    await NoorStore.cacheJson('prayer.last', res.body);
    return day;
  }

  /// Hijri date for [date] via AlAdhan gToH. Falls back to the
  /// Hijri date embedded in timings, then to the sample string.
  Future<String> fetchHijriDisplay({DateTime? date}) async {
    final d = date ?? DateTime.now();
    try {
      final uri = Uri.parse('$baseUrl/gToH/${_dateKey(d)}');
      final res = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final hijri = (body['data'] as Map<String, dynamic>)['hijri']
            as Map<String, dynamic>;
        final month = (hijri['month'] as Map<String, dynamic>)['en'] as String;
        return '${hijri['day']} $month ${hijri['year']} AH';
      }
    } catch (_) {
      /* fall through */
    }
    final day = _memoryCache ?? await _persistedCache();
    return day?.hijriDisplay ?? SampleData.hijriDate;
  }

  /// Qibla bearing in degrees clockwise from north.
  /// Tries the AlAdhan qibla endpoint, then computes the
  /// great-circle bearing locally — no network needed for the math.
  Future<double> fetchQiblaBearing({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/qibla/$latitude/$longitude');
      final res = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        final direction = (data['direction'] as num).toDouble();
        if (direction > 0) return direction;
      }
    } catch (_) {
      /* fall through to local computation */
    }
    return computeQiblaBearing(latitude, longitude);
  }

  /// Great-circle initial bearing to Makkah, degrees from north.
  static double computeQiblaBearing(double lat, double lng) {
    final lat1 = _rad(lat);
    final lat2 = _rad(makkahLat);
    final dLng = _rad(makkahLng - lng);
    final y = math.sin(dLng);
    final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(dLng);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  // ---- Helpers --------------------------------------------------------

  static Future<PrayerDay?> _persistedCache() async {
    final raw = await NoorStore.cachedJson('prayer.last');
    if (raw == null) return null;
    try {
      return PrayerDay.fromAlAdhanJson(
        jsonDecode(raw) as Map<String, dynamic>,
        source: PrayerSource.cache,
      );
    } catch (_) {
      return null;
    }
  }

  static String _dateKey(DateTime d) => '${d.day.toString().padLeft(2, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-${d.year}';

  static double _rad(double deg) => deg * math.pi / 180;

  /// "3:46 PM" style label without depending on intl.
  static String formatTime(DateTime t) {
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $suffix';
  }

  /// "1h 18m remaining" / "42m remaining" style countdown label.
  static String formatRemaining(Duration d) {
    if (d.isNegative) return 'now';
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m remaining';
    if (d.inMinutes >= 1) return '${d.inMinutes}m remaining';
    return 'less than a minute remaining';
  }
}

enum PrayerSource { live, cache, sample }

/// One day of prayer times + Hijri date, however it was obtained.
class PrayerDay {
  PrayerDay({
    required this.timings,
    required this.hijriDisplay,
    required this.source,
  });

  /// Prayer name -> local time. Keys from [PrayerService.prayerOrder].
  final Map<String, DateTime> timings;

  /// e.g. "12 Sha'ban 1448 AH" (Page 01 greeting line).
  final String hijriDisplay;

  final PrayerSource source;

  bool get isLive => source == PrayerSource.live;

  /// Parses the documented AlAdhan timings response:
  /// data.timings {Fajr: "05:12 (PKT)", ...}, data.date.hijri {...}.
  factory PrayerDay.fromAlAdhanJson(
    Map<String, dynamic> body, {
    required PrayerSource source,
  }) {
    final data = body['data'] as Map<String, dynamic>;
    final rawTimings = data['timings'] as Map<String, dynamic>;
    final dateInfo = data['date'] as Map<String, dynamic>?;
    final gregorian = dateInfo?['gregorian'] as Map<String, dynamic>?;
    final dateStr = gregorian?['date'] as String?; // DD-MM-YYYY
    var year = DateTime.now().year;
    var month = DateTime.now().month;
    var dayNum = DateTime.now().day;
    if (dateStr != null && dateStr.length >= 10) {
      dayNum = int.tryParse(dateStr.substring(0, 2)) ?? dayNum;
      month = int.tryParse(dateStr.substring(3, 5)) ?? month;
      year = int.tryParse(dateStr.substring(6, 10)) ?? year;
    }

    final timings = <String, DateTime>{};
    for (final name in PrayerService.prayerOrder) {
      final raw = rawTimings[name]?.toString();
      if (raw == null) continue;
      // Values look like "05:12" or "05:12 (PKT)" — keep HH:mm only.
      final clean = raw.split(' ').first;
      final parts = clean.split(':');
      if (parts.length < 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) continue;
      timings[name] = DateTime(year, month, dayNum, h, m);
    }

    var hijriDisplay = SampleData.hijriDate;
    final hijri = dateInfo?['hijri'] as Map<String, dynamic>?;
    if (hijri != null) {
      final monthMap = hijri['month'] as Map<String, dynamic>?;
      final monthEn = monthMap?['en']?.toString() ?? '';
      hijriDisplay = '${hijri['day']} $monthEn ${hijri['year']} AH';
    }
    return PrayerDay(
        timings: timings, hijriDisplay: hijriDisplay, source: source);
  }

  /// The design's sample day (Pages 01/14) — offline fallback.
  factory PrayerDay.sample() {
    final now = DateTime.now();
    DateTime at(String label) {
      // Labels look like '5:32 AM' / '12:45 PM' in SampleData.
      final match = RegExp(r'(\d+):(\d+)\s*(AM|PM)').firstMatch(label);
      if (match == null) return now;
      var h = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      final pm = match.group(3) == 'PM';
      if (pm && h != 12) h += 12;
      if (!pm && h == 12) h = 0;
      return DateTime(now.year, now.month, now.day, h, m);
    }

    return PrayerDay(
      timings: <String, DateTime>{
        for (final p in SampleData.salahTimes) p.$1: at(p.$2),
        'Sunrise': at('5:36 AM'),
      },
      hijriDisplay: SampleData.hijriDate,
      source: PrayerSource.sample,
    );
  }

  /// Next obligatory prayer after [now] (Sunrise excluded).
  /// Returns (name, time, remaining). After Isha, the next prayer
  /// is tomorrow's Fajr (time shown +1 day; exact tomorrow times
  /// need tomorrow's API call — marked by [NextPrayer.isTomorrow]).
  NextPrayer nextPrayer({DateTime? now}) {
    final n = now ?? DateTime.now();
    const obligatory = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final name in obligatory) {
      final t = timings[name];
      if (t != null && t.isAfter(n)) {
        return NextPrayer(name: name, time: t, remaining: t.difference(n));
      }
    }
    final fajr = timings['Fajr'];
    if (fajr != null) {
      final tomorrow = fajr.add(const Duration(days: 1));
      return NextPrayer(
        name: 'Fajr',
        time: tomorrow,
        remaining: tomorrow.difference(n),
        isTomorrow: true,
      );
    }
    // Extremely defensive: should never happen with sample fallback.
    final fallback = n.add(const Duration(hours: 1));
    return NextPrayer(
        name: SampleData.nextPrayer,
        time: fallback,
        remaining: const Duration(hours: 1));
  }
}

class NextPrayer {
  NextPrayer({
    required this.name,
    required this.time,
    required this.remaining,
    this.isTomorrow = false,
  });

  final String name;
  final DateTime time;
  final Duration remaining;
  final bool isTomorrow;

  String get timeLabel => PrayerService.formatTime(time);
  String get remainingLabel => PrayerService.formatRemaining(remaining);
}

class PrayerServiceException implements Exception {
  PrayerServiceException(this.message);
  final String message;
  @override
  String toString() => 'PrayerServiceException: $message';
}
