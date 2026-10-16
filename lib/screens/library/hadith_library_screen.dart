import 'package:flutter/material.dart';
import '../../data/hadith_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'hadith_chapters_screen.dart';
import 'hadith_detail_screen.dart';

/// Page 15 — Hadith Library. Deep-green header with the real
/// mosque/lantern skyline crop, overlapping search pill, Featured
/// Collections, Browse by Category, Popular Books, and the Build
/// Your Knowledge card. Book names/counts as drawn; the six
/// canonical books open the LIVE full databank
/// ([HadithService]) — each book's real chapter list and full
/// hadith text are fetched at runtime from the CDN, never
/// embedded. The small "Live databank" pill reflects
/// [HadithService.hasLive] honestly (offline = honest banner).
class HadithLibraryScreen extends StatefulWidget {
  const HadithLibraryScreen({super.key});
  @override
  State<HadithLibraryScreen> createState() => _HadithLibraryScreenState();
}

class _HadithLibraryScreenState extends State<HadithLibraryScreen> {
  final HadithService _svc = HadithService();
  String _q = '';
  bool? _live; // null = checking
  HadithLanguage _lang = HadithLanguage.eng;

  /// Design-drawn cover per book; books without a dedicated cover
  /// reuse the generic one (no asset invented).
  static const Map<String, String> _covers = {
    'bukhari': NoorAssets.hadithCoverBukhari,
    'muslim': NoorAssets.hadithCoverMuslim,
    'tirmidhi': NoorAssets.hadithCoverTirmidhi,
    'abudawud': NoorAssets.hadithCoverDawud,
  };

  /// Featured row order, as drawn (first four covers).
  static const List<String> _featured = ['bukhari', 'muslim', 'tirmidhi', 'abudawud'];

  /// Design-drawn count labels per book (from SampleData.hadithBooks
  /// order, keyed by id since the live list is ordered
  /// differently). These are the design's labels; the REAL
  /// per-book count is shown once the book itself is opened.
  static const Map<String, String> _countLabels = {
    'bukhari': '7,563 Hadith',
    'muslim': '4,301 Hadith',
    'tirmidhi': '3,956 Hadith',
    'abudawud': '4,803 Hadith',
    'nasai': '5,578 Hadith',
    'ibnmajah': '4,341 Hadith',
  };

  @override
  void initState() {
    super.initState();
    _svc.checkLive().then((live) {
      if (mounted) setState(() => _live = live);
    });
  }

