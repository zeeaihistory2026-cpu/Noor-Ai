/// Phase 17 — Daily Content Service for rotating Ayat, Hadith, and Duas.
///
/// Features authentic Quranic verses, Sahih Hadiths (Bukhari, Muslim,
/// Tirmidhi, Abu Dawud, Ibn Majah, Nasai), and authentic supplications.
/// Each collection deterministically rotates every calendar day, and also
/// allows interactive changing / shuffling / cycling by the user.
class DailyContentItem {
  const DailyContentItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    required this.reference,
    this.transliteration,
    this.urdu,
    this.contextOrReflection,
    this.category = 'Daily',
  });

  final String id;
  final String title;
  final String arabic;
  final String translation;
  final String reference;
  final String? transliteration;
  final String? urdu;
  final String? contextOrReflection;
  final String category;

  String get source => reference;
  String get surahReference => reference;
  String get about => contextOrReflection ?? '';
  String get reflection => contextOrReflection ?? '';
}

class DailyContentService {
  DailyContentService._();

  static int _dayIndex(int length, [DateTime? date]) {
    if (length <= 0) return 0;
    final d = date ?? DateTime.now();
    // Calendar arithmetic must not lose a day at daylight-saving boundaries.
    final epoch = DateTime.utc(2025, 1, 1);
    final diff = DateTime.utc(d.year, d.month, d.day).difference(epoch).inDays;
    return diff.abs() % length;
  }

  static int get totalAyat => ayatList.length;
  static int get totalHadiths => hadithList.length;
  static int get totalDuas => duaList.length;

  /// Returns today's Ayat of the Day, with optional offset for card changing.
  static DailyContentItem getAyahOfDay([DateTime? date]) =>
      getAyah(offset: 0, date: date);

  /// Returns today's Hadith of the Day, with optional offset for card changing.
  static DailyContentItem getHadithOfDay([DateTime? date]) =>
      getHadith(offset: 0, date: date);

  /// Returns today's Dua of the Day, with optional offset for card changing.
  static DailyContentItem getDuaOfDay([DateTime? date]) =>
      getDua(offset: 0, date: date);

  /// Flexible card rotation & shuffle getter for Ayat
  static DailyContentItem getAyah({int offset = 0, DateTime? date}) {
    if (ayatList.isEmpty) {
      return const DailyContentItem(
        id: 'fallback',
        title: 'Remembrance',
        arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ',
        translation: 'Remember Me; I will remember you.',
        reference: 'Quran 2:152',
      );
    }
    final baseIdx = _dayIndex(ayatList.length, date);
    final idx = (baseIdx + offset) % ayatList.length;
    return ayatList[idx < 0 ? idx + ayatList.length : idx];
  }

  /// Flexible card rotation & shuffle getter for Hadith
  static DailyContentItem getHadith({int offset = 0, DateTime? date}) {
    if (hadithList.isEmpty) {
      return const DailyContentItem(
        id: 'fallback',
        title: 'Good Deeds',
        arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        translation: 'Actions are judged by intentions.',
        reference: 'Sahih al-Bukhari 1',
      );
    }
    final baseIdx = _dayIndex(hadithList.length, date);
    final idx = (baseIdx + offset) % hadithList.length;
    return hadithList[idx < 0 ? idx + hadithList.length : idx];
  }

  /// Flexible card rotation & shuffle getter for Dua
  static DailyContentItem getDua({int offset = 0, DateTime? date}) {
    if (duaList.isEmpty) {
      return const DailyContentItem(
        id: 'fallback',
        title: 'Knowledge',
        arabic: 'رَّبِّ زِدْنِي عِلْمًا',
        translation: 'My Lord, increase me in knowledge.',
        reference: 'Quran 20:114',
      );
    }
    final baseIdx = _dayIndex(duaList.length, date);
    final idx = (baseIdx + offset) % duaList.length;
    return duaList[idx < 0 ? idx + duaList.length : idx];
  }

  static DailyContentItem getAyahByIndex(int index) =>
      ayatList[index.clamp(0, ayatList.length - 1)];

  static DailyContentItem getHadithByIndex(int index) =>
      hadithList[index.clamp(0, hadithList.length - 1)];

  static DailyContentItem getDuaByIndex(int index) =>
      duaList[index.clamp(0, duaList.length - 1)];

