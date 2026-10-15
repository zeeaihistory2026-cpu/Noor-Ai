import 'quran_service.dart';
import 'share_content.dart';

/// Phase 14 — databank search behind the AI Companion's topic
/// prompts. This is search over referenced sources, not a language
/// model: every result carries a reference that exists either in
/// the live AlQuran Cloud response or in the curated local index
/// below, and a no-match query returns an honest empty state.
///
/// Sources:
/// * Qur'an — live keyword search via [QuranService.search]
///   (AlQuran Cloud, no key). Offline/failure falls back to the
///   local topic index (brief excerpts in [ShareContent]).
/// * Hadith — LIVE full databank since Phase 16: all six canonical
///   books via [HadithService] (fawazahmed0 hadith-api CDN, no key;
///   book/chapter browsing is fully live). "Find a hadith on X"
///   still runs over the curated local topic index — its entries
///   carry real collection + global hadith numbers
///   ([KnowledgeResult.hadithBookId]/[KnowledgeResult.hadithNumber])
///   that deep-link into the live databank. Full cross-book live
///   keyword search is v2 (needs a server-side index); per-section
///   full-text scan is supported on an open book+section via
///   [HadithBook.searchInSection].
///
/// Issue answers are descriptive only: one cautious line per
/// result ("what this teaches"), sources always attached, and the
/// UI carries "For personal rulings, consult a scholar." Nothing
/// here issues fatwas, medical or financial rulings.
enum KnowledgeKind { quran, hadith }

enum KnowledgeIntent { any, quran, hadith, issue }

class KnowledgeResult {
  const KnowledgeResult({
    required this.kind,
    required this.title,
    required this.briefExcerpt,
    required this.reference,
    required this.teaching,
    required this.sourceLabel,
    required this.isLive,
    this.arabicText,
    this.surahNumber,
    this.ayahNumber,
    this.collection,
    this.hadithNumber,
    this.score = 0,
  });

  final KnowledgeKind kind;
  final String title;

  /// Brief excerpt only (live Qur'an text arrives at runtime and
  /// is trimmed to card length before display).
  final String briefExcerpt;
  final String? arabicText;

  /// `Quran 2:153` or `Sahih al-Bukhari 1` — always data-derived.
  final String reference;
  final int? surahNumber;
  final int? ayahNumber;
  final String? collection;
  final int? hadithNumber;

  /// Live-databank book id for this collection ('bukhari',
  /// 'muslim', …), or null when the collection has no live book.
  /// Hadith-index entries deep-link into the real book/section
  /// numbers via [hadithNumber] (the global databank number).
  String? get hadithBookId => hadithBookIdFor(collection);

  /// One cautious descriptive line. Never a ruling.
  final String teaching;

  /// Where this result came from, shown honestly in the UI.
  final String sourceLabel;
  final bool isLive;
  final int score;

  String get refPill => reference;

  KnowledgeResult withScore(int s) => KnowledgeResult(
        kind: kind,
        title: title,
        briefExcerpt: briefExcerpt,
        reference: reference,
        teaching: teaching,
        sourceLabel: sourceLabel,
        isLive: isLive,
        arabicText: arabicText,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        collection: collection,
        hadithNumber: hadithNumber,
        score: s,
      );
}

class KnowledgeSearchResponse {
  const KnowledgeSearchResponse({
    required this.query,
    required this.topic,
    required this.results,
    required this.isLive,
    this.message,
  });

  final String query;
  final String? topic;
  final List<KnowledgeResult> results;
  final bool isLive;

  /// Honest no-result / fallback note. Never a fabricated answer.
  final String? message;

  bool get isEmpty => results.isEmpty;
}