  void _openBook(String bookId) => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => HadithChaptersScreen(bookId: bookId, initialLanguage: _lang)));

  void _openNumberSearchDialog({String? initialQuery, String? initialBookId}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _HadithNumberSearchModal(
        initialQuery: initialQuery,
        initialBookId: initialBookId ?? 'bukhari',
        initialLanguage: _lang,
      ),
    );
  }

  static const _catIcons = [
    Icons.star_outline,
    Icons.mosque_outlined,
    Icons.favorite_border,
    Icons.business_center_outlined,
    Icons.family_restroom_outlined,
    Icons.restaurant_outlined,
    Icons.shield_outlined,
    Icons.medication_outlined
  ];

  @override
  Widget build(BuildContext context) {
    final books = HadithService.books
        .where((b) => b.name.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
          child: Column(children: [
        NoorDarkHeader(
          title: 'Hadith Library',
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          actions: [
            IconButton(
                tooltip: 'Search by Hadith Number',
                icon: const Icon(Icons.tag, color: Colors.white),
                onPressed: () => _openNumberSearchDialog()),
            IconButton(
                tooltip: 'About the databank',
                icon: const Icon(Icons.menu_book_outlined,
                    color: Colors.white),
                // Phase 16 audit: honest databank info — the same
                // sourcing the HadithDatabankGate documents.
                onPressed: () => showNoorOverflowSheet(context,
                    title: 'Hadith databank',
                    info: const [
                      'The complete text of all six books loads live from the free hadith-api CDN (fawazahmed0), in English, Arabic and Urdu.',
                      'Sunnah.com grades are a future upgrade and need an API key — grades show only where the databank ships them.',
                    ])),
          ],
          child: Image.asset(NoorAssets.hadithLibraryHeader,
              cacheWidth: 1170,
              height: 74,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 24)),
        ),
        Transform.translate(
            offset: const Offset(0, -22),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: NoorShadows.card),
                  child: TextField(
                      onChanged: (v) => setState(() => _q = v),
                      onSubmitted: (v) {
                        if (RegExp(r'\d+').hasMatch(v)) {
                          _openNumberSearchDialog(initialQuery: v);
                        }
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: const Icon(Icons.search,
                              color: NoorColors.mutedDark, size: 20),
                          hintText:
                              'Search by Hadith # (e.g. 1) or topic...',
                          hintStyle: NoorType.meta.copyWith(color: NoorColors.muted),
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.tag,
                                  size: 20, color: NoorColors.emeraldDark),
                              tooltip: 'Hadith Number Search',
                              onPressed: () => _openNumberSearchDialog(initialQuery: _q)))),
                ))),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
              if (RegExp(r'\d+').hasMatch(_q)) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Material(
                    color: NoorColors.emeraldDark,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _openNumberSearchDialog(initialQuery: _q),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search, color: NoorColors.gold, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lookup Hadith #${RegExp(r'\d+').firstMatch(_q)?.group(0)} in Databank',
                                    style: NoorType.body.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap to search in Bukhari, Muslim, Abu Dawud, etc.',
                                    style: NoorType.meta.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _openNumberSearchDialog(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: NoorColors.emeraldSoft,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: NoorColors.emeraldMid.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: NoorColors.emeraldDark,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.numbers, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hadith Database Number Search',
                                      style: NoorType.secondary.copyWith(
                                          fontWeight: FontWeight.w700, color: NoorColors.emeraldDark)),
                                  const SizedBox(height: 2),
                                  Text('Directly lookup any Hadith by its number (1 to 7,563)',
                                      style: NoorType.meta.copyWith(color: NoorColors.mutedDark, fontSize: 11.5)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: NoorColors.emeraldDark),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              _rowHead('Featured Collections', _livePill()),
              const SizedBox(height: 10),
              // Language selector: English / Urdu / Arabic
              Row(children: [
                for (final lang in HadithLanguage.values) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _lang = lang),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _lang == lang
                              ? NoorColors.emeraldDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NoorColors.hairline),
                        ),
                        child: Text(lang.label,
                            textAlign: TextAlign.center,
                            style: NoorType.meta.copyWith(
                                color: _lang == lang
                                    ? Colors.white
                                    : NoorColors.ink,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 12),
              // All four featured covers visible across, as drawn.
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var i = 0; i < _featured.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                      child: Semantics(button: true, child: GestureDetector(
                          onTap: () => _openBook(_featured[i]),
                          child: Column(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                    _covers[_featured[i]]!,
                                    width: 76,
                                    cacheWidth: 228,
                                    height: 94,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        width: 76,
                                        height: 94,
                                        color: NoorColors.emeraldDark))),
                            const SizedBox(height: 8),
                            Text(HadithService.bookName(_featured[i]),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: NoorType.meta),
                          ])))),
                ],
              ]),
              const SizedBox(height: 8),
              _rowHead('Browse by Category', null),
              const SizedBox(height: 12),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.95),
                  itemCount: 8,
                  itemBuilder: (_, i) => Semantics(button: true, child: GestureDetector(
                      onTap: () => _openBook('bukhari'),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: NoorColors.hairline)),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(_catIcons[i],
                                    size: 22, color: NoorColors.emeraldDark),
                                const SizedBox(height: 8),
                                Text(SampleData.hadithCategories[i].$1,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: NoorType.meta.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.2)),
                                const SizedBox(height: 4),
                                Text(SampleData.hadithCategories[i].$2,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: NoorType.meta.copyWith(
                                        color: NoorColors.muted,
                                        fontSize: 11))
                              ]))))),
              const SizedBox(height: 20),
              _rowHead('Popular Books', null),
              const SizedBox(height: 12),
              NoorCard(
                  padding: EdgeInsets.zero,
                  child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(NoorRadius.card),
                      child: Column(children: [
                        for (var i = 0; i < books.length; i++) ...[
                          if (i > 0)
                            const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: NoorColors.hairlineSoft),
                          ListTile(
                              onTap: () => _openBook(books[i].id),
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                      _covers[books[i].id] ??
                                          NoorAssets.hadithBookCover,
                                      width: 34,
                                      cacheWidth: 102,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                          width: 34,
                                          height: 48,
                                          color: NoorColors.emeraldDark))),
                              title: Text(books[i].name,
                                  style: NoorType.secondary),
                              subtitle: Text(books[i].author,
                                  style: NoorType.meta.copyWith(color: NoorColors.muted)),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        // Design-drawn count label for this
                                        // book (keyed by id; see _countLabels).
                                        _countLabels[books[i].id] ?? '',
                                        style: NoorType.meta.copyWith(color: NoorColors.muted)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.bookmark_border,
                                        size: 18, color: NoorColors.emeraldDark)
                                  ])),
                        ],
                        if (books.isEmpty)
                          Padding(
                              padding: const EdgeInsets.all(18),
                              child: Text('No books match your search.',
                                  style: NoorType.meta.copyWith(color: NoorColors.muted))),
                      ]))),
              const SizedBox(height: 16),
              NoorCard(
                  onTap: () => _openBook('bukhari'),
                  child: Row(children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(NoorAssets.hadithBooksLantern,
                            width: 104,
                            cacheWidth: 312,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 104,
                                height: 76,
                                color: NoorColors.emeraldSoft))),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('Build Your Knowledge',
                              style: NoorType.cardTitle),
                          const SizedBox(height: 5),
                          Text(
                              'Read authentic Hadith and improve your understanding of Islam.',
                              style: NoorType.meta.copyWith(color: NoorColors.mutedDark,
                                  height: 1.4)),
                          const SizedBox(height: 10),
                          FilledButton(
                              onPressed: () => _openBook('bukhari'),
                              style: FilledButton.styleFrom(
                                  backgroundColor: NoorColors.emeraldDark,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8)),
                              child: const Text('Continue Reading →',
                                  style: TextStyle(color: Colors.white))),
                        ])),
                  ])),
            ])),
      ])),
    );
  }

  /// Honest connectivity pill: live databank vs offline. Null while
  /// the check is in flight (no claim made before the answer).
  Widget _livePill() {
    if (_live == null) {
      return const SizedBox(
          width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2));
    }
    final live = _live!;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: live ? NoorColors.emeraldSoft : NoorColors.sand,
            borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: live ? NoorColors.emerald : NoorColors.muted,
                  shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(live ? 'Live databank' : 'Offline',
              style: NoorType.meta.copyWith(
                  color: live ? NoorColors.emeraldDark : NoorColors.mutedDark)),
        ]));
  }

  Widget _rowHead(String t, Widget? trailing) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t, style: NoorType.cardTitle),
        trailing ?? Text('View All',
            style: NoorType.meta.copyWith(color: NoorColors.emerald))
      ]);
}

