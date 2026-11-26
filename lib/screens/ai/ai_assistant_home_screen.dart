import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import 'ai_chat_screen.dart';
import 'voice_ai_screen.dart';
import '../../data/noor_store.dart';
import '../../widgets/noor_components.dart';
import 'madhhab_compare_screen.dart';

/// Page 12 — AI Assistant Home. Dark emerald header with the real
/// mosque artwork cropped from the design, Assalamu Alaikum greeting,
/// Ask a question… pill (mic + send), Suggested Questions grid,
/// Recent Conversations, lantern promo card and Popular Topics row.
class AiAssistantHomeScreen extends StatefulWidget {
  const AiAssistantHomeScreen({super.key});

  @override
  State<AiAssistantHomeScreen> createState() => _AiAssistantHomeScreenState();
}

class _AiAssistantHomeScreenState extends State<AiAssistantHomeScreen> {
  List<Map<String, dynamic>> _savedChats = const [];

  @override
  void initState() {
    super.initState();
    _loadSavedChats();
  }

  Future<void> _loadSavedChats() async {
    final list = await NoorStore.getAiConversations();
    if (!mounted) return;
    setState(() => _savedChats = list);
  }

  @override
  Widget build(BuildContext context) {
    void openChat() => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AiChatScreen()))
        .then((_) => _loadSavedChats());
    void openPrompt(String prefix) => Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (_) => AiChatScreen(initialPromptPrefix: prefix)))
        .then((_) => _loadSavedChats());
    void openQuestion(String query) => Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (_) => AiChatScreen(initialQuery: query)))
        .then((_) => _loadSavedChats());
    void openVoice() => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const VoiceAiScreen()));
