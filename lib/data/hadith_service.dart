import 'dart:async';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'file_cache_store.dart';
import 'noor_store.dart';

/// Phase 16 (Job 4) — FULL hadith databank: all six canonical books,
/// complete, not half. One-fetch-per-edition over the free
/// fawazahmed0 hadith-api CDN (jsdelivr mirror, no API key):
///
///   GET https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/{edition}.min.json
///
/// Verified shapes (live curl, 2026-10-13 — never invent fields):
/// * `/editions.json` -> 200, map book -> {name, collection[]}; books:
///   bukhari, muslim, abudawud, tirmidhi, nasai, ibnmajah (each ships
///   ara-<book>, ara-<book>1, eng-<book>, urd-<book>). Extra books
///   (dehlawi, malik, nawawi, qudsi) exist but are OUT of scope here.
/// * `/editions/{edition}.min.json` -> 200:
///   {"metadata": {"name": "...", "sections": {"0":"", "1":"Revelation",
///   ...}}, "hadiths": [{"hadithnumber":1, "arabicnumber":1, "text":"...",
///   "grades":[], "reference":{"book":1,"hadith":1}}, ...]}
///   `reference.book` = SECTION number, `reference.hadith` = hadith
///   number within that section; `hadithnumber` = sequential global
///   number. eng-bukhari carries 7,589 hadiths (~4.8 MB JSON).
/// * Do NOT use per-section `{n}.json` for the main fetch, and do NOT
///   use `.../sections.json` (returns empty) or `.../chapters.json`
///   (404) — the `.min.json` per edition is the one-fetch pattern.
///
/// RULE (same as Qur'an): full text is runtime-only — fetched at
/// runtime, held in memory and in a compressed on-device cache.
/// Nothing but brief attributed excerpts is embedded in code.
///
/// Search design (documented honestly):
/// * Live book/chapter browsing works for ALL six books (chapters =
///   `metadata.sections`, full hadith text per chapter).
/// * "Find a hadith on X" runs over the curated offline topic index
///   (knowledge_search.dart); its entries now carry real
///   book/section numbers into this databank (see
///   [KnowledgeSearchService.hadithBookIdFor]).
/// * Per-section full-text scan is supported locally via
///   [HadithBook.searchInSection] when a book+section is open.
/// * Full cross-book live keyword search = v2 (needs a server-side
///   index — fetching six multi-MB editions per query would be
///   wasteful on a phone).
class HadithService {
  HadithService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String cdnBase =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';

  /// Primary CDN with fallback mirrors in case jsDelivr is blocked, throttled, or times out.
  static const List<String> cdnMirrors = [
    'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1',
    'https://raw.githubusercontent.com/fawazahmed0/hadith-api/1',
    'https://gcore.jsdelivr.net/gh/fawazahmed0/hadith-api@1',
  ];

  /// The six canonical books. Display names match the user's design.
  static const List<HadithBookMeta> books = <HadithBookMeta>[
    HadithBookMeta(
        id: 'bukhari',
        name: 'Sahih al-Bukhari',
        author: 'Imam Muhammad ibn Ismail Al-Bukhari'),
    HadithBookMeta(
        id: 'muslim',
        name: 'Sahih Muslim',
        author: 'Imam Muslim ibn Al-Hajjaj'),
    HadithBookMeta(
        id: 'abudawud',
        name: 'Sunan Abu Dawud',
        author: 'Imam Abu Dawud'),
    HadithBookMeta(
        id: 'tirmidhi',
        name: "Jami' At Tirmidhi",
        author: 'Imam Muhammad At-Tirmidhi'),
    HadithBookMeta(
        id: 'nasai', name: 'Sunan An-Nasai', author: 'Imam An-Nasai'),
    HadithBookMeta(
        id: 'ibnmajah',
        name: 'Sunan Ibn Majah',
        author: 'Imam Ibn Majah'),
  ];

  static String bookName(String bookId) => books
      .firstWhere((b) => b.id == bookId,
          orElse: () => HadithBookMeta(id: bookId, name: bookId, author: ''))
      .name;

  /// Approximate maximum sequential Hadith numbers for each canonical book.
  static const Map<String, int> bookMaxHadiths = {
    'bukhari': 7563,
    'muslim': 4301,
    'abudawud': 4803,
    'tirmidhi': 3956,
    'nasai': 5578,
    'ibnmajah': 4341,
  };

