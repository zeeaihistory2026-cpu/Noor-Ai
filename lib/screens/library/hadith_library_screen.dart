import 'package:flutter/material.dart';
import '../../data/hadith_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'hadith_chapters_screen.dart';

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
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: const Icon(Icons.search,
                              color: NoorColors.mutedDark, size: 20),
                          hintText:
                              'Search Hadith books, topics or keywords...',
                          hintStyle: NoorType.meta.copyWith(color: NoorColors.muted),
                          suffixIcon: const Icon(Icons.tune,
                              size: 19, color: NoorColors.emeraldDark))),
                ))),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
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
