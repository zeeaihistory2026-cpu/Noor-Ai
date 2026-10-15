import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';import '../ai/ai_chat_screen.dart';
import '../../data/hadith_service.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Page 17 — Hadith Detail + AI Explanation. REAL hadith text from
/// the live databank ([HadithService]): the chosen book/section is
/// opened, the entry's number, chapter title and grades come from
/// the databank response itself — never fabricated. Brief
/// attributed excerpt only in code; full text is runtime-only.
///
/// * Bookmark persists in NoorStore (bookmark id
///   `hadith:<edition>:<hadithnumber>`).
/// * Copy puts the text + reference on the clipboard; Share uses
///   the platform share sheet.
/// * The AI explanation card stays labelled "AI explanation —
///   sample, not source text": descriptive, no fatwa, with the
///   scholar note kept. It is visually separate from the source
///   text, exactly as the design draws it.
class HadithDetailScreen extends StatefulWidget {
  const HadithDetailScreen({
    super.key,
    required this.book,
    required this.sectionNumber,
    this.entryIndex = 0,
  });

  final HadithBook book;
  final int sectionNumber;
  final int entryIndex;

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  late final HadithService _svc;
  late int _index;
  late List<HadithEntry> _inSection;
  bool _saved = false;
  String? _arabic; // Arabic line (rtl), loaded when primary isn't Arabic
  String? _translation; // English line, loaded when primary IS Arabic

  HadithEntry get _entry => _inSection[_index];
  HadithSection get _section => widget.book.sectionOf(_entry);
  bool get _isArabic => widget.book.language == HadithLanguage.ara;

  String get _bookmarkId =>
      HadithService.bookmarkId(widget.book.edition, _entry.hadithnumber);

  @override
  void initState() {
    super.initState();
    _svc = HadithService();
    _inSection = widget.book.hadithsInSection(widget.sectionNumber);
    _index = widget.entryIndex.clamp(0, _inSection.length - 1);
    NoorStore.isBookmarked(_bookmarkId).then((v) {
      if (mounted) setState(() => _saved = v);
    });
    _loadCompanionText();
  }

  /// Loads the Arabic line when the primary language isn't Arabic
  /// (or the English line when it is). Companion edition only;
  /// failure is silent — the primary text always stands alone.
  Future<void> _loadCompanionText() async {
    final want =
        _isArabic ? HadithLanguage.eng : HadithLanguage.ara;
    try {
      final other = await _svc.fetchEdition(widget.book.id, language: want);
      final match = other.entryByNumber(_entry.hadithnumber);
      if (!mounted || match == null) return;
      setState(() {
        if (_isArabic) {
          _translation = match.text;
        } else {
          _arabic = match.text;
        }
      });
    } catch (_) {
      /* companion text is a bonus, not a requirement */
    }
  }