  /// Find a hadith entry by its exact number in a canonical book.
  Future<({HadithBook book, HadithEntry entry})?> findByNumber(
    String bookId,
    int hadithNumber, {
    HadithLanguage language = HadithLanguage.eng,
  }) async {
    final book = await fetchEdition(bookId, language: language);
    final entry = book.entryByNumber(hadithNumber);
    if (entry != null) {
      return (book: book, entry: entry);
    }
    return null;
  }

  /// True once a network fetch succeeded in this session, false
  /// after a network failure. Screens show "Live databank" vs an
  /// honest offline banner based on this.
  bool get hasLive => _hasLive;
  bool _hasLive = false;

  final Map<String, HadithBook> _memory = <String, HadithBook>{};
  final Map<String, Future<HadithBook>> _inFlightEditions = <String, Future<HadithBook>>{};

  static String editionId(String bookId, HadithLanguage language) =>
      '${language.prefix}-$bookId';

  static String _cacheKey(String edition) => 'hadith.edition.$edition';

  /// Lightweight live check: the editions manifest (~30 KB, one
  /// round-trip). Sets [hasLive]; never throws. The library screen
  /// uses this to label "Live databank" vs offline honestly before
  /// any multi-MB edition is fetched.
  Future<bool> checkLive() async {
    for (final base in cdnMirrors) {
      try {
        final res = await _client
            .get(
              Uri.parse('$base/editions.json'),
              headers: const {'Accept': 'application/json', 'User-Agent': 'NoorApp/1.0'},
            )
            .timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          _hasLive = true;
          return true;
        }
      } catch (e) {
        debugPrint('HadithService: Mirror check failed for $base: $e');
      }
    }
    _hasLive = false;
    return false;
  }

  /// One edition of one book (e.g. fetchEdition('bukhari')).
  /// Order: memory -> compressed disk cache -> network (with
  /// multi-mirror fallback and 25s timeout) with single-flight request coalescing.
  Future<HadithBook> fetchEdition(
    String bookId, {
    HadithLanguage language = HadithLanguage.eng,
    bool forceRefresh = false,
  }) async {
    final edition = editionId(bookId, language);
    if (!forceRefresh) {
      final mem = _memory[edition];
      if (mem != null) return mem;
      final disk = await _readDiskCache(edition);
      if (disk != null) {
        _memory[edition] = disk;
        return disk;
      }
    }

    final inFlight = _inFlightEditions[edition];
    if (inFlight != null) return inFlight;

    final future = () async {
      try {
        String? body;
        Object? lastError;
        for (final base in cdnMirrors) {
          try {
            final uri = Uri.parse('$base/editions/$edition.min.json');
            final res = await _client.get(
              uri,
              headers: const {
                'Accept': 'application/json',
                'User-Agent': 'NoorApp/1.0',
              },
            ).timeout(const Duration(seconds: 25));
            if (res.statusCode == 200 && res.body.isNotEmpty) {
              body = res.body;
              break;
            } else if (res.statusCode != 200) {
              lastError = HadithServiceException('Hadith CDN HTTP ${res.statusCode}');
            }
          } catch (e) {
            lastError = e;
          }
        }

        if (body == null) {
          final disk = await _readDiskCache(edition);
          if (disk != null) {
            _hasLive = false;
            _memory[edition] = disk;
            return disk;
          }
          _hasLive = false;
          if (lastError is HadithServiceException) throw lastError;
          throw HadithServiceException(
              lastError is TimeoutException
                  ? 'Connection timed out while loading $edition'
                  : 'Unable to load Hadith databank ($edition). Please check connection.');
        }

        _hasLive = true;
        final book = parseEditionJson(body,
            bookId: bookId, language: language);
        _memory[edition] = book;
        unawaited(_writeDiskCache(edition, body));
        return book;
      } finally {
        _inFlightEditions.remove(edition);
      }
    }();

    _inFlightEditions[edition] = future;
    return future;
  }

  /// Memory- or disk-cached edition only; null when never fetched.
  /// Never throws.
  Future<HadithBook?> cachedEdition(
    String bookId, {
    HadithLanguage language = HadithLanguage.eng,
  }) async {
    final edition = editionId(bookId, language);
    final mem = _memory[edition];
    if (mem != null) return mem;
    try {
      final disk = await _readDiskCache(edition);
      if (disk != null) _memory[edition] = disk;
      return disk;
    } catch (e) {
      debugPrint('HadithService: getOrFetchDisk error for $edition: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    _memory.clear();
    _inFlightEditions.clear();
    for (final b in books) {
      for (final l in HadithLanguage.values) {
        final key = _cacheKey(editionId(b.id, l));
        await FileCacheStore.delete(key);
        await NoorStore.cacheJson(key, '');
      }
    }
  }

  /// Phase 6D: Dedicated file cache for large Hadith books (decoupled from SharedPreferences).
  /// GZip compressed bytes written directly to app file storage.
  Future<void> _writeDiskCache(String edition, String body) async {
    try {
      final bytes = utf8.encode(body);
      final zipped = const GZipEncoder().encode(bytes);
      await FileCacheStore.writeBytes(_cacheKey(edition), zipped);
    } catch (e) {
      debugPrint('HadithService: Failed to write disk cache for $edition: $e');
    }
  }

  Future<HadithBook?> _readDiskCache(String edition) async {
    try {
      final zipped = await FileCacheStore.readBytes(_cacheKey(edition));
      if (zipped == null || zipped.isEmpty) {
        // Automatic migration check from legacy SharedPreferences cache
        final legacy = await NoorStore.cachedJson(_cacheKey(edition));
        if (legacy == null || legacy.isEmpty) return null;
        final legacyZipped = base64Decode(legacy);
        final bytes = const GZipDecoder().decodeBytes(legacyZipped);
        await FileCacheStore.writeBytes(_cacheKey(edition), legacyZipped);
        await NoorStore.cacheJson(_cacheKey(edition), '');
        return parseEditionJson(utf8.decode(bytes),
            bookId: _bookIdForEdition(edition), language: _langForEdition(edition));
      }
      final bytes = const GZipDecoder().decodeBytes(zipped);
      return parseEditionJson(utf8.decode(bytes),
          bookId: _bookIdForEdition(edition), language: _langForEdition(edition));
    } catch (e) {
      debugPrint('HadithService: Failed to read disk cache for $edition: $e');
      return null;
    }
  }

  static String _bookIdForEdition(String edition) {
    for (final b in books) {
      if (edition.endsWith('-${b.id}')) return b.id;
    }
    return edition;
  }

  static HadithLanguage _langForEdition(String edition) {
    for (final l in HadithLanguage.values) {
      if (edition.startsWith('${l.prefix}-')) return l;
    }
    return HadithLanguage.eng;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is num) return val.toInt();
    if (val is String) {
      final s = val.trim();
      final parsedInt = int.tryParse(s);
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(s);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return 0;
  }

  // ---- Parsing (pure, fully unit-testable) ---------------------------

  /// Parses the verified `.min.json` shape. Section "0" has an
  /// empty title in the source — it still carries hadiths
  /// (311 in eng-bukhari), so it is shown as "General". Entries
  /// with no text are skipped (they cannot be displayed or
  /// searched). Every returned entry has a non-empty `hadithnumber`
  /// and `text`; references are always built from the response's
  /// own numbers — never fabricated.
  static HadithBook parseEditionJson(
    String body, {
    required String bookId,
    required HadithLanguage language,
  }) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final metadata = (decoded['metadata'] as Map<String, dynamic>?) ?? const {};
    final sectionsRaw =
        (metadata['sections'] as Map<String, dynamic>?) ?? const {};
    final rawHadiths = (decoded['hadiths'] as List<dynamic>?) ?? <dynamic>[];

    final hadiths = <HadithEntry>[];
    final counts = <int, int>{};
    for (final e in rawHadiths) {
      if (e is! Map<String, dynamic>) continue;
      final m = e;
      final text = (m['text'] as String?)?.trim() ?? '';
      if (text.isEmpty) continue; // no text -> not displayable
      final ref = (m['reference'] as Map<String, dynamic>?) ?? const {};
      final sectionNumber = _parseInt(ref['book']);
      final hadithnumber = _parseInt(m['hadithnumber']);
      if (hadithnumber <= 0) continue; // never fabricate numbers

      final entry = HadithEntry(
        hadithnumber: hadithnumber,
        arabicnumber: _parseInt(m['arabicnumber']),
        text: text,
        grades: _parseGrades(m['grades']),
        sectionNumber: sectionNumber,
        hadithInSection: _parseInt(ref['hadith']),
      );
      hadiths.add(entry);
      counts[sectionNumber] = (counts[sectionNumber] ?? 0) + 1;
    }

    final sections = <HadithSection>[];
    final allNumbers = <int>{
      ...sectionsRaw.keys.map((k) => int.tryParse(k)).whereType<int>(),
      ...counts.keys,
    }.toList()..sort();

    for (final n in allNumbers) {
      final title = sectionsRaw['$n']?.toString().trim() ?? '';
      final count = counts[n] ?? 0;
      if (count == 0 && title.isEmpty) continue; // empty, unused slot
      sections.add(HadithSection(
        number: n,
        title: title.isEmpty ? (n == 0 ? 'General' : 'Chapter $n') : title,
        count: count,
      ));
    }

    if (sections.isEmpty && hadiths.isNotEmpty) {
      sections.add(HadithSection(
        number: 0,
        title: 'All Hadiths',
        count: hadiths.length,
      ));
    }
    return HadithBook(
      id: bookId,
      name: bookName(bookId),
      edition: editionId(bookId, language),
      language: language,
      sections: sections,
      hadiths: hadiths,
    );
  }

  static List<String> _parseGrades(dynamic raw) {
    if (raw is! List) return const [];
    final out = <String>[];
    for (final g in raw) {
      if (g is Map) {
        final name = g['name']?.toString() ?? '';
        final grade = g['grade']?.toString() ?? '';
        final label =
            [name, grade].where((s) => s.isNotEmpty).join(': ');
        if (label.isNotEmpty) out.add(label);
      } else if (g != null) {
        out.add(g.toString());
      }
    }
    return out;
  }

  /// Bookmark id shape for a databank entry (persisted in NoorStore).
  static String bookmarkId(String edition, int hadithnumber) =>
      'hadith:$edition:$hadithnumber';
}

