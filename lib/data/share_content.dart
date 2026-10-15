import 'app_state.dart';
import 'noor_controller.dart';

/// Phase 14 — curated Share Studio content library.
///
/// Every card is a brief excerpt or one-line reminder plus a full
/// reference. This file deliberately does not become a religious
/// text database: translations/excerpts stay short, the source
/// reference is always attached, and the cards point back to the
/// verified runtime sources (Qur'an service / hadith databank gate)
/// for reading in context.
///
/// The streak cards are not content: their numbers come from the
/// one canonical progress state ([NoorAppState.streaks] today, or
/// [NoorController.streaks] when live state is present), so a shared
/// streak can never disagree with the Salah/Tasbih screens.
enum ShareContentType { ayah, hadith, dua, streak }

class ShareContentItem {
  const ShareContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.text,
    required this.reference,
    required this.tags,
    this.arabicText,
    this.teaching,
  });

  final String id;
  final ShareContentType type;
  final String title;

  /// Brief English excerpt / translation. Kept to card length.
  final String text;

  /// Full source reference, e.g. `Quran 2:153` / `Sahih Muslim 223`.
  final String reference;

  /// Theme tags used by topic search and the picker.
  final List<String> tags;

  /// Very short Arabic excerpt where the design language calls for
  /// it; null when the card is typographic English only.
  final String? arabicText;

  /// One cautious descriptive line ("what this teaches") for AI
  /// result cards; not a ruling and not tafsir.
  final String? teaching;

  String get typeLabel => switch (type) {
        ShareContentType.ayah => 'AYAH',
        ShareContentType.hadith => 'HADITH',
        ShareContentType.dua => 'DUA',
        ShareContentType.streak => 'STREAK',
      };

  String get searchText =>
      '$title $text $reference ${tags.join(' ')}'.toLowerCase();
}

/// A streak milestone card (Salah / Dhikr), auto-filled from state.
class ShareStreakCard {
  const ShareStreakCard({
    required this.id,
    required this.label,
    required this.days,
    required this.caption,
    required this.iconName,
  });

  final String id;

  /// `Salah streak` / `Zikr streak` (the design's wording: Dhikr is
  /// shown as Zikr on the share surfaces).
  final String label;
  final int days;
  final String caption;

  /// Name of the motif to draw (`flame` / `calendar`); the widget
  /// maps it to an existing icon — no new artwork is introduced.
  final String iconName;

  String get headline => '$days';

  /// As a [ShareContentItem] so the editor/export pipeline treats
  /// streaks like any other card. Reference slot carries the
  /// streak fact itself (there is no scripture source to cite).
  ShareContentItem asItem() => ShareContentItem(
        id: id,
        type: ShareContentType.streak,
        title: label,
        text: caption,
        reference: '$days-day streak',
        tags: const ['streak'],
      );
}

/// Social export geometry. Aspect ratios are the platforms'
/// published canvas shapes; pixel sizes are the standard export
/// sizes used by [ShareExportService]. The system share sheet is
/// how the PNG reaches Instagram/TikTok/Facebook — NOOR does not
/// post directly to any platform.
class ShareFormatOption {
  const ShareFormatOption({
    required this.id,
    required this.label,
    required this.detail,
    required this.aspectRatio,
    required this.exportWidth,
    required this.exportHeight,
  });

  final String id;
  final String label;
  final String detail;
  final double aspectRatio;
  final int exportWidth;
  final int exportHeight;

  String get sizeLabel => '$exportWidth×$exportHeight PNG';
}

abstract final class ShareFormats {
  static const instagramPost = ShareFormatOption(
    id: 'instagram-post',
    label: 'Instagram Post',
    detail: '4:5',
    aspectRatio: 4 / 5,
    exportWidth: 1080,
    exportHeight: 1350,
  );
  static const storyReel = ShareFormatOption(
    id: 'story-reel',
    label: 'Story / Reel',
    detail: '9:16 · Instagram & TikTok',
    aspectRatio: 9 / 16,
    exportWidth: 1080,
    exportHeight: 1920,
  );
  static const facebookPost = ShareFormatOption(
    id: 'facebook-post',
    label: 'Facebook Post',
    detail: '1.91:1',
    aspectRatio: 1200 / 628,
    exportWidth: 1200,
    exportHeight: 628,
  );
  static const square = ShareFormatOption(
    id: 'square',
    label: 'Square',
    detail: '1:1',
    aspectRatio: 1,
    exportWidth: 1080,
    exportHeight: 1080,
  );

  static const all = [instagramPost, storyReel, facebookPost, square];
}

