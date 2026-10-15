import 'dart:convert';

import 'package:http/http.dart' as http;

import 'noor_store.dart';
import 'sample_data.dart';

/// Phase 6 — Qur'an text, translation and audio wiring.
///
/// Primary source: AlQuran Cloud (https://alquran.cloud/api), free,
/// no key. Documented endpoints used here (constants below):
///   GET /v1/surah
///   GET /v1/surah/{number}/{edition}
///   GET /v1/surah/{number}/editions/{e1},{e2},{e3}
/// Editions: `quran-uthmani` (Arabic), `en.sahih` (Saheeh
/// International), `ur.jalandhry` (Fateh Muhammad Jalandhari —
/// matches the Reader's Urdu source line on Page 03).
/// Per-ayah audio is returned by audio editions (e.g. `ar.alafasy`)
/// and also follows the Islamic Network CDN pattern built by
/// [ayahAudioUrl]. Secondary source: Quran.com API v4 — stubbed
/// (URL builders + one chapters call) for a later phase.
///
/// RULE: no Qur'an text is embedded in code beyond the brief,
/// attributed excerpts already in [SampleData]. Full text is only
/// ever fetched at runtime from the APIs above. Phase 7
/// (2026-10-06): live-tested from the shell — /v1/surah returned
/// HTTP 200 with 114 items, and the multi-edition call for Surah
/// 18 returned 3 editions (quran-uthmani, en.sahih, ur.jalandhry)
/// with the identifiers/ayah counts the parser below expects.
class QuranService {
  QuranService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String alQuranBase = 'https://api.alquran.cloud/v1';
  static const String quranComBase = 'https://api.quran.com/api/v4';

  /// Surah navigation wraps 1<->114 (a closed 114-cycle) — the
  /// documented choice for the reader/player Previous/Next Surah
  /// buttons: the buttons never go dead at the ends, so there is
  /// always a surah to move to. Out-of-range input clamps to the
  /// nearest end before wrapping.
  static int nextSurahNumber(int n) => n >= 114 ? 1 : (n < 1 ? 1 : n + 1);

  static int previousSurahNumber(int n) =>
      n <= 1 ? 114 : (n > 114 ? 114 : n - 1);

  static const String editionArabic = 'quran-uthmani';
  static const String editionEnglish = 'en.sahih';
  static const String editionUrdu = 'ur.jalandhry';
  static const String editionAudioDefault = 'ar.alafasy';

  // ---- Surah list (Page 02) ------------------------------------------

  /// All 114 surahs from AlQuran Cloud, persisted-cached, with the
  /// design's sample list as the never-break offline fallback.
  Future<List<SurahMeta>> fetchSurahListOrFallback() async {
    try {
      final list = await fetchSurahList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      /* fall through */
    }
    final cached = await _cachedSurahList();
    return cached ?? sampleSurahList();
  }