/// Edition language. Prefixes match the CDN naming exactly
/// (ara-/eng-/urd-<book>).
enum HadithLanguage {
  ara('ara', 'العربية'),
  eng('eng', 'English'),
  urd('urd', 'اردو');

  const HadithLanguage(this.prefix, this.label);
  final String prefix;
  final String label;
}

class HadithBookMeta {
  const HadithBookMeta({
    required this.id,
    required this.name,
    required this.author,
  });
  final String id;
  final String name;
  final String author;
}

class HadithSection {
  const HadithSection({
    required this.number,
    required this.title,
    required this.count,
  });
  final int number;
  final String title;

  /// Number of displayable hadiths in this section.
  final int count;
}

class HadithEntry {
  const HadithEntry({
    required this.hadithnumber,
    required this.arabicnumber,
    required this.text,
    required this.grades,
    required this.sectionNumber,
    required this.hadithInSection,
  });

  /// Sequential global number from the databank response — always
  /// data-derived, never fabricated (see [HadithServiceException]).
  final int hadithnumber;
  final int arabicnumber;

  /// Full text — runtime-only from the CDN, never embedded in code.
  final String text;
  final List<String> grades;

  /// From the response's `reference.book` (= section number).
  final int sectionNumber;

  /// From the response's `reference.hadith` (number within section).
  final int hadithInSection;
}