abstract final class ShareContent {
  // ---- Ayah cards (12) ---------------------------------------------
  static const ayahCards = <ShareContentItem>[
    ShareContentItem(
      id: 'ayah-20-114',
      type: ShareContentType.ayah,
      title: 'For knowledge',
      arabicText: 'رَّبِّ زِدْنِي عِلْمًا',
      text: '“My Lord, increase me in knowledge.”',
      reference: 'Quran 20:114',
      tags: ['knowledge', 'study', 'learning', 'dua'],
      teaching: 'Ask Allah for increase whenever you learn.',
    ),
    ShareContentItem(
      id: 'ayah-94-6',
      type: ShareContentType.ayah,
      title: 'Ease with hardship',
      arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      text: '“Indeed, with hardship comes ease.”',
      reference: 'Quran 94:6',
      tags: ['hardship', 'hope', 'comfort', 'patience'],
      teaching: 'Hardship is paired with ease, not left alone.',
    ),
    ShareContentItem(
      id: 'ayah-2-153',
      type: ShareContentType.ayah,
      title: 'Help through patience',
      arabicText: 'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
      text: '“Seek help through patience and prayer.”',
      reference: 'Quran 2:153',
      tags: ['patience', 'sabr', 'prayer', 'salah', 'help'],
      teaching: 'Patience and prayer are presented as the way to seek help.',
    ),
    ShareContentItem(
      id: 'ayah-13-28',
      type: ShareContentType.ayah,
      title: 'Rest for the heart',
      arabicText: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      text: '“Hearts find rest in the remembrance of Allah.”',
      reference: 'Quran 13:28',
      tags: ['dhikr', 'zikr', 'anxiety', 'calm', 'remembrance', 'comfort'],
      teaching: 'Remembrance is described as rest for hearts.',
    ),
    ShareContentItem(
      id: 'ayah-2-152',
      type: ShareContentType.ayah,
      title: 'Remember Me',
      arabicText: 'فَاذْكُرُونِي أَذْكُرْكُمْ',
      text: '“Remember Me; I will remember you.”',
      reference: 'Quran 2:152',
      tags: ['dhikr', 'zikr', 'gratitude', 'remembrance'],
      teaching: 'Remembering Allah and gratitude are joined in one verse.',
    ),
    ShareContentItem(
      id: 'ayah-14-7',
      type: ShareContentType.ayah,
      title: 'Gratitude increases',
      arabicText: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
      text: '“If you are grateful, I will surely increase you.”',
      reference: 'Quran 14:7',
      tags: ['gratitude', 'thankfulness', 'blessings'],
      teaching: 'Gratitude is linked with increase.',
    ),
    ShareContentItem(
      id: 'ayah-40-60',
      type: ShareContentType.ayah,
      title: 'Call upon Me',
      arabicText: 'ادْعُونِي أَسْتَجِبْ لَكُمْ',
      text: '“Call upon Me; I will respond to you.”',
      reference: 'Quran 40:60',
      tags: ['dua', 'supplication', 'prayer', 'help'],
      teaching: 'The verse invites direct supplication.',
    ),
    ShareContentItem(
      id: 'ayah-65-3',
      type: ShareContentType.ayah,
      title: 'Allah is sufficient',
      arabicText: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      text: '“Whoever relies on Allah — He is sufficient for him.”',
      reference: 'Quran 65:3',
      tags: ['trust', 'tawakkul', 'rizq', 'provision', 'anxiety'],
      teaching: 'Reliance on Allah is described as sufficiency.',
    ),
    ShareContentItem(
      id: 'ayah-39-53',
      type: ShareContentType.ayah,
      title: 'Do not despair',
      arabicText: 'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ',
      text: '“Do not despair of the mercy of Allah.”',
      reference: 'Quran 39:53',
      tags: ['mercy', 'forgiveness', 'hope', 'repentance', 'despair'],
      teaching: 'Despair of mercy is discouraged; hope is commanded.',
    ),
    ShareContentItem(
      id: 'ayah-3-139',
      type: ShareContentType.ayah,
      title: 'Do not lose heart',
      arabicText: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا',
      text: '“Do not lose heart, nor grieve.”',
      reference: 'Quran 3:139',
      tags: ['courage', 'grief', 'comfort', 'strength'],
      teaching: 'The verse addresses grief with steadiness.',
    ),
    ShareContentItem(
      id: 'ayah-2-286',
      type: ShareContentType.ayah,
      title: 'Within your capacity',
      arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      text: '“Allah does not burden a soul beyond its capacity.”',
      reference: 'Quran 2:286',
      tags: ['capacity', 'hardship', 'comfort', 'patience', 'illness'],
      teaching: 'No soul is burdened beyond what it can bear.',
    ),
    ShareContentItem(
      id: 'ayah-29-45',
      type: ShareContentType.ayah,
      title: 'Prayer protects',
      arabicText: 'إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ',
      text: '“Prayer restrains from shameful and unjust deeds.”',
      reference: 'Quran 29:45',
      tags: ['salah', 'prayer', 'habits', 'character'],
      teaching: 'Prayer is described as a restraint from wrongdoing.',
    ),
  ];

