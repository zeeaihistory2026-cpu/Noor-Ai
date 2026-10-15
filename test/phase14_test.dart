import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:noor_ai_companion/screens/ai/ai_chat_screen.dart';
import 'package:http/testing.dart';
import 'package:noor_ai_companion/data/app_state.dart';
import 'package:noor_ai_companion/data/knowledge_search.dart';
import 'package:noor_ai_companion/data/quran_service.dart';
import 'package:noor_ai_companion/data/share_content.dart';

void main() {
  group('Phase 14 — Share Studio content library', () {
    test('has at least 12 Ayah, 12 Hadith and Dua cards', () {
      expect(ShareContent.ayahCards.length, greaterThanOrEqualTo(12));
      expect(ShareContent.hadithCards.length, greaterThanOrEqualTo(12));
      expect(ShareContent.duaCards.length, greaterThanOrEqualTo(6));
    });

    test('every card has a formatted source reference and brief text', () {
      final quranRef = RegExp(r'^Quran \d+:\d+$');
      final hadithRef = RegExp(r"^[A-Z][A-Za-z`' -]+ \d+$");
      for (final item in ShareContent.all) {
        expect(item.reference.trim(), isNotEmpty, reason: item.id);
        expect(item.text.trim(), isNotEmpty, reason: item.id);
        expect(item.text.length, lessThanOrEqualTo(150), reason: item.id);
        if (item.type == ShareContentType.hadith) {
          expect(hadithRef.hasMatch(item.reference), isTrue,
              reason: '${item.id}: ${item.reference}');
        } else {
          expect(quranRef.hasMatch(item.reference), isTrue,
              reason: '${item.id}: ${item.reference}');
        }
      }
    });

    test('platform formats carry their platform pixel sizes', () {
      expect(ShareFormats.instagramPost.sizeLabel, '1080×1350 PNG');
      expect(ShareFormats.storyReel.sizeLabel, '1080×1920 PNG');
      expect(ShareFormats.facebookPost.sizeLabel, '1200×628 PNG');
      expect(ShareFormats.square.sizeLabel, '1080×1080 PNG');
      expect(
          ShareFormats.instagramPost.aspectRatio, closeTo(1080 / 1350, 0.001));
      expect(ShareFormats.storyReel.aspectRatio, closeTo(1080 / 1920, 0.001));
      expect(ShareFormats.facebookPost.aspectRatio, closeTo(1200 / 628, 0.001));
    });

    test('streak cards use the canonical Salah/Dhikr values', () {
      final cards = ShareContent.streakCards();
      expect(cards, hasLength(2));
      expect(cards[0].label, 'Namaz streak');
      expect(cards[0].days, NoorAppState.streaks[0].$2);
      expect(cards[1].label, 'Zikr streak');
      expect(cards[1].days, NoorAppState.streaks[1].$2);
    });
  });

  group('Phase 14 — knowledge search (offline, deterministic)', () {
    final service = KnowledgeSearchService(
      quranService: QuranService(
        client: MockClient((_) async => http.Response('{}', 500)),
      ),
    );

    const topics = [
      'patience',
      'anxiety',
      'gratitude',
      'anger',
      'forgiveness',
      'knowledge',
    ];

    for (final topic in topics) {
      test('“find a hadith on $topic” returns referenced hadith', () async {
        final response = await service.search('Find a hadith on $topic');
        expect(response.results, isNotEmpty, reason: topic);
        expect(
          response.results.every((r) => r.kind == KnowledgeKind.hadith),
          isTrue,
        );
        expect(
          response.results.every((r) =>
              r.collection != null &&
              r.hadithNumber != null &&
              r.reference.trim().isNotEmpty),
          isTrue,
        );
      });

      test('issue help on $topic returns referenced sources', () async {
        final response = await service.search('I need help with $topic');
        expect(response.results, isNotEmpty, reason: topic);
        expect(
          response.results.every((r) =>
              r.reference.trim().isNotEmpty &&
              (r.kind != KnowledgeKind.quran ||
                  (r.surahNumber != null && r.ayahNumber != null)) &&
              (r.kind != KnowledgeKind.hadith ||
                  (r.collection != null && r.hadithNumber != null))),
          isTrue,
        );
        expect(
          response.results.every((r) => r.teaching.trim().isNotEmpty),
          isTrue,
        );
      });
    }

    test('prompt parsing routes the three chip phrasings', () {
      expect(
        KnowledgeSearchService.parsePrompt('Find a hadith on patience').intent,
        KnowledgeIntent.hadith,
      );
      expect(
        KnowledgeSearchService.parsePrompt(
                'What does the Qur’an say about anxiety?')
            .intent,
        KnowledgeIntent.issue,
      );
      final ayah =
          KnowledgeSearchService.parsePrompt('Find an ayah on gratitude');
      expect(ayah.intent, KnowledgeIntent.quran);
      expect(ayah.topicText, contains('gratitude'));
    });

    test('no-result state is honest and suggests real topics', () async {
      final response = await service.search('Find a hadith on zxqwv ukj');
      expect(response.results, isEmpty);
      expect(response.message, isNotNull);
      expect(response.message, contains('never invented'));
    });

    test('every indexed hadith result carries collection + number', () async {
      final response = await service.search('Find a hadith on knowledge');
      expect(response.results, isNotEmpty);
      for (final r in response.results) {
        expect(r.reference, matches(RegExp(r"^[A-Z][A-Za-z`' -]+ \d+$")));
      }
    });
  });

  group('Phase 14 — AI Chat databank UI', () {
    testWidgets('renders referenced result cards for a topic search',
        (tester) async {
      tester.view.physicalSize = const Size(780, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: AiChatScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(
          find.byType(TextField), 'Find a hadith on patience');
      await tester.tap(find.byIcon(Icons.chevron_right).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Jami` at-Tirmidhi 2516'), findsWidgets);
      expect(find.text('Show sources'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('Phase 14 — live Qur’an search parsing', () {
    test('parses the documented AlQuran Cloud search shape', () {
      const body = '''
{
  "code": 200,
  "status": "OK",
  "data": {
    "count": 1,
    "matches": [
      {
        "number": 9001,
        "text": "Synthetic translation text about patience.",
        "numberInSurah": 45,
        "surah": {
          "number": 2,
          "englishName": "Al-Baqara"
        },
        "edition": {"identifier": "en.sahih"}
      }
    ]
  }
}
''';
      final matches = QuranService.parseSearchResponse(body);
      expect(matches, hasLength(1));
      expect(matches.single.surahNumber, 2);
      expect(matches.single.ayahNumber, 45);
      expect(matches.single.reference, 'Quran 2:45');
    });

    test('live search uses the response reference, not the query', () async {
      final client = MockClient((request) async {
        expect(request.url.path, contains('/search/'));
        return http.Response(
          '''
{
  "code": 200,
  "status": "OK",
  "data": {
    "count": 1,
    "matches": [
      {
        "number": 9002,
        "text": "Synthetic translation text about gratitude.",
        "numberInSurah": 7,
        "surah": {"number": 14, "englishName": "Ibrahim"},
        "edition": {"identifier": "en.sahih"}
      }
    ]
  }
}
''',
          200,
        );
      });
      final service = KnowledgeSearchService(
        quranService: QuranService(client: client),
      );
      final response =
          await service.search('What does the Qur’an say about gratitude?');
      expect(response.isLive, isTrue);
      expect(response.results.first.reference, 'Quran 14:7');
      expect(response.results.first.isLive, isTrue);
      expect(response.results.first.sourceLabel, contains('Live'));
    });
  });
}