/// Modal bottom sheet for interactive Hadith number lookup across the 6 canonical books.
class _HadithNumberSearchModal extends StatefulWidget {
  final String? initialQuery;
  final String initialBookId;
  final HadithLanguage initialLanguage;

  const _HadithNumberSearchModal({
    this.initialQuery,
    this.initialBookId = 'bukhari',
    this.initialLanguage = HadithLanguage.eng,
  });

  @override
  State<_HadithNumberSearchModal> createState() => _HadithNumberSearchModalState();
}

class _HadithNumberSearchModalState extends State<_HadithNumberSearchModal> {
  late String _selectedBookId;
  late HadithLanguage _selectedLanguage;
  late TextEditingController _numberCtrl;
  final HadithService _svc = HadithService();

  bool _isSearching = false;
  String? _errorMessage;
  ({HadithBook book, HadithEntry entry})? _result;

  @override
  void initState() {
    super.initState();
    _selectedBookId = widget.initialBookId;
    _selectedLanguage = widget.initialLanguage;

    final q = widget.initialQuery?.trim() ?? '';
    final digits = RegExp(r'\d+').firstMatch(q)?.group(0) ?? '';
    _numberCtrl = TextEditingController(text: digits);

    // Auto-search if a valid number was prefilled
    if (digits.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _doSearch());
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    final text = _numberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim();
    final number = int.tryParse(text);
    if (number == null || number <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid Hadith number (e.g. 1, 42).';
        _result = null;
      });
      return;
    }

    final maxKnown = HadithService.bookMaxHadiths[_selectedBookId];
    if (maxKnown != null && number > maxKnown + 500) {
      setState(() {
        _errorMessage =
            'Hadith #$number exceeds known range for ${HadithService.bookName(_selectedBookId)} (up to ~$maxKnown).';
        _result = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final res = await _svc.findByNumber(
        _selectedBookId,
        number,
        language: _selectedLanguage,
      );
      if (!mounted) return;
      if (res != null) {
        setState(() {
          _result = res;
          _isSearching = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Hadith #$number not found in ${HadithService.bookName(_selectedBookId)}.';
          _isSearching = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Unable to fetch Hadith from databank. Please verify your connection.';
        _isSearching = false;
      });
    }
  }

  void _openDetail() {
    final res = _result;
    if (res == null) return;
    final inSection = res.book.hadithsInSection(res.entry.sectionNumber);
    final idx = inSection.indexOf(res.entry);
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HadithDetailScreen(
          book: res.book,
          sectionNumber: res.entry.sectionNumber,
          entryIndex: idx >= 0 ? idx : 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookName = HadithService.bookName(_selectedBookId);
    final maxHadiths = HadithService.bookMaxHadiths[_selectedBookId];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: NoorColors.hairline,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: NoorColors.emeraldDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.numbers, color: NoorColors.gold, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hadith Database Number Search',
                        style: NoorType.section.copyWith(color: NoorColors.emeraldDark),
                      ),
                      Text(
                        'Look up any Hadith by its sequential databank number',
                        style: NoorType.meta.copyWith(color: NoorColors.mutedDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Select Book Label
            Text('1. Select Hadith Collection:',
                style: NoorType.meta.copyWith(
                    fontWeight: FontWeight.w700, color: NoorColors.ink)),
            const SizedBox(height: 8),

            // Book Chips Wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HadithService.books.map((b) {
                final isSelected = b.id == _selectedBookId;
                final count = HadithService.bookMaxHadiths[b.id];
                return ChoiceChip(
                  label: Text('${b.name} ${count != null ? "(1–$count)" : ""}'),
                  selected: isSelected,
                  selectedColor: NoorColors.emeraldDark,
                  backgroundColor: NoorColors.emeraldSoft,
                  labelStyle: NoorType.meta.copyWith(
                    color: isSelected ? Colors.white : NoorColors.ink,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedBookId = b.id;
                        _result = null;
                        _errorMessage = null;
                      });
                      if (_numberCtrl.text.trim().isNotEmpty) {
                        _doSearch();
                      }
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Language Selector
            Text('2. Translation Language:',
                style: NoorType.meta.copyWith(
                    fontWeight: FontWeight.w700, color: NoorColors.ink)),
            const SizedBox(height: 8),
            Row(
              children: HadithLanguage.values.map((l) {
                final isSelected = l == _selectedLanguage;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = l;
                        _result = null;
                      });
                      if (_numberCtrl.text.trim().isNotEmpty) {
                        _doSearch();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? NoorColors.emeraldDark : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? NoorColors.emeraldDark : NoorColors.hairline,
                        ),
                      ),
                      child: Text(
                        l.label,
                        textAlign: TextAlign.center,
                        style: NoorType.meta.copyWith(
                          color: isSelected ? Colors.white : NoorColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Number Input
            Text(
              '3. Enter Hadith Number ${maxHadiths != null ? "(1 to $maxHadiths)" : ""}:',
              style: NoorType.meta.copyWith(
                  fontWeight: FontWeight.w700, color: NoorColors.ink),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberCtrl,
                    keyboardType: TextInputType.number,
                    style: NoorType.section.copyWith(color: NoorColors.emeraldDark),
                    onSubmitted: (_) => _doSearch(),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: NoorColors.emeraldMid),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: NoorColors.emeraldDark, width: 2),
                      ),
                      hintText: 'e.g. 1, 42, 100...',
                      prefixIcon: const Icon(Icons.numbers, color: NoorColors.emeraldDark),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NoorColors.emeraldDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSearching ? null : _doSearch,
                  child: _isSearching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          children: [
                            Icon(Icons.search, size: 18),
                            SizedBox(width: 6),
                            Text('Search'),
                          ],
                        ),
                ),
              ],
            ),

            // Error Banner
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: NoorType.meta.copyWith(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Result Preview Card
            if (_result != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NoorColors.emeraldSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NoorColors.emeraldMid.withValues(alpha: 0.3)),
                  boxShadow: NoorShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: NoorColors.emeraldDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Hadith #${_result!.entry.hadithnumber}',
                            style: NoorType.meta.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$bookName · ${_result!.book.sectionOf(_result!.entry).title}',
                            style: NoorType.meta.copyWith(
                              color: NoorColors.emeraldDark,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _result!.entry.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textDirection: _selectedLanguage == HadithLanguage.ara ||
                              _selectedLanguage == HadithLanguage.urd
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: NoorType.body.copyWith(
                        color: NoorColors.ink,
                        height: 1.4,
                      ),
                    ),
                    if (_result!.entry.grades.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _result!.entry.grades.first,
                        style: NoorType.meta.copyWith(
                          color: NoorColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.menu_book, size: 18),
                        label: const Text('Open Full Hadith & Explanation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NoorColors.emeraldDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _openDetail,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