  // =========================================================================
  // 30 Authentic Ayat of the Day
  // =========================================================================
  static const List<DailyContentItem> ayatList = [
    DailyContentItem(
      id: 'ayah-13-28',
      title: 'Hearts Find Rest',
      arabic:
          "ٱلَّذِينَ ءَامَنُوا۟ وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ ٱللَّهِ ۗ أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ",
      translation:
          "Those who have believed and whose hearts are assured by the remembrance of Allah. Unquestionably, by the remembrance of Allah hearts are assured.\"",
      urdu:
          "(یعنی) جو لوگ ایمان لاتے اور جن کے دل یادِ خدا سے آرام پاتے ہیں (ان کو) اور سن رکھو کہ خدا کی یاد سے دل آرام پاتے ہیں",
      reference: 'Surah Ar-Ra’d 13:28',
      contextOrReflection:
          'True peace and relief from internal restlessness are found only in the heartfelt remembrance of Allah.',
    ),
    DailyContentItem(
      id: 'ayah-94-5-6',
      title: 'With Hardship Comes Ease',
      arabic: "فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا إِنَّ مَعَ ٱلْعُسْرِ يُسْرًۭا",
      translation:
          "For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.",
      urdu:
          "ہاں ہاں مشکل کے ساتھ آسانی بھی ہے (اور) بے شک مشکل کے ساتھ آسانی ہے",
      reference: 'Surah Ash-Sharh 94:5-6',
      contextOrReflection:
          'Allah emphasizes twice that ease is woven directly into hardship. No difficulty lasts forever.',
    ),
    DailyContentItem(
      id: 'ayah-2-152',
      title: 'Remember Me, I Remember You',
      arabic: "فَٱذْكُرُونِىٓ أَذْكُرْكُمْ وَٱشْكُرُوا۟ لِى وَلَا تَكْفُرُونِ",
      translation:
          "So remember Me; I will remember you. And be grateful to Me and do not deny Me.",
      urdu:
          "سو تم مجھے یاد کرو۔ میں تمہیں یاد کیا کروں گا۔ اور میرے احسان مانتے رہنا اور ناشکری نہ کرنا",
      reference: 'Surah Al-Baqarah 2:152',
      contextOrReflection:
          'Whenever a servant mentions Allah in their heart, Allah mentions them in an assembly greater than theirs.',
    ),
    DailyContentItem(
      id: 'ayah-14-7',
      title: 'Gratitude Brings Increase',
      arabic:
          "وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِى لَشَدِيدٌۭ",
      translation:
          "And [remember] when your Lord proclaimed, 'If you are grateful, I will surely increase you [in favor]; but if you deny, indeed, My punishment is severe.' \"",
      urdu:
          "اور جب تمہارے پروردگار نے (تم کو) آگاہ کیا کہ اگر شکر کرو گے تو میں تمہیں زیادہ دوں گا اور اگر ناشکری کرو گے تو (یاد رکھو کہ) میرا عذاب بھی سخت ہے",
      reference: 'Surah Ibrahim 14:7',
      contextOrReflection:
          'Shukr (gratitude) safeguards existing blessings and attracts more divine favor into one’s life.',
    ),
    DailyContentItem(
      id: 'ayah-65-3',
      title: 'Allah is Sufficient',
      arabic:
          "وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَن يَتَوَكَّلْ عَلَى ٱللَّهِ فَهُوَ حَسْبُهُۥٓ ۚ إِنَّ ٱللَّهَ بَٰلِغُ أَمْرِهِۦ ۚ قَدْ جَعَلَ ٱللَّهُ لِكُلِّ شَىْءٍۢ قَدْرًۭا",
      translation:
          "And will provide for him from where he does not expect. And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose. Allah has already set for everything a [decreed] extent.",
      urdu:
          "اور اس کو ایسی جگہ سے رزق دے گا جہاں سے (وہم و) گمان بھی نہ ہو۔ اور جو خدا پر بھروسہ رکھے گا تو وہ اس کو کفایت کرے گا۔ خدا اپنے کام کو (جو وہ کرنا چاہتا ہے) پورا کردیتا ہے۔ خدا نے ہر چیز کا اندازہ مقرر کر رکھا ہے",
      reference: 'Surah At-Talaq 65:3',
      contextOrReflection:
          'Tawakkul is placing full trust in the Creator after doing your best. Allah opens doors unseen.',
    ),
    DailyContentItem(
      id: 'ayah-39-53',
      title: 'Do Not Despair of Mercy',
      arabic:
          "۞ قُلْ يَٰعِبَادِىَ ٱلَّذِينَ أَسْرَفُوا۟ عَلَىٰٓ أَنفُسِهِمْ لَا تَقْنَطُوا۟ مِن رَّحْمَةِ ٱللَّهِ ۚ إِنَّ ٱللَّهَ يَغْفِرُ ٱلذُّنُوبَ جَمِيعًا ۚ إِنَّهُۥ هُوَ ٱلْغَفُورُ ٱلرَّحِيمُ",
      translation:
          "Say, \"O My servants who have transgressed against themselves [by sinning], do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful.\"",
      urdu:
          "(اے پیغمبر میری طرف سے لوگوں کو) کہہ دو کہ اے میرے بندو جنہوں نے اپنی جانوں پر زیادتی کی ہے خدا کی رحمت سے ناامید نہ ہونا۔ خدا تو سب گناہوں کو بخش دیتا ہے۔ (اور) وہ تو بخشنے والا مہربان ہے",
      reference: 'Surah Az-Zumar 39:53',
      contextOrReflection:
          'The gate of repentance is never closed while a soul breathes. Allah’s mercy encompasses everything.',
    ),
    DailyContentItem(
      id: 'ayah-2-186',
      title: 'I am Near',
      arabic:
          "وَإِذَا سَأَلَكَ عِبَادِى عَنِّى فَإِنِّى قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ ٱلدَّاعِ إِذَا دَعَانِ ۖ فَلْيَسْتَجِيبُوا۟ لِى وَلْيُؤْمِنُوا۟ بِى لَعَلَّهُمْ يَرْشُدُونَ",
      translation:
          "And when My servants ask you, [O Muhammad], concerning Me - indeed I am near. I respond to the invocation of the supplicant when he calls upon Me. So let them respond to Me [by obedience] and believe in Me that they may be [rightly] guided.",
      urdu:
          "اور (اے پیغمبر) جب تم سے میرے بندے میرے بارے میں دریافت کریں تو (کہہ دو کہ) میں تو (تمہارے) پاس ہوں جب کوئی پکارنے والا مجھے پکارتا ہے تو میں اس کی دعا قبول کرتا ہوں تو ان کو چاہیئے کہ میرے حکموں کو مانیں اور مجھ پر ایمان لائیں تاکہ نیک رستہ پائیں",
      reference: 'Surah Al-Baqarah 2:186',
      contextOrReflection:
          'No intermediary is needed to talk to Allah; He hears your whisper in the depths of the night.',
    ),
    DailyContentItem(
      id: 'ayah-2-286',
      title: 'Beyond Capacity',
      arabic:
          "لَا يُكَلِّفُ ٱللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا ٱكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَآ إِن نَّسِينَآ أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَآ إِصْرًۭا كَمَا حَمَلْتَهُۥ عَلَى ٱلَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِۦ ۖ وَٱعْفُ عَنَّا وَٱغْفِرْ لَنَا وَٱرْحَمْنَآ ۚ أَنتَ مَوْلَىٰنَا فَٱنصُرْنَا عَلَى ٱلْقَوْمِ ٱلْكَٰفِرِينَ",
      translation:
          "Allah does not charge a soul except [with that within] its capacity. It will have [the consequence of] what [good] it has gained, and it will bear [the consequence of] what [evil] it has earned. \"Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us. Our Lord, and burden us not with that which we have no ability to bear. And pardon us; and forgive us; and have mercy upon us. You are our protector, so give us victory over the disbelieving people.\"",
      urdu:
          "خدا کسی شخص کو اس کی طاقت سے زیادہ تکلیف نہیں دیتا۔ اچھے کام کرے گا تو اس کو ان کا فائدہ ملے گا برے کرے گا تو اسے ان کا نقصان پہنچے گا۔ اے پروردگار اگر ہم سے بھول یا چوک ہوگئی ہو تو ہم سے مؤاخذہ نہ کیجیو۔ اے پروردگار ہم پر ایسا بوجھ نہ ڈالیو جیسا تو نے ہم سے پہلے لوگوں پر ڈالا تھا۔ اے پروردگار جتنا بوجھ اٹھانے کی ہم میں طاقت نہیں اتنا ہمارے سر پر نہ رکھیو۔ اور (اے پروردگار) ہمارے گناہوں سے درگزر کر اور ہمیں بخش دے۔ اور ہم پر رحم فرما۔ تو ہی ہمارا مالک ہے اور ہم کو کافروں پر غالب فرما",
      reference: 'Surah Al-Baqarah 2:286',
      contextOrReflection:
          'Whatever trial you currently face, Allah knows you possess the spiritual strength to overcome it.',
    ),
    DailyContentItem(
      id: 'ayah-3-139',
      title: 'Do Not Lose Heart',
      arabic:
          "وَلَا تَهِنُوا۟ وَلَا تَحْزَنُوا۟ وَأَنتُمُ ٱلْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ",
      translation:
          "So do not weaken and do not grieve, and you will be superior if you are [true] believers.",
      urdu:
          "اور (دیکھو) بے دل نہ ہونا اور نہ کسی طرح کا غم کرنا اگر تم مومن (صادق) ہو تو تم ہی غالب رہو گے",
      reference: 'Surah Ali ‘Imran 3:139',
      contextOrReflection:
          'Grief and fear cannot conquer a heart that anchors its hope and purpose in Allah.',
    ),
    DailyContentItem(
      id: 'ayah-29-45',
      title: 'Prayer Restrains',
      arabic:
          "ٱتْلُ مَآ أُوحِىَ إِلَيْكَ مِنَ ٱلْكِتَٰبِ وَأَقِمِ ٱلصَّلَوٰةَ ۖ إِنَّ ٱلصَّلَوٰةَ تَنْهَىٰ عَنِ ٱلْفَحْشَآءِ وَٱلْمُنكَرِ ۗ وَلَذِكْرُ ٱللَّهِ أَكْبَرُ ۗ وَٱللَّهُ يَعْلَمُ مَا تَصْنَعُونَ",
      translation:
          "Recite, [O Muhammad], what has been revealed to you of the Book and establish prayer. Indeed, prayer prohibits immorality and wrongdoing, and the remembrance of Allah is greater. And Allah knows that which you do.",
      urdu:
          "(اے محمدﷺ! یہ) کتاب جو تمہاری طرف وحی کی گئی ہے اس کو پڑھا کرو اور نماز کے پابند رہو۔ کچھ شک نہیں کہ نماز بےحیائی اور بری باتوں سے روکتی ہے۔ اور خدا کا ذکر بڑا (اچھا کام) ہے۔ اور جو کچھ تم کرتے ہو خدا اُسے جانتا ہے",
      reference: 'Surah Al-Ankabut 29:45',
      contextOrReflection:
          'True Salah transforms a person from the inside out, shielding their heart from spiritual harm.',
    ),
    DailyContentItem(
      id: 'ayah-3-200',
      title: 'Patience and Perseverance',
      arabic:
          "يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱصْبِرُوا۟ وَصَابِرُوا۟ وَرَابِطُوا۟ وَٱتَّقُوا۟ ٱللَّهَ لَعَلَّكُمْ تُفْلِحُونَ",
      translation:
          "O you who have believed, persevere and endure and remain stationed and fear Allah that you may be successful.",
      urdu:
          "اے اہل ایمان (کفار کے مقابلے میں) ثابت قدم رہو اور استقامت رکھو اور مورچوں پر جمے رہو اور خدا سے ڈرو تاکہ مراد حاصل کرو",
      reference: 'Surah Ali ‘Imran 3:200',
      contextOrReflection:
          'Success in both this world and the Hereafter is built on steadfast patience and devotion.',
    ),
    DailyContentItem(
      id: 'ayah-2-153',
      title: 'Seek Help Through Patience & Prayer',
      arabic:
          "يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱسْتَعِينُوا۟ بِٱلصَّبْرِ وَٱلصَّلَوٰةِ ۚ إِنَّ ٱللَّهَ مَعَ ٱلصَّٰبِرِينَ",
      translation:
          "O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.",
      urdu:
          "اے ایمان والو صبر اور نماز سے مدد لیا کرو بےشک خدا صبر کرنے والوں کے ساتھ ہے",
      reference: 'Surah Al-Baqarah 2:153',
      contextOrReflection:
          'When life feels overwhelming, step onto the prayer mat and speak to the One who controls all things.',
    ),
    DailyContentItem(
      id: 'ayah-20-114',
      title: 'Increase Me in Knowledge',
      arabic:
          "فَتَعَٰلَى ٱللَّهُ ٱلْمَلِكُ ٱلْحَقُّ ۗ وَلَا تَعْجَلْ بِٱلْقُرْءَانِ مِن قَبْلِ أَن يُقْضَىٰٓ إِلَيْكَ وَحْيُهُۥ ۖ وَقُل رَّبِّ زِدْنِى عِلْمًۭا",
      translation:
          "So high [above all] is Allah, the Sovereign, the Truth. And, [O Muhammad], do not hasten with [recitation of] the Qur'an before its revelation is completed to you, and say, \"My Lord, increase me in knowledge.\"",
      urdu:
          "تو خدا جو سچا بادشاہ ہے عالی قدر ہے۔ اور قرآن کی وحی جو تمہاری طرف بھیجی جاتی ہے اس کے پورا ہونے سے پہلے قرآن کے (پڑھنے کے) لئے جلدی نہ کیا کرو اور دعا کرو کہ میرے پروردگار مجھے اور زیادہ علم دے",
      reference: 'Surah Ta-Ha 20:114',
      contextOrReflection:
          'Knowledge of Allah and His guidance is the greatest light a believer can ask for.',
    ),
    DailyContentItem(
      id: 'ayah-55-60',
      title: 'Reward of Goodness',
      arabic: "هَلْ جَزَآءُ ٱلْإِحْسَٰنِ إِلَّا ٱلْإِحْسَٰنُ",
      translation: "Is the reward for good [anything] but good?",
      urdu: "نیکی کا بدلہ نیکی کے سوا کچھ نہیں ہے",
      reference: 'Surah Ar-Rahman 55:60',
      contextOrReflection:
          'Every act of kindness, charity, and goodness is recognized by the Most Generous Lord.',
    ),
    DailyContentItem(
      id: 'ayah-49-10',
      title: 'Believers are Brothers',
      arabic:
          "إِنَّمَا ٱلْمُؤْمِنُونَ إِخْوَةٌۭ فَأَصْلِحُوا۟ بَيْنَ أَخَوَيْكُمْ ۚ وَٱتَّقُوا۟ ٱللَّهَ لَعَلَّكُمْ تُرْحَمُونَ",
      translation:
          "The believers are but brothers, so make settlement between your brothers. And fear Allah that you may receive mercy.",
      urdu:
          "مومن تو آپس میں بھائی بھائی ہیں۔ تو اپنے دو بھائیوں میں صلح کرادیا کرو۔ اور خدا سے ڈرتے رہو تاکہ تم پر رحمت کی جائے",
      reference: 'Surah Al-Hujurat 49:10',
      contextOrReflection:
          'The brotherhood of faith is sacred; mend relationships and spread peace among people.',
    ),
    DailyContentItem(
      id: 'ayah-2-255',
      title: 'Ayatul Kursi — The Throne Verse',
      arabic:
          "ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُۥ سِنَةٌۭ وَلَا نَوْمٌۭ ۚ لَّهُۥ مَا فِى ٱلسَّمَٰوَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ مَن ذَا ٱلَّذِى يَشْفَعُ عِندَهُۥٓ إِلَّا بِإِذْنِهِۦ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَىْءٍۢ مِّنْ عِلْمِهِۦٓ إِلَّا بِمَا شَآءَ ۚ وَسِعَ كُرْسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضَ ۖ وَلَا يَـُٔودُهُۥ حِفْظُهُمَا ۚ وَهُوَ ٱلْعَلِىُّ ٱلْعَظِيمُ",
      translation:
          "Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.",
      urdu:
          "خدا (وہ معبود برحق ہے کہ) اس کے سوا کوئی عبادت کے لائق نہیں زندہ ہمیشہ رہنے والا اسے نہ اونگھ آتی ہے نہ نیند جو کچھ آسمانوں میں اور جو کچھ زمین میں ہیں سب اسی کا ہے کون ہے جو اس کی اجازت کے بغیر اس سے (کسی کی) سفارش کر سکے جو کچھ لوگوں کے روبرو ہو رہا ہے اور جو کچھ ان کے پیچھے ہوچکا ہے اسے سب معلوم ہے اور وہ اس کی معلومات میں سے کسی چیز پر دسترس حاصل نہیں کر سکتے ہاں جس قدر وہ چاہتا ہے (اسی قدر معلوم کرا دیتا ہے) اس کی بادشاہی (اور علم) آسمان اور زمین سب پر حاوی ہے اور اسے ان کی حفاظت کچھ بھی دشوار نہیں وہ بڑا عالی رتبہ اور جلیل القدر ہے",
      reference: 'Surah Al-Baqarah 2:255',
      contextOrReflection:
          'The greatest verse in the Holy Quran, conveying Allah’s absolute sovereignty and majestic power.',
    ),
    DailyContentItem(
      id: 'ayah-3-159',
      title: 'Gentleness & Reliance on Allah',
      arabic:
          "فَبِمَا رَحْمَةٍۢ مِّنَ ٱللَّهِ لِنتَ لَهُمْ ۖ وَلَوْ كُنتَ فَظًّا غَلِيظَ ٱلْقَلْبِ لَٱنفَضُّوا۟ مِنْ حَوْلِكَ ۖ فَٱعْفُ عَنْهُمْ وَٱسْتَغْفِرْ لَهُمْ وَشَاوِرْهُمْ فِى ٱلْأَمْرِ ۖ فَإِذَا عَزَمْتَ فَتَوَكَّلْ عَلَى ٱللَّهِ ۚ إِنَّ ٱللَّهَ يُحِبُّ ٱلْمُتَوَكِّلِينَ",
      translation:
          "So by mercy from Allah, [O Muhammad], you were lenient with them. And if you had been rude [in speech] and harsh in heart, they would have disbanded from about you. So pardon them and ask forgiveness for them and consult them in the matter. And when you have decided, then rely upon Allah. Indeed, Allah loves those who rely [upon Him].",
      urdu:
          "(اے محمدﷺ) خدا کی مہربانی سے تمہاری افتاد مزاج ان لوگوں کے لئے نرم واقع ہوئی ہے۔ اور اگر تم بدخو اور سخت دل ہوتے تو یہ تمہارے پاس سے بھاگ کھڑے ہوتے۔ تو ان کو معاف کردو اور ان کے لئے (خدا سے) مغفرت مانگو۔ اور اپنے کاموں میں ان سے مشورت لیا کرو۔ اور جب (کسی کام کا) عزم مصمم کرلو تو خدا پر بھروسا رکھو۔ بےشک خدا بھروسا رکھنے والوں کو دوست رکھتا ہے",
      reference: 'Surah Ali ‘Imran 3:159',
      contextOrReflection:
          'Gentleness and compassion win hearts and reflect true divine character.',
    ),
    DailyContentItem(
      id: 'ayah-4-86',
      title: 'Returning Greetings with Excellence',
      arabic:
          "وَإِذَا حُيِّيتُم بِتَحِيَّةٍۢ فَحَيُّوا۟ بِأَحْسَنَ مِنْهَآ أَوْ رُدُّوهَآ ۗ إِنَّ ٱللَّهَ كَانَ عَلَىٰ كُلِّ شَىْءٍ حَسِيبًا",
      translation:
          "And when you are greeted with a greeting, greet [in return] with one better than it or [at least] return it [in a like manner]. Indeed, Allah is ever, over all things, an Accountant.",
      urdu:
          "اور جب تم کو کوئی دعا دے تو (جواب میں) تم اس سے بہتر (کلمے) سے (اسے) دعا دو یا انہیں لفظوں سے دعا دو بےشک خدا ہر چیز کا حساب لینے والا ہے",
      reference: 'Surah An-Nisa 4:86',
      contextOrReflection:
          'Spreading greetings of peace (Salam) with warmth fosters unity and love in the community.',
    ),
    DailyContentItem(
      id: 'ayah-5-32',
      title: 'The Sanctity of Human Life',
      arabic:
          "مِنْ أَجْلِ ذَٰلِكَ كَتَبْنَا عَلَىٰ بَنِىٓ إِسْرَٰٓءِيلَ أَنَّهُۥ مَن قَتَلَ نَفْسًۢا بِغَيْرِ نَفْسٍ أَوْ فَسَادٍۢ فِى ٱلْأَرْضِ فَكَأَنَّمَا قَتَلَ ٱلنَّاسَ جَمِيعًۭا وَمَنْ أَحْيَاهَا فَكَأَنَّمَآ أَحْيَا ٱلنَّاسَ جَمِيعًۭا ۚ وَلَقَدْ جَآءَتْهُمْ رُسُلُنَا بِٱلْبَيِّنَٰتِ ثُمَّ إِنَّ كَثِيرًۭا مِّنْهُم بَعْدَ ذَٰلِكَ فِى ٱلْأَرْضِ لَمُسْرِفُونَ",
      translation:
          "Because of that, We decreed upon the Children of Israel that whoever kills a soul unless for a soul or for corruption [done] in the land - it is as if he had slain mankind entirely. And whoever saves one - it is as if he had saved mankind entirely. And our messengers had certainly come to them with clear proofs. Then indeed many of them, [even] after that, throughout the land, were transgressors.",
      urdu:
          "اس قتل کی وجہ سے ہم نے بنی اسرائیل پر یہ حکم نازل کیا کہ جو شخص کسی کو (ناحق) قتل کرے گا (یعنی) بغیر اس کے کہ جان کا بدلہ لیا جائے یا ملک میں خرابی کرنے کی سزا دی جائے اُس نے گویا تمام لوگوں کو قتل کیا اور جو اس کی زندگانی کا موجب ہوا تو گویا تمام لوگوں کی زندگانی کا موجب ہوا اور ان لوگوں کے پاس ہمارے پیغمبر روشن دلیلیں لا چکے ہیں پھر اس کے بعد بھی ان سے بہت سے لوگ ملک میں حدِ اعتدال سے نکل جاتے ہیں",
      reference: 'Surah Al-Ma’idah 5:32',
      contextOrReflection:
          'Every soul is precious; preserving life, relieving suffering, and supporting others carries monumental reward.',
    ),
    DailyContentItem(
      id: 'ayah-6-162',
      title: 'Devotion of the Whole Life',
      arabic:
          "قُلْ إِنَّ صَلَاتِى وَنُسُكِى وَمَحْيَاىَ وَمَمَاتِى لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ",
      translation:
          "Say, \"Indeed, my prayer, my rites of sacrifice, my living and my dying are for Allah, Lord of the worlds.",
      urdu:
          "(یہ بھی) کہہ دو کہ میری نماز اور میری عبادت اور میرا جینا اور میرا مرنا سب خدائے رب العالمین ہی کے لیے ہے",
      reference: 'Surah Al-An’am 6:162',
      contextOrReflection:
          'Living with purpose means dedicating our daily routine, work, worship, and rest to the Almighty.',
    ),
    DailyContentItem(
      id: 'ayah-7-199',
      title: 'Forgiveness and Goodness',
      arabic:
          "خُذِ ٱلْعَفْوَ وَأْمُرْ بِٱلْعُرْفِ وَأَعْرِضْ عَنِ ٱلْجَٰهِلِينَ",
      translation:
          "Take what is given freely, enjoin what is good, and turn away from the ignorant.",
      urdu:
          "(اے محمدﷺ) عفو اختیار کرو اور نیک کام کرنے کا حکم دو اور جاہلوں سے کنارہ کرلو",
      reference: 'Surah Al-A’raf 7:199',
      contextOrReflection:
          'A timeless rule of emotional resilience: forgive readily, encourage virtue, and do not entertain toxic provocations.',
    ),
    DailyContentItem(
      id: 'ayah-8-2',
      title: 'Quality of the True Believers',
      arabic:
          "إِنَّمَا ٱلْمُؤْمِنُونَ ٱلَّذِينَ إِذَا ذُكِرَ ٱللَّهُ وَجِلَتْ قُلُوبُهُمْ وَإِذَا تُلِيَتْ عَلَيْهِمْ ءَايَٰتُهُۥ زَادَتْهُمْ إِيمَٰنًۭا وَعَلَىٰ رَبِّهِمْ يَتَوَكَّلُونَ",
      translation:
          "The believers are only those who, when Allah is mentioned, their hearts become fearful, and when His verses are recited to them, it increases them in faith; and upon their Lord they rely -",
      urdu:
          "مومن تو وہ ہیں کہ جب خدا کا ذکر کیا جاتا ہے کہ ان کے دل ڈر جاتے ہیں اور جب انہیں اس کی آیتیں پڑھ کر سنائی جاتی ہیں تو ان کا ایمان اور بڑھ جاتا ہے۔ اور وہ اپنے پروردگار پر بھروسہ رکھتے ہیں",
      reference: 'Surah Al-Anfal 8:2',
      contextOrReflection:
          'Contemplating Quranic verses deeply revitalizes faith and softens the heart.',
    ),
    DailyContentItem(
      id: 'ayah-9-129',
      title: 'Allah is Enough for Me',
      arabic:
          "فَإِن تَوَلَّوْا۟ فَقُلْ حَسْبِىَ ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ ۖ وَهُوَ رَبُّ ٱلْعَرْشِ ٱلْعَظِيمِ",
      translation:
          "But if they turn away, [O Muhammad], say, \"Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.\"",
      urdu:
          "پھر اگر یہ لوگ پھر جائیں (اور نہ مانیں) تو کہہ دو کہ خدا مجھے کفایت کرتا ہے اس کے سوا کوئی معبود نہیں اسی پر میرا بھروسہ ہے اور وہی عرش عظیم کا مالک ہے",
      reference: 'Surah At-Tawbah 9:129',
      contextOrReflection:
          'When you feel isolated or misunderstood, anchor yourself with Hasbiyallah.',
    ),
    DailyContentItem(
      id: 'ayah-10-57',
      title: 'Healing for the Hearts',
      arabic:
          "يَٰٓأَيُّهَا ٱلنَّاسُ قَدْ جَآءَتْكُم مَّوْعِظَةٌۭ مِّن رَّبِّكُمْ وَشِفَآءٌۭ لِّمَا فِى ٱلصُّدُورِ وَهُدًۭى وَرَحْمَةٌۭ لِّلْمُؤْمِنِينَ",
      translation:
          "O mankind, there has to come to you instruction from your Lord and healing for what is in the breasts and guidance and mercy for the believers.",
      urdu:
          "لوگو تمہارے پروردگار کی طرف سے نصیحت اور دلوں کی بیماریوں کی شفا۔ اور مومنوں کے لیے ہدایت اور رحمت آپہنچی ہے",
      reference: 'Surah Yunus 10:57',
      contextOrReflection:
          'The Quran heals emotional sorrow, spiritual doubt, and mental restlessness.',
    ),
    DailyContentItem(
      id: 'ayah-11-88',
      title: 'Success Comes Only From Allah',
      arabic:
          "قَالَ يَٰقَوْمِ أَرَءَيْتُمْ إِن كُنتُ عَلَىٰ بَيِّنَةٍۢ مِّن رَّبِّى وَرَزَقَنِى مِنْهُ رِزْقًا حَسَنًۭا ۚ وَمَآ أُرِيدُ أَنْ أُخَالِفَكُمْ إِلَىٰ مَآ أَنْهَىٰكُمْ عَنْهُ ۚ إِنْ أُرِيدُ إِلَّا ٱلْإِصْلَٰحَ مَا ٱسْتَطَعْتُ ۚ وَمَا تَوْفِيقِىٓ إِلَّا بِٱللَّهِ ۚ عَلَيْهِ تَوَكَّلْتُ وَإِلَيْهِ أُنِيبُ",
      translation:
          "He said, \"O my people, have you considered: if I am upon clear evidence from my Lord and He has provided me with a good provision from Him...? And I do not intend to differ from you in that which I have forbidden you; I only intend reform as much as I am able. And my success is not but through Allah. Upon him I have relied, and to Him I return.",
      urdu:
          "انہوں نے کہا کہ اے قوم! دیکھو تو اگر میں اپنے پروردگار کی طرف سے دلیل روشن پر ہوں اور اس نے اپنے ہاں سے مجھے نیک روزی دی ہو (تو کیا میں ان کے خلاف کروں گا؟) اور میں نہیں چاہتا کہ جس امر سے میں تمہیں منع کروں خود اس کو کرنے لگوں۔ میں تو جہاں تک مجھ سے ہوسکے (تمہارے معاملات کی) اصلاح چاہتا ہوں اور (اس بارے میں) مجھے توفیق کا ملنا خدا ہی (کے فضل) سے ہے۔ میں اسی پر بھروسہ رکھتا ہوں اور اس کی طرف رجوع کرتا ہوں",
      reference: 'Surah Hud 11:88',
      contextOrReflection:
          'Humility in our endeavors: our effort is required, but success (tawfeeq) is gifted by Allah alone.',
    ),
    DailyContentItem(
      id: 'ayah-12-86',
      title: 'Complaining Only to Allah',
      arabic:
          "قَالَ إِنَّمَآ أَشْكُوا۟ بَثِّى وَحُزْنِىٓ إِلَى ٱللَّهِ وَأَعْلَمُ مِنَ ٱللَّهِ مَا لَا تَعْلَمُونَ",
      translation:
          "He said, \"I only complain of my suffering and my grief to Allah, and I know from Allah that which you do not know.",
      urdu:
          "انہوں نے کہا کہ میں اپنے غم واندوہ کا اظہار خدا سے کرتا ہوں۔ اور خدا کی طرف سے وہ باتیں جانتا ہوں جو تم نہیں جانتے",
      reference: 'Surah Yusuf 12:86',
      contextOrReflection:
          'Do not exhaust yourself complaining to people; pour out your vulnerability to the One who can fix everything.',
    ),
    DailyContentItem(
      id: 'ayah-16-90',
      title: 'Justice and Excellence',
      arabic:
          "۞ إِنَّ ٱللَّهَ يَأْمُرُ بِٱلْعَدْلِ وَٱلْإِحْسَٰنِ وَإِيتَآئِ ذِى ٱلْقُرْبَىٰ وَيَنْهَىٰ عَنِ ٱلْفَحْشَآءِ وَٱلْمُنكَرِ وَٱلْبَغْىِ ۚ يَعِظُكُمْ لَعَلَّكُمْ تَذَكَّرُونَ",
      translation:
          "Indeed, Allah orders justice and good conduct and giving to relatives and forbids immorality and bad conduct and oppression. He admonishes you that perhaps you will be reminded.",
      urdu:
          "خدا تم کو انصاف اور احسان کرنے اور رشتہ داروں کو (خرچ سے مدد) دینے کا حکم دیتا ہے۔ اور بےحیائی اور نامعقول کاموں سے اور سرکشی سے منع کرتا ہے (اور) تمہیں نصیحت کرتا ہے تاکہ تم یاد رکھو",
      reference: 'Surah An-Nahl 16:90',
      contextOrReflection:
          'The foundation of moral excellence: justice in dealings, kindness in relationships, and restraint from harm.',
    ),
    DailyContentItem(
      id: 'ayah-17-23',
      title: 'Honoring Parents',
      arabic:
          "۞ وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوٓا۟ إِلَّآ إِيَّاهُ وَبِٱلْوَٰلِدَيْنِ إِحْسَٰنًا ۚ إِمَّا يَبْلُغَنَّ عِندَكَ ٱلْكِبَرَ أَحَدُهُمَآ أَوْ كِلَاهُمَا فَلَا تَقُل لَّهُمَآ أُفٍّۢ وَلَا تَنْهَرْهُمَا وَقُل لَّهُمَا قَوْلًۭا كَرِيمًۭا",
      translation:
          "And your Lord has decreed that you not worship except Him, and to parents, good treatment. Whether one or both of them reach old age [while] with you, say not to them [so much as], \"uff,\" and do not repel them but speak to them a noble word.",
      urdu:
          "اور تمہارے پروردگار نے ارشاد فرمایا ہے کہ اس کے سوا کسی کی عبادت نہ کرو اور ماں باپ کے ساتھ بھلائی کرتے رہو۔ اگر ان میں سے ایک یا دونوں تمہارے سامنے بڑھاپے کو پہنچ جائیں تو اُن کو اُف تک نہ کہنا اور نہ انہیں جھڑکنا اور اُن سے بات ادب کے ساتھ کرنا",
      reference: 'Surah Al-Isra 17:23',
      contextOrReflection:
          'Serving parents with patience, respect, and affectionate words is second only to monotheism.',
    ),
    DailyContentItem(
      id: 'ayah-18-10',
      title: 'Mercy and Right Guidance',
      arabic:
          "إِذْ أَوَى ٱلْفِتْيَةُ إِلَى ٱلْكَهْفِ فَقَالُوا۟ رَبَّنَآ ءَاتِنَا مِن لَّدُنكَ رَحْمَةًۭ وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًۭا",
      translation:
          "[Mention] when the youths retreated to the cave and said, \"Our Lord, grant us from Yourself mercy and prepare for us from our affair right guidance.\"",
      urdu:
          "جب وہ جوان غار میں جا رہے تو کہنے لگے کہ اے ہمارے پروردگار ہم پر اپنے ہاں سے رحمت نازل فرما۔ اور ہمارے کام درستی (کے سامان) مہیا کر",
      reference: 'Surah Al-Kahf 18:10',
      contextOrReflection:
          'The prayer of the Youth of the Cave: asking Allah for spiritual sanctuary and divine direction during moral storms.',
    ),
    DailyContentItem(
      id: 'ayah-19-96',
      title: 'Love Bestowed by the Most Merciful',
      arabic:
          "إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّٰلِحَٰتِ سَيَجْعَلُ لَهُمُ ٱلرَّحْمَٰنُ وُدًّۭا",
      translation:
          "Indeed, those who have believed and done righteous deeds - the Most Merciful will appoint for them affection.",
      urdu:
          "اور جو لوگ ایمان لائے اور عمل نیک کئے خدا ان کی محبت (مخلوقات کے دل میں) پیدا کردے گا",
      reference: 'Surah Maryam 19:96',
      contextOrReflection:
          'When you please Allah in secret, He places love and respect for you in the hearts of righteous people.',
    ),
  ];