  /// Raw GET /v1/surah. Throws on failure; UI uses the OrFallback.
  Future<List<SurahMeta>> fetchSurahList() async {
    final uri = Uri.parse('$alQuranBase/surah');
    final res = await _client.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw QuranServiceException('AlQuran /surah HTTP ${res.statusCode}');
    }
    await NoorStore.cacheJson('quran.surahList', res.body);
    return _parseSurahList(res.body);
  }

  Future<List<SurahMeta>?> _cachedSurahList() async {
    final raw = await NoorStore.cachedJson('quran.surahList');
    if (raw == null) return null;
    try {
      final list = _parseSurahList(raw);
      return list.isEmpty ? null : list;
    } catch (_) {
      return null;
    }
  }

  static List<SurahMeta> _parseSurahList(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>;
    return data.map((e) {
      final m = e as Map<String, dynamic>;
      return SurahMeta(
        number: (m['number'] as num).toInt(),
        arabicName: m['name']?.toString() ?? '',
        englishName: m['englishName']?.toString() ?? '',
        englishNameTranslation: m['englishNameTranslation']?.toString() ?? '',
        numberOfAyahs: (m['numberOfAyahs'] as num?)?.toInt() ?? 0,
        revelationType: m['revelationType']?.toString() ?? '',
      );
    }).toList();
  }

  /// The design's 10 sample surahs (Page 02) as [SurahMeta].
  static List<SurahMeta> sampleSurahList() => <SurahMeta>[
        for (final s in SampleData.surahs)
          SurahMeta(
            number: s.$1,
            englishName: s.$2,
            englishNameTranslation: s.$3,
            numberOfAyahs: s.$4,
            arabicName: s.$6,
            revelationType: '',
          ),
      ];

  // ---- Surah content (Pages 03/04/05) ---------------------------------
  // Full text comes from the API at runtime. Nothing is cached in
  // code; the parsed result is kept only in the returned objects
  // (and, for the list above, in the on-device JSON cache).

  /// One surah in one edition, e.g. fetchSurah(18, editionEnglish).
  Future<SurahDetail> fetchSurah(
    int number, {
    String edition = editionArabic,
  }) async {
    final uri = Uri.parse('$alQuranBase/surah/$number/$edition');
    final res = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw QuranServiceException(
          'AlQuran /surah/$number HTTP ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return SurahDetail.fromEditionJson(
      body['data'] as Map<String, dynamic>,
      edition: edition,
    );
  }

  /// Arabic + English + Urdu in one documented editions call.
  /// Returns a map edition -> detail; missing editions are skipped
  /// rather than failing the whole reader.
  Future<Map<String, SurahDetail>> fetchSurahEditions(int number) async {
    const editions = <String>[editionArabic, editionEnglish, editionUrdu];
    final uri =
        Uri.parse('$alQuranBase/surah/$number/editions/${editions.join(',')}');
    final res = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw QuranServiceException('AlQuran editions HTTP ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'];
    final out = <String, SurahDetail>{};
    if (data is List) {
      for (final e in data) {
        final map = e as Map<String, dynamic>;
        final ed = (map['edition'] as Map<String, dynamic>?)?['identifier']
                ?.toString() ??
            '';
        if (ed.isNotEmpty) {
          out[ed] = SurahDetail.fromEditionJson(map, edition: ed);
        }
      }
    }
    return out;
  }

  // ---- Search (Phase 14 — AI topic search) ----------------------------
  // Documented AlQuran Cloud keyword search:
  //   GET /v1/search/{keyword}/all/{edition}
  // returns data.matches[] with {number (global), text, numberInSurah,
  // surah{number, englishName}, edition{identifier}}. Verified live
  // 2026-10-08 (HTTP 200, `patience` -> 18 matches). Text only ever
  // exists at runtime; nothing is embedded in code.

  static Uri searchUri(String keyword, {String edition = editionEnglish}) =>
      Uri.parse('$alQuranBase/search/${Uri.encodeComponent(keyword)}/all/'
          '$edition');

  /// Live keyword search (English edition by default). Throws on
  /// failure so callers can fall back to the offline topic index.
  Future<List<QuranSearchMatch>> search(
    String keyword, {
    String edition = editionEnglish,
  }) async {
    final res = await _client
        .get(searchUri(keyword, edition: edition))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw QuranServiceException('AlQuran /search HTTP ${res.statusCode}');
    }
    return parseSearchResponse(res.body);
  }

  static List<QuranSearchMatch> parseSearchResponse(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    final matches = (data?['matches'] as List<dynamic>?) ?? <dynamic>[];
    return matches.map((e) {
      final m = e as Map<String, dynamic>;
      final surah = (m['surah'] as Map<String, dynamic>?) ?? const {};
      return QuranSearchMatch(
        globalNumber: (m['number'] as num?)?.toInt() ?? 0,
        text: m['text']?.toString() ?? '',
        surahNumber: (surah['number'] as num?)?.toInt() ?? 0,
        surahEnglishName: surah['englishName']?.toString() ?? '',
        ayahNumber: (m['numberInSurah'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  // ---- Audio (Page 05) --------------------------------------------------

  /// Islamic Network CDN pattern used by AlQuran Cloud audio
  /// editions: /quran/audio/{bitrate}/{edition}/{globalAyah}.mp3
  /// where globalAyah is 1..6236 across the whole Qur'an.
  static String ayahAudioUrl(
    int globalAyahNumber, {
    String edition = editionAudioDefault,
    int bitrate = 128,
  }) =>
      'https://cdn.islamic.network/quran/audio/$bitrate/$edition/'
      '$globalAyahNumber.mp3';

  /// Surah-level audio is a playlist of its ayahs; the player
  /// (Phase 7, just_audio) steps through these URLs in order.
  static List<String> surahAudioUrls(SurahDetail detail,
          {String edition = editionAudioDefault}) =>
      <String>[
        for (final a in detail.ayahs)
          if (a.globalNumber > 0)
            ayahAudioUrl(a.globalNumber, edition: edition),
      ];

  // ---- Quran.com API v4 (secondary source — STUBS) --------------------
  // Kept for a later phase (tafsir, word-by-word, reciter catalogues
  // are richer there). Stubs only: URL builders + chapters list. No
  // screen depends on these yet, so Quran.com being unreachable can
  // never break the app.

  static Uri quranComChaptersUri() => Uri.parse('$quranComBase/chapters');

  static Uri quranComChapterUri(int id) =>
      Uri.parse('$quranComBase/chapters/$id');

  static Uri quranComVersesByChapterUri(int chapter,
          {int translationId = 131}) =>
      Uri.parse('$quranComBase/verses/by_chapter/$chapter'
          '?translations=$translationId&fields=text_uthmani');

  /// STUB: fetches Quran.com chapter metadata. Returns raw decoded
  /// JSON for now; typed models land when a screen consumes it.
  Future<List<dynamic>> fetchChaptersQuranComStub() async {
    final res = await _client
        .get(quranComChaptersUri())
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw QuranServiceException('Quran.com /chapters HTTP ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['chapters'] as List<dynamic>?) ?? <dynamic>[];
  }
}

/// Surah metadata row (Page 02). Arabic name is the surah title
/// (a proper name), never verse text.
class SurahMeta {
  const SurahMeta({
    required this.number,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.arabicName,
    required this.revelationType,
  });

  final int number;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String arabicName;
  final String revelationType;

  /// Shape used by the existing Page 02 row widget:
  /// (number, english, meaning, ayahs, startPage-placeholder, arabic).
  (int, String, String, int, int, String) toSampleTuple() => (
        number,
        englishName,
        englishNameTranslation,
        numberOfAyahs,
        0, // Page number needs Mushaf metadata — TODO(phase-7).
        arabicName,
      );
}

/// One ayah as fetched at runtime. Text fields hold API content
/// only in memory; they are never written into source code.
class Ayah {
  const Ayah({
    required this.numberInSurah,
    required this.globalNumber,
    required this.text,
    this.audioUrl,
    this.juz,
    this.page,
  });

  final int numberInSurah;
  final int globalNumber;
  final String text;
  final String? audioUrl;

  /// Mushaf position of this ayah when the API carries it
  /// (AlQuran Cloud surah responses do); null when unknown.
  final int? juz;
  final int? page;
}

/// A surah in a single edition (Arabic OR a translation OR audio).
class SurahDetail {
  SurahDetail({
    required this.meta,
    required this.edition,
    required this.ayahs,
  });

  final SurahMeta meta;
  final String edition;
  final List<Ayah> ayahs;

  factory SurahDetail.fromEditionJson(
    Map<String, dynamic> data, {
    required String edition,
  }) {
    final meta = SurahMeta(
      number: (data['number'] as num?)?.toInt() ?? 0,
      englishName: data['englishName']?.toString() ?? '',
      englishNameTranslation: data['englishNameTranslation']?.toString() ?? '',
      numberOfAyahs: (data['numberOfAyahs'] as num?)?.toInt() ?? 0,
      arabicName: data['name']?.toString() ?? '',
      revelationType: data['revelationType']?.toString() ?? '',
    );
    final rawAyahs = (data['ayahs'] as List<dynamic>?) ?? <dynamic>[];
    final ayahs = rawAyahs.map((e) {
      final a = e as Map<String, dynamic>;
      return Ayah(
        numberInSurah: (a['numberInSurah'] as num?)?.toInt() ?? 0,
        globalNumber: (a['number'] as num?)?.toInt() ?? 0,
        text: a['text']?.toString() ?? '',
        audioUrl: a['audio']?.toString(),
        juz: (a['juz'] as num?)?.toInt(),
        page: (a['page'] as num?)?.toInt(),
      );
    }).toList();
    return SurahDetail(meta: meta, edition: edition, ayahs: ayahs);
  }
}

/// One live keyword-search match. [reference] is built from the
/// response's own surah/ayah numbers — never from the query — so a
/// shown citation always comes from the databank response itself.
class QuranSearchMatch {
  const QuranSearchMatch({
    required this.globalNumber,
    required this.text,
    required this.surahNumber,
    required this.surahEnglishName,
    required this.ayahNumber,
  });

  final int globalNumber;
  final String text;
  final int surahNumber;
  final String surahEnglishName;
  final int ayahNumber;

  String get reference => 'Quran $surahNumber:$ayahNumber';
}

class QuranServiceException implements Exception {
  QuranServiceException(this.message);
  final String message;
  @override
  String toString() => 'QuranServiceException: $message';
}
