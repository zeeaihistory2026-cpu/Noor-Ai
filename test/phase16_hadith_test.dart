import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:noor_ai_companion/data/hadith_service.dart';
import 'package:noor_ai_companion/data/knowledge_search.dart';

/// Phase 16 (Job 4) — full hadith databank tests.
///
/// Shapes below mirror the VERIFIED CDN responses (live curl,
/// 2026-10-13) in miniature: the `.min.json` top-level shape
/// (metadata.name, metadata.sections, hadiths[]) and the entry
/// shape ({hadithnumber, arabicnumber, text, grades,
/// reference:{book, hadith}}). Brief excerpts only — no
/// substantial text is embedded in this file.
///
/// Key invariants asserted:
/// * section titles parse from metadata.sections; section "0"
///   (empty title in the source) is labelled "General" and still
///   carries its hadiths;
/// * `reference.book` routes an entry to its section (sectionOf);
/// * every parsed entry has a non-empty data-derived hadithnumber —
///   references are never fabricated;
/// * network failure falls back without throwing raw (the fake
///   client returns HTTP 500 and the service surfaces
///   HadithServiceException; the curated offline index still
///   answers);
/// * curated topic entries deep-link into real databank ids
///   (collection -> book id mapping).

/// Miniature recorded shape of
/// /editions/eng-bukhari.min.json (two sections, three entries —
/// one with empty text, which the parser must skip).
const _minJsonSample = '''
{
  "metadata": {
    "name": "Sahih al Bukhari",
    "sections": {
      "0": "",
      "1": "Revelation",
      "2": "Belief"
    }
  },
  "hadiths": [
    {
      "hadithnumber": 1,
      "arabicnumber": 1,
      "text": "Sample translation text one.",
      "grades": [],
      "reference": {"book": 1, "hadith": 1}
    },
    {
      "hadithnumber": 2,
      "arabicnumber": 2,
      "text": "Sample translation text two.",
      "grades": [{"name": "Darussalam", "grade": "Sahih"}],
      "reference": {"book": 2, "hadith": 1}
    },
    {
      "hadithnumber": 3,
      "arabicnumber": 3,
      "text": "",
      "grades": [],
      "reference": {"book": 0, "hadith": 1}
    },
    {
      "hadithnumber": 4,
      "arabicnumber": 4,
      "text": "Sample translation text four.",
      "grades": [],
      "reference": {"book": 0, "hadith": 2}
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HadithService book list', () {
    test('six complete books with display names and edition ids', () {
      expect(HadithService.books.length, 6);
      final ids = HadithService.books.map((b) => b.id).toList();
      expect(ids,
          ['bukhari', 'muslim', 'abudawud', 'tirmidhi', 'nasai', 'ibnmajah']);
      expect(HadithService.bookName('bukhari'), 'Sahih al-Bukhari');
      expect(HadithService.bookName('tirmidhi'), "Jami' At Tirmidhi");
      expect(HadithService.editionId('bukhari', HadithLanguage.eng),
          'eng-bukhari');
      expect(HadithService.editionId('muslim', HadithLanguage.ara),
          'ara-muslim');
      expect(
          HadithService.editionId('ibnmajah', HadithLanguage.urd), 'urd-ibnmajah');
      expect(HadithLanguage.values.map((l) => l.prefix).toSet(),
          {'ara', 'eng', 'urd'});
    });

    test('bookMaxHadiths defines valid upper bounds for all six canonical books', () {
      for (final book in HadithService.books) {
        final maxH = HadithService.bookMaxHadiths[book.id];
        expect(maxH, isNotNull, reason: 'Book ${book.id} must have a max Hadith count');
        expect(maxH!, greaterThan(1000));
      }
      expect(HadithService.bookMaxHadiths['bukhari'], 7563);
      expect(HadithService.bookMaxHadiths['muslim'], 4301);
    });
  });

  group('parseEditionJson (verified .min.json shape)', () {
    late HadithBook book;
    setUp(() {
      book = HadithService.parseEditionJson(_minJsonSample,
          bookId: 'bukhari', language: HadithLanguage.eng);
    });

    test('sections parse from metadata.sections', () {
      expect(book.sections.map((s) => s.title),
          ['General', 'Revelation', 'Belief']);
      expect(book.sections.map((s) => s.number), [0, 1, 2]);
    });

    test('empty-title section 0 becomes "General" and keeps hadiths', () {
      final general = book.sections.firstWhere((s) => s.number == 0);
      expect(general.title, 'General');
      expect(general.count, 1);
    });

    test('entries with empty text are skipped', () {
      expect(book.hadiths.length, 3);
      expect(book.hadiths.every((h) => h.text.isNotEmpty), isTrue);
    });

    test('hadithnumber is non-empty and data-derived (never fabricated)', () {
      expect(book.hadiths.map((h) => h.hadithnumber), [1, 2, 4]);
      expect(book.hadiths.every((h) => h.hadithnumber > 0), isTrue);
    });

    test('reference.book routes entries to sections', () {
      final first = book.entryByNumber(1)!;
      expect(first.sectionNumber, 1);
      expect(first.hadithInSection, 1);
      expect(book.sectionOf(first).title, 'Revelation');

      final fourth = book.entryByNumber(4)!;
      expect(fourth.sectionNumber, 0);
      expect(book.sectionOf(fourth).title, 'General');
    });

    test('hadithsInSection and per-section search scan', () {
      expect(book.hadithsInSection(1).length, 1);
      expect(book.hadithsInSection(2).length, 1);
      final hits = book.searchInSection(1, 'translation text one');
      expect(hits.length, 1);
      expect(hits.first.hadithnumber, 1);
      // Case-insensitive; empty query returns nothing.
      expect(book.searchInSection(1, 'TRANSLATION').length, 1);
      expect(book.searchInSection(1, ''), isEmpty);
      expect(book.searchInSection(1, 'no such words here'), isEmpty);
    });

    test('grades parse when present', () {
      expect(book.entryByNumber(2)!.grades, ['Darussalam: Sahih']);
      expect(book.entryByNumber(1)!.grades, isEmpty);
    });

    test('bookmark id shape', () {
      expect(HadithService.bookmarkId('eng-bukhari', 1),
          'hadith:eng-bukhari:1');
    });
  });

  group('fetchEdition fallback', () {
    test('HTTP failure -> HadithServiceException (curated index is the path)',
        () async {
      final client = MockClient((_) async =>
          http.Response('boom', 500, headers: {'content-type': 'text/plain'}));
      final svc = HadithService(client: client);
      expect(svc.hasLive, isFalse);
      await expectLater(
          svc.fetchEdition('bukhari'), throwsA(isA<HadithServiceException>()));
      expect(svc.hasLive, isFalse);
    });

    test('HTTP 200 populates the book and sets hasLive', () async {
      final client = MockClient((_) async => http.Response(
          _minJsonSample, 200,
          headers: {'content-type': 'application/json'}));
      final svc = HadithService(client: client);
      final book = await svc.fetchEdition('bukhari');
      expect(svc.hasLive, isTrue);
      expect(book.hadiths.length, 3);
      expect(book.edition, 'eng-bukhari');
    });

    test('findByNumber locates hadith accurately in cached edition', () async {
      final client = MockClient((_) async => http.Response(
          _minJsonSample, 200,
          headers: {'content-type': 'application/json'}));
      final svc = HadithService(client: client);

      // Locate hadith 2
      final match = await svc.findByNumber('bukhari', 2);
      expect(match, isNotNull);
      expect(match!.entry.hadithnumber, 2);
      expect(match.entry.text, contains('Sample translation text two'));
      expect(match.book.id, 'bukhari');

      // Out of bounds hadith returns null
      final missing = await svc.findByNumber('bukhari', 9999);
      expect(missing, isNull);
    });
  });

  group('curated index deep-links into real databank ids', () {
    test('collection names map to live book ids', () {
      expect(hadithBookIdFor('Sahih al-Bukhari'), 'bukhari');
      expect(hadithBookIdFor('Sahih Muslim'), 'muslim');
      expect(hadithBookIdFor('Jami` at-Tirmidhi'), 'tirmidhi');
      expect(hadithBookIdFor('Sunan Ibn Majah'), 'ibnmajah');
      expect(hadithBookIdFor(null), isNull);
      expect(hadithBookIdFor('Some Unknown Book'), isNull);
    });

    test('offline topic results carry databank-linkable refs', () {
      final svc = KnowledgeSearchService();
      final res = svc.searchOffline('find a hadith on patience');
      final hadith =
          res.results.where((r) => r.kind == KnowledgeKind.hadith);
      expect(hadith, isNotEmpty);
      for (final r in hadith) {
        // Every curated hadith result links into a real book id +
        // a real global hadith number — never a fabricated ref.
        expect(r.hadithBookId, isNotNull,
            reason: 'collection "${r.collection}" must map to a book id');
        expect(r.hadithNumber, isNotNull);
        expect(r.hadithNumber, greaterThan(0));
      }
    });

    test('HadithDatabankGate documents the connected state honestly', () {
      expect(HadithDatabankGate.status, contains('Connected'));
      expect(HadithDatabankGate.status, isNot(contains('Not connected')));
    });
  });
}
