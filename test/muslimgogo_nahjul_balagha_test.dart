import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/hadith_service.dart';

/// MuslimGo addition: Nahjul Balagha parser — three parts
/// (sermons / letters / sayings), numbers stay within their part,
/// empty texts are skipped, and a part title is prepended only
/// when the text does not already start with it.
void main() {
  group('Nahjul Balagha parsing', () {
    final parts = <String, dynamic>{
      'nahj_khutab.json': [
        {'number': '1', 'title': 'Sermon subject line', 'text': 'Sermon body text.'},
        {'number': '2', 'title': '', 'text': 'Second sermon body.'},
        {'number': '3', 'title': 'Skipped', 'text': '   '},
      ],
      'nahj_kutub.json': [
        {'number': '1', 'title': 'To the people of Kufa', 'text': 'Letter body.'},
      ],
      'nahj_hikam.json': [
        {'number': '1', 'text': 'A short saying.'},
        {'number': '0', 'text': 'Invalid number, skipped.'},
      ],
    };

    test('builds 3 sections with within-part numbering', () {
      final book = HadithService.parseNahjulBalaghaJson(parts);
      expect(book.id, 'nahjulbalagha');
      expect(book.name, 'Nahjul Balagha');
      expect(book.language, HadithLanguage.ara);
      expect(book.sections.length, 3);
      expect(book.sections[0].title, contains('Sermons'));
      expect(book.sections[0].count, 2); // empty-text sermon skipped
      expect(book.sections[1].count, 1);
      expect(book.sections[2].count, 1); // number 0 skipped
      expect(book.hadiths.length, 4);
    });

    test('entries keep canonical within-part references', () {
      final book = HadithService.parseNahjulBalaghaJson(parts);
      final letter = book.hadithsInSection(2).single;
      expect(letter.hadithnumber, 1);
      expect(letter.sectionNumber, 2);
      expect(book.hadithsInSection(1).length, 2);
      expect(book.hadithsInSection(3).single.text, 'A short saying.');
    });

    test('title is prepended when missing from the text', () {
      final book = HadithService.parseNahjulBalaghaJson(parts);
      final sermon = book.hadithsInSection(1).first;
      expect(sermon.text, startsWith('Sermon subject line'));
      expect(sermon.text, contains('Sermon body text.'));
      final letter = book.hadithsInSection(2).single;
      expect(letter.text, startsWith('To the people of Kufa'));
    });

    test('the book is listed in the library catalogue', () {
      final meta = HadithService.books
          .where((b) => b.id == HadithService.nahjulBookId)
          .toList();
      expect(meta.length, 1);
      expect(meta.single.name, 'Nahjul Balagha');
    });
  });
}
