import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../worship/zikr_tasbih_screen.dart';

/// Detailed Dua Model for category views
class AuthenticDua {
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  final int count;

  const AuthenticDua({
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
    this.count = 1,
  });
}

/// Page 18 — Dua & Adhkar Library.
/// Displays daily adhkar progress, category filters, interactive dua cards,
/// and instant transition to the Tasbih counter or detailed dua sheet.
class DuaLibraryScreen extends StatefulWidget {
  const DuaLibraryScreen({super.key});

  @override
  State<DuaLibraryScreen> createState() => _DuaLibraryScreenState();
}

class _DuaLibraryScreenState extends State<DuaLibraryScreen> {
  int _chip = 0;
  String _q = '';
  final TextEditingController _searchCtrl = TextEditingController();

  static const _chips = ['All', 'Morning', 'Evening', 'Situations'];

  static const Map<String, List<AuthenticDua>> _categoryDuas = {
    'Before Sleep': [
      AuthenticDua(
        arabic: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ',
        transliteration: 'Bismika Rabbi wada\'tu janbi wa bika arfa\'uh',
        translation: 'In Your name my Lord, I lie down and in Your name I rise.',
        reference: 'Sahih al-Bukhari 6320',
        count: 1,
      ),
      AuthenticDua(
        arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        transliteration: 'Allahumma qini \'adhabaka yawma tab\'athu \'ibadak',
        translation: 'O Allah, protect me from Your punishment on the Day You resurrect Your slaves.',
        reference: 'Sunan Abu Dawud 5045',
        count: 3,
      ),
    ],
    'For Knowledge': [
      AuthenticDua(
        arabic: 'رَّبِّ زِدْنِي عِلْمًا',
        transliteration: 'Rabbi zidni \'ilma',
        translation: 'My Lord, increase me in knowledge.',
        reference: 'Surah Ta-Ha 20:114',
        count: 3,
      ),
      AuthenticDua(
        arabic: 'اللَّهُمَّ انْفَعْنِي بِمَا عَلَّمْتَنِي وَعَلِّمْنِي مَا يَنْفَعُنِي',
        transliteration: 'Allahumma infa\'ni bima \'allamtani wa \'allimni ma yanfa\'uni',
        translation: 'O Allah, benefit me with what You taught me and teach me what benefits me.',
        reference: 'Sunan Ibn Majah 251',
        count: 1,
      ),
    ],
    'For Protection': [
      AuthenticDua(
        arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        transliteration: 'A\'udhu bi kalimatil-lahit-tammati min sharri ma khalaq',
        translation: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
        reference: 'Sahih Muslim 2708',
        count: 3,
      ),
      AuthenticDua(
        arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ',
        transliteration: 'Bismillahil-lazi la yadurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\'',
        translation: 'In the Name of Allah, with Whose Name nothing can cause harm in earth or heaven.',
        reference: 'Sunan Abu Dawud 5088',
        count: 3,
      ),
    ],
    'Travel': [
      AuthenticDua(
        arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
        transliteration: 'Subhanal-lazi sakh-khara lana hadha wa ma kunna lahu muqrinin',
        translation: 'Glory be to Him Who has subjected this to us, and we could never have achieved it by ourselves.',
        reference: 'Surah Az-Zukhruf 43:13-14',
        count: 1,
      ),
    ],
    'Forgiveness': [
      AuthenticDua(
        arabic: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
        transliteration: 'Astaghfirullahal-\'Adheem al-lazi la ilaha illa Huwal-Hayyul-Qayyum wa atubu ilayh',
        translation: 'I seek forgiveness from Allah the Magnificent, besides Whom there is no deity, the Ever-Living, and I repent to Him.',
        reference: 'Sunan Abi Dawud 1517',
        count: 3,
      ),
      AuthenticDua(
        arabic: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
        transliteration: 'Rabbighfir li wa tub \'alayya innaka Antat-Tawwabur-Rahim',
        translation: 'My Lord, forgive me and accept my repentance, You are the Accepter of Repentance, the Most Merciful.',
        reference: 'Sunan Abi Dawud 1516',
        count: 100,
      ),
    ],
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openCategoryDetail(String categoryName) {
    if (categoryName == 'Morning Adhkar' ||
        categoryName == 'Evening Adhkar' ||
        categoryName == 'After Salah') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ZikrTasbihScreen(initialTab: 1)),
      );
      return;
    }

    final duas = _categoryDuas[categoryName] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NoorColors.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(categoryName, style: NoorType.section.copyWith(color: NoorColors.emeraldDark)),
                        Text('${duas.length} Authentic Supplications', style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NoorColors.emeraldDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.touch_app, size: 16),
                    label: const Text('Open Tasbih'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ZikrTasbihScreen(initialTab: 0)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (duas.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Dua text will be loaded from authenticated sources.'),
                  ),
                ),
              ] else ...[
                ...duas.map((d) => Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: NoorColors.cream,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NoorColors.hairlineSoft),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.arabic,
                            textDirection: TextDirection.rtl,
                            style: NoorType.arabic(size: 20, color: NoorColors.emeraldDark),
                          ),
                          const SizedBox(height: 8),
                          Text(d.transliteration, style: NoorType.secondary.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(d.translation, style: NoorType.meta.copyWith(color: NoorColors.mutedDark, height: 1.4)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(d.reference, style: NoorType.meta.copyWith(color: NoorColors.emerald, fontSize: 11)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NoorColors.emeraldSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${d.count}x', style: NoorType.meta.copyWith(color: NoorColors.emeraldDark, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = SampleData.duaCategories
        .where((c) =>
            (_chip == 0 || c.$3 == _chips[_chip]) &&
            (c.$1.toLowerCase().contains(_q.toLowerCase()) ||
                c.$2.toLowerCase().contains(_q.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // Daily Adhkar Progress Banner
                  Material(
                    color: NoorColors.emeraldSoft,
                    borderRadius: BorderRadius.circular(NoorRadius.card),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ZikrTasbihScreen(initialTab: 1)),
                      ),
                      borderRadius: BorderRadius.circular(NoorRadius.card),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(NoorRadius.card),
                          border: Border.all(color: NoorColors.emerald.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Daily Adhkar Practice',
                                  style: NoorType.section.copyWith(color: NoorColors.emeraldDark, fontWeight: FontWeight.w700),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: NoorColors.emeraldDark),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Morning set • 8 of 15 completed',
                              style: NoorType.meta.copyWith(color: NoorColors.mutedDark),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: const LinearProgressIndicator(
                                value: 8 / 15,
                                minHeight: 7,
                                backgroundColor: Colors.white,
                                color: NoorColors.emeraldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Search Bar with Clear Icon
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NoorColors.hairline),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _q = v),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search duas, categories...',
                        hintStyle: NoorType.secondary.copyWith(color: NoorColors.muted),
                        suffixIcon: _q.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _q = '');
                                },
                              )
                            : const Icon(Icons.search, size: 20, color: NoorColors.emeraldDark),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (var i = 0; i < _chips.length; i++) ...[
                          Semantics(
                            button: true,
                            child: GestureDetector(
                              onTap: () => setState(() => _chip = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: _chip == i ? NoorColors.emeraldDark : NoorColors.emeraldSoft,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  _chips[i],
                                  style: NoorType.meta.copyWith(
                                    color: _chip == i ? Colors.white : NoorColors.ink,
                                    fontWeight: _chip == i ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Category Rows
                  for (var i = 0; i < rows.length; i++) ...[
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 1,
                      child: InkWell(
                        onTap: () => _openCategoryDetail(rows[i].$1),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NoorColors.hairlineSoft),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: NoorColors.emeraldSoft,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: NoorType.secondary.copyWith(
                                    color: NoorColors.emeraldDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rows[i].$1,
                                      style: NoorType.body.copyWith(fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      rows[i].$2,
                                      style: NoorType.meta.copyWith(color: NoorColors.muted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 20, color: NoorColors.muted),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.search_off, size: 36, color: NoorColors.muted),
                            const SizedBox(height: 8),
                            Text('No categories match your search.', style: NoorType.secondary.copyWith(color: NoorColors.muted)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [NoorColors.emeraldDark, NoorColors.emeraldMid],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Dua & Adhkar Library',
                  textAlign: TextAlign.center,
                  style: NoorType.section.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Authentic duas & daily adhkar',
                  style: NoorType.meta.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Tasbih Counter',
            icon: const Icon(Icons.touch_app, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ZikrTasbihScreen(initialTab: 0)),
            ),
          ),
        ],
      ),
    );
  }
}