  // =========================================================================
  // 30 Authentic Sahih Hadiths of the Day
  // =========================================================================
  static const List<DailyContentItem> hadithList = [
    DailyContentItem(
      id: 'hadith-bukhari-1',
      title: 'Actions are by Intentions',
      arabic:
          'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      translation:
          '“Actions are judged only by intentions, and every person will have only what they intended.”',
      urdu:
          'اعمال کا دارومدار نیتوں پر ہے، اور ہر شخص کے لیے وہی ہے جس کی اس نے نیت کی۔',
      reference: 'Sahih al-Bukhari 1',
      contextOrReflection:
          'Purify your intention before speaking, praying, working, or helping others. A sincere intention elevates everyday actions into worship.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-223',
      title: 'Purity is Half of Faith',
      arabic:
          'الطُّهُورُ شَطْرُ الإِيمَانِ، وَالْحَمْدُ لِلَّهِ تَمْلأُ الْمِيزَانَ',
      translation:
          '“Purity is half of faith, and saying ‘Alhamdulillah’ fills the scale of good deeds.”',
      urdu: 'پاکیزگی نصف ایمان ہے، اور الحمد للہ کہنا میزان کو بھر دیتا ہے۔',
      reference: 'Sahih Muslim 223',
      contextOrReflection:
          'Physical and spiritual purity are deeply linked. Keep your body, clothes, environment, and intentions clean.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-13',
      title: 'Love for Your Brother',
      arabic:
          'لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      translation:
          '“None of you truly believes until he loves for his brother what he loves for himself.”',
      urdu:
          'تم میں سے کوئی اس وقت تک کامل مومن نہیں ہو سکتا جب تک وہ اپنے بھائی کے لیے وہی پسند نہ کرے جو اپنے لیے پسند کرتا ہے۔',
      reference: 'Sahih al-Bukhari 13',
      contextOrReflection:
          'True faith purges envy and jealousy, replacing them with goodwill and genuine joy for others’ success.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-5027',
      title: 'The Best Among You',
      arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      translation:
          '“The best among you are those who learn the Qur’an and teach it to others.”',
      urdu: 'تم میں سب سے بہتر وہ ہے جو قرآن سیکھے اور اسے دوسروں کو سکھائے۔',
      reference: 'Sahih al-Bukhari 5027',
      contextOrReflection:
          'Spending even five minutes daily reciting and contemplating the Qur’an places you among the best of the Ummah.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-1987',
      title: 'Taqwa and Good Character',
      arabic:
          'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ، وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا، وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
      translation:
          '“Be conscious of Allah wherever you are; follow up a bad deed with a good one to wipe it out; and treat people with good manners.”',
      urdu:
          'جہاں بھی رہو اللہ سے ڈرو، اور برائی کے بعد نیکی کرو وہ اسے مٹا دے گی، اور لوگوں کے ساتھ اچھے اخلاق سے پیش آؤ۔',
      reference: 'Jami` at-Tirmidhi 1987 (Hasan)',
      contextOrReflection:
          'A profound three-part compass: relationship with Allah (Taqwa), relationship with oneself (Repentance), and relationship with people (Kindness).',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-69',
      title: 'Make Things Easy',
      arabic: 'يَسِّرُوا وَلاَ تُعَسِّرُوا، وَبَشِّرُوا وَلاَ تُنَفِّرُوا',
      translation:
          '“Facilitate things for people and do not make them difficult; give good tidings and do not repel them.”',
      urdu:
          'آسانیاں پیدا کرو اور مشکلات نہ کھڑی کرو، خوشخبری دو اور نفرت نہ پھیلاؤ۔',
      reference: 'Sahih al-Bukhari 69',
      contextOrReflection:
          'The prophetic way is one of mercy, encouragement, and practical ease, never unnecessary harshness.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-2516',
      title: 'Remember Allah in Ease',
      arabic: 'احْفَظِ اللَّهَ يَحْفَظْكَ، احْفَظِ اللَّهَ تَجِدْهُ تُجَاهَكَ',
      translation:
          '“Be mindful of Allah and He will protect you. Be mindful of Allah and you will find Him before you.”',
      urdu:
          'اللہ کے احکام کی حفاظت کرو وہ تمہاری حفاظت کرے گا، اللہ کو یاد رکھو تم اسے اپنے سامنے پاؤ گے۔',
      reference: 'Jami` at-Tirmidhi 2516 (Sahih)',
      contextOrReflection:
          'Hold firm to prayers and integrity in times of comfort, and Allah will be your shield in times of adversity.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6035',
      title: 'The Best in Manners',
      arabic: 'إِنَّ مِنْ خِيَارِكُمْ أَحْسَنَكُمْ أَخْلاَقًا',
      translation:
          '“The best among you are those who have the best character and manners.”',
      urdu: 'تم میں سے بہترین لوگ وہ ہیں جو اچھے اخلاق کے مالک ہیں۔',
      reference: 'Sahih al-Bukhari 6035',
      contextOrReflection:
          'Religious practice manifests in humble speech, patience in disagreement, and warm courtesy to family and strangers alike.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-1956',
      title: 'Smiling is Charity',
      arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
      translation:
          '“Your smiling in the face of your brother is an act of charity for you.”',
      urdu: 'اپنے بھائی کے سامنے مسکرانا بھی تمہارے لیے صدقہ ہے۔',
      reference: 'Jami` at-Tirmidhi 1956 (Sahih)',
      contextOrReflection:
          'Charity is not solely monetary; a gentle word, a warm smile, and lifting someone’s spirit is beloved to Allah.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6114',
      title: 'True Strength',
      arabic:
          'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
      translation:
          '“The strong man is not the one who wrestles; the strong man is the one who controls himself in anger.”',
      urdu:
          'طاقتور وہ نہیں جو پہلوان ہو، بلکہ طاقتور وہ ہے جو غصے کے وقت اپنے نفس پر قابو رکھے۔',
      reference: 'Sahih al-Bukhari 6114',
      contextOrReflection:
          'Mastering your temper requires far greater courage and spiritual discipline than any physical feat.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-2588',
      title: 'Charity Does Not Decrease Wealth',
      arabic:
          'مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ، وَمَا زَادَ اللَّهُ عَبْدًا بِعَفْوٍ إِلاَّ عِزًّا',
      translation:
          '“Charity does not decrease wealth, and no one forgives another except that Allah increases his honor.”',
      urdu:
          'صدقہ مال میں کمی نہیں کرتا، اور جو شخص معاف کرتا ہے اللہ اس کی عزت ہی بڑھاتا ہے۔',
      reference: 'Sahih Muslim 2588',
      contextOrReflection:
          'Give generously and let go of grudges; divine abundance and dignity are the guaranteed return.',
    ),
    DailyContentItem(
      id: 'hadith-ibn-majah-224',
      title: 'Seeking Knowledge',
      arabic: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
      translation: '“Seeking knowledge is an obligation upon every Muslim.”',
      urdu: 'علم حاصل کرنا ہر مسلمان پر فرض ہے۔',
      reference: 'Sunan Ibn Majah 224 (Sahih)',
      contextOrReflection:
          'Every believer is on a lifelong journey of learning their faith, honing beneficial skills, and improving the world.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-2699',
      title: 'Relieving Hardship',
      arabic:
          'مَنْ نَفَّسَ عَنْ مُؤْمِنٍ كُرْبَةً مِنْ كُرَبِ الدُّنْيَا نَفَّسَ اللَّهُ عَنْهُ كُرْبَةً مِنْ كُرَبِ يَوْمِ الْقِيَامَةِ',
      translation:
          '“Whoever relieves a believer of a distress from the distresses of this world, Allah will relieve him of a distress from the Day of Resurrection.”',
      urdu:
          'جس نے کسی مومن کی دنیاوی پریشانیوں میں سے کوئی پریشانی دور کی، اللہ قیامت کے دن اس کی پریشانیوں میں سے پریشانی دور فرمائے گا۔',
      reference: 'Sahih Muslim 2699',
      contextOrReflection:
          'Be an instrument of ease and relief for others, and your own hardships will be eased by the Almighty.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6407',
      title: 'Two Beloved Words',
      arabic:
          'كَلِمَتَانِ حَبِيبَتَانِ إِلَى الرَّحْمَنِ، خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      translation:
          '“Two words are beloved to the Most Merciful, light on the tongue, and heavy on the scale: SubhanAllahi wa bihamdihi, SubhanAllahil Azeem.”',
      urdu:
          'دو کلمے رحمان کو بہت محبوب ہیں، زبان پر ہلکے اور میزان میں بھاری ہیں: سبحان اللہ وبحمدہ، سبحان اللہ العظیم۔',
      reference: 'Sahih al-Bukhari 6407',
      contextOrReflection:
          'Keep your tongue moist with the praise of Allah throughout your day; its weight on the Day of Judgment is immense.',
    ),
    DailyContentItem(
      id: 'hadith-hakim-7831',
      title: 'Take Advantage of Five Before Five',
      arabic:
          'اغْتَنِمْ خَمْسًا قَبْلَ خَمْسٍ: شَبَابَكَ قَبْلَ هَرَمِكَ، وَصِحَّتَكَ قَبْلَ سَقَمِكَ، وَغِنَاكَ قَبْلَ فَقْرِكَ، وَفَرَاغَكَ قَبْلَ شُغْلِكَ، وَحَيَاتَكَ قَبْلَ مَوْتِكَ',
      translation:
          '“Take advantage of five before five: your youth before your old age, your health before your illness, your wealth before your poverty, your free time before your busyness, and your life before your death.”',
      urdu:
          'پانچ چیزوں کو پانچ چیزوں سے پہلے غنیمت جانو: جوانی کو بڑھاپے سے پہلے، صحت کو بیماری سے پہلے، مالداری کو غربت سے پہلے، فراغت کو مصروفیت سے پہلے، اور زندگی کو موت سے پہلے۔',
      reference: 'Al-Hakim 7831 (Sahih)',
      contextOrReflection:
          'Time is your most irreplaceable capital; seize present opportunities to build your eternal Hereafter.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-10',
      title: 'Definition of a True Muslim',
      arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      translation:
          '“A Muslim is the one from whose tongue and hands the Muslims are safe.”',
      urdu: 'کامل مسلمان وہ ہے جس کی زبان اور ہاتھ سے دوسرے مسلمان محفوظ رہیں۔',
      reference: 'Sahih al-Bukhari 10',
      contextOrReflection:
          'Faith is validated by social safety: neither damaging others’ honor with words nor hurting them with actions.',
    ),
    DailyContentItem(
      id: 'hadith-abudawud-4682',
      title: 'Completeness of Faith',
      arabic:
          'أَكْمَلُ الْمُؤْمِنِينَ إِيمَانًا أَحْسَنُهُمْ خُلُقًا، وَخِيَارُكُمْ خِيَارُكُمْ لِنِسَائِهِمْ',
      translation:
          '“The most complete of believers in faith are those with the best character, and the best of you are those best to their wives.”',
      urdu:
          'مومنوں میں سب سے کامل ایمان والا وہ ہے جو اخلاق میں سب سے اچھا ہو، اور تم میں سب سے بہتر وہ ہے جو اپنے اہل و عیال کے لیے سب سے بہتر ہو۔',
      reference: 'Sunan Abi Dawud 4682 (Sahih)',
      contextOrReflection:
          'Private conduct at home with your family is the true benchmark of spiritual sincerity.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-2564',
      title: 'Allah Looks at the Hearts',
      arabic:
          'إِنَّ اللَّهَ لاَ يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ، وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ',
      translation:
          '“Allah does not look at your outward appearances or your wealth, but He looks at your hearts and your actions.”',
      urdu:
          'اللہ تمہاری صورتوں اور مالوں کو نہیں دیکھتا، بلکہ وہ تمہارے دلوں اور اعمال کو دیکھتا ہے۔',
      reference: 'Sahih Muslim 2564',
      contextOrReflection:
          'Outer status means nothing without inner sincerity and righteous deeds.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6018',
      title: 'Speak Good or Remain Silent',
      arabic:
          'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      translation:
          '“Whoever believes in Allah and the Last Day, let him speak good or remain silent.”',
      urdu:
          'جو اللہ اور آخرت کے دن پر ایمان رکھتا ہو، اسے چاہیے کہ اچھی بات کہے یا خاموش رہے۔',
      reference: 'Sahih al-Bukhari 6018',
      contextOrReflection:
          'Guard your tongue; silence is wisdom and prevents countless regrets.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-5304',
      title: 'Caring for the Orphan',
      arabic:
          'أَنَا وَكَافِلُ الْيَتِيمِ فِي الْجَنَّةِ هَكَذَا — وَأَشَارَ بِالسَّبَّابَةِ وَالْوُسْطَى',
      translation:
          '“I and the sponsor of an orphan will be in Paradise like this” — and he indicated with his index and middle fingers.',
      urdu:
          'میں اور یتیم کی کفالت کرنے والا جنت میں اس طرح ہوں گے — اور آپ نے شہادت اور بیچ کی انگلی سے اشارہ فرمایا۔',
      reference: 'Sahih al-Bukhari 5304',
      contextOrReflection:
          'Supporting vulnerable children brings direct companionship with the Prophet (ﷺ) in the highest gardens of Jannah.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-2553',
      title: 'Righteousness and Sin',
      arabic:
          'الْبِرُّ حُسْنُ الْخُلُقِ، وَالإِثْمُ مَا حَاكَ فِي صَدْرِكَ وَكَرِهْتَ أَنْ يَطَّلِعَ عَلَيْهِ النَّاسُ',
      translation:
          '“Righteousness is good character, and sin is that which wavers in your chest and you dislike that people should find out about it.”',
      urdu:
          'نیکی اچھے اخلاق کا نام ہے، اور گناہ وہ ہے جو تمہارے سینے میں کھٹکے اور تم ناپسند کرو کہ لوگوں کو اس کی خبر ہو۔',
      reference: 'Sahih Muslim 2553',
      contextOrReflection:
          'Your conscience is a divine compass; when something feels unsettled, turn away from it.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6446',
      title: 'True Wealth is Contentment',
      arabic:
          'لَيْسَ الْغِنَى عَنْ كَثْرَةِ الْعَرَضِ، وَلَكِنَّ الْغِنَى غِنَى النَّفْسِ',
      translation:
          '“Richness does not lie in an abundance of worldly goods; true richness is the contentment of the soul.”',
      urdu:
          'مالداری ساز و سامان کی کثرت کا نام نہیں، بلکہ حقیقی مالداری دل کا غنی ہونا ہے۔',
      reference: 'Sahih al-Bukhari 6446',
      contextOrReflection:
          'A peaceful, grateful heart experiences wealth that no bank account can purchase.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-2664',
      title: 'The Strong Believer',
      arabic:
          'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ، وَفِي كُلٍّ خَيْرٌ',
      translation:
          '“The strong believer is better and more beloved to Allah than the weak believer, while there is good in both.”',
      urdu:
          'طاقتور مومن کمزور مومن سے بہتر اور اللہ کو زیادہ محبوب ہے، اگرچہ دونوں میں ہی بھلائی ہے۔',
      reference: 'Sahih Muslim 2664',
      contextOrReflection:
          'Strive for mental fortitude, physical vitality, financial independence, and spiritual depth.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6117',
      title: 'Modesty Brings Only Good',
      arabic: 'الْحَيَاءُ لاَ يَأْتِي إِلاَّ بِخَيْرٍ',
      translation: '“Modesty (Haya) brings forth nothing but goodness.”',
      urdu: 'حیا ہمیشہ بھلائی ہی لاتی ہے۔',
      reference: 'Sahih al-Bukhari 6117',
      contextOrReflection:
          'Modesty before Allah and people protects dignity, speech, and moral clarity.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6416',
      title: 'A Traveler in This World',
      arabic: 'كُنْ فِي الدُّنْيَا كَأَنَّكَ غَرِيبٌ، أَوْ عَابِرُ سَبِيلٍ',
      translation:
          '“Be in this world as if you were a stranger or a traveler passing on a pathway.”',
      urdu:
          'دنیا میں اس طرح رہو گویا کہ تم کوئی پردیسی ہو یا راستہ پار کرنے والے مسافر۔',
      reference: 'Sahih al-Bukhari 6416',
      contextOrReflection:
          'Do not attach your soul permanently to a temporary station; pack good deeds for the eternal home.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-1924',
      title: 'Mercy to the Creation',
      arabic:
          'الرَّاحِمُونَ يَرْحَمُهُمُ الرَّحْمَنُ، ارْحَمُوا مَنْ فِي الأَرْضِ يَرْحَمْكُمْ مَنْ فِي السَّمَاءِ',
      translation:
          '“The merciful will be shown mercy by the Most Merciful. Be merciful to those on earth, and the One in the heavens will be merciful to you.”',
      urdu:
          'رحم کرنے والوں پر رحمان رحم فرماتا ہے، تم زمین والوں پر رحم کرو، آسمان والا تم پر رحم فرمائے گا۔',
      reference: 'Jami` at-Tirmidhi 1924 (Sahih)',
      contextOrReflection:
          'Extend forgiveness, gentle care, and kindness to every human and animal in your orbit.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6116',
      title: 'Do Not Be Angry',
      arabic: 'لاَ تَغْضَبْ — فَرَدَّدَ مِرَارًا، قَالَ: لاَ تَغْضَبْ',
      translation:
          '“‘Do not become angry.’ The man asked repeatedly, and each time the Prophet said: ‘Do not become angry.’”',
      urdu:
          'غصہ مت کرو — اس شخص نے بار بار پوچھا، آپ نے ہر بار یہی فرمایا: غصہ مت کرو۔',
      reference: 'Sahih al-Bukhari 6116',
      contextOrReflection:
          'Pause and breathe before reacting; suppressing impulsive rage safeguards relationships and dignity.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-1977',
      title: 'Noble Speech',
      arabic:
          'لَيْسَ الْمُؤْمِنُ بِالطَّعَّانِ وَلاَ اللَّعَّانِ وَلاَ الْفَاحِشِ وَلاَ الْبَذِيءِ',
      translation:
          '“The believer is not one who taunts, curses, or acts indecently or speaks foul language.”',
      urdu:
          'مومن نہ طعنہ دینے والا ہوتا ہے، نہ لعنت کرنے والا، نہ بے حیا اور نہ گالی گلوچ کرنے والا۔',
      reference: 'Jami` at-Tirmidhi 1977 (Sahih)',
      contextOrReflection:
          'Clean speech reflects an illuminated heart. Refrain from gossip, mockery, and slander.',
    ),
    DailyContentItem(
      id: 'hadith-adab-594',
      title: 'Exchanging Gifts',
      arabic: 'تَهَادَوْا تَحَابُّوا',
      translation:
          '“Exchange gifts and you will increase in love for one another.”',
      urdu: 'ایک دوسرے کو تحفے دیا کرو، تم میں باہمی محبت بڑھے گی۔',
      reference: 'Al-Adab Al-Mufrad 594 (Hasan)',
      contextOrReflection:
          'Even a small thoughtful gesture melts grudges and solidifies companionship.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-2317',
      title: 'Leaving What Does Not Concern You',
      arabic: 'مِنْ حُسْنِ إِسْلاَمِ الْمَرْءِ تَرْكُهُ مَا لاَ يَعْنِيهِ',
      translation:
          '“Part of the excellence of one’s Islam is his leaving alone that which does not concern him.”',
      urdu:
          'انسان کے اسلام کی اچھائی میں سے یہ ہے کہ وہ بے مقصد اور فضول باتوں کو چھوڑ دے۔',
      reference: 'Jami` at-Tirmidhi 2317 (Sahih)',
      contextOrReflection:
          'Focus on your personal growth, family, and duties; discard needless drama and curiosity.',
    ),
  ];

