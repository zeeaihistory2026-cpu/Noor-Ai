import 'package:flutter/material.dart';
import '../../data/hadith_service.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'hadith_detail_screen.dart';

/// Page 16 — Hadith Book / Chapters. Real chapter list from the
/// live databank ([HadithService]): `metadata.sections` of the
/// chosen book, with true per-chapter hadith counts. Chapters/
/// Bookmarks/Notes chips kept as drawn; Bookmarks lists this
/// edition's saved hadiths (persisted in NoorStore); Notes has no
/// backing store yet and says so honestly.
///
/// Offline: the service falls back to its compressed disk cache
/// ("Cached · offline"); with no cache at all, an honest banner +
/// retry is shown instead of fabricated chapters. Search filters
/// chapter titles; when no title matches, a bounded live text
/// scan runs across the book's sections (results labelled as
/// such). Per-section scan is [HadithBook.searchInSection];
/// full cross-book live search is a documented v2.
class HadithChaptersScreen extends StatefulWidget {
  const HadithChaptersScreen({
    super.key,
    required this.bookId,
    this.initialLanguage = HadithLanguage.eng,
    this.initialHadithNumber,
  });

  final String bookId;
  final HadithLanguage initialLanguage;

  /// Optional deep-link (from topic-index results): opens the
  /// detail of this global hadith number after load.
  final int? initialHadithNumber;

  @override
  State<HadithChaptersScreen> createState() => _HadithChaptersScreenState();
}

class _HadithChaptersScreenState extends State<HadithChaptersScreen> {
  late final HadithService _svc;
  late HadithLanguage _language;
  HadithBook? _book;
  String? _error;
  bool _cachedOffline = false;
  int _chip = 0;
  String _q = '';
  List<HadithEntry> _scanHits = const [];
  bool _deepLinked = false;

