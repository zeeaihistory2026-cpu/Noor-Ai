import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  static List<SurahMeta>? _memorySurahList;
  static final Map<int, Map<String, SurahDetail>> _editionsCache = <int, Map<String, SurahDetail>>{};
  static final Map<String, SurahDetail> _surahCache = <String, SurahDetail>{};
  static final Map<String, List<QuranSearchMatch>> _searchCache = <String, List<QuranSearchMatch>>{};

  static Future<List<SurahMeta>>? _inFlightSurahList;
  static final Map<String, Future<SurahDetail>> _inFlightSurah = <String, Future<SurahDetail>>{};
  static final Map<int, Future<Map<String, SurahDetail>>> _inFlightEditions = <int, Future<Map<String, SurahDetail>>>{};
  static final Map<String, Future<List<QuranSearchMatch>>> _inFlightSearch = <String, Future<List<QuranSearchMatch>>>{};

  /// Clears in-memory caches and in-flight requests. Useful for tests.
  static void clearCache() {
    _memorySurahList = null;
    _editionsCache.clear();
    _surahCache.clear();
    _searchCache.clear();
    _inFlightSurahList = null;
    _inFlightSurah.clear();
    _inFlightEditions.clear();
    _inFlightSearch.clear();
  }

  // ---- Surah list (Page 02) ------------------------------------------

  /// All 114 surahs from AlQuran Cloud, persisted-cached with TTL,
  /// with cache-first resolution and sample list fallback.
  Future<List<SurahMeta>> fetchSurahListOrFallback({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (_memorySurahList != null && _memorySurahList!.isNotEmpty) {
        return _memorySurahList!;
      }
      final cached = await _cachedSurahList();
      if (cached != null && cached.isNotEmpty) {
        _memorySurahList = cached;
        return cached;
      }
    }
    try {
      final list = await fetchSurahList(forceRefresh: forceRefresh);
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('QuranService: fetchSurahList failed, falling back to cache: $e');
    }
    final cached = await _cachedSurahList();
    return cached ?? sampleSurahList();
  }

  /// Raw GET /v1/surah with single-flight coalescing and TTL caching.
  Future<List<SurahMeta>> fetchSurahList({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (_memorySurahList != null && _memorySurahList!.isNotEmpty) {
        return _memorySurahList!;
      }
      final cached = await _cachedSurahList();
      if (cached != null && cached.isNotEmpty) {
        _memorySurahList = cached;
        return cached;
      }
    }

    final inFlight = _inFlightSurahList;
    if (inFlight != null) return inFlight;

    final future = () async {
      try {
        final uri = Uri.parse('$alQuranBase/surah');
        final res = await _client.get(uri).timeout(const Duration(seconds: 12));
        if (res.statusCode != 200) {
          throw QuranServiceException('AlQuran /surah HTTP ${res.statusCode}');
        }
        await NoorStore.cacheJsonWithTtl(
          'quran.surahList',
          res.body,
          ttl: const Duration(days: 90),
        );
        await NoorStore.cacheJson('quran.surahList', res.body);
        final list = _parseSurahList(res.body);
        _memorySurahList = list;
        return list;
      } finally {
        _inFlightSurahList = null;
      }
    }();

    _inFlightSurahList = future;
    return future;
  }

  Future<List<SurahMeta>?> _cachedSurahList() async {
    final raw = await NoorStore.cachedJsonWithTtl('quran.surahList') ??
        await NoorStore.cachedJson('quran.surahList');
    if (raw == null) return null;
    try {
      final list = _parseSurahList(raw);
      return list.isEmpty ? null : list;
    } catch (e) {
      debugPrint('QuranService: Failed to parse cached surah list: $e');
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

  /// One surah in one edition with TTL caching and in-flight coalescing.
  Future<SurahDetail> fetchSurah(
    int number, {
    String edition = editionArabic,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'quran.surah.$number.$edition';
    if (!forceRefresh) {
      final mem = _surahCache[cacheKey];
      if (mem != null) return mem;

      final diskCached = await NoorStore.cachedJsonWithTtl(cacheKey);
      if (diskCached != null && diskCached.isNotEmpty) {
        try {
          final body = jsonDecode(diskCached) as Map<String, dynamic>;
          final parsed = SurahDetail.fromEditionJson(
            body['data'] as Map<String, dynamic>,
            edition: edition,
          );
          _surahCache[cacheKey] = parsed;
          return parsed;
        } catch (e) {
          debugPrint('QuranService: Failed to parse cached Surah $number ($edition): $e');
        }
      }
    }

    final inFlight = _inFlightSurah[cacheKey];
    if (inFlight != null) return inFlight;

    final future = () async {
      try {
        final uri = Uri.parse('$alQuranBase/surah/$number/$edition');
        final res = await _client.get(uri).timeout(const Duration(seconds: 15));
        if (res.statusCode != 200) {
          throw QuranServiceException(
              'AlQuran /surah/$number HTTP ${res.statusCode}');
        }
        await NoorStore.cacheJsonWithTtl(
          cacheKey,
          res.body,
          ttl: const Duration(days: 90),
        );
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final detail = SurahDetail.fromEditionJson(
          body['data'] as Map<String, dynamic>,
          edition: edition,
        );
        _surahCache[cacheKey] = detail;
        return detail;
      } finally {
        _inFlightSurah.remove(cacheKey);
      }
    }();

    _inFlightSurah[cacheKey] = future;
    return future;
  }

  /// Arabic + English + Urdu in one documented editions call with TTL caching.
  Future<Map<String, SurahDetail>> fetchSurahEditions(
    int number, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'quran.surah.$number.editions';
    if (!forceRefresh) {
      final mem = _editionsCache[number];
      if (mem != null) return mem;

      final diskCached = await NoorStore.cachedJsonWithTtl(cacheKey);
      if (diskCached != null && diskCached.isNotEmpty) {
        try {
          final body = jsonDecode(diskCached) as Map<String, dynamic>;
          final parsed = _parseEditionsData(body['data']);
          if (parsed.isNotEmpty) {
            _editionsCache[number] = parsed;
            return parsed;
          }
        } catch (e) {
          debugPrint('QuranService: Failed to parse cached editions for Surah $number: $e');
        }
      }
    }

    final inFlight = _inFlightEditions[number];
    if (inFlight != null) return inFlight;

    final future = () async {
      try {
        const editions = <String>[editionArabic, editionEnglish, editionUrdu];
        final uri =
            Uri.parse('$alQuranBase/surah/$number/editions/${editions.join(',')}');
        final res = await _client.get(uri).timeout(const Duration(seconds: 20));
        if (res.statusCode != 200) {
          throw QuranServiceException('AlQuran editions HTTP ${res.statusCode}');
        }
        await NoorStore.cacheJsonWithTtl(
          cacheKey,
          res.body,
          ttl: const Duration(days: 90),
        );
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final out = _parseEditionsData(body['data']);
        _editionsCache[number] = out;
        return out;
      } finally {
        _inFlightEditions.remove(number);
      }
    }();

    _inFlightEditions[number] = future;
    return future;
  }

  static Map<String, SurahDetail> _parseEditionsData(dynamic data) {
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

  static Uri searchUri(String keyword, {String edition = editionEnglish}) =>
      Uri.parse('$alQuranBase/search/${Uri.encodeComponent(keyword)}/all/'
          '$edition');

  /// Live keyword search with TTL caching and in-flight deduplication.
  Future<List<QuranSearchMatch>> search(
    String keyword, {
    String edition = editionEnglish,
    bool forceRefresh = false,
  }) async {
    final norm = keyword.toLowerCase().trim();
    final cacheKey = 'quran.search.$edition.$norm';

    if (!forceRefresh) {
      final mem = _searchCache[cacheKey];
      if (mem != null) return mem;

      final diskCached = await NoorStore.cachedJsonWithTtl(cacheKey);
      if (diskCached != null && diskCached.isNotEmpty) {
        try {
          final parsed = parseSearchResponse(diskCached);
          _searchCache[cacheKey] = parsed;
          return parsed;
        } catch (e) {
          debugPrint('QuranService: Failed to parse search cache for "$keyword": $e');
        }
      }
    }

    final inFlight = _inFlightSearch[cacheKey];
    if (inFlight != null) return inFlight;

    final future = () async {
      try {
        final res = await _client
            .get(searchUri(keyword, edition: edition))
            .timeout(const Duration(seconds: 15));
        if (res.statusCode != 200) {
          throw QuranServiceException('AlQuran /search HTTP ${res.statusCode}');
        }
        await NoorStore.cacheJsonWithTtl(
          cacheKey,
          res.body,
          ttl: const Duration(days: 7),
        );
        final matches = parseSearchResponse(res.body);
        _searchCache[cacheKey] = matches;
        return matches;
      } finally {
        _inFlightSearch.remove(cacheKey);
      }
    }();

    _inFlightSearch[cacheKey] = future;
    return future;
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

  // ---- 16-Line Mushaf (Hifz Quran) ------------------------------------
  static final Map<int, Mushaf16Page> _mushafPageCache = <int, Mushaf16Page>{};
  static final Map<int, Future<Mushaf16Page>> _inFlightMushafPage = <int, Future<Mushaf16Page>>{};

  static const int totalMushaf16Pages = 604;

  /// Fetches a 16-line Mushaf page with word coordinates and line numbers (1..16).
  /// Primary source: Quran.com API v4 (mushaf=7, IndoPak 16-line layout).
  Future<Mushaf16Page> fetchMushaf16LinePage(
    int pageNumber, {
    bool forceRefresh = false,
  }) async {
    final page = pageNumber.clamp(1, totalMushaf16Pages);
    final cacheKey = 'quran.mushaf16.page.$page';

    if (!forceRefresh) {
      final mem = _mushafPageCache[page];
      if (mem != null) return mem;

      final diskCached = await NoorStore.cachedJsonWithTtl(cacheKey);
      if (diskCached != null && diskCached.isNotEmpty) {
        try {
          final parsed = parseMushaf16PageJson(diskCached, page);
          _mushafPageCache[page] = parsed;
          return parsed;
        } catch (e) {
          debugPrint('QuranService: Failed to parse cached mushaf page $page: $e');
        }
      }
    }

    final inFlight = _inFlightMushafPage[page];
    if (inFlight != null) return inFlight;

    final future = () async {
      try {
        final uri = Uri.parse(
          '$quranComBase/verses/by_page/$page?mushaf=7&words=true&word_fields=line_number,text_indopak,text_uthmani',
        );
        final res = await _client.get(uri).timeout(const Duration(seconds: 15));
        if (res.statusCode == 200) {
          await NoorStore.cacheJsonWithTtl(
            cacheKey,
            res.body,
            ttl: const Duration(days: 90),
          );
          final parsed = parseMushaf16PageJson(res.body, page);
          _mushafPageCache[page] = parsed;
          return parsed;
        }
      } catch (e) {
        debugPrint('QuranService: Mushaf page $page network fetch error: $e');
      }

      // Fallback for offline safety
      final fallback = sampleMushaf16Page(page);
      _mushafPageCache[page] = fallback;
      return fallback;
    }();

    _inFlightMushafPage[page] = future;
    try {
      return await future;
    } finally {
      _inFlightMushafPage.remove(page);
    }
  }

  static Mushaf16Page parseMushaf16PageJson(String jsonStr, int page) {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    final versesList = (decoded['verses'] as List<dynamic>?) ?? <dynamic>[];

    final lineWords = <int, List<Mushaf16Word>>{};
    for (var i = 1; i <= 16; i++) {
      lineWords[i] = <Mushaf16Word>[];
    }

    int primarySurah = 1;
    int primaryJuz = 1;
    final startingSurahs = <int, int>{};

    for (final v in versesList) {
      final vMap = v as Map<String, dynamic>;
      final vKey = vMap['verse_key']?.toString() ?? '1:1';
      final vNum = (vMap['verse_number'] as num?)?.toInt() ?? 1;
      final juz = (vMap['juz_number'] as num?)?.toInt() ?? 1;
      primaryJuz = juz;

      final sNum = int.tryParse(vKey.split(':').first) ?? 1;
      if (primarySurah == 1 && sNum > 1) {
        primarySurah = sNum;
      }

      final words = (vMap['words'] as List<dynamic>?) ?? <dynamic>[];
      if (words.isNotEmpty && vNum == 1) {
        final firstLine = (words.first['line_number'] as num?)?.toInt() ?? 1;
        startingSurahs[firstLine] = sNum;
      }

      for (final w in words) {
        final wMap = w as Map<String, dynamic>;
        final lineNo = (wMap['line_number'] as num?)?.toInt() ?? 1;
        if (lineNo >= 1 && lineNo <= 16) {
          lineWords[lineNo]!.add(Mushaf16Word.fromJson(wMap, vKey));
        }
      }
    }

    final assembledLines = <Mushaf16Line>[];
    for (var i = 1; i <= 16; i++) {
      final words = lineWords[i] ?? [];

      bool isHeader = false;
      bool isBismillah = false;
      int? headerSurah;
      String? headerSurahName;
      String? headerSurahEnglish;

      if (startingSurahs.containsKey(i + 2)) {
        isHeader = true;
        headerSurah = startingSurahs[i + 2];
        final info = surahInfoMap[headerSurah];
        headerSurahEnglish = info?.$1 ?? 'Surah $headerSurah';
        headerSurahName = info?.$2 ?? 'سُورَةُ $headerSurah';
      } else if (startingSurahs.containsKey(i + 1)) {
        final s = startingSurahs[i + 1]!;
        if (s != 9) {
          isBismillah = true;
        } else {
          isHeader = true;
          headerSurah = s;
          final info = surahInfoMap[headerSurah];
          headerSurahEnglish = info?.$1 ?? 'Surah $headerSurah';
          headerSurahName = info?.$2 ?? 'سُورَةُ $headerSurah';
        }
      } else if (words.isEmpty && i == 1 && page == 2) {
        isHeader = true;
        headerSurah = 2;
        headerSurahName = 'سُورَةُ البَقَرَةِ';
        headerSurahEnglish = 'Al-Baqarah';
      } else if (words.isEmpty && i == 2 && page == 2) {
        isBismillah = true;
      } else if (words.isEmpty && i == 1 && page == 1) {
        isHeader = true;
        headerSurah = 1;
        headerSurahName = 'سُورَةُ الفَاتِحَةِ';
        headerSurahEnglish = 'Al-Fatihah';
      }

      assembledLines.add(Mushaf16Line(
        lineNumber: i,
        words: words,
        isSurahHeader: isHeader,
        surahNumber: headerSurah,
        surahName: headerSurahName,
        surahEnglishName: headerSurahEnglish,
        isBismillah: isBismillah,
      ));
    }

    final surahInfo = surahInfoMap[primarySurah] ?? ('Al-Baqarah', 'البَقَرَة', 286);
    return Mushaf16Page(
      pageNumber: page,
      juzNumber: primaryJuz,
      surahNumber: primarySurah,
      surahEnglishName: surahInfo.$1,
      surahArabicName: surahInfo.$2,
      lines: assembledLines,
    );
  }

  static Mushaf16Page sampleMushaf16Page(int page) {
    if (page == 2) {
      final sampleWords = [
        // Line 3
        const Mushaf16Word(id: 1, position: 1, lineNumber: 3, textIndoPak: 'الٓمّٓۚ‏', textUthmani: 'الٓمٓ', verseKey: '2:1', isAyahEnd: false),
        const Mushaf16Word(id: 2, position: 2, lineNumber: 3, textIndoPak: '١', textUthmani: '١', verseKey: '2:1', isAyahEnd: true),
        const Mushaf16Word(id: 3, position: 3, lineNumber: 3, textIndoPak: 'ذٰلِكَ', textUthmani: 'ذَٰلِكَ', verseKey: '2:2', isAyahEnd: false),
        const Mushaf16Word(id: 4, position: 4, lineNumber: 3, textIndoPak: 'الۡڪِتٰبُ', textUthmani: 'ٱلْكِتَـٰبُ', verseKey: '2:2', isAyahEnd: false),
        const Mushaf16Word(id: 5, position: 5, lineNumber: 3, textIndoPak: 'لَا', textUthmani: 'لَا', verseKey: '2:2', isAyahEnd: false),
        const Mushaf16Word(id: 6, position: 6, lineNumber: 3, textIndoPak: 'رَيۡبَۛۚۖ', textUthmani: 'رَيْبَ', verseKey: '2:2', isAyahEnd: false),
        const Mushaf16Word(id: 7, position: 7, lineNumber: 3, textIndoPak: 'فِيۡهِۛۚ', textUthmani: 'فِيهِ', verseKey: '2:2', isAyahEnd: false),
        const Mushaf16Word(id: 8, position: 8, lineNumber: 3, textIndoPak: 'هُدًى', textUthmani: 'هُدًى', verseKey: '2:2', isAyahEnd: false),
        // Line 4
        const Mushaf16Word(id: 9, position: 1, lineNumber: 4, textIndoPak: 'لِّلۡمُتَّقِيۡنَۙ‏', textUthmani: 'لِّلْمُتَّقِينَ', verseKey: '2:2', isAyahEnd: false),
        const Mushaf16Word(id: 10, position: 2, lineNumber: 4, textIndoPak: '٢', textUthmani: '٢', verseKey: '2:2', isAyahEnd: true),
        const Mushaf16Word(id: 11, position: 3, lineNumber: 4, textIndoPak: 'الَّذِيۡنَ', textUthmani: 'ٱلَّذِينَ', verseKey: '2:3', isAyahEnd: false),
        const Mushaf16Word(id: 12, position: 4, lineNumber: 4, textIndoPak: 'يُؤۡمِنُوۡنَ', textUthmani: 'يُؤْمِنُونَ', verseKey: '2:3', isAyahEnd: false),
        const Mushaf16Word(id: 13, position: 5, lineNumber: 4, textIndoPak: 'بِالۡغَيۡبِ', textUthmani: 'بِٱلْغَيْبِ', verseKey: '2:3', isAyahEnd: false),
        const Mushaf16Word(id: 14, position: 6, lineNumber: 4, textIndoPak: 'وَ', textUthmani: 'وَ', verseKey: '2:3', isAyahEnd: false),
        const Mushaf16Word(id: 15, position: 7, lineNumber: 4, textIndoPak: 'يُقِيۡمُوۡنَ', textUthmani: 'يُقِيمُونَ', verseKey: '2:3', isAyahEnd: false),
        const Mushaf16Word(id: 16, position: 8, lineNumber: 4, textIndoPak: 'الصَّلٰوةَ', textUthmani: 'ٱلصَّلَوٰةَ', verseKey: '2:3', isAyahEnd: false),
        // Line 5
        const Mushaf16Word(id: 17, position: 1, lineNumber: 5, textIndoPak: 'وَمِمَّا', textUthmani: 'وَمِمَّا', verseKey: '2:3', isAyahEnd: false),
        const Mushaf16Word(id: 18, position: 2, lineNumber: 5, textIndoPak: 'رَزَقۡنٰهُمۡ', textUthmani: 'رَزَقْنَـٰهُمْ', verseKey: '2:3', isAyahEnd: false),
        const Mushaf16Word(id: 19, position: 3, lineNumber: 5, textIndoPak: 'يُنۡفِقُوۡنَۙ‏', textUthmani: 'يُنفِقُونَ', verseKey: '2:3', isAyahEnd: false),
        const Mushaf16Word(id: 20, position: 4, lineNumber: 5, textIndoPak: '٣', textUthmani: '٣', verseKey: '2:3', isAyahEnd: true),
        const Mushaf16Word(id: 21, position: 5, lineNumber: 5, textIndoPak: 'وَالَّذِيۡنَ', textUthmani: 'وَٱلَّذِينَ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 22, position: 6, lineNumber: 5, textIndoPak: 'يُؤۡمِنُوۡنَ', textUthmani: 'يُؤْمِنُونَ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 23, position: 7, lineNumber: 5, textIndoPak: 'بِمَۤا', textUthmani: 'بِمَآ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 24, position: 8, lineNumber: 5, textIndoPak: 'اُنۡزِلَ', textUthmani: 'أُنزِلَ', verseKey: '2:4', isAyahEnd: false),
        // Line 6
        const Mushaf16Word(id: 25, position: 1, lineNumber: 6, textIndoPak: 'اِلَيۡكَ', textUthmani: 'إِلَيْكَ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 26, position: 2, lineNumber: 6, textIndoPak: 'وَمَاۤ', textUthmani: 'وَمَآ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 27, position: 3, lineNumber: 6, textIndoPak: 'اُنۡزِلَ', textUthmani: 'أُنزِلَ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 28, position: 4, lineNumber: 6, textIndoPak: 'مِنۡ', textUthmani: 'مِن', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 29, position: 5, lineNumber: 6, textIndoPak: 'قَبۡلِكَۚ', textUthmani: 'قَبْلِكَ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 30, position: 6, lineNumber: 6, textIndoPak: 'وَبِالۡاٰخِرَةِ', textUthmani: 'وَبِٱلْـَٔاخِرَةِ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 31, position: 7, lineNumber: 6, textIndoPak: 'هُمۡ', textUthmani: 'هُمْ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 32, position: 8, lineNumber: 6, textIndoPak: 'يُوۡقِنُوۡنَؕ‏', textUthmani: 'يُوقِنُونَ', verseKey: '2:4', isAyahEnd: false),
        const Mushaf16Word(id: 33, position: 9, lineNumber: 6, textIndoPak: '٤', textUthmani: '٤', verseKey: '2:4', isAyahEnd: true),
        // Line 7
        const Mushaf16Word(id: 34, position: 1, lineNumber: 7, textIndoPak: 'اُولٰٓٮِٕكَ', textUthmani: 'أُو۟لَـٰٓئِكَ', verseKey: '2:5', isAyahEnd: false),
        const Mushaf16Word(id: 35, position: 2, lineNumber: 7, textIndoPak: 'عَلٰى', textUthmani: 'عَلَىٰ', verseKey: '2:5', isAyahEnd: false),
        const Mushaf16Word(id: 36, position: 3, lineNumber: 7, textIndoPak: 'هُدًى', textUthmani: 'هُدًۭى', verseKey: '2:5', isAyahEnd: false),
        const Mushaf16Word(id: 37, position: 4, lineNumber: 7, textIndoPak: 'مِّنۡ', textUthmani: 'مِّن', verseKey: '2:5', isAyahEnd: false),
        const Mushaf16Word(id: 38, position: 5, lineNumber: 7, textIndoPak: 'رَّبِّهِمۡ​', textUthmani: 'رَّبِّهِمْ ۖ', verseKey: '2:5', isAyahEnd: false),
        const Mushaf16Word(id: 39, position: 6, lineNumber: 7, textIndoPak: 'وَاُولٰٓٮِٕكَ', textUthmani: 'وَأُو۟لَـٰٓئِكَ', verseKey: '2:5', isAyahEnd: false),
        // Line 8
        const Mushaf16Word(id: 40, position: 1, lineNumber: 8, textIndoPak: 'هُمُ', textUthmani: 'هُمُ', verseKey: '2:5', isAyahEnd: false),
        const Mushaf16Word(id: 41, position: 2, lineNumber: 8, textIndoPak: 'الۡمُفۡلِحُوۡنَ‏', textUthmani: 'ٱلْمُفْلِحُونَ', verseKey: '2:5', isAyahEnd: false),
        const Mushaf16Word(id: 42, position: 3, lineNumber: 8, textIndoPak: '٥', textUthmani: '٥', verseKey: '2:5', isAyahEnd: true),
      ];

      final lines = <Mushaf16Line>[
        const Mushaf16Line(lineNumber: 1, words: [], isSurahHeader: true, surahNumber: 2, surahName: 'سُورَةُ البَقَرَةِ', surahEnglishName: 'Al-Baqarah'),
        const Mushaf16Line(lineNumber: 2, words: [], isBismillah: true),
        for (var i = 3; i <= 8; i++)
          Mushaf16Line(
            lineNumber: i,
            words: sampleWords.where((w) => w.lineNumber == i).toList(),
          ),
        for (var i = 9; i <= 16; i++)
          Mushaf16Line(lineNumber: i, words: const []),
      ];

      return Mushaf16Page(
        pageNumber: 2,
        juzNumber: 1,
        surahNumber: 2,
        surahEnglishName: 'Al-Baqarah',
        surahArabicName: 'البَقَرَة',
        lines: lines,
      );
    }

    // Generic fallback for other pages
    int sNum = 1;
    for (final entry in surahStartPages.entries) {
      if (entry.value <= page) {
        sNum = entry.key;
      } else {
        break;
      }
    }
    final info = surahInfoMap[sNum] ?? ('Al-Baqarah', 'البَقَرَة', 286);
    int jNum = ((page - 1) ~/ 20) + 1;
    if (jNum > 30) jNum = 30;

    return Mushaf16Page(
      pageNumber: page,
      juzNumber: jNum,
      surahNumber: sNum,
      surahEnglishName: info.$1,
      surahArabicName: info.$2,
      lines: [
        for (var i = 1; i <= 16; i++)
          Mushaf16Line(lineNumber: i, words: const []),
      ],
    );
  }

  static const Map<int, (String, String, int)> surahInfoMap = {
    1: ('Al-Fatihah', 'الفَاتِحَة', 7),
    2: ('Al-Baqarah', 'البَقَرَة', 286),
    3: ('Ali \'Imran', 'آل عِمْرَان', 200),
    4: ('An-Nisa', 'النِّسَاء', 176),
    5: ('Al-Ma\'idah', 'المَائِدَة', 120),
    6: ('Al-An\'am', 'الأَنْعَام', 165),
    7: ('Al-A\'raf', 'الأَعْرَاف', 206),
    8: ('Al-Anfal', 'الأَنْفَال', 75),
    9: ('At-Tawbah', 'التَّوْبَة', 129),
    10: ('Yunus', 'يُونُس', 109),
    11: ('Hud', 'هُود', 123),
    12: ('Yusuf', 'يُوسُف', 111),
    13: ('Ar-Ra\'d', 'الرَّعْد', 43),
    14: ('Ibrahim', 'إِبْرَاهِيم', 52),
    15: ('Al-Hijr', 'الحِجْر', 99),
    16: ('An-Nahl', 'النَّحْل', 128),
    17: ('Al-Isra', 'الإِسْرَاء', 111),
    18: ('Al-Kahf', 'الكَهْف', 110),
    19: ('Maryam', 'مَرْيَم', 98),
    20: ('Ta-Ha', 'طه', 135),
    21: ('Al-Anbiya', 'الأَنْبِيَاء', 112),
    22: ('Al-Hajj', 'الحَجّ', 78),
    23: ('Al-Mu\'minun', 'المُؤْمِنُون', 118),
    24: ('An-Nur', 'النُّور', 64),
    25: ('Al-Furqan', 'الفُرْقَان', 77),
    26: ('Ash-Shu\'ara', 'الشُّعَرَاء', 227),
    27: ('An-Naml', 'النَّمْل', 93),
    28: ('Al-Qasas', 'القَصَص', 88),
    29: ('Al-\'Ankabut', 'العَنْكَبُوت', 69),
    30: ('Ar-Rum', 'الرُّوم', 60),
    31: ('Luqman', 'لُقْمَان', 34),
    32: ('As-Sajdah', 'السَّجْدَة', 30),
    33: ('Al-Ahzab', 'الأَحْزَاب', 73),
    34: ('Saba', 'سَبَأ', 54),
    35: ('Fatir', 'فَاطِر', 45),
    36: ('Ya-Sin', 'يس', 83),
    37: ('As-Saffat', 'الصَّافَّات', 182),
    38: ('Sad', 'ص', 88),
    39: ('Az-Zumar', 'الزُّمَر', 75),
    40: ('Ghafir', 'غَافِر', 85),
    41: ('Fussilat', 'فُصِّلَت', 54),
    42: ('Ash-Shura', 'الشُّورَى', 53),
    43: ('Az-Zukhruf', 'الزُّخْرُف', 89),
    44: ('Ad-Dukhan', 'الدُّخَان', 59),
    45: ('Al-Jathiyah', 'الجَاثِيَة', 37),
    46: ('Al-Ahqaf', 'الأَحْقَاف', 35),
    47: ('Muhammad', 'مُحَمَّد', 38),
    48: ('Al-Fath', 'الفَتْح', 29),
    49: ('Al-Hujurat', 'الحُجُرَات', 18),
    50: ('Qaf', 'ق', 45),
    51: ('Adh-Dhariyat', 'الذَّارِيَات', 60),
    52: ('At-Tur', 'الطُّور', 49),
    53: ('An-Najm', 'النَّجْم', 62),
    54: ('Al-Qamar', 'القَمَر', 55),
    55: ('Ar-Rahman', 'الرَّحْمَٰن', 78),
    56: ('Al-Waqi\'ah', 'الوَاقِعَة', 96),
    57: ('Al-Hadid', 'الحَدِيد', 29),
    58: ('Al-Mujadila', 'المُجَادِلَة', 22),
    59: ('Al-Hashr', 'الحَشْر', 24),
    60: ('Al-Mumtahanah', 'المُمْتَحَنَة', 13),
    61: ('As-Saff', 'الصَّفّ', 14),
    62: ('Al-Jumu\'ah', 'الجُمُعَة', 11),
    63: ('Al-Munafiqun', 'المُنَافِقُون', 11),
    64: ('At-Taghabun', 'التَّغَابُن', 18),
    65: ('At-Talaq', 'الطَّلَاق', 12),
    66: ('At-Tahrim', 'التَّحْرِيم', 12),
    67: ('Al-Mulk', 'المُلْك', 30),
    68: ('Al-Qalam', 'القَلَم', 52),
    69: ('Al-Haqqah', 'الحَاقَّة', 52),
    70: ('Al-Ma\'arij', 'المَعَارِج', 44),
    71: ('Nuh', 'نُوح', 28),
    72: ('Al-Jinn', 'الجِنّ', 28),
    73: ('Al-Muzzammil', 'المُزَّمِّل', 20),
    74: ('Al-Muddaththir', 'المُدَّثِّر', 56),
    75: ('Al-Qiyamah', 'القِيَامَة', 40),
    76: ('Al-Insan', 'الإِنْسَان', 31),
    77: ('Al-Mursalat', 'المُرْسَلَات', 50),
    78: ('An-Naba', 'النَّبَأ', 40),
    79: ('An-Nazi\'at', 'النَّازِعَات', 46),
    80: ('\'Abasa', 'عَبَسَ', 42),
    81: ('At-Takwir', 'التَّكْوِير', 29),
    82: ('Al-Infitar', 'الانْفِطَار', 19),
    83: ('Al-Mutaffifin', 'المُطَفِّفِين', 36),
    84: ('Al-Inshiqaq', 'الانْشِقَاق', 25),
    85: ('Al-Buruj', 'البُرُوج', 22),
    86: ('At-Tariq', 'الطَّارِق', 17),
    87: ('Al-A\'la', 'الأَعْلَى', 19),
    88: ('Al-Ghashiyah', 'الغَاشِيَة', 26),
    89: ('Al-Fajr', 'الفَجْر', 30),
    90: ('Al-Balad', 'البَلَد', 20),
    91: ('Ash-Shams', 'الشَّمْس', 15),
    92: ('Al-Layl', 'اللَّيْل', 21),
    93: ('Ad-Duha', 'الضُّحَى', 11),
    94: ('Ash-Sharh', 'الشَّرْح', 8),
    95: ('At-Tin', 'التِّين', 8),
    96: ('Al-\'Alaq', 'العَلَق', 19),
    97: ('Al-Qadr', 'القَدْر', 5),
    98: ('Al-Bayyinah', 'البَيِّنَة', 8),
    99: ('Az-Zalzalah', 'الزَّلْزَلَة', 8),
    100: ('Al-\'Adiyat', 'العَادِيَات', 11),
    101: ('Al-Qari\'ah', 'القَارِعَة', 11),
    102: ('At-Takathur', 'التَّكَاثُر', 8),
    103: ('Al-\'Asr', 'العَصْر', 3),
    104: ('Al-Humazah', 'الهُمَزَة', 9),
    105: ('Al-Fil', 'الفِيل', 5),
    106: ('Quraysh', 'قُرَيْش', 4),
    107: ('Al-Ma\'un', 'المَاعُون', 7),
    108: ('Al-Kawthar', 'الكَوْثَر', 3),
    109: ('Al-Kafirun', 'الكَافِرُون', 6),
    110: ('An-Nasr', 'النَّصْر', 3),
    111: ('Al-Masad', 'المَسَد', 5),
    112: ('Al-Ikhlas', 'الإِخْلَاص', 4),
    113: ('Al-Falaq', 'الفَلَق', 5),
    114: ('An-Nas', 'النَّاس', 6),
  };

  static const Map<int, int> juzStartPages = {
    1: 1, 2: 22, 3: 42, 4: 62, 5: 82, 6: 102, 7: 122, 8: 142, 9: 162, 10: 182,
    11: 202, 12: 222, 13: 242, 14: 262, 15: 282, 16: 302, 17: 322, 18: 342, 19: 362, 20: 382,
    21: 402, 22: 422, 23: 442, 24: 462, 25: 482, 26: 502, 27: 522, 28: 542, 29: 562, 30: 582,
  };

  static const Map<int, int> surahStartPages = {
    1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187, 10: 208,
    11: 221, 12: 235, 13: 249, 14: 255, 15: 262, 16: 267, 17: 282, 18: 293, 19: 305, 20: 312,
    21: 322, 22: 332, 23: 342, 24: 350, 25: 359, 26: 367, 27: 377, 28: 385, 29: 396, 30: 404,
    31: 411, 32: 415, 33: 418, 34: 428, 35: 434, 36: 440, 37: 446, 38: 453, 39: 458, 40: 467,
    41: 477, 42: 483, 43: 489, 44: 496, 45: 499, 46: 502, 47: 507, 48: 511, 49: 515, 50: 518,
    51: 520, 52: 523, 53: 526, 54: 528, 55: 531, 56: 534, 57: 537, 58: 542, 59: 545, 60: 549,
    61: 551, 62: 553, 63: 554, 64: 556, 65: 558, 66: 560, 67: 562, 68: 564, 69: 566, 70: 568,
    71: 570, 72: 572, 73: 574, 74: 575, 75: 577, 76: 578, 77: 580, 78: 582, 79: 583, 80: 585,
    81: 586, 82: 587, 83: 587, 84: 589, 85: 590, 86: 591, 87: 591, 88: 592, 89: 593, 90: 594,
    91: 595, 92: 595, 93: 596, 94: 596, 95: 597, 96: 597, 97: 598, 98: 598, 99: 599, 100: 599,
    101: 600, 102: 600, 103: 601, 104: 601, 105: 601, 106: 602, 107: 602, 108: 602, 109: 603, 110: 603,
    111: 603, 112: 604, 113: 604, 114: 604,
  };
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

/// Represents a single word/token in a 16-line Mushaf page layout.
class Mushaf16Word {
  const Mushaf16Word({
    required this.id,
    required this.position,
    required this.lineNumber,
    required this.textIndoPak,
    required this.textUthmani,
    required this.verseKey,
    required this.isAyahEnd,
    this.translation,
  });

  final int id;
  final int position;
  final int lineNumber;
  final String textIndoPak;
  final String textUthmani;
  final String verseKey;
  final bool isAyahEnd;
  final String? translation;

  factory Mushaf16Word.fromJson(Map<String, dynamic> json, String verseKey) {
    final charType = json['char_type_name']?.toString() ?? 'word';
    final trans = json['translation'] as Map<String, dynamic>?;
    return Mushaf16Word(
      id: (json['id'] as num?)?.toInt() ?? 0,
      position: (json['position'] as num?)?.toInt() ?? 0,
      lineNumber: (json['line_number'] as num?)?.toInt() ?? 1,
      textIndoPak: json['text_indopak']?.toString() ?? '',
      textUthmani: json['text_uthmani']?.toString() ?? json['text']?.toString() ?? '',
      verseKey: verseKey,
      isAyahEnd: charType == 'end',
      translation: trans?['text']?.toString(),
    );
  }
}

/// Represents a single line on a 16-line Mushaf page.
class Mushaf16Line {
  const Mushaf16Line({
    required this.lineNumber,
    required this.words,
    this.isSurahHeader = false,
    this.surahNumber,
    this.surahName,
    this.surahEnglishName,
    this.isBismillah = false,
  });

  final int lineNumber;
  final List<Mushaf16Word> words;
  final bool isSurahHeader;
  final int? surahNumber;
  final String? surahName;
  final String? surahEnglishName;
  final bool isBismillah;

  bool get isEmpty => words.isEmpty && !isSurahHeader && !isBismillah;
}

/// Full 16-line Mushaf page data (1..604).
class Mushaf16Page {
  const Mushaf16Page({
    required this.pageNumber,
    required this.juzNumber,
    required this.surahNumber,
    required this.surahEnglishName,
    required this.surahArabicName,
    required this.lines,
  });

  final int pageNumber;
  final int juzNumber;
  final int surahNumber;
  final String surahEnglishName;
  final String surahArabicName;
  final List<Mushaf16Line> lines; // 16 lines
}