/// The full-databank gate, documented in code so no surface can
/// pretend the whole hadith corpus is connected before it is.
/// UPDATE Phase 16: the databank IS now connected — the complete
/// six books live behind [HadithService] (fawazahmed0 hadith-api
/// CDN, keyless, verified 2026-10-13). A Sunnah.com API key would
/// only be an upgrade path (grades metadata, additional books),
/// documented here, not faked as active.
abstract final class HadithDatabankGate {
  static const provider = 'Sunnah.com API';
  static const status =
      'Connected via the fawazahmed0 hadith-api CDN (keyless): all '
      'six canonical books, full chapter lists and full text at '
      'runtime. A user-owned Sunnah.com API key would be a future '
      'upgrade path only — nothing here claims it is connected.';
  static const envKey = 'SUNNAH_API_KEY'; // future dart-define name
}

/// Curated collection name -> live databank book id. Lets offline
/// topic-index entries deep-link into the real book/section
/// numbers ([HadithService]). Matching is case-insensitive and
/// tolerant of the backtick/quote variants the index uses.
String? hadithBookIdFor(String? collection) {
  if (collection == null) return null;
  final c = collection
      .toLowerCase()
      .replaceAll('`', '')
      .replaceAll("'", '')
      .replaceAll(RegExp(r'[^a-z ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  const map = <String, String>{
    'sahih al bukhari': 'bukhari',
    'sahih muslim': 'muslim',
    'sunan abu dawud': 'abudawud',
    'jami at tirmidhi': 'tirmidhi',
    'jami tirmidhi': 'tirmidhi',
    'sunan an nasai': 'nasai',
    'sunan nasa i': 'nasai',
    'sunan ibn majah': 'ibnmajah',
    'sunan ibne majah': 'ibnmajah',
  };
  return map[c];
}

class _Topic {
  const _Topic(
      this.name, this.synonyms, this.teaching, this.quranRefs, this.hadithRefs);
  final String name;
  final List<String> synonyms;
  final String teaching;
  final List<String> quranRefs;
  final List<String> hadithRefs;
}

/// Canonical topic map. References point into [ShareContent] (or
/// the extra index entries below) — a topic can only surface
/// references that exist there.
const _topics = <_Topic>[
  _Topic(
    'patience',
    ['patience', 'sabr', 'patient', 'endurance', 'perseverance'],
    'Patience is repeatedly joined with prayer and trust; read each '
        'verse in its surrounding passage.',
    ['Quran 2:153', 'Quran 94:6', 'Quran 2:286'],
    ['Jami` at-Tirmidhi 2516'],
  ),
  _Topic(
    'anxiety',
    [
      'anxiety',
      'anxious',
      'worry',
      'worried',
      'stress',
      'fear',
      'calm',
      'peace',
      'comfort',
      'sad',
      'sadness'
    ],
    'These verses describe remembrance and reliance as rest for '
        'the heart; they comfort, they do not diagnose or treat.',
    ['Quran 13:28', 'Quran 65:3', 'Quran 94:6', 'Quran 39:53'],
    ['Sahih Muslim 2699'],
  ),
  _Topic(
    'gratitude',
    [
      'gratitude',
      'grateful',
      'thankful',
      'thankfulness',
      'blessing',
      'blessings',
      'shukr'
    ],
    'Gratitude is linked with remembrance and with increase.',
    ['Quran 14:7', 'Quran 2:152'],
    ['Sahih Muslim 2588'],
  ),
  _Topic(
    'anger',
    ['anger', 'angry', 'temper', 'rage'],
    'Strength is described as self-control at the moment of anger.',
    ['Quran 29:45'],
    ['Sahih al-Bukhari 6114'],
  ),
  _Topic(
    'forgiveness',
    [
      'forgiveness',
      'forgive',
      'repentance',
      'repent',
      'sin',
      'sins',
      'mercy',
      'despair',
      'hopeless'
    ],
    'Despair of mercy is discouraged; return and hope are the '
        'direction given. For personal rulings, consult a scholar.',
    ['Quran 39:53', 'Quran 2:286'],
    ['Sahih Muslim 2699'],
  ),
  _Topic(
    'rizq',
    [
      'rizq',
      'provision',
      'money',
      'wealth',
      'job',
      'work',
      'income',
      'sustenance'
    ],
    'Provision is discussed alongside trust and gratitude; this '
        'is not financial advice.',
    ['Quran 65:3', 'Quran 14:7'],
    ['Sahih Muslim 2588'],
  ),
  _Topic(
    'illness',
    ['illness', 'sick', 'sickness', 'health', 'pain', 'disease', 'healing'],
    'These references speak of capacity and relief in hardship; '
        'they are not medical advice — seek qualified care.',
    ['Quran 2:286', 'Quran 94:6'],
    ['Sahih Muslim 2699'],
  ),
  _Topic(
    'knowledge',
    [
      'knowledge',
      'study',
      'studying',
      'learning',
      'learn',
      'exams',
      'exam',
      'education',
      'school'
    ],
    'Seeking knowledge is presented as worship-adjacent duty and '
        'a direct dua.',
    ['Quran 20:114'],
    ['Sunan Ibn Majah 224', 'Sahih al-Bukhari 5027'],
  ),
  _Topic(
    'prayer',
    ['prayer', 'salah', 'namaz', 'pray', 'focus in prayer'],
    'Prayer is described as remembrance and a restraint from '
        'wrongdoing.',
    ['Quran 29:45', 'Quran 2:153'],
    ['Sahih al-Bukhari 69'],
  ),
  _Topic(
    'dhikr',
    ['dhikr', 'zikr', 'remembrance', 'remember allah', 'tasbih'],
    'Remembrance is described as rest and nearness.',
    ['Quran 13:28', 'Quran 2:152'],
    ['Jami` at-Tirmidhi 1987'],
  ),
  _Topic(
    'family',
    ['family', 'parents', 'mother', 'father', 'children', 'marriage', 'spouse'],
    'Family duas ask for comfort and steadfastness; personal '
        'family rulings belong with a scholar.',
    ['Quran 25:74', 'Quran 14:40'],
    ['Sahih al-Bukhari 13'],
  ),
  _Topic(
    'hardship',
    [
      'hardship',
      'difficulty',
      'trial',
      'trials',
      'suffering',
      'tough time',
      'problems',
      'grief',
      'loss'
    ],
    'Hardship is consistently paired with ease and capacity; read '
        'in context and seek support around you.',
    ['Quran 94:6', 'Quran 2:286', 'Quran 3:139'],
    ['Sahih Muslim 2699', 'Sahih Muslim 1631'],
  ),
  _Topic(
    'charity',
    ['charity', 'giving', 'sadaqah', 'donate', 'generosity'],
    'Giving is described as continuance and not as loss.',
    ['Quran 2:201'],
    ['Sahih Muslim 1631', 'Sahih Muslim 2588'],
  ),
  _Topic(
    'kindness',
    [
      'kindness',
      'kind',
      'people',
      'brotherhood',
      'community',
      'neighbours',
      'neighbors'
    ],
    'Faith is repeatedly tied to how people treat one another.',
    ['Quran 2:201'],
    ['Sahih al-Bukhari 13', 'Sahih al-Bukhari 69'],
  ),
];

class KnowledgeSearchService {
  KnowledgeSearchService({QuranService? quranService})
      : _quran = quranService ?? QuranService();

  final QuranService _quran;

  static const scholarNote =
      'For personal rulings, consult a scholar. These are sources '
      'to read in context, not a fatwa.';

  /// Route a natural prompt to (intent, topic-haystack). Handles
  /// the three chip phrasings plus free text:
  /// "Find a hadith on patience", "What does the Qur'an say about
  /// anxiety?", "I need help with anger".
  static ({KnowledgeIntent intent, String topicText}) parsePrompt(String raw) {
    var q = raw.trim().toLowerCase().replaceAll('’', "'");
    var intent = KnowledgeIntent.any;
    if (RegExp(r'\b(hadith|hadees|hadeeth)\b').hasMatch(q)) {
      intent = KnowledgeIntent.hadith;
    } else if (RegExp(r"\b(ayah|ayat|verse|qur'an|quran|qur’an)\b")
        .hasMatch(q)) {
      intent = KnowledgeIntent.quran;
    }
    if (q.startsWith('i need help') ||
        q.startsWith('i want help') ||
        q.contains('what does the qur') ||
        q.contains('help me with') ||
        q.contains('issue')) {
      intent = intent == KnowledgeIntent.hadith
          ? KnowledgeIntent.hadith
          : KnowledgeIntent.issue;
    }
    // Strip command scaffolding, leaving the topic words.
    q = q
        .replaceAll(
            RegExp(
                r"^(please\s+)?(find|search|show|tell me|give me)(\s+me)?\s+(a\s+|an\s+)?(hadith|hadees|hadeeth|ayah|ayat|verse|verses)?\s*(on|about|for|regarding)?\s*"),
            '')
        .replaceAll(RegExp(r"^what does the qur'?an say about\s*"), '')
        .replaceAll(RegExp(r"^i (need|want) help( with)?\s*"), '')
        .replaceAll(RegExp(r"^help me with\s*"), '')
        .replaceAll(RegExp(r"\b(hadith|hadees|hadeeth)\b"), '')
        .replaceAll(RegExp(r"\b(ayah|ayat|verse|verses)\b"), '')
        .replaceAll(RegExp(r"^(on|about|for)\s+"), '')
        .replaceAll(RegExp(r'[?.!]+$'), '')
        .trim();
    return (intent: intent, topicText: q.isEmpty ? raw.toLowerCase() : q);
  }

  /// Deterministic offline search (topic map + keyword ranking).
  /// This is also the live-path fallback, so it is fully testable
  /// without network.
  KnowledgeSearchResponse searchOffline(
    String raw, {
    KnowledgeIntent intent = KnowledgeIntent.any,
  }) {
    final parsed = parsePrompt(raw);
    final effectiveIntent = intent == KnowledgeIntent.any
        ? (parsed.intent == KnowledgeIntent.any
            ? KnowledgeIntent.issue
            : parsed.intent)
        : intent;
    final topicText = parsed.topicText;
    final topic = _matchTopic(topicText);
    final scored = <KnowledgeResult>[];

    void consider(KnowledgeResult r, int score) {
      if (effectiveIntent == KnowledgeIntent.quran &&
          r.kind != KnowledgeKind.quran) {
        return;
      }
      if (effectiveIntent == KnowledgeIntent.hadith &&
          r.kind != KnowledgeKind.hadith) {
        return;
      }
      if (score > 0) scored.add(r.withScore(score));
    }

    if (topic != null) {
      final refs = <String>[
        ...topic.quranRefs.map((r) => 'Q:$r'),
        ...topic.hadithRefs.map((r) => 'H:$r'),
      ];
      for (final ref in refs) {
        final bare = ref.substring(2);
        final item = _itemByReference(bare);
        if (item == null) continue;
        consider(_fromItem(item, topic.teaching), 100);
      }
    }

    // Keyword ranking over the whole index (titles, excerpts, tags).
    final words = topicText
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length > 2)
        .toSet();
    for (final item in _indexItems()) {
      if (scored.any((r) => r.reference == item.reference)) continue;
      var score = 0;
      for (final w in words) {
        if (item.tags.contains(w)) score += 30;
        if (item.title.toLowerCase().contains(w)) score += 20;
        if (item.text.toLowerCase().contains(w)) score += 10;
      }
      consider(_fromItem(item, _teachingFor(item, topic)), score);
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      if (a.kind != b.kind) {
        return a.kind == KnowledgeKind.quran ? -1 : 1;
      }
      return a.reference.compareTo(b.reference);
    });

    final results = scored.take(6).toList();
    return KnowledgeSearchResponse(
      query: raw,
      topic: topic?.name,
      results: results,
      isLive: false,
      message: results.isEmpty
          ? 'No indexed source matched “$raw”. Try a topic like '
              'patience, gratitude, anxiety, anger or knowledge — '
              'references are never invented.'
          : null,
    );
  }

  /// Full search: live Qur'an keyword search first (when the
  /// intent includes the Qur'an), local topic index for Hadith and
  /// as the offline fallback for everything.
  Future<KnowledgeSearchResponse> search(String raw) async {
    final parsed = parsePrompt(raw);
    final intent = parsed.intent;
    if (intent != KnowledgeIntent.hadith &&
        parsed.topicText.trim().length >= 3) {
      try {
        final matches = await _quran.search(parsed.topicText);
        if (matches.isNotEmpty) {
          final topic = _matchTopic(parsed.topicText);
          final results = matches.take(5).map((m) {
            return KnowledgeResult(
              kind: KnowledgeKind.quran,
              title: m.surahEnglishName.isEmpty
                  ? m.reference
                  : '${m.surahEnglishName} · Ayah ${m.ayahNumber}',
              briefExcerpt: _trimExcerpt(m.text),
              reference: m.reference,
              surahNumber: m.surahNumber,
              ayahNumber: m.ayahNumber,
              teaching: topic?.teaching ??
                  'Read this verse in its surrounding passage; '
                      'translation is Saheeh International.',
              sourceLabel: 'Live Qur’an search · AlQuran Cloud',
              isLive: true,
              score: 100,
            );
          }).toList();
          // Hadith companions from the local index on issue queries.
          if (intent == KnowledgeIntent.issue ||
              intent == KnowledgeIntent.any) {
            final local = searchOffline(raw, intent: KnowledgeIntent.hadith);
            results.addAll(local.results.take(2));
          }
          return KnowledgeSearchResponse(
            query: raw,
            topic: topic?.name,
            results: results,
            isLive: true,
          );
        }
      } catch (_) {
        // Fall through to the offline index — honest, referenced.
      }
    }
    return searchOffline(raw);
  }

  static _Topic? _matchTopic(String text) {
    final q = ' ${text.toLowerCase()} ';
    _Topic? best;
    var bestScore = 0;
    for (final t in _topics) {
      var score = 0;
      if (q.contains(' ${t.name} ')) score += 50;
      for (final s in t.synonyms) {
        if (q.contains(' $s ') || text.toLowerCase() == s) score += 40;
        if (text.toLowerCase().contains(s)) score += 15;
      }
      if (score > bestScore) {
        bestScore = score;
        best = t;
      }
    }
    return bestScore > 0 ? best : null;
  }

  static String _trimExcerpt(String text) {
    final t = text.trim();
    if (t.length <= 220) return t;
    final cut = t.lastIndexOf(' ', 217);
    return '${t.substring(0, cut > 80 ? cut : 217)}…';
  }

  static List<ShareContentItem> _indexItems() => ShareContent.all;

  static ShareContentItem? _itemByReference(String reference) {
    for (final item in ShareContent.all) {
      if (item.reference == reference) return item;
    }
    return null;
  }

  static String _teachingFor(ShareContentItem item, _Topic? topic) =>
      topic?.teaching ??
      item.teaching ??
      'Read this reference in context; translations and excerpts '
          'here are brief by design.';

  static KnowledgeResult _fromItem(ShareContentItem item, String teaching) {
    final isQuran =
        item.type == ShareContentType.ayah || item.type == ShareContentType.dua;
    int? surah;
    int? ayah;
    String? collection;
    int? hadithNo;
    if (isQuran) {
      final m = RegExp(r'Quran (\d+):(\d+)').firstMatch(item.reference);
      if (m != null) {
        surah = int.parse(m.group(1)!);
        ayah = int.parse(m.group(2)!);
      }
    } else {
      final m = RegExp(r'^(.*) (\d+)$').firstMatch(item.reference);
      if (m != null) {
        collection = m.group(1);
        hadithNo = int.parse(m.group(2)!);
      }
    }
    return KnowledgeResult(
      kind: isQuran ? KnowledgeKind.quran : KnowledgeKind.hadith,
      title: item.title,
      briefExcerpt: item.text,
      arabicText: item.arabicText,
      reference: item.reference,
      surahNumber: surah,
      ayahNumber: ayah,
      collection: collection,
      hadithNumber: hadithNo,
      teaching: teaching,
      sourceLabel: isQuran
          ? 'Offline topic index · Qur’an references'
          : 'Offline topic index · Hadith references',
      isLive: false,
    );
  }
}