  @override
  void initState() {
    super.initState();
    _svc = HadithService();
    _language = widget.initialLanguage;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _book = null;
      _error = null;
      _cachedOffline = false;
      _scanHits = const [];
    });
    try {
      final book = await _svc.fetchEdition(widget.bookId, language: _language);
      if (!mounted) return;
      setState(() {
        _book = book;
        _cachedOffline = !_svc.hasLive;
      });
      _maybeDeepLink();
    } on HadithServiceException catch (e) {
      if (!mounted) return;
      // Graceful: disk cache before giving up.
      final cached =
          await _svc.cachedEdition(widget.bookId, language: _language);
      if (!mounted) return;
      if (cached != null) {
        setState(() {
          _book = cached;
          _cachedOffline = true;
        });
        _maybeDeepLink();
      } else {
        setState(() => _error = e.message);
      }
    }
  }

  void _maybeDeepLink() {
    final n = widget.initialHadithNumber;
    final book = _book;
    if (_deepLinked || n == null || book == null) return;
    final entry = book.entryByNumber(n);
    if (entry == null) return;
    _deepLinked = true;
    final inSection = book.hadithsInSection(entry.sectionNumber);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => HadithDetailScreen(
              book: book,
              sectionNumber: entry.sectionNumber,
              entryIndex: inSection.indexOf(entry))));
    });
  }

  bool _isNumberSearch(String q) =>
      RegExp(r'^(?:hadith\s*#?|#)?\s*(\d+)$', caseSensitive: false)
          .hasMatch(q.trim());

  void _onSearchChanged(String v) {
    setState(() => _q = v);
    final book = _book;
    final q = v.trim();
    if (book == null || q.isEmpty) {
      setState(() => _scanHits = const []);
      return;
    }

    // 1. Direct Hadith Number Search (e.g. "1", "42", "#42", "hadith 42")
    final numMatch = RegExp(r'^(?:hadith\s*#?|#)?\s*(\d+)$', caseSensitive: false)
        .firstMatch(q);
    if (numMatch != null) {
      final numVal = int.tryParse(numMatch.group(1)!);
      if (numVal != null) {
        final hit = book.entryByNumber(numVal);
        if (hit != null) {
          setState(() => _scanHits = [hit]);
          return;
        }
      }
    }

    if (q.length < 3) {
      setState(() => _scanHits = const []);
      return;
    }
    final titleHit = book.sections
        .any((s) => s.title.toLowerCase().contains(q.toLowerCase()));
    if (titleHit) {
      setState(() => _scanHits = const []);
      return;
    }
    // Bounded live text scan (one pass over the loaded book only).
    final hits = <HadithEntry>[];
    for (final s in book.sections) {
      hits.addAll(book.searchInSection(s.number, q));
      if (hits.length >= 12) break;
    }
    setState(() => _scanHits = hits.take(12).toList());
  }

  void _openSection(int sectionNumber, [int entryIndex = 0]) {
    final book = _book;
    if (book == null) return;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HadithDetailScreen(
            book: book,
            sectionNumber: sectionNumber,
            entryIndex: entryIndex)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: Column(children: [
          _noorHeader(context,
              onBookmarks: () => setState(() => _chip = 1)),
          Expanded(child: _body()),
        ])));
  }

  Widget _body() {
    if (_book == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 40),
        const Icon(Icons.cloud_off_outlined, size: 44, color: NoorColors.muted),
        const SizedBox(height: 14),
        const Text('The full book needs a connection',
            textAlign: TextAlign.center, style: NoorType.cardTitle),
        const SizedBox(height: 8),
        Text(
            'This chapter list comes from the live hadith databank, '
            'so it cannot load offline yet. Nothing is shown from '
            'memory — the curated topic index in the AI Companion '
            'still works offline.',
            textAlign: TextAlign.center,
            style: NoorType.meta.copyWith(color: NoorColors.muted, height: 1.5)),
        const SizedBox(height: 18),
        Center(
            child: FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'))),
      ]);
    }
    final book = _book!;
    final rows = book.sections
        .where((s) => s.title.toLowerCase().contains(_q.trim().toLowerCase()))
        .toList();
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: NoorColors.emeraldSoft,
                  borderRadius: BorderRadius.circular(NoorRadius.card)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(book.name,
                              style: NoorType.section
                                  .copyWith(color: NoorColors.emeraldDark))),
                      _statusPill(),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                        '${_fmt(book.hadiths.length)} hadiths · ${book.sections.length} chapters',
                        style: NoorType.meta.copyWith(color: NoorColors.muted)),
                    const SizedBox(height: 12),
                    // Language chooser: Arabic + English + Urdu.
                    Row(children: [
                      for (final l in HadithLanguage.values) ...[
                        _langChip(l),
                        const SizedBox(width: 8),
                      ]
                    ]),
                  ])),
          const SizedBox(height: 14),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NoorColors.hairline)),
              child: TextField(
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchChanged,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search by Hadith # (e.g. 1) or chapter...',
                      hintStyle:
                          NoorType.secondary.copyWith(color: NoorColors.muted),
                      suffixIcon: const Icon(Icons.search,
                          size: 19, color: NoorColors.emeraldDark)))),
          const SizedBox(height: 14),
          Row(children: [
            for (var i = 0; i < 3; i++) ...[
              Semantics(
                  button: true,
                  child: GestureDetector(
                      onTap: () => setState(() => _chip = i),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                              color: _chip == i
                                  ? NoorColors.emeraldDark
                                  : NoorColors.emeraldSoft,
                              borderRadius: BorderRadius.circular(99)),
                          child: Text(const ['Chapters', 'Bookmarks', 'Notes'][i],
                              style: NoorType.meta.copyWith(
                                  color: _chip == i
                                      ? Colors.white
                                      : NoorColors.ink))))),
              const SizedBox(width: 8),
            ]
          ]),
          const SizedBox(height: 14),
          if (_chip == 0) ...[
            if (_scanHits.isNotEmpty) ...[
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                      _isNumberSearch(_q)
                          ? 'Hadith #${_scanHits.first.hadithnumber} (Exact match)'
                          : 'Text matches (live scan) — ${_scanHits.length}',
                      style: NoorType.meta.copyWith(
                          color: _isNumberSearch(_q)
                              ? NoorColors.emeraldDark
                              : NoorColors.muted,
                          fontWeight: _isNumberSearch(_q)
                              ? FontWeight.w700
                              : FontWeight.normal))),
              for (final h in _scanHits) _hitRow(book, h),
            ] else
              for (final s in rows) _chapterRow(book, s),
            if (rows.isEmpty && _scanHits.isEmpty && _q.trim().isNotEmpty)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                      child: Text(
                          _isNumberSearch(_q)
                              ? 'Hadith #$_q not found in ${book.name}.\n(Valid range: 1 – ${book.hadiths.length})'
                              : 'No chapter or text matched.',
                          textAlign: TextAlign.center,
                          style: NoorType.secondary
                              .copyWith(color: NoorColors.muted)))),
          ] else if (_chip == 1)
            _bookmarksTab(book)
          else
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                    child: Text('Nothing saved here yet.',
                        style: NoorType.secondary
                            .copyWith(color: NoorColors.muted)))),
        ]);
  }

  Widget _langChip(HadithLanguage l) {
    final selected = l == _language;
    return Semantics(
        button: true,
        child: GestureDetector(
            onTap: selected
                ? null
                : () {
                    setState(() => _language = l);
                    _load();
                  },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                    color: selected ? NoorColors.emeraldDark : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: selected
                            ? NoorColors.emeraldDark
                            : NoorColors.hairline)),
                child: Text(l.label,
                    style: NoorType.meta.copyWith(
                        color: selected ? Colors.white : NoorColors.ink)))));
  }

  Widget _statusPill() {
    final label = _cachedOffline ? 'Cached · offline' : 'Live databank';
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: _cachedOffline
                      ? NoorColors.muted
                      : NoorColors.emerald,
                  shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: NoorType.meta.copyWith(color: NoorColors.emeraldDark)),
        ]));
  }

  Widget _chapterRow(HadithBook book, HadithSection s) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
              onTap: () => _openSection(s.number),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NoorColors.hairline)),
                  child: Row(children: [
                    Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: NoorColors.emeraldSoft,
                            shape: BoxShape.circle),
                        child: Text('${s.number}',
                            style: NoorType.secondary
                                .copyWith(color: NoorColors.emeraldDark))),
                    const SizedBox(width: 13),
                    Expanded(
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                          Text(s.title, style: NoorType.body),
                          const SizedBox(height: 3),
                          Text('${s.count} narrations',
                              style: NoorType.meta
                                  .copyWith(color: NoorColors.muted))
                        ])),
                    const Icon(Icons.chevron_right,
                        size: 19, color: NoorColors.muted),
                  ])))));

  Widget _hitRow(HadithBook book, HadithEntry h) {
    final section = book.sectionOf(h);
    final inSection = book.hadithsInSection(h.sectionNumber);
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
                onTap: () =>
                    _openSection(h.sectionNumber, inSection.indexOf(h)),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NoorColors.hairline)),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                            Text('Hadith ${h.hadithnumber}',
                                style: NoorType.secondary.copyWith(
                                    color: NoorColors.emeraldDark)),
                            const SizedBox(height: 3),
                            Text(section.title,
                                style: NoorType.meta.copyWith(
                                    color: NoorColors.muted)),
                          ])),
                      const Icon(Icons.chevron_right,
                          size: 19, color: NoorColors.muted),
                    ])))));
  }

  Widget _bookmarksTab(HadithBook book) => FutureBuilder<List<String>>(
      future: NoorStore.getBookmarks(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()));
        }
        final prefix = 'hadith:${book.edition}:';
        final entries = <HadithEntry>[];
        for (final id in snap.data!) {
          if (!id.startsWith(prefix)) continue;
          final n = int.tryParse(id.substring(prefix.length));
          final e = n == null ? null : book.entryByNumber(n);
          if (e != null) entries.add(e);
        }
        if (entries.isEmpty) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                  child: Text('Nothing saved here yet.',
                      style: NoorType.secondary
                          .copyWith(color: NoorColors.muted))));
        }
        return Column(
            children: [for (final e in entries) _hitRow(book, e)]);
      });

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// Emerald sub-page header as drawn on this page of the design.
///
/// Phase 16 audit: the ⋮ jumps to the real Bookmarks tab and states
/// the honest databank limits.
Widget _noorHeader(BuildContext context, {required VoidCallback onBookmarks}) =>
    Container(
      color: NoorColors.emeraldDark,
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
      child: Row(children: [
        IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 19),
            onPressed: () => Navigator.of(context).maybePop()),
        Expanded(
            child: Column(children: [
          Text('Hadith Book / Chapters',
              textAlign: TextAlign.center,
              style: NoorType.screenTitle.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text('Structured reading',
              style: NoorType.meta.copyWith(color: Colors.white70)),
        ])),
        IconButton(
            tooltip: 'Book options',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => showNoorOverflowSheet(context,
                title: 'Hadith book',
                info: const [
                  'Full cross-book keyword search needs a server-side index — coming in a later version. Use the chapter list and the in-book search above.',
                ],
                actions: [
                  (
                    Icons.bookmark_border,
                    'View my bookmarks',
                    onBookmarks
                  ),
                ])),
      ]),
    );