  Future<void> _toggleSave() async {
    final v = await NoorStore.toggleBookmark(_bookmarkId);
    if (mounted) {
      setState(() => _saved = v);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(v ? 'Bookmarked' : 'Removed from bookmarks')));
    }
  }

  String get _shareText =>
      '"${_entry.text}"\n— ${widget.book.name} • Hadith ${_entry.hadithnumber}';

  Future<void> _copyHadith() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied - paste anywhere to share')));
    }
  }

  Future<void> _shareHadith() async {
    await SharePlus.instance.share(ShareParams(
        text: _shareText,
        subject: '${widget.book.name} • Hadith ${_entry.hadithnumber}'));
  }

  void _step(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= _inSection.length) return;
    setState(() {
      _index = next;
      _arabic = null;
      _translation = null;
    });
    NoorStore.isBookmarked(_bookmarkId).then((v) {
      if (mounted) setState(() => _saved = v);
    });
    _loadCompanionText();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
          child: Column(children: [
        _noorHeader(context),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
              _prevNextBar(),
              const SizedBox(height: 10),
              Container(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                  decoration: BoxDecoration(
                      color: NoorColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(NoorRadius.card),
                      border: Border.all(color: NoorColors.hairline)),
                  child: Column(children: [
                    if (_arabic != null) ...[
                      Text(_arabic!,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: NoorType.screenTitle.copyWith(
                              height: 1.6, color: NoorColors.emeraldDark)),
                      const SizedBox(height: 14),
                    ],
                    Text(
                        _isArabic ? _entry.text : '"${_entry.text}"',
                        textDirection: _isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: _isArabic
                            ? NoorType.screenTitle.copyWith(
                                height: 1.6,
                                color: NoorColors.emeraldDark)
                            : NoorType.body.copyWith(height: 1.5)),
                    if (_translation != null) ...[
                      const SizedBox(height: 14),
                      Text('"$_translation"',
                          textAlign: TextAlign.center,
                          style: NoorType.body.copyWith(height: 1.5)),
                    ],
                    if (_entry.grades.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text('Grade: ${_entry.grades.join(' · ')}',
                          style: NoorType.meta
                              .copyWith(color: NoorColors.emeraldDark)),
                    ],
                    const SizedBox(height: 16),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            '${widget.book.name} • Hadith ${_entry.hadithnumber}',
                            style: NoorType.meta
                                .copyWith(color: NoorColors.emeraldDark))),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Chapter ${_section.number}: ${_section.title}',
                            style: NoorType.meta
                                .copyWith(color: NoorColors.muted))),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _action(Icons.volume_up_outlined, 'Listen', null),
                          _action(
                              _saved ? Icons.bookmark : Icons.bookmark_border,
                              'Save',
                              _toggleSave),
                          _action(Icons.share_outlined, 'Share', _shareHadith),
                          _action(Icons.copy_outlined, 'Copy', _copyHadith),
                        ]),
                  ])),
              const SizedBox(height: 14),
              _card(
                  'AI explanation — sample, not source text',
                  'A brief, descriptive explanation of this hadith\'s theme '
                      'would appear here. This is a sample explanation, '
                      'separate from the original text above — never a '
                      'ruling. For personal rulings, consult a scholar.'),
              const SizedBox(height: 12),
              _card('Context',
                  'Chapter ${_section.number}: ${_section.title}. This is '
                      'hadith ${_index + 1} of ${_inSection.length} in this '
                      'chapter (${widget.book.name}, no. ${_entry.hadithnumber}).'),
              const SizedBox(height: 12),
              _card('Related Sources',
                  'Other hadiths in "${_section.title}" appear with the '
                      'arrows above; related Qur\'an verses on this theme '
                      'are in the AI Companion\'s topic search.'),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiChatScreen())),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: const Text('Ask AI About This Hadith')),
            ])),
      ])));

  Widget _prevNextBar() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
                onPressed: _index > 0 ? () => _step(-1) : null,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Previous')),
            Text('Hadith ${_index + 1} of ${_inSection.length}',
                style: NoorType.meta.copyWith(color: NoorColors.muted)),
            TextButton.icon(
                onPressed:
                    _index < _inSection.length - 1 ? () => _step(1) : null,
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('Next'),
                iconAlignment: IconAlignment.end),
          ]);

  Widget _action(IconData icon, String label, VoidCallback? onTap) => Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color:
                      onTap == null ? NoorColors.sand : NoorColors.emeraldSoft,
                  shape: BoxShape.circle),
              child: Icon(icon,
                  size: 19,
                  color: onTap == null
                      ? NoorColors.mutedDark
                      : NoorColors.emeraldDark)),
          const SizedBox(height: 5),
          Text(label, style: NoorType.meta)
        ]),
      ));
  Widget _card(String title, String body) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NoorColors.hairline)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: NoorType.body),
        const SizedBox(height: 7),
        Text(body,
            style: NoorType.meta.copyWith(color: NoorColors.muted, height: 1.45))
      ]));

  /// Emerald sub-page header as drawn on this page of the design.
  Widget _noorHeader(BuildContext context) => Container(
        color: NoorColors.emeraldDark,
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
        child: Row(children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 19),
              onPressed: () => Navigator.of(context).maybePop()),
          Expanded(
              child: Column(children: [
            Text('Hadith Detail + AI Explanation',
                textAlign: TextAlign.center,
                style: NoorType.screenTitle.copyWith(color: Colors.white)),
            const SizedBox(height: 2),
            Text('${widget.book.name} • Hadith ${_entry.hadithnumber}',
                style: NoorType.meta.copyWith(color: Colors.white70)),
          ])),
          IconButton(
              tooltip: 'Hadith options',
              icon: const Icon(Icons.more_vert, color: Colors.white),
              // Phase 16 audit: real actions — copy reuses the same
              // text the Copy button copies; Ask AI opens the chat.
              onPressed: () => showNoorOverflowSheet(context,
                  title: 'Hadith ${_entry.hadithnumber}',
                  actions: [
                    (
                      Icons.copy_outlined,
                      'Copy hadith text',
                      _copyHadith
                    ),
                    (
                      Icons.chat_outlined,
                      'Ask AI about this hadith',
                      () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AiChatScreen()))
                    ),
                  ])),
        ]),
      );
}