  // =========================================================================
  // 30 Authentic Daily Duas
  // =========================================================================
  static const List<DailyContentItem> duaList = [
    DailyContentItem(
      id: 'dua-20-114',
      title: 'Dua for Knowledge',
      arabic: 'رَّبِّ زِدْنِي عِلْمًا',
      transliteration: "Rabbi zidnee 'ilma",
      translation: '“My Lord, increase me in knowledge.”',
      urdu: 'اے میرے رب! میرے علم میں اضافہ فرما۔',
      reference: 'Quran 20:114',
      contextOrReflection:
          'Recite this before studying, reading, or seeking clarity in any decision.',
    ),
    DailyContentItem(
      id: 'dua-2-201',
      title: 'Goodness in Both Worlds',
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      transliteration:
          "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina 'athaban-nar",
      translation:
          '“Our Lord, give us in this world that which is good and in the Hereafter that which is good and protect us from the punishment of the Fire.”',
      urdu:
          'اے ہمارے رب! ہمیں دنیا میں بھی بھلائی دے اور آخرت میں بھی بھلائی دے اور ہمیں آگ کے عذاب سے بچا۔',
      reference: 'Quran 2:201',
      contextOrReflection:
          'The most frequent supplication of the Prophet Muhammad (ﷺ), encompassing all worldly and eternal welfare.',
    ),
    DailyContentItem(
      id: 'dua-3-8',
      title: 'Steadfast Heart',
      arabic:
          'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
      transliteration:
          "Rabbana la tuzigh quloobana ba'da ith hadaytana wa hab lana min ladunka rahmah",
      translation:
          '“Our Lord, let not our hearts deviate after You have guided us and grant us from Yourself mercy. Indeed, You are the Bestower.”',
      urdu:
          'اے ہمارے رب! ہمارے دلوں کو ہدایت کے بعد ٹیڑھا نہ کر اور ہمیں اپنی بارگاہ سے رحمت عطا فرما۔',
      reference: 'Quran 3:8',
      contextOrReflection:
          'A powerful prayer asking Allah to protect faith and spiritual consistency until our last breath.',
    ),
    DailyContentItem(
      id: 'dua-28-24',
      title: 'Dua in Need of Goodness',
      arabic: 'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      transliteration: "Rabbi innee lima anzalta ilayya min khayrin faqeer",
      translation:
          '“My Lord, indeed I am, for whatever good You would send down to me, in need.”',
      urdu:
          'اے میرے رب! جو بھی بھلائی تو مجھ پر نازل فرمائے، میں اس کا محتاج ہوں۔',
      reference: 'Quran 28:24 (Dua of Musa AS)',
      contextOrReflection:
          'The humble prayer of Prophet Musa (AS) when destitute and alone; Allah blessed him with shelter, family, and work.',
    ),
    DailyContentItem(
      id: 'dua-21-87',
      title: 'Dua of Prophet Yunus (AS)',
      arabic:
          'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      transliteration:
          "La ilaha illa anta subhanaka innee kuntu minaz-zalimeen",
      translation:
          '“There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.”',
      urdu: 'تیرے سوا کوئی معبود نہیں، تو پاک ہے، بے شک میں ہی قصوروار تھا۔',
      reference: 'Quran 21:87 (Ayat-e-Kareema)',
      contextOrReflection:
          'No Muslim calls upon Allah with these words in distress except that Allah relieves their hardship.',
    ),
    DailyContentItem(
      id: 'dua-morning-evening',
      title: 'Seeking Protection and Well-Being',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ',
      transliteration:
          "Allahumma innee as'alukal-'afwa wal-'afiyata fid-dunya wal-akhirah",
      translation:
          '“O Allah, I ask You for pardon and well-being in this world and the Hereafter.”',
      urdu:
          'اے اللہ! میں تجھ سے دنیا اور آخرت میں معافی اور عافیت کا سوال کرتا ہوں۔',
      reference: 'Sunan Abi Dawud 5074 (Sahih)',
      contextOrReflection:
          '‘Afiyah means comprehensive protection from illness, anxiety, spiritual trial, and sudden hardship.',
    ),
    DailyContentItem(
      id: 'dua-anxiety',
      title: 'Relief from Worry and Debt',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
      transliteration:
          "Allahumma innee a'oothu bika minal-hammi wal-hazan, wal-'ajzi wal-kasal, wal-bukhli wal-jubn, wa dala'id-dayni wa ghalabatir-rijal",
      translation:
          '“O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, miserliness and cowardice, the burden of debt, and being overpowered by men.”',
      urdu:
          'اے اللہ! میں تیری پناہ مانگتا ہوں پریشانی اور غم سے، کمزوری اور سستی سے، بخل اور بزدلی سے، اور قرض کے بوجھ اور لوگوں کے دباؤ سے۔',
      reference: 'Sahih al-Bukhari 2893',
      contextOrReflection:
          'The ultimate daily supplication against mental overwhelm, fatigue, financial distress, and self-doubt.',
    ),
    DailyContentItem(
      id: 'dua-17-24',
      title: 'Dua for Parents',
      arabic: 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      transliteration: "Rabbi irhamhuma kama rabbayanee sagheera",
      translation:
          '“My Lord, have mercy upon them as they brought me up [when I was] small.”',
      urdu:
          'اے میرے رب! ان دونوں پر رحم فرما جیسا کہ انہوں نے بچپن میں میری پرورش کی۔',
      reference: 'Quran 17:24',
      contextOrReflection:
          'The most beautiful prayer for parents, honoring their tender sacrifices during childhood.',
    ),
    DailyContentItem(
      id: 'dua-25-74',
      title: 'Dua for Family & Offspring',
      arabic:
          'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      transliteration:
          "Rabbana hab lana min azwajina wa dhurriyyatina qurrata a'yunin waj'alna lil-muttaqeena imama",
      translation:
          '“Our Lord, grant us from among our spouses and offspring comfort to our eyes and make us an example for the righteous.”',
      urdu:
          'اے ہمارے رب! ہمیں ہماری بیویوں اور اولاد کی طرف سے آنکھوں کی ٹھنڈک عطا فرما اور ہمیں پرہیزگاروں کا پیشوا بنا۔',
      reference: 'Quran 25:74',
      contextOrReflection:
          'A comprehensive prayer for household harmony, pious children, and spiritual leadership.',
    ),
    DailyContentItem(
      id: 'dua-bukhari-6306',
      title: 'Sayyidul Istighfar (Chief of Prayers for Forgiveness)',
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ',
      transliteration:
          "Allahumma anta Rabbi la ilaha illa anta, khalaqtanee wa ana 'abduka, wa ana 'ala 'ahdika wa wa'dika mastata'tu...",
      translation:
          '“O Allah, You are my Lord; there is no deity except You. You created me and I am Your servant, and I abide by Your covenant as much as I am able...”',
      urdu:
          'اے اللہ! تو میرا رب ہے، تیرے سوا کوئی معبود نہیں، تو نے مجھے پیدا کیا اور میں تیرا بندہ ہوں اور تیرے عہد پر قائم ہوں۔',
      reference: 'Sahih al-Bukhari 6306',
      contextOrReflection:
          'Whoever recites this with firm conviction during the day or night and dies, enters Paradise.',
    ),
    DailyContentItem(
      id: 'dua-home-leaving',
      title: 'Dua Leaving Home',
      arabic:
          'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ',
      transliteration:
          "Bismillahi tawakkaltu 'ala Allahi, wa la hawla wa la quwwata illa billah",
      translation:
          '“In the name of Allah, I rely upon Allah; there is no power nor strength except with Allah.”',
      urdu:
          'اللہ کے نام کے ساتھ، میں نے اللہ پر بھروسہ کیا، اور گناہ سے بچنے اور نیکی کرنے کی طاقت اللہ ہی کی توفیق سے ہے۔',
      reference: 'Sunan Abi Dawud 5095 (Sahih)',
      contextOrReflection:
          'Upon reciting this, an angel calls out: You are guided, defended, and protected, and Shaytan steps away.',
    ),
    DailyContentItem(
      id: 'dua-muslim-2721',
      title: 'Dua for Guidance, Piety & Contentment',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      transliteration:
          "Allahumma innee as'alukal-huda wat-tuqa wal-'afafa wal-ghina",
      translation:
          '“O Allah, I ask You for guidance, piety, chastity, and self-sufficiency.”',
      urdu:
          'اے اللہ! میں تجھ سے ہدایت، تقویٰ، پاکدامنی اور دل کی بے نیازی کا سوال کرتا ہوں۔',
      reference: 'Sahih Muslim 2721',
      contextOrReflection:
          'Four words that encompass the pinnacle of spiritual success and worldly peace.',
    ),
    DailyContentItem(
      id: 'dua-2-250',
      title: 'Dua for Patience & Firmness',
      arabic:
          'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      transliteration:
          "Rabbana afrigh 'alayna sabran wa thabbit aqdamana wansurna 'alal-qawmil-kafireen",
      translation:
          '“Our Lord, pour upon us patience and plant firmly our feet and give us victory over the disbelieving people.”',
      urdu:
          'اے ہمارے رب! ہم پر صبر انڈیل دے اور ہمارے قدم جما دے اور کافر قوم کے مقابلے میں ہماری مدد فرما۔',
      reference: 'Quran 2:250',
      contextOrReflection:
          'Recite when facing challenging trials, high-stakes tasks, or moments requiring extreme endurance.',
    ),
    DailyContentItem(
      id: 'dua-7-23',
      title: 'Prayer of Adam & Hawwa (AS)',
      arabic:
          'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      transliteration:
          "Rabbana zalamna anfusana wa-in lam taghfir lana wa tarhamna lanakoonanna minal-khasireen",
      translation:
          '“Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.”',
      urdu:
          'اے ہمارے رب! ہم نے اپنی جانوں پر ظلم کیا، اور اگر تو نے ہمیں نہ بخشا اور ہم پر رحم نہ فرمایا تو ہم خسارہ پانے والوں میں سے ہو جائیں گے۔',
      reference: 'Quran 7:23',
      contextOrReflection:
          'The humble prayer of sincere tawbah (repentance) taught to our first parents by Allah Himself.',
    ),
    DailyContentItem(
      id: 'dua-muslim-763',
      title: 'Dua for Light (Nur) in Heart and Senses',
      arabic:
          'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا، وَفِي لِسَانِي نُورًا، وَفِي بَصَرِي نُورًا، وَفِي سَمْعِي نُورًا، وَعَنْ يَمِينِي نُورًا، وَعَنْ يَسَارِي نُورًا',
      transliteration:
          "Allahumma ij'al fee qalbee noora, wa fee lisaanee noora, wa fee basaree noora, wa fee sam'ee noora...",
      translation:
          '“O Allah, place light in my heart, light on my tongue, light in my hearing, light in my sight, light on my right, and light on my left...”',
      urdu:
          'اے اللہ! میرے دل میں نور پیدا فرما، میری زبان میں نور، میری آنکھوں میں نور، میرے کانوں میں نور، میرے دائیں نور اور میرے بائیں نور پیدا فرما۔',
      reference: 'Sahih Muslim 763',
      contextOrReflection:
          'Invokes divine illumination (Noor) so that your thoughts, speech, and vision are guided by truth.',
    ),
    DailyContentItem(
      id: 'dua-21-83',
      title: 'Dua of Ayyub (AS) in Sickness',
      arabic: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ',
      transliteration: "Annee massaniya addurru wa-anta arhamu arrahimeen",
      translation:
          '“‘Indeed, adversity has touched me, and You are the most merciful of the merciful.’”',
      urdu:
          'بے شک مجھے بیماری نے آ گھیرا ہے اور تو سب رحم کرنے والوں سے بڑھ کر رحم فرمانے والا ہے۔',
      reference: 'Quran 21:83',
      contextOrReflection:
          'The humble prayer of Prophet Ayyub (AS) during illness; Allah answered him and restored his health and family.',
    ),
    DailyContentItem(
      id: 'dua-3-173',
      title: 'Allah is Sufficient for Us',
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      transliteration: "Hasbuna Allahu wa ni'mal-wakeel",
      translation:
          '“Allah is sufficient for us, and He is the best Disposer of affairs.”',
      urdu: 'ہمیں اللہ ہی کافی ہے اور وہ بہترین کارساز ہے۔',
      reference: 'Quran 3:173',
      contextOrReflection:
          'Uttered by Prophet Ibrahim (AS) when thrown into the fire, and Prophet Muhammad (ﷺ) in the face of daunting adversity.',
    ),
    DailyContentItem(
      id: 'dua-tirmidhi-3522',
      title: 'Dua for a Steadfast Heart in Faith',
      arabic: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
      transliteration: "Ya Muqallibal-quloob, thabbit qalbee 'ala deenik",
      translation:
          '“O Turner of hearts, make my heart firm upon Your religion.”',
      urdu: 'اے دلوں کو پھیرنے والے! میرے دل کو اپنے دین پر ثابت قدم رکھ۔',
      reference: 'Jami` at-Tirmidhi 3522 (Sahih)',
      contextOrReflection:
          'The Prophet (ﷺ) recited this frequently, reminding us that hearts change easily and require continuous divine steadfastness.',
    ),
    DailyContentItem(
      id: 'dua-muslim-2708',
      title: 'Protection from Harm & Evil',
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      transliteration:
          "A'oothu bi-kalimatillahi attammati min sharri ma khalaq",
      translation:
          '“I seek refuge in the perfect words of Allah from the evil of what He has created.”',
      urdu:
          'میں اللہ کے کامل کلمات کی پناہ مانگتا ہوں اس کی پیدا کردہ تمام چیزوں کے شر سے۔',
      reference: 'Sahih Muslim 2708',
      contextOrReflection:
          'A powerful sunnah protection when stopping at any place or beginning morning and evening hours.',
    ),
    DailyContentItem(
      id: 'dua-abudawud-5090',
      title: 'Dua for Health & Senses',
      arabic:
          'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لاَ إِلَهَ إِلاَّ أَنْتَ',
      transliteration:
          "Allahumma 'afinee fee badanee, Allahumma 'afinee fee sam'ee, Allahumma 'afinee fee basaree, la ilaha illa anta",
      translation:
          '“O Allah, grant well-being to my body; O Allah, grant well-being to my hearing; O Allah, grant well-being to my sight. There is no deity except You.”',
      urdu:
          'اے اللہ! میرے بدن میں عافیت دے، اے اللہ! میرے کانوں میں عافیت دے، اے اللہ! میری آنکھوں میں عافیت دے، تیرے سوا کوئی معبود نہیں۔',
      reference: 'Sunan Abi Dawud 5090 (Hasan)',
      contextOrReflection:
          'Recite three times morning and evening to seek lifelong bodily health and clarity of senses.',
    ),
    DailyContentItem(
      id: 'dua-tirmidhi-3563',
      title: 'Dua for Halal Provision & Freedom from Debt',
      arabic:
          'اللَّهُمَّ اكْفِنِي بِحَلاَلِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      transliteration:
          "Allahumma ikfinee bi-halalika 'an haramik, wa aghninee bi-fadlika 'amman siwak",
      translation:
          '“O Allah, suffice me with Your lawful against Your unlawful, and enrich me with Your grace from all besides You.”',
      urdu:
          'اے اللہ! مجھے حلال رزق دے کر حرام سے بچا، اور اپنے فضل سے اپنے سوا سب سے بے نیاز کر دے۔',
      reference: 'Jami` at-Tirmidhi 3563 (Hasan)',
      contextOrReflection:
          'Relieves financial anxiety and anchors one to pure, ethical earning free from corrupt compromise.',
    ),
    DailyContentItem(
      id: 'dua-2-127',
      title: 'Dua for Acceptance of Worship',
      arabic: 'رَبَّنَا تَقَبَّلْ مِنَّا ۖ إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
      transliteration: "Rabbana taqabbal minna innaka anta Assamee'ul-'Aleem",
      translation:
          '“Our Lord, accept [this] from us. Indeed, You are the Hearing, the Knowing.”',
      urdu:
          'اے ہمارے رب! ہم سے قبول فرما، بے شک تو ہی سب کچھ سننے والا اور جاننے والا ہے۔',
      reference: 'Quran 2:127 (Dua of Ibrahim AS & Ismail AS)',
      contextOrReflection:
          'Supplicated after finishing prayer, fasting, charity, or reading Quran, asking Allah to graciously accept our modest deeds.',
    ),
    DailyContentItem(
      id: 'dua-tirmidhi-3433',
      title: 'Expiation of the Gathering (Kaffaratul Majlis)',
      arabic:
          'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
      transliteration:
          "Subhanakallahumma wa bihamdika, ash-hadu alla ilaha illa anta, astaghfiruka wa atoobu ilayk",
      translation:
          '“Glory is to You, O Allah, and praise. I bear witness that there is no deity except You. I seek Your forgiveness and repent to You.”',
      urdu:
          'پاک ہے تو اے اللہ اور تیری ہی تعریف ہے، میں گواہی دیتا ہوں کہ تیرے سوا کوئی معبود نہیں، میں تجھ سے بخشش مانگتا ہوں اور تیری طرف توبہ کرتا ہوں۔',
      reference: 'Jami` at-Tirmidhi 3433 (Sahih)',
      contextOrReflection:
          'Wipes clean any unintentional idle words or mistakes made during any conversation or gathering before departing.',
    ),
    DailyContentItem(
      id: 'dua-abudawud-5079',
      title: 'Protection from Hellfire',
      arabic: 'اللَّهُمَّ أَجِرْنِي مِنَ النَّارِ',
      transliteration: "Allahumma ajirnee minan-nar",
      translation: '“O Allah, protect me from the Fire.”',
      urdu: 'اے اللہ! مجھے جہنم کی آگ سے پناہ عطا فرما۔',
      reference: 'Sunan Abi Dawud 5079',
      contextOrReflection:
          'Recite seven times after Fajr and Maghrib for divine safety and preservation.',
    ),
    DailyContentItem(
      id: 'dua-ibnmajah-4340',
      title: 'Asking for Paradise',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ، وَأَعُوذُ بِكَ مِنَ النَّارِ',
      transliteration:
          "Allahumma innee as'alukal-jannata wa ma qarraba ilayha min qawlin aw 'amal, wa a'oothu bika minan-nar",
      translation:
          '“O Allah, I ask You for Paradise and whatever words or actions bring me closer to it, and I seek refuge in You from the Fire.”',
      urdu:
          'اے اللہ! میں تجھ سے جنت اور اس کے قریب کرنے والے قول و عمل کا سوال کرتا ہوں، اور جہنم کی آگ سے پناہ مانگتا ہوں۔',
      reference: 'Sunan Ibn Majah 4340 (Sahih)',
      contextOrReflection:
          'The ultimate aspiration of every Muslim: requesting entry into Jannah and the righteous deeds that lead to it.',
    ),
    DailyContentItem(
      id: 'dua-bukhari-6345',
      title: 'Dua During Distress & Calamity',
      arabic:
          'لاَ إِلَهَ إِلاَّ اللَّهُ الْعَظِيمُ الْحَلِيمُ، لاَ إِلَهَ إِلاَّ اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لاَ إِلَهَ إِلاَّ اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ',
      transliteration:
          "La ilaha illallahu Al-'Azeemul-Haleem, la ilaha illallahu Rabbul-'Arshil-'Azeem...",
      translation:
          '“There is no deity except Allah, the Magnificent, the Forbearing. There is no deity except Allah, Lord of the Magnificent Throne...”',
      urdu:
          'اللہ کے سوا کوئی معبود نہیں جو عظیم اور بردبار ہے، اللہ کے سوا کوئی معبود نہیں جو عرشِ عظیم کا رب ہے، آسمانوں اور زمین اور عزت والے عرش کا رب ہے۔',
      reference: 'Sahih al-Bukhari 6345',
      contextOrReflection:
          'The Prophet (ﷺ) turned to this magnificent praise whenever an acute crisis or severe distress emerged.',
    ),
    DailyContentItem(
      id: 'dua-abudawud-5073',
      title: 'Morning Thanksgiving',
      arabic:
          'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لاَ شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
      transliteration:
          "Allahumma ma asbaha bee min ni'matin aw bi-ahadin min khalqika faminka wahdaka la shareeka lak...",
      translation:
          '“O Allah, whatever blessing has come to me or any of Your creation this morning is from You alone, without partner; to You belongs praise and thanks.”',
      urdu:
          'اے اللہ! مجھ پر یا تیری مخلوق میں سے کسی پر بھی جو نعمت صبح کے وقت ہے وہ اکیلے تیری طرف سے ہے، تیرا کوئی شریک نہیں، پس تیرے ہی لیے تمام تعریف اور شکر ہے۔',
      reference: 'Sunan Abi Dawud 5073 (Sahih)',
      contextOrReflection:
          'Whoever recites this in the morning fulfills their obligation of gratitude for that entire day.',
    ),
    DailyContentItem(
      id: 'dua-26-83',
      title: 'Wisdom & Joining the Righteous',
      arabic:
          'رَبِّ هَبْ لِي حُكْمًا وَأَلْحِقْنِي بِالصَّالِحِينَ • وَاجْعَل لِّي لِسَانَ صِدْقٍ فِي الْآخِرِينَ',
      transliteration:
          "Rabbi hab lee hukman wa-alhiqnee bissaliheen, waj'al lee lisana sidqin fil-akhireen",
      translation:
          '“My Lord, grant me wisdom and join me with the righteous, and grant me a reputation of honor among later generations.”',
      urdu:
          'اے میرے رب! مجھے حکمت عطا فرما اور مجھے نیکوکاروں کے ساتھ ملا دے، اور بعد کے لوگوں میں میرا اچھا ذکر قائم رکھ۔',
      reference: 'Quran 26:83-84 (Dua of Ibrahim AS)',
      contextOrReflection:
          'A prayer for sound moral judgment, righteous company, and leaving behind a legacy that guides others.',
    ),
    DailyContentItem(
      id: 'dua-ahmad-3712',
      title: 'Relief from Anxiety and Heavy Grief',
      arabic:
          'اللَّهُمَّ إِنِّي عَبْدُكَ، ابْنُ عَبْدِكَ، ابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ',
      transliteration:
          "Allahumma innee 'abduka, ibnu 'abdika, ibnu amatika, nasiyatee biyadika, madin fiyya hukmuka, 'adlun fiyya qada-uka...",
      translation:
          '“O Allah, I am Your servant, son of Your servant, son of Your maidservant; my forelock is in Your hand, Your command over me is ever executed and Your decree over me is just...”',
      urdu:
          'اے اللہ! میں تیرا بندہ ہوں، تیرے بندے اور تیری بندی کا بیٹا ہوں، میری پیشانی تیرے ہاتھ میں ہے، مجھ پر تیرا حکم نافذ ہے، میرے حق میں تیرا فیصلہ سراسر عدل ہے۔',
      reference: 'Musnad Ahmad 3712 (Sahih)',
      contextOrReflection:
          'Whoever says this in deep grief, Allah removes their sorrow and replaces it with joy and ease.',
    ),
    DailyContentItem(
      id: 'dua-2-286',
      title: 'Our Lord, Do Not Hold Us Accountable',
      arabic:
          'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا',
      transliteration:
          "Rabbana la tu-akhithna in naseena aw akhta'na, Rabbana wala tahmil 'alayna isran...",
      translation:
          '“Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us...”',
      urdu:
          'اے ہمارے رب! اگر ہم بھول جائیں یا خطا کر بیٹھیں تو ہماری پکڑ نہ فرما، اے ہمارے رب! اور ہم پر بھاری بوجھ نہ ڈال جیسا کہ تو نے ہم سے پہلے لوگوں پر ڈالا تھا۔',
      reference: 'Quran 2:286',
      contextOrReflection:
          'The concluding verse of Surah Al-Baqarah, carrying divine guarantees of pardon, protection, and victory.',
    ),
  ];
}