return Material(
      color: NoorTheme.background(context),
      child: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Dark header with mosque art (Page 12 crop).
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [NoorColors.emeraldDark, NoorColors.emeraldMid],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Stack(children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(28)),
                  child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.transparent, Colors.white],
                          stops: [0, 0.45]).createShader(rect),
                      blendMode: BlendMode.dstIn,
                      child: ExcludeSemantics(
                          child: Image.asset(NoorAssets.aiHeaderMosque,
                          cacheWidth: 1170,
                          // Wider box: at 165 the cover crop cut
                          // both minarets off the dome art. Left
                          // edge fades into the header (Phase 12)
                          // so the art no longer slices the title.
                          width: 190,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink()))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        IconButton(
                            tooltip: 'AI tools menu',
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => showNoorOverflowSheet(context,
                                    title: 'AI Companion Tools',
                                    actions: [
                                      (
                                        Icons.mic_none_outlined,
                                        'Voice Companion',
                                        openVoice
                                      ),
                                      (
                                        Icons.compare_arrows_outlined,
                                        'Compare Madhhab Opinions',
                                        () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const MadhhabCompareScreen()))
                                      ),
                                      (
                                        Icons.chat_outlined,
                                        'Open Text Chat',
                                        openChat
                                      ),
                                    ])),
                        Expanded(
                            child: Semantics(
                                header: true,
                                child: Text('AI Assistant',
                                    textAlign: TextAlign.center,
                                    style: NoorType.section
                                        .copyWith(color: Colors.white)))),
                        IconButton(
                            tooltip: 'Recent questions',
                            icon:
                                const Icon(Icons.history, color: Colors.white),
                            onPressed: () => showModalBottomSheet<void>(
                                context: context,
                                backgroundColor: NoorTheme.surface(context),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20))),
                                builder: (c) => SafeArea(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 16, 20, 20),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                        'Recent AI Questions',
                                                        style:
                                                            NoorType.cardTitle),
                                                    if (_savedChats.isNotEmpty)
                                                      TextButton(
                                                          onPressed: () async {
                                                            await NoorStore
                                                                .clearAiConversations();
                                                            await _loadSavedChats();
                                                            if (c.mounted) {
                                                              Navigator.pop(c);
                                                            }
                                                          },
                                                          child: const Text(
                                                              'Clear')),
                                                  ]),
                                              if (_savedChats.isEmpty)
                                                Padding(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 16),
                                                    child: Text(
                                                        'Your saved AI questions will appear here.',
                                                        style: NoorType
                                                            .secondary
                                                            .copyWith(
                                                                color: NoorTheme
                                                                    .muted(c))))
                                              else
                                                for (final item
                                                    in _savedChats.take(5))
                                                  ListTile(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                          '${item['question'] ?? ''}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      subtitle: Text(
                                                          '${item['answer'] ?? ''}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      onTap: () {
                                                        Navigator.pop(c);
                                                        openQuestion(
                                                            '${item['question'] ?? ''}');
                                                      }),
                                            ]))))),
                      ]),
                      const SizedBox(height: 26),
                      Text('Assalamu Alaikum',
                          style: NoorType.screenTitle
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 6),
                      const Text('How can I help you today?',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      TextField(
                        readOnly: true,
                        onTap: openChat,
                        decoration: InputDecoration(
                          hintText: 'Ask a question...',
                          hintStyle: NoorType.secondary.copyWith(color: NoorTheme.muted(context)),
                          filled: true,
                          fillColor: NoorTheme.surface(context),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          suffixIcon:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                tooltip: 'Voice companion',
                                icon: Icon(Icons.mic,
                                    color: NoorTheme.muted(context)),
                                onPressed: openVoice),
                            Container(
                              margin: const EdgeInsetsDirectional.only(end: 6),
                              decoration: const BoxDecoration(
                                  color: NoorColors.emeraldDark,
                                  shape: BoxShape.circle),
                              child: IconButton(
                                  tooltip: 'Ask AI',
                                  icon: const Icon(Icons.send,
                                      color: Colors.white, size: 18),
                                  onPressed: openChat),
                            ),
                          ]),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(NoorRadius.input),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Find in the Qur’an & Hadith databank',
                  style: NoorType.cardTitle),
              const SizedBox(height: 6),
              Text(
                  'Referenced search — every result carries its source number.',
                  style: NoorType.meta.copyWith(color: null)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _promptChip(context, Icons.library_books_outlined,
                    'Find a Hadith on…', () => openPrompt('Find a hadith on ')),
                _promptChip(
                    context,
                    Icons.menu_book_outlined,
                    'What does the Qur’an say about…',
                    () => openPrompt('What does the Qur’an say about ')),
                _promptChip(context, Icons.auto_stories_outlined,
                    'Find an Ayah on…', () => openPrompt('Find an ayah on ')),
              ]),
              const SizedBox(height: 22),
              _row(context, 'Suggested Questions', onTap: openChat),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount:
                    MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio:
                    MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 2.5 : 1.45,
                children: [
                  _suggested(
                      context,
                      Icons.menu_book,
                      SampleData.suggestedQuestions[0],
                      () => openQuestion(SampleData.suggestedQuestions[0])),
                  _suggested(
                      context,
                      Icons.self_improvement,
                      SampleData.suggestedQuestions[1],
                      () => openQuestion(SampleData.suggestedQuestions[1])),
                  _suggested(
                      context,
                      Icons.favorite_border,
                      SampleData.suggestedQuestions[2],
                      () => openQuestion(SampleData.suggestedQuestions[2])),
                  _suggested(
                      context,
                      Icons.star_border,
                      SampleData.suggestedQuestions[3],
                      () => openQuestion(SampleData.suggestedQuestions[3])),
                ],
              ),
              const SizedBox(height: 20),
              _row(context, 'Recent Conversations', onTap: openChat),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                    color: NoorTheme.surface(context),
                    borderRadius: BorderRadius.circular(NoorRadius.card),
                    boxShadow: NoorShadows.card),
                child: Material(
                    color: NoorTheme.surface(context),
                    borderRadius: BorderRadius.circular(NoorRadius.card),
                    child: Column(children: [
                      if (_savedChats.isNotEmpty)
                        for (var i = 0;
                            i < _savedChats.take(3).length;
                            i++) ...[
                          if (i > 0)
                            Divider(
                                height: 1,
                                indent: 62,
                                color: NoorTheme.border(context)),
                          ListTile(
                            onTap: () => openQuestion(
                                '${_savedChats[i]['question'] ?? ''}'),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                  color: NoorColors.emeraldDark,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.chat_outlined,
                                  color: NoorColors.gold, size: 18),
                            ),
                            title: Text('${_savedChats[i]['question'] ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NoorType.secondary),
                            subtitle: Text('${_savedChats[i]['answer'] ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NoorType.meta.copyWith(
                                    color: NoorTheme.muted(context))),
                            trailing: ExcludeSemantics(
                                child: Icon(Icons.chevron_right,
                                    size: 18,
                                    color: NoorTheme.muted(context))),
                          ),
                        ]
                      else
                        for (var i = 0;
                            i < SampleData.recentChats.length;
                            i++) ...[
                          if (i > 0)
                            Divider(
                                height: 1,
                                indent: 62,
                                color: NoorTheme.border(context)),
                          ListTile(
                            onTap: () =>
                                openQuestion(SampleData.recentChats[i].$1),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                  color: NoorColors.emeraldDark,
                                  shape: BoxShape.circle),
                              child: Icon(
                                  [
                                    Icons.menu_book,
                                    Icons.nightlight,
                                    Icons.star
                                  ][i],
                                  color: NoorColors.gold,
                                  size: 18),
                            ),
                            title: Text(SampleData.recentChats[i].$1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NoorType.secondary),
                            subtitle: Text(
                                const [
                                  'Fasting on the day of doubt is discouraged…',
                                  'Morning and evening adhkar, with sources…',
                                  'Reciting Al-Kahf on Friday, with sources…',
                                ][i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NoorType.meta.copyWith(
                                    color: NoorTheme.muted(context))),
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(SampleData.recentChats[i].$2,
                                      style: NoorType.meta.copyWith(
                                          color: NoorTheme.muted(context))),
                                  ExcludeSemantics(
                                      child: Icon(Icons.chevron_right,
                                          size: 18,
                                          color: NoorTheme.muted(context))),
                                ]),
                          ),
                        ],
                    ])),
              ),
              const SizedBox(height: 16),
              // Lantern promo card — real lantern.png (Pages 09/12).
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [NoorColors.emeraldDark, NoorColors.emeraldMid]),
                  borderRadius: BorderRadius.circular(NoorRadius.heroCard),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(NoorAssets.lantern,
                        width: 74,
                        cacheWidth: 222,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 74,
                            height: 96,
                            color: NoorColors.emeraldMid)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ask. Learn. Grow.',
                              style: NoorType.cardTitle
                                  .copyWith(color: Colors.white)),
                          const SizedBox(height: 5),
                          Text(
                              'Answers from trusted Islamic sources, powered by AI.',
                              style: NoorType.meta.copyWith(
                                  color: Colors.white70, height: 1.45)),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: openChat,
                            style: FilledButton.styleFrom(
                              backgroundColor: NoorColors.cream,
                              foregroundColor: NoorColors.emeraldDark,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                            ),
                            child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Learn More'),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, size: 16),
                                ]),
                          ),
                        ]),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              _row(context, 'Popular Topics', onTap: openChat),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (var i = 0;
                        i < SampleData.popularTopics.length;
                        i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Semantics(
                        button: true,
                        label: SampleData.popularTopics[i],
                        child: Material(
                          color: NoorTheme.surface(context),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () =>
                                openQuestion(SampleData.popularTopics[i]),
                            child: Container(
                              constraints: const BoxConstraints(
                                  minWidth: 78, minHeight: 48),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: NoorTheme.border(context)),
                              ),
                              child: Column(children: [
                                Icon(
                                    [
                                      Icons.menu_book_outlined,
                                      Icons.library_books_outlined,
                                      Icons.balance_outlined,
                                      Icons.favorite_border,
                                      Icons.mosque_outlined
                                    ][i],
                                    color: NoorTheme.accent(context),
                                    size: 22),
                                const SizedBox(height: 7),
                                Text(SampleData.popularTopics[i],
                                    style: NoorType.meta.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: NoorTheme.foreground(context),
                                    )),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      ),
    );
  }

  Widget _promptChip(BuildContext context, IconData icon, String label,
          VoidCallback onTap) =>
      Semantics(
          button: true,
          label: label,
          child: Material(
              color: NoorTheme.surface(context),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: NoorTheme.border(context))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(icon, size: 16, color: null),
                        const SizedBox(width: 7),
                        Flexible(
                            child: Text(label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: NoorType.meta)),
                      ])))));

  Widget _row(BuildContext context, String title, {VoidCallback? onTap}) =>
      Row(children: [
        Expanded(
            child: Semantics(
                header: true, child: Text(title, style: NoorType.cardTitle))),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: NoorTheme.accent(context),
            ),
            child: const Text('View All', style: NoorType.secondary),
          ),
      ]);

  Widget _suggested(BuildContext context, IconData icon, String text,
          VoidCallback onTap) =>
      Semantics(
          button: true,
          label: text,
          child: Material(
            color: NoorTheme.surface(context),
            borderRadius: BorderRadius.circular(NoorRadius.card),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(NoorRadius.card),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NoorRadius.card),
                  border: Border.all(color: NoorTheme.border(context)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: NoorTheme.accent(context), size: 22),
                      const Spacer(),
                      Text(text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: NoorType.meta.copyWith(height: 1.35)),
                    ]),
              ),
            ),
          ));
}
