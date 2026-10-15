import 'sample_data.dart';

/// Phase 9 — AI Companion service layer (PREP ONLY, no live backend).
///
/// There is NO AI backend for NOOR yet, so nothing in this file may
/// claim a live AI answer. Two implementations exist:
///
/// * [LocalAiService] — returns the brief sample answers/sources
///   already drawn in the design (Pages 12/23/24), always flagged
///   `isSample = true` ("sample/offline"). This is what the UI uses
///   today, and the UI labels it honestly.
/// * [HttpAiService] — stub for the future backend. Its base URL
///   comes from the compile-time env `NOOR_AI_API`
///   (`--dart-define=NOOR_AI_API=https://…`). Until a backend is
///   actually provided it throws [UnimplementedError]; callers must
///   fall back to [LocalAiService] (see [NoorAi]).
///
/// Religious-content rule: answers here are short descriptive
/// summaries with sources cited by reference only, exactly as drawn
/// in the design. No substantial Qur'an/Hadith/Dua text, and no
/// original religious rulings.
class AiAnswer {
  const AiAnswer({
    required this.text,
    required this.sourceRefs,
    required this.isSample,
  });

  final String text;

  /// Sources cited by reference only, e.g. "Quran 2:153".
  final List<String> sourceRefs;

  /// True for [LocalAiService] sample/offline answers. The UI must
  /// show this state honestly; it is never a live-AI claim.
  final bool isSample;
}

abstract interface class AiService {
  Future<AiAnswer> ask(String question);

  /// True only for a real, connected backend. False today.
  bool get isLive;

  /// Short human label for the current mode, shown in the UI.
  String get modeLabel;
}

/// Sample/offline answers built from the design's own brief wording.
class LocalAiService implements AiService {
  const LocalAiService();

  @override
  bool get isLive => false;

  @override
  String get modeLabel => 'Sample answers (offline)';

  @override
  Future<AiAnswer> ask(String question) async {
    // Tiny delay so the chat UI can show a natural pending state.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = question.toLowerCase();

    if (q.contains('patience') || q.contains('sabr')) {
      return const AiAnswer(
        text: 'Patience (sabr) is repeatedly praised in the Quran, '
            'and is connected with prayer, perseverance and reward. '
            'I can show you the relevant verses and Hadith.',
        sourceRefs: ['Quran 2:153', 'Quran 39:10'],
        isSample: true,
      );
    }
    if (q.contains('tahajjud') || q.contains('night')) {
      return const AiAnswer(
        text: SampleData.sourcesSummary,
        sourceRefs: ['Quran 17:79', 'Sahih Muslim 1163'],
        isSample: true,
      );
    }
    if (q.contains('salah') || q.contains('prayer')) {
      return const AiAnswer(
        text: 'Consistency in Salah grows from fixed anchors: pray '
            'on time, keep wudu early, and review your day in the '
            'Salah Tracker. Sources can be opened from Page 24.',
        sourceRefs: ['Quran 29:45', 'Sahih al-Bukhari 527'],
        isSample: true,
      );
    }
    if (q.contains('dua') || q.contains('dhikr') || q.contains('zikr')) {
      return const AiAnswer(
        text: 'Morning and evening adhkar are a daily protection '
            'and remembrance routine. Open the Dua & Adhkar Library '
            '(Page 18) for the categories drawn in your design.',
        sourceRefs: [SampleData.duaSource],
        isSample: true,
      );
    }
    return const AiAnswer(
      text: 'Jazakumullah khayran for asking. This is a sample '
          'answer while the live AI backend is not connected yet — '
          'in the full app I answer with sources you can open and '
          'check.',
      sourceRefs: [],
      isSample: true,
    );
  }
}

/// Future live backend. Throws until a backend is provided — by
/// design, so no code path can silently pretend to be live AI.
class HttpAiService implements AiService {
  const HttpAiService();

  /// Compile-time base URL, e.g.
  /// `--dart-define=NOOR_AI_API=https://api.example.com`.
  static const String baseUrl = String.fromEnvironment('NOOR_AI_API');

  static bool get configured => baseUrl.isNotEmpty;

  @override
  bool get isLive => false; // Not connected until Phase 10+ backend.

  @override
  String get modeLabel => 'Live AI not connected yet';

  @override
  Future<AiAnswer> ask(String question) async {
    // TODO(phase-10): POST {question} to $baseUrl/chat with the
    // account token from AuthService, stream/parse the answer +
    // cited source references, and return isSample=false only when
    // a real response lands. Needs: backend URL, API contract and
    // an API key/secret stored server-side (never in the app).
    throw UnimplementedError(
      'HttpAiService: no AI backend provided yet '
      '(NOOR_AI_API=${configured ? 'set' : 'unset'}). '
      'Use LocalAiService until Phase 10.',
    );
  }
}

/// What the UI should use today: the HTTP stub when a backend URL
/// is configured, transparently falling back to local samples.
class NoorAi implements AiService {
  NoorAi({AiService? primary, AiService? fallback})
      : _primary = primary ??
            (HttpAiService.configured
                ? const HttpAiService()
                : const LocalAiService()),
        _fallback = fallback ?? const LocalAiService();

  final AiService _primary;
  final AiService _fallback;

  @override
  bool get isLive => _primary.isLive;

  @override
  String get modeLabel =>
      _primary is LocalAiService ? _primary.modeLabel : _fallback.modeLabel;

  @override
  Future<AiAnswer> ask(String question) async {
    try {
      return await _primary.ask(question);
    } on UnimplementedError {
      return _fallback.ask(question);
    } catch (_) {
      return _fallback.ask(question);
    }
  }
}