/// One fetched edition of one book: sections + all entries, with
/// section-aware lookups. Text fields hold CDN content only in
/// memory; they are never written into source code.
class HadithBook {
  const HadithBook({
    required this.id,
    required this.name,
    required this.edition,
    required this.language,
    required this.sections,
    required this.hadiths,
  });

  final String id;
  final String name;
  final String edition;
  final HadithLanguage language;
  final List<HadithSection> sections;
  final List<HadithEntry> hadiths;

  /// Section title for an entry (via `reference.book`).
  HadithSection sectionOf(HadithEntry entry) => sections.firstWhere(
        (s) => s.number == entry.sectionNumber,
        orElse: () => HadithSection(
            number: entry.sectionNumber,
            title: entry.sectionNumber == 0 ? 'General' : 'Chapter',
            count: 0),
      );

  /// All entries in one section, in databank order.
  List<HadithEntry> hadithsInSection(int sectionNumber) =>
      hadiths.where((h) => h.sectionNumber == sectionNumber).toList();

  HadithEntry? entryByNumber(int hadithnumber) {
    for (final h in hadiths) {
      if (h.hadithnumber == hadithnumber) return h;
    }
    return null;
  }

  /// Per-section full-text scan (case-insensitive). Scoped to ONE
  /// section deliberately — full cross-book live search is a v2
  /// (needs a server-side index).
  List<HadithEntry> searchInSection(int sectionNumber, String keyword) {
    final q = keyword.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return hadithsInSection(sectionNumber)
        .where((h) => h.text.toLowerCase().contains(q))
        .toList();
  }
}

class HadithServiceException implements Exception {
  HadithServiceException(this.message);
  final String message;
  @override
  String toString() => 'HadithServiceException: $message';
}