  // ---- Hadith cards (12) --------------------------------------------
  static const hadithCards = <ShareContentItem>[
    ShareContentItem(
      id: 'hadith-bukhari-1',
      type: ShareContentType.hadith,
      title: 'Intentions',
      arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      text: '“Actions are only by intentions.”',
      reference: 'Sahih al-Bukhari 1',
      tags: ['intentions', 'niyyah', 'actions', 'sincerity'],
      teaching: 'The value of an action begins with its intention.',
    ),
    ShareContentItem(
      id: 'hadith-muslim-223',
      type: ShareContentType.hadith,
      title: 'Purity is half of faith',
      arabicText: 'الطُّهُورُ شَطْرُ الْإِيمَانِ',
      text: '“Purity is half of faith.”',
      reference: 'Sahih Muslim 223',
      tags: ['purity', 'wudu', 'faith', 'cleanliness'],
      teaching: 'Cleanliness is given a central place in faith.',
    ),
    ShareContentItem(
      id: 'hadith-bukhari-13',
      type: ShareContentType.hadith,
      title: 'Love for your brother',
      text: '“Love for your brother what you love for yourself.”',
      reference: 'Sahih al-Bukhari 13',
      tags: ['brotherhood', 'kindness', 'faith', 'community'],
      teaching: 'Faith is linked with wanting good for others.',
    ),
    ShareContentItem(
      id: 'hadith-muslim-1631',
      type: ShareContentType.hadith,
      title: 'What continues after death',
      text: '“Deeds end at death, except ongoing charity, beneficial '
          'knowledge, and a righteous child who prays.”',
      reference: 'Sahih Muslim 1631',
      tags: ['charity', 'knowledge', 'death', 'legacy'],
      teaching: 'Three things are described as continuing after death.',
    ),
    ShareContentItem(
      id: 'hadith-bukhari-5027',
      type: ShareContentType.hadith,
      title: 'Learn and teach the Qur’an',
      arabicText: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      text: '“The best of you learn the Qur’an and teach it.”',
      reference: 'Sahih al-Bukhari 5027',
      tags: ['quran', 'knowledge', 'teaching', 'learning'],
      teaching: 'Learning and teaching the Qur’an are paired as excellence.',
    ),
    ShareContentItem(
      id: 'hadith-tirmidhi-2516',
      type: ShareContentType.hadith,
      title: 'Be mindful of Allah',
      arabicText: 'احْفَظِ اللَّهَ يَحْفَظْكَ',
      text: '“Be mindful of Allah, and He will protect you.”',
      reference: 'Jami` at-Tirmidhi 2516',
      tags: ['mindfulness', 'taqwa', 'trust', 'guidance'],
      teaching: 'Mindfulness of Allah is linked with His protection.',
    ),
    ShareContentItem(
      id: 'hadith-tirmidhi-1987',
      type: ShareContentType.hadith,
      title: 'Wherever you are',
      arabicText: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ',
      text: '“Be conscious of Allah wherever you are.”',
      reference: 'Jami` at-Tirmidhi 1987',
      tags: ['taqwa', 'character', 'habits', 'mindfulness'],
      teaching: 'God-consciousness is not limited to one place.',
    ),
    ShareContentItem(
      id: 'hadith-ibn-majah-224',
      type: ShareContentType.hadith,
      title: 'Seeking knowledge',
      arabicText: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ',
      text: '“Seeking knowledge is an obligation.”',
      reference: 'Sunan Ibn Majah 224',
      tags: ['knowledge', 'study', 'learning', 'exams'],
      teaching: 'Seeking knowledge is presented as a duty.',
    ),
    ShareContentItem(
      id: 'hadith-bukhari-69',
      type: ShareContentType.hadith,
      title: 'Make things easy',
      arabicText: 'يَسِّرُوا وَلَا تُعَسِّرُوا',
      text: '“Make things easy and do not make them difficult.”',
      reference: 'Sahih al-Bukhari 69',
      tags: ['ease', 'teaching', 'kindness', 'da’wah'],
      teaching: 'Ease, not hardship, is the taught approach with people.',
    ),
    ShareContentItem(
      id: 'hadith-muslim-2699',
      type: ShareContentType.hadith,
      title: 'Relieve a hardship',
      text: '“Whoever relieves a believer’s hardship, Allah will '
          'relieve his hardship.”',
      reference: 'Sahih Muslim 2699',
      tags: ['hardship', 'help', 'kindness', 'community', 'charity'],
      teaching: 'Relieving others is linked with relief for oneself.',
    ),
    ShareContentItem(
      id: 'hadith-bukhari-6114',
      type: ShareContentType.hadith,
      title: 'Strength and anger',
      text: '“The strong is not the one who overcomes people; the '
          'strong controls himself in anger.”',
      reference: 'Sahih al-Bukhari 6114',
      tags: ['anger', 'self-control', 'strength', 'character'],
      teaching: 'Strength is defined as self-control at anger.',
    ),
    ShareContentItem(
      id: 'hadith-muslim-2588',
      type: ShareContentType.hadith,
      title: 'Charity does not decrease',
      text: '“Charity does not decrease wealth.”',
      reference: 'Sahih Muslim 2588',
      tags: ['charity', 'giving', 'wealth', 'rizq'],
      teaching: 'Giving is not described as loss.',
    ),
  ];

