import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/hadith_service.dart';

void main() {
  group('Hadith Parsing Robustness & All Books Verification', () {
    test('Sahih Muslim fractional arabic numbers ("8.01") parse cleanly without TypeError', () {
      final sample = jsonEncode({
        'metadata': {
          'name': 'Sahih Muslim',
          'sections': {'1': 'The Book of Faith'},
        },
        'hadiths': [
          {
            'hadithnumber': 92,
            'arabicnumber': '8.01', // String fractional arabic number from live Muslim dataset
            'text': 'It is narrated on the authority of...',
            'grades': [],
            'reference': {'book': 1, 'hadith': 92},
          },
          {
            'hadithnumber': 93,
            'arabicnumber': 8.02, // double
            'text': 'Another chain of narration...',
            'grades': [],
            'reference': {'book': 1, 'hadith': 93},
          },
          {
            'hadithnumber': 94,
            'arabicnumber': null, // null
            'text': 'A third narration...',
            'grades': [],
            'reference': {'book': 1, 'hadith': 94},
          },
        ],
      });

      final book = HadithService.parseEditionJson(sample,
          bookId: 'muslim', language: HadithLanguage.eng);

      expect(book.hadiths.length, 3);
      expect(book.hadiths[0].arabicnumber, 8);
      expect(book.hadiths[1].arabicnumber, 8);
      expect(book.hadiths[2].arabicnumber, 0);
      expect(book.sections.length, 1);
      expect(book.sections[0].title, 'The Book of Faith');
    });

    test('All canonical book IDs are recognized with authentic names', () {
      final expectedBooks = [
        ('bukhari', 'Sahih al-Bukhari'),
        ('muslim', 'Sahih Muslim'),
        ('abudawud', 'Sunan Abu Dawud'),
        ('tirmidhi', "Jami' At Tirmidhi"),
        ('nasai', 'Sunan An-Nasai'),
        ('ibnmajah', 'Sunan Ibn Majah'),
      ];

      for (final (id, name) in expectedBooks) {
        expect(HadithService.bookName(id), name);
        expect(HadithService.bookMaxHadiths[id], isNotNull);
        expect(HadithService.bookMaxHadiths[id]!, greaterThan(3000));
      }
    });

    test('Books with missing or unindexed section numbers in metadata still produce valid navigable sections', () {
      final sample = jsonEncode({
        'metadata': {
          'name': 'Sunan Abu Dawud',
          'sections': {'0': ''}, // empty section 0 in metadata
        },
        'hadiths': [
          {
            'hadithnumber': 1,
            'arabicnumber': 1,
            'text': 'Narration in section 1 which is not in metadata.sections',
            'grades': ['Sahih'],
            'reference': {'book': 1, 'hadith': 1},
          },
          {
            'hadithnumber': 2,
            'arabicnumber': 2,
            'text': 'Narration in section 2 which is not in metadata.sections',
            'grades': [],
            'reference': {'book': 2, 'hadith': 1},
          },
        ],
      });

      final book = HadithService.parseEditionJson(sample,
          bookId: 'abudawud', language: HadithLanguage.eng);

      expect(book.hadiths.length, 2);
      expect(book.sections.length, 2);
      expect(book.sections.map((s) => s.number), containsAll([1, 2]));
      expect(book.hadithsInSection(1).length, 1);
      expect(book.hadithsInSection(2).length, 1);
    });

    test('Mirror CDN list contains resilient fallbacks', () {
      expect(HadithService.cdnMirrors.length, greaterThanOrEqualTo(2));
      expect(HadithService.cdnMirrors, contains('https://raw.githubusercontent.com/fawazahmed0/hadith-api/1'));
    });
  });
}
