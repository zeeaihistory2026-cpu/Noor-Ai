import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/ai_service.dart';
import '../../data/knowledge_search.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'ai_answer_sources_screen.dart';

/// Page 23 — AI Chat Conversation. Emerald header (AI Companion /
/// Islamic Q&A · Sample answers (offline)), user/AI bubbles,
/// "Show sources" opening Page 24, and the Ask a follow-up pill.
///
/// Phase 14: prompts like "Find a hadith on patience", "What does
/// the Qur'an say about anxiety?" and "I need help with anger" are
/// routed to [KnowledgeSearchService] — live AlQuran Cloud keyword
/// search for Qur'an, curated local topic index for Hadith —
/// and results render as referenced source cards. Free-form
/// questions still use the Phase 9 sample AI, honestly labelled;
/// databank search is never branded as a full LLM answer.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({
    super.key,
    this.initialQuery,
    this.initialPromptPrefix,
  });

  /// A full question to run on open (AI Home suggested questions).
  final String? initialQuery;

  /// A chip prefix to prefill, e.g. "Find a hadith on " — the user
  /// adds the topic and sends.
  final String? initialPromptPrefix;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _ChatEntry {
  const _ChatEntry.user(this.text)
      : isUser = true,
        results = null,
        isLive = false;
  const _ChatEntry.answer(this.text, {this.results, this.isLive = false})
      : isUser = false;

  final bool isUser;
  final String text;
  final List<KnowledgeResult>? results;
  final bool isLive;
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiService _ai = NoorAi();
  final KnowledgeSearchService _search = KnowledgeSearchService();
  bool _sending = false;
  final _input = TextEditingController();
  final _focus = FocusNode();
  List<KnowledgeResult>? _lastResults;
  bool _lastLive = false;
  String? _lastQuestion;
  String? _pendingPrefix;

  final List<_ChatEntry> _messages = [
    const _ChatEntry.user('What does Islam say about patience?'),
    const _ChatEntry.answer(
        'Patience (sabr) is repeatedly praised in the Quran. Allah '
        'connects patience with prayer, perseverance and reward.'),
    const _ChatEntry.user('Show me the strongest sources.'),
    const _ChatEntry.answer(
        'Here are references to check: Quran 2:153, 39:10, and '
        'supporting authentic Hadith. Tap any source to open it '
        'in context.'),
  ];

  @override
  void initState() {
    super.initState();
    final prefix = widget.initialPromptPrefix;
    if (prefix != null) {
      _pendingPrefix = prefix;
      _input.text = prefix;
      _input.selection = TextSelection.collapsed(offset: prefix.length);
    }
    final query = widget.initialQuery;
    if (query != null && query.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _input.clear();
        _runQuery(query);
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  static bool _looksLikeSearch(String text) {
    final parsed = KnowledgeSearchService.parsePrompt(text);
    final q = text.toLowerCase();
    return parsed.intent != KnowledgeIntent.any ||
        q.contains('find') ||
        q.contains('what does the qur') ||
        q.contains('help with') ||
        q.contains('hadith on') ||
        q.contains('hadees on') ||
        q.contains('ayah on');
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    _input.clear();
    await _runQuery(text);
  }

  Future<void> _runQuery(String text) async {
    if (_sending) return;
    setState(() {
      _messages.add(_ChatEntry.user(text));
      _sending = true;
      _lastQuestion = text;
    });

    if (_looksLikeSearch(text)) {
      final response = await _search.search(text);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _lastResults = response.results;
        _lastLive = response.isLive;
        if (response.results.isEmpty) {
          _messages.add(_ChatEntry.answer(
            response.message ??
                'No referenced source matched. Try patience, '
                    'gratitude, anxiety, anger or knowledge.',
          ));
        } else {
          _messages.add(_ChatEntry.answer(
            response.isLive
                ? 'Live Qur’an search found these referenced verses. '
                    'Read each in context from its source.'
                : 'These are referenced sources from the offline '
                    'topic index. Read each in context from its source.',
            results: response.results,
            isLive: response.isLive,
          ));
        }
      });
      return;
    }

    final answer = await _ai.ask(text);
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatEntry.answer(answer.text));
      _sending = false;
    });
  }

  void _chip(String prefix, String hint) {
    setState(() {
      _pendingPrefix = prefix;
      _input.text = prefix;
      _input.selection = TextSelection.collapsed(offset: prefix.length);
    });
    _focus.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hint),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openSources() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AiAnswerSourcesScreen(
        question: _lastQuestion,
        results: _lastResults,
        summary: _lastResults == null
            ? null
            : 'Databank search results with their full references. '
                'Brief excerpts are shown for orientation; read the '
                'complete text at the source.',
        isLive: _lastLive,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
        child: Column(children: [
          Container(
            color: NoorColors.emeraldDark,
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 20),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 19),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(children: [
                  Text('AI Companion',
                      style:
                          NoorType.screenTitle.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Islamic Q&A · Sample answers (offline)',
                      style: NoorType.meta.copyWith(color: Colors.white70)),
                ]),
              ),
              IconButton(
                tooltip: 'Chat options',
                icon: const Icon(Icons.more_vert, color: Colors.white),
                // Phase 16 audit: real conversation actions — copy the
                // latest AI answer, or clear back to the welcome thread.
                onPressed: () => showNoorOverflowSheet(context,
                    title: 'AI Companion',
                    actions: [
                      (
                        Icons.copy_outlined,
                        'Copy last answer',
                        () async {
                          final last = _messages.lastWhere(
                              (m) => !m.isUser,
                              orElse: () => const _ChatEntry.answer(''));
                          await Clipboard.setData(
                              ClipboardData(text: last.text));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Answer copied')));
                          }
                        }
                      ),
                      (
                        Icons.delete_outline,
                        'Clear conversation',
                        () => setState(() => _messages.removeRange(
                            4, _messages.length))
                      ),
                    ])),
            ]),
          ),
          Container(
            width: double.infinity,
            color: NoorColors.emeraldSoft,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              _ai.isLive ? 'Live AI connected' : _ai.modeLabel,
              textAlign: TextAlign.center,
              style: NoorType.meta.copyWith(color: NoorColors.emeraldDark),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              children: [
                _databankSection(),
                const SizedBox(height: 16),
                for (final m in _messages) ...[
                  _bubble(m.isUser, m.text),
                  if (m.results != null) ...[
                    const SizedBox(height: 10),
                    for (final r in m.results!) ...[
                      _resultCard(r),
                      const SizedBox(height: 10),
                    ],
                  ],
                  const SizedBox(height: 12),
                ],
                if (_sending)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text('Searching referenced sources…',
                        style: NoorType.meta),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _openSources,
                    icon: const Icon(Icons.library_books_outlined,
                        size: 17, color: NoorColors.emerald),
                    label: const Text('Show sources',
                        style: TextStyle(
                            color: NoorColors.emerald,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: TextField(
              controller: _input,
              focusNode: _focus,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask a follow-up...',
                hintStyle: NoorType.secondary.copyWith(color: NoorColors.muted),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: NoorColors.emeraldDark, shape: BoxShape.circle),
                  child: IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: Colors.white, size: 21),
                      onPressed: _send),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(NoorRadius.input),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _databankSection() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Search the Qur’an & Hadith databank',
            style: NoorType.secondary),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _searchChip(
            Icons.library_books_outlined,
            'Find a Hadith on…',
            () => _chip(
              'Find a hadith on ',
              'Type a topic, e.g. patience, then send.',
            ),
          ),
          _searchChip(
            Icons.menu_book_outlined,
            'What does the Qur’an say about…',
            () => _chip(
              'What does the Qur’an say about ',
              'Type an issue, e.g. anxiety, then send.',
            ),
          ),
          _searchChip(
            Icons.auto_stories_outlined,
            'Find an Ayah on…',
            () => _chip(
              'Find an ayah on ',
              'Type a topic, e.g. gratitude, then send.',
            ),
          ),
        ]),
        if (_pendingPrefix != null) ...[
          const SizedBox(height: 8),
          Text('Add your topic after “${_pendingPrefix!.trim()}”.',
              style: NoorType.meta.copyWith(color: NoorColors.muted)),
        ],
      ]);

  Widget _searchChip(IconData icon, String label, VoidCallback onTap) =>
      Semantics(
          button: true,
          label: label,
          child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: NoorColors.hairline)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(icon, size: 16, color: NoorColors.emeraldDark),
                        const SizedBox(width: 7),
                        Flexible(
                            child: Text(label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: NoorType.meta)),
                      ])))));

  Widget _resultCard(KnowledgeResult r) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AiAnswerSourcesScreen(
              question: _lastQuestion,
              results: [r],
              summary: 'One referenced source from the databank '
                  'search. Read the complete text at the source.',
              isLive: r.isLive,
            ),
          )),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NoorColors.hairline)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldDark,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(r.reference,
                        style: NoorType.meta.copyWith(color: Colors.white))),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(r.sourceLabel,
                        style:
                            NoorType.meta.copyWith(color: NoorColors.muted))),
                const Icon(Icons.open_in_new,
                    size: 16, color: NoorColors.muted),
              ]),
              const SizedBox(height: 9),
              if (r.arabicText != null) ...[
                Text(r.arabicText!,
                    textDirection: TextDirection.rtl,
                    style: NoorType.arabic(size: 20)),
                const SizedBox(height: 6),
              ],
              Text(r.briefExcerpt,
                  style: NoorType.secondary
                      .copyWith(color: NoorColors.ink, height: 1.5)),
              const SizedBox(height: 7),
              Text(r.teaching, style: NoorType.meta.copyWith(height: 1.45)),
              const SizedBox(height: 8),
              Text(KnowledgeSearchService.scholarNote,
                  style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
            ]),
          ),
        ),
      );

  Widget _bubble(bool user, String text) => Align(
        alignment: user ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 290),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: user ? NoorColors.emeraldDark : NoorColors.hairlineSoft,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(user ? 20 : 6),
              bottomRight: Radius.circular(user ? 6 : 20),
            ),
          ),
          child: Text(text,
              style: NoorType.body.copyWith(
                  color: user ? Colors.white : NoorColors.ink, height: 1.5)),
        ),
      );
}