  // ---- Dua cards (6) ---------------------------------------------------
  static const duaCards = <ShareContentItem>[
    ShareContentItem(
      id: 'dua-20-114',
      type: ShareContentType.dua,
      title: 'Dua for knowledge',
      arabicText: 'رَّبِّ زِدْنِي عِلْمًا',
      text: '“My Lord, increase me in knowledge.”',
      reference: 'Quran 20:114',
      tags: ['dua', 'knowledge', 'study', 'exams'],
      teaching: 'A short Qur’anic dua for learning.',
    ),
    ShareContentItem(
      id: 'dua-2-201',
      type: ShareContentType.dua,
      title: 'Good in both worlds',
      arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
      text: '“Our Lord, give us good in this world and the next.”',
      reference: 'Quran 2:201',
      tags: ['dua', 'balance', 'rizq', 'guidance'],
      teaching: 'A balanced dua for both worlds.',
    ),
    ShareContentItem(
      id: 'dua-3-8',
      type: ShareContentType.dua,
      title: 'Steadfast hearts',
      text: '“Our Lord, do not let our hearts deviate after You '
          'have guided us.”',
      reference: 'Quran 3:8',
      tags: ['dua', 'guidance', 'steadfastness', 'heart'],
      teaching: 'A dua asking for a heart that stays guided.',
    ),
    ShareContentItem(
      id: 'dua-14-40',
      type: ShareContentType.dua,
      title: 'Establish prayer',
      text: '“My Lord, make me steadfast in prayer, and my '
          'descendants too.”',
      reference: 'Quran 14:40',
      tags: ['dua', 'salah', 'prayer', 'family', 'children'],
      teaching: 'A dua for prayer in oneself and one’s family.',
    ),
    ShareContentItem(
      id: 'dua-25-74',
      type: ShareContentType.dua,
      title: 'Comfort of the eyes',
      text: '“Grant us comfort in our spouses and children, and '
          'make us leaders for the righteous.”',
      reference: 'Quran 25:74',
      tags: ['dua', 'family', 'marriage', 'children'],
      teaching: 'A dua for family as a source of comfort.',
    ),
    ShareContentItem(
      id: 'dua-2-286',
      type: ShareContentType.dua,
      title: 'Pardon and mercy',
      text: '“Pardon us, forgive us, and have mercy on us.”',
      reference: 'Quran 2:286',
      tags: ['dua', 'forgiveness', 'mercy', 'repentance'],
      teaching: 'A closing dua for pardon and mercy.',
    ),
  ];

  static const all = <ShareContentItem>[
    ...ayahCards,
    ...hadithCards,
    ...duaCards,
  ];

  static ShareContentItem byReference(String reference) => all.firstWhere(
        (i) => i.reference == reference,
        orElse: () => ayahCards.first,
      );

  static List<ShareContentItem> byType(ShareContentType type) => switch (type) {
        ShareContentType.ayah => ayahCards,
        ShareContentType.hadith => hadithCards,
        ShareContentType.dua => duaCards,
        ShareContentType.streak => const [],
      };

  /// The two streak cards, auto-filled. With a live [controller]
  /// the numbers follow the app-wide state; without one they use
  /// the canonical demo snapshot — the same values the Salah and
  /// Tasbih screens show (12 and 8 today).
  static List<ShareStreakCard> streakCards([NoorController? controller]) {
    final streaks = controller?.streaks ??
        {for (final s in NoorAppState.streaks) s.$1: s.$2};
    final salah = streaks['Salah'] ?? NoorAppState.streaks[0].$2;
    final dhikr = streaks['Dhikr'] ?? NoorAppState.streaks[1].$2;
    return [
      ShareStreakCard(
        id: 'streak-salah',
        label: 'Namaz streak',
        days: salah,
        caption: 'Salah in a row — keep the chain unbroken.',
        iconName: 'flame',
      ),
      ShareStreakCard(
        id: 'streak-zikr',
        label: 'Zikr streak',
        days: dhikr,
        caption: 'Zikr in a row — a heart kept remembering.',
        iconName: 'calendar',
      ),
    ];
  }
}
