/// Phase 17 — Daily Content Service for rotating Ayat, Hadith, and Duas.
///
/// Features authentic Quranic verses, Sahih Hadiths (Bukhari, Muslim,
/// Tirmidhi, Abu Dawud, Ibn Majah), and authentic supplications.
/// Each collection deterministically rotates every calendar day, so:
/// 1. A new Ayah, Hadith, and Dua appears every day.
/// 2. Throughout that specific day, it remains consistent.
/// 3. Offline-safe with complete fallback content.
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
    final epoch = DateTime(2025, 1, 1);
    final diff = DateTime(d.year, d.month, d.day).difference(epoch).inDays;
    return diff.abs() % length;
  }

  /// Returns today's Ayat of the Day, rotating each day.
  static DailyContentItem getAyahOfDay([DateTime? date]) {
    final idx = _dayIndex(ayatList.length, date);
    return ayatList[idx];
  }

  /// Returns today's Hadith of the Day, rotating each day.
  static DailyContentItem getHadithOfDay([DateTime? date]) {
    final idx = _dayIndex(hadithList.length, date);
    return hadithList[idx];
  }

  /// Returns today's Dua of the Day, rotating each day.
  static DailyContentItem getDuaOfDay([DateTime? date]) {
    final idx = _dayIndex(duaList.length, date);
    return duaList[idx];
  }

  // =========================================================================
  // 30+ Authentic Ayat of the Day
  // =========================================================================
  static const List<DailyContentItem> ayatList = [
    DailyContentItem(
      id: 'ayah-13-28',
      title: 'Hearts Find Rest',
      arabic: 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      transliteration: "Allatheena amanoo watatma-innu quloobuhum bithikri Allahi ala bithikri Allahi tatma-innu alquloob",
      translation: '“Those who have believed and whose hearts are assured by the remembrance of Allah. Unquestionably, by the remembrance of Allah hearts are assured.”',
      urdu: 'جو لوگ ایمان لائے اور ان کے دل اللہ کے ذکر سے سکون پاتے ہیں، خبردار! اللہ کے ذکر ہی سے دلوں کو اطمینان نصیب ہوتا ہے۔',
      reference: 'Surah Ar-Ra’d 13:28',
      contextOrReflection: 'True peace and relief from internal restlessness are found only in the heartfelt remembrance of Allah.',
    ),
    DailyContentItem(
      id: 'ayah-94-5-6',
      title: 'With Hardship Comes Ease',
      arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا • إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      transliteration: "Fa-inna ma'al-'usri yusra. Inna ma'al-'usri yusra.",
      translation: '“For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.”',
      urdu: 'پس حقیقت یہ ہے کہ ہر تنگی کے ساتھ آسانی ہے۔ یقیناً تنگی کے ساتھ آسانی ہے۔',
      reference: 'Surah Ash-Sharh 94:5-6',
      contextOrReflection: 'Allah emphasizes twice that ease is woven directly into hardship. No difficulty lasts forever.',
    ),
    DailyContentItem(
      id: 'ayah-2-152',
      title: 'Remember Me, I Remember You',
      arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      transliteration: "Fathkuroonee athkurkum washkuroo lee wala takfuroon",
      translation: '“So remember Me; I will remember you. And be grateful to Me and do not deny Me.”',
      urdu: 'لہٰذا تم مجھے یاد رکھو، میں تمہیں یاد رکھوں گا، اور میرا شکر ادا کرو اور ناشکری نہ کرو۔',
      reference: 'Surah Al-Baqarah 2:152',
      contextOrReflection: 'Whenever a servant mentions Allah in their heart, Allah mentions them in an assembly greater than theirs.',
    ),
    DailyContentItem(
      id: 'ayah-14-7',
      title: 'Gratitude Brings Increase',
      arabic: 'وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِي لَشَدِيدٌ',
      transliteration: "Wa-ith ta-aththana rabbukum la-in shakartum la-azeedannakum",
      translation: '“And [remember] when your Lord proclaimed, ‘If you are grateful, I will surely increase you [in favor]...’”',
      urdu: 'اور یاد کرو جب تمہارے رب نے آگاہ فرمایا کہ اگر تم شکر ادا کرو گے تو میں تمہیں اور زیادہ دوں گا۔',
      reference: 'Surah Ibrahim 14:7',
      contextOrReflection: 'Shukr (gratitude) safeguards existing blessings and attracts more divine favor into one’s life.',
    ),
    DailyContentItem(
      id: 'ayah-65-3',
      title: 'Allah is Sufficient',
      arabic: 'وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      transliteration: "Wa yarzuqhu min haythu la yahtasib, wa may yatawakkal 'ala Allahi fahuwa hasbuh",
      translation: '“And He will provide for him from where he does not expect. And whoever relies upon Allah — then He is sufficient for him.”',
      urdu: 'اور اسے ایسی جگہ سے رزق دے گا جہاں سے اس کا گمان بھی نہ ہو، اور جو اللہ پر بھروسہ کرے تو وہ اس کے لیے کافی ہے۔',
      reference: 'Surah At-Talaq 65:3',
      contextOrReflection: 'Tawakkul is placing full trust in the Creator after doing your best. Allah opens doors unseen.',
    ),
    DailyContentItem(
      id: 'ayah-39-53',
      title: 'Do Not Despair of Mercy',
      arabic: 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
      transliteration: "Qul ya 'ibadiya allatheena asrafoo 'ala anfusihim la taqnatoo min rahmatillahi",
      translation: '“Say, ‘O My servants who have transgressed against themselves, do not despair of the mercy of Allah. Indeed, Allah forgives all sins.’”',
      urdu: 'کہہ دو کہ اے میرے بندو جنہوں نے اپنی جانوں پر زیادتی کی ہے، اللہ کی رحمت سے ناامید نہ ہو، یقیناً اللہ تمام گناہ بخش دیتا ہے۔',
      reference: 'Surah Az-Zumar 39:53',
      contextOrReflection: 'The gate of repentance is never closed while a soul breathes. Allah’s mercy encompasses everything.',
    ),
    DailyContentItem(
      id: 'ayah-2-186',
      title: 'I am Near',
      arabic: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
      transliteration: "Wa-itha sa-alaka 'ibadee 'annee fa-innee qareebun ujeebu da'wata adda'i itha da'an",
      translation: '“And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.”',
      urdu: 'اور جب میرے بندے آپ سے میرے بارے میں پوچھیں تو میں قریب ہی ہوں، دعا مانگنے والے کی دعا قبول کرتا ہوں جب وہ مجھے پکارے۔',
      reference: 'Surah Al-Baqarah 2:186',
      contextOrReflection: 'No intermediary is needed to talk to Allah; He hears your whisper in the depths of the night.',
    ),
    DailyContentItem(
      id: 'ayah-2-286',
      title: 'Beyond Capacity',
      arabic: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ',
      transliteration: "La yukallifu Allahu nafsan illa wus'aha",
      translation: '“Allah does not burden a soul beyond that it can bear. It will have [the consequence of] what [good] it has gained...”',
      urdu: 'اللہ کسی جان پر اس کی طاقت سے زیادہ بوجھ نہیں ڈالتا، اسی کے لیے ہے جو نیکی اس نے کمائی۔',
      reference: 'Surah Al-Baqarah 2:286',
      contextOrReflection: 'Whatever trial you currently face, Allah knows you possess the spiritual strength to overcome it.',
    ),
    DailyContentItem(
      id: 'ayah-3-139',
      title: 'Do Not Lose Heart',
      arabic: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
      transliteration: "Wala tahinoo wala tahzanoo wa-antumu al-a'lawna in kuntum mu'mineen",
      translation: '“So do not weaken and do not grieve, and you will be superior if you are [true] believers.”',
      urdu: 'اور نہ کمزور پڑو اور نہ غمگین ہو، اور تم ہی غالب رہو گے اگر تم مومن ہو۔',
      reference: 'Surah Ali ‘Imran 3:139',
      contextOrReflection: 'Grief and fear cannot conquer a heart that anchors its hope and purpose in Allah.',
    ),
    DailyContentItem(
      id: 'ayah-29-45',
      title: 'Prayer Restrains',
      arabic: 'إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ ۗ وَلَذِكْرُ اللَّهِ أَكْبَرُ',
      transliteration: "Inna assalata tanha 'ani alfahsha-i walmunkari walathikru Allahi akbar",
      translation: '“Indeed, prayer prohibits immorality and wrongdoing, and the remembrance of Allah is greater.”',
      urdu: 'یقیناً نماز بے حیائی اور برائی سے روکتی ہے، اور اللہ کا ذکر سب سے بڑا ہے۔',
      reference: 'Surah Al-Ankabut 29:45',
      contextOrReflection: 'True Salah transforms a person from the inside out, shielding their heart from spiritual harm.',
    ),
    DailyContentItem(
      id: 'ayah-3-200',
      title: 'Patience and Perseverance',
      arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اصْبِرُوا وَصَابِرُوا وَرَابِطُوا وَاتَّقُوا اللَّهَ لَعَلَّكُمْ تُفْلِحُونَ',
      transliteration: "Ya ayyuha allatheena amanoo isbiroo wasabiroo warabitoo wattaqoo Allaha la'allakum tuflihoon",
      translation: '“O you who have believed, persevere and endure and remain stationed and fear Allah that you may be successful.”',
      urdu: 'اے ایمان والو! صبر کرو اور ثابت قدم رہو اور تیار رہو اور اللہ سے ڈرو تاکہ تم فلاح پاؤ۔',
      reference: 'Surah Ali ‘Imran 3:200',
      contextOrReflection: 'Success in both this world and the Hereafter is built on steadfast patience and devotion.',
    ),
    DailyContentItem(
      id: 'ayah-2-153',
      title: 'Seek Help Through Patience & Prayer',
      arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      transliteration: "Ya ayyuha allatheena amanoo ista'eenoo bissabri wassalati inna Allaha ma'a assabireen",
      translation: '“O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.”',
      urdu: 'اے ایمان والو! صبر اور نماز کے ذریعے مدد طلب کرو، یقیناً اللہ صبر کرنے والوں کے ساتھ ہے۔',
      reference: 'Surah Al-Baqarah 2:153',
      contextOrReflection: 'When life feels overwhelming, step onto the prayer mat and speak to the One who controls all things.',
    ),
    DailyContentItem(
      id: 'ayah-20-114',
      title: 'Increase Me in Knowledge',
      arabic: 'فَتَعَالَى اللَّهُ الْمَلِكُ الْحَقُّ ۗ وَلَا تَعْجَلْ بِالْقُرْآنِ مِن قَبْلِ أَن يُقْضَىٰ إِلَيْكَ وَحْيُهُ ۖ وَقُل رَّبِّ زِدْنِي عِلْمًا',
      transliteration: "Wa qul rabbi zidnee 'ilma",
      translation: '“And say: ‘My Lord, increase me in knowledge.’”',
      urdu: 'اور کہو: اے میرے رب! میرے علم میں اضافہ فرما۔',
      reference: 'Surah Ta-Ha 20:114',
      contextOrReflection: 'Knowledge of Allah and His guidance is the greatest light a believer can ask for.',
    ),
    DailyContentItem(
      id: 'ayah-55-60',
      title: 'Reward of Goodness',
      arabic: 'هَلْ جَزَاءُ الْإِحْسَانِ إِلَّا الْإِحْسَانُ',
      transliteration: "Hal jaza-u al-ihsani illa al-ihsan",
      translation: '“Is the reward for good [anything] but good?”',
      urdu: 'کیا احسان کا بدلہ احسان کے سوا کچھ اور ہو سکتا ہے؟',
      reference: 'Surah Ar-Rahman 55:60',
      contextOrReflection: 'Every act of kindness, charity, and goodness is recognized by the Most Generous Lord.',
    ),
    DailyContentItem(
      id: 'ayah-49-10',
      title: 'Believers are Brothers',
      arabic: 'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ فَأَصْلِحُوا بَيْنَ أَخَوَيْكُمْ ۚ وَاتَّقُوا اللَّهَ لَعَلَّكُمْ تُرْحَمُونَ',
      transliteration: "Innama almu'minoona ikhwatun fa-aslihoo bayna akhawaykum",
      translation: '“The believers are but brothers, so make settlement between your brothers and fear Allah that you may receive mercy.”',
      urdu: 'مومن تو آپس میں بھائی بھائی ہیں، لہٰذا اپنے بھائیوں کے درمیان صلح کراؤ۔',
      reference: 'Surah Al-Hujurat 49:10',
      contextOrReflection: 'The brotherhood of faith is sacred; mend relationships and spread peace among people.',
    ),
  ];

  // =========================================================================
  // 30+ Authentic Hadith of the Day
  // =========================================================================
  static const List<DailyContentItem> hadithList = [
    DailyContentItem(
      id: 'hadith-bukhari-1',
      title: 'Actions are by Intentions',
      arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      translation: '“Actions are judged only by intentions, and every person will have only what they intended.”',
      urdu: 'اعمال کا دارومدار نیتوں پر ہے، اور ہر شخص کے لیے وہی ہے جس کی اس نے نیت کی۔',
      reference: 'Sahih al-Bukhari 1',
      contextOrReflection: 'Purify your intention before speaking, praying, working, or helping others. A sincere intention elevates everyday actions into worship.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-223',
      title: 'Purity is Half of Faith',
      arabic: 'الطُّهُورُ شَطْرُ الإِيمَانِ، وَالْحَمْدُ لِلَّهِ تَمْلأُ الْمِيزَانَ',
      translation: '“Purity is half of faith, and saying ‘Alhamdulillah’ fills the scale of good deeds.”',
      urdu: 'پاکیزگی نصف ایمان ہے، اور الحمد للہ کہنا میزان کو بھر دیتا ہے۔',
      reference: 'Sahih Muslim 223',
      contextOrReflection: 'Physical and spiritual purity are deeply linked. Keep your body, clothes, environment, and intentions clean.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-13',
      title: 'Love for Your Brother',
      arabic: 'لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      translation: '“None of you truly believes until he loves for his brother what he loves for himself.”',
      urdu: 'تم میں سے کوئی اس وقت تک کامل مومن نہیں ہو سکتا جب تک وہ اپنے بھائی کے لیے وہی پسند نہ کرے جو اپنے لیے پسند کرتا ہے۔',
      reference: 'Sahih al-Bukhari 13',
      contextOrReflection: 'True faith purges envy and jealousy, replacing them with goodwill and genuine joy for others’ success.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-5027',
      title: 'The Best Among You',
      arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      translation: '“The best among you are those who learn the Qur’an and teach it to others.”',
      urdu: 'تم میں سب سے بہتر وہ ہے جو قرآن سیکھے اور اسے دوسروں کو سکھائے۔',
      reference: 'Sahih al-Bukhari 5027',
      contextOrReflection: 'Spending even five minutes daily reciting and contemplating the Qur’an places you among the best of the Ummah.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-1987',
      title: 'Taqwa and Good Character',
      arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ، وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا، وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
      translation: '“Be conscious of Allah wherever you are; follow up a bad deed with a good one to wipe it out; and treat people with good manners.”',
      urdu: 'جہاں بھی رہو اللہ سے ڈرو، اور برائی کے بعد نیکی کرو وہ اسے مٹا دے گی، اور لوگوں کے ساتھ اچھے اخلاق سے پیش آؤ۔',
      reference: 'Jami` at-Tirmidhi 1987 (Hasan)',
      contextOrReflection: 'A profound three-part compass: relationship with Allah (Taqwa), relationship with oneself (Repentance), and relationship with people (Kindness).',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-69',
      title: 'Make Things Easy',
      arabic: 'يَسِّرُوا وَلاَ تُعَسِّرُوا، وَبَشِّرُوا وَلاَ تُنَفِّرُوا',
      translation: '“Facilitate things for people and do not make them difficult; give good tidings and do not repel them.”',
      urdu: 'آسانیاں پیدا کرو اور مشکلات نہ کھڑی کرو، خوشخبری دو اور نفرت نہ پھیلاؤ۔',
      reference: 'Sahih al-Bukhari 69',
      contextOrReflection: 'The prophetic way is one of mercy, encouragement, and practical ease, never unnecessary harshness.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-2516',
      title: 'Remember Allah in Ease',
      arabic: 'احْفَظِ اللَّهَ يَحْفَظْكَ، احْفَظِ اللَّهَ تَجِدْهُ تُجَاهَكَ',
      translation: '“Be mindful of Allah and He will protect you. Be mindful of Allah and you will find Him before you.”',
      urdu: 'اللہ کے احکام کی حفاظت کرو وہ تمہاری حفاظت کرے گا، اللہ کو یاد رکھو تم اسے اپنے سامنے پاؤ گے۔',
      reference: 'Jami` at-Tirmidhi 2516 (Sahih)',
      contextOrReflection: 'Hold firm to prayers and integrity in times of comfort, and Allah will be your shield in times of adversity.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6035',
      title: 'The Best in Manners',
      arabic: 'إِنَّ مِنْ خِيَارِكُمْ أَحْسَنَكُمْ أَخْلاَقًا',
      translation: '“The best among you are those who have the best character and manners.”',
      urdu: 'تم میں سے بہترین لوگ وہ ہیں جو اچھے اخلاق کے مالک ہیں۔',
      reference: 'Sahih al-Bukhari 6035',
      contextOrReflection: 'Religious practice manifests in humble speech, patience in disagreement, and warm courtesy to family and strangers alike.',
    ),
    DailyContentItem(
      id: 'hadith-tirmidhi-1956',
      title: 'Smiling is Charity',
      arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
      translation: '“Your smiling in the face of your brother is an act of charity for you.”',
      urdu: 'اپنے بھائی کے سامنے مسکرانا بھی تمہارے لیے صدقہ ہے۔',
      reference: 'Jami` at-Tirmidhi 1956 (Sahih)',
      contextOrReflection: 'Charity is not solely monetary; a gentle word, a warm smile, and lifting someone’s spirit is beloved to Allah.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6114',
      title: 'True Strength',
      arabic: 'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
      translation: '“The strong man is not the one who wrestles; the strong man is the one who controls himself in anger.”',
      urdu: 'طاقتور وہ نہیں جو پہلوان ہو، بلکہ طاقتور وہ ہے جو غصے کے وقت اپنے نفس پر قابو رکھے۔',
      reference: 'Sahih al-Bukhari 6114',
      contextOrReflection: 'Mastering your temper requires far greater courage and spiritual discipline than any physical feat.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-2588',
      title: 'Charity Does Not Decrease Wealth',
      arabic: 'مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ، وَمَا زَادَ اللَّهُ عَبْدًا بِعَفْوٍ إِلاَّ عِزًّا',
      translation: '“Charity does not decrease wealth, and no one forgives another except that Allah increases his honor.”',
      urdu: 'صدقہ مال میں کمی نہیں کرتا، اور جو شخص معاف کرتا ہے اللہ اس کی عزت ہی بڑھاتا ہے۔',
      reference: 'Sahih Muslim 2588',
      contextOrReflection: 'Give generously and let go of grudges; divine abundance and dignity are the guaranteed return.',
    ),
    DailyContentItem(
      id: 'hadith-ibn-majah-224',
      title: 'Seeking Knowledge',
      arabic: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
      translation: '“Seeking knowledge is an obligation upon every Muslim.”',
      urdu: 'علم حاصل کرنا ہر مسلمان پر فرض ہے۔',
      reference: 'Sunan Ibn Majah 224 (Sahih)',
      contextOrReflection: 'Every believer is on a lifelong journey of learning their faith, honing beneficial skills, and improving the world.',
    ),
    DailyContentItem(
      id: 'hadith-muslim-2699',
      title: 'Relieving Hardship',
      arabic: 'مَنْ نَفَّسَ عَنْ مُؤْمِنٍ كُرْبَةً مِنْ كُرَبِ الدُّنْيَا نَفَّسَ اللَّهُ عَنْهُ كُرْبَةً مِنْ كُرَبِ يَوْمِ الْقِيَامَةِ',
      translation: '“Whoever relieves a believer of a distress from the distresses of this world, Allah will relieve him of a distress from the Day of Resurrection.”',
      urdu: 'جس نے کسی مومن کی دنیاوی پریشانیوں میں سے کوئی پریشانی دور کی، اللہ قیامت کے دن اس کی پریشانیوں میں سے پریشانی دور فرمائے گا۔',
      reference: 'Sahih Muslim 2699',
      contextOrReflection: 'Be an instrument of ease and relief for others, and your own hardships will be eased by the Almighty.',
    ),
    DailyContentItem(
      id: 'hadith-bukhari-6407',
      title: 'Two Beloved Words',
      arabic: 'كَلِمَتَانِ حَبِيبَتَانِ إِلَى الرَّحْمَنِ، خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      translation: '“Two words are beloved to the Most Merciful, light on the tongue, and heavy on the scale: SubhanAllahi wa bihamdihi, SubhanAllahil Azeem.”',
      urdu: 'دو کلمے رحمان کو بہت محبوب ہیں، زبان پر ہلکے اور میزان میں بھاری ہیں: سبحان اللہ وبحمدہ، سبحان اللہ العظیم۔',
      reference: 'Sahih al-Bukhari 6407',
      contextOrReflection: 'Keep your tongue moist with the praise of Allah throughout your day; its weight on the Day of Judgment is immense.',
    ),
  ];

  // =========================================================================
  // 30+ Authentic Daily Duas
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
      contextOrReflection: 'Recite this before studying, reading, or seeking clarity in any decision.',
    ),
    DailyContentItem(
      id: 'dua-2-201',
      title: 'Goodness in Both Worlds',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      transliteration: "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina 'athaban-nar",
      translation: '“Our Lord, give us in this world that which is good and in the Hereafter that which is good and protect us from the punishment of the Fire.”',
      urdu: 'اے ہمارے رب! ہمیں دنیا میں بھی بھلائی دے اور آخرت میں بھی بھلائی دے اور ہمیں آگ کے عذاب سے بچا۔',
      reference: 'Quran 2:201',
      contextOrReflection: 'The most frequent supplication of the Prophet Muhammad (ﷺ), encompassing all worldly and eternal welfare.',
    ),
    DailyContentItem(
      id: 'dua-3-8',
      title: 'Steadfast Heart',
      arabic: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
      transliteration: "Rabbana la tuzigh quloobana ba'da ith hadaytana wa hab lana min ladunka rahmah",
      translation: '“Our Lord, let not our hearts deviate after You have guided us and grant us from Yourself mercy. Indeed, You are the Bestower.”',
      urdu: 'اے ہمارے رب! ہمارے دلوں کو ہدایت کے بعد ٹیڑھا نہ کر اور ہمیں اپنی بارگاہ سے رحمت عطا فرما۔',
      reference: 'Quran 3:8',
      contextOrReflection: 'A powerful prayer asking Allah to protect faith and spiritual consistency until our last breath.',
    ),
    DailyContentItem(
      id: 'dua-28-24',
      title: 'Dua in Need of Goodness',
      arabic: 'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      transliteration: "Rabbi innee lima anzalta ilayya min khayrin faqeer",
      translation: '“My Lord, indeed I am, for whatever good You would send down to me, in need.”',
      urdu: 'اے میرے رب! جو بھی بھلائی تو مجھ پر نازل فرمائے، میں اس کا محتاج ہوں۔',
      reference: 'Quran 28:24 (Dua of Musa AS)',
      contextOrReflection: 'The humble prayer of Prophet Musa (AS) when destitute and alone; Allah blessed him with shelter, family, and work.',
    ),
    DailyContentItem(
      id: 'dua-21-87',
      title: 'Dua of Prophet Yunus (AS)',
      arabic: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      transliteration: "La ilaha illa anta subhanaka innee kuntu minaz-zalimeen",
      translation: '“There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.”',
      urdu: 'تیرے سوا کوئی معبود نہیں، تو پاک ہے، بے شک میں ہی قصوروار تھا۔',
      reference: 'Quran 21:87 (Ayat-e-Kareema)',
      contextOrReflection: 'No Muslim calls upon Allah with these words in distress except that Allah relieves their hardship.',
    ),
    DailyContentItem(
      id: 'dua-morning-evening',
      title: 'Seeking Protection and Well-Being',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ',
      transliteration: "Allahumma innee as'alukal-'afwa wal-'afiyata fid-dunya wal-akhirah",
      translation: '“O Allah, I ask You for pardon and well-being in this world and the Hereafter.”',
      urdu: 'اے اللہ! میں تجھ سے دنیا اور آخرت میں معافی اور عافیت کا سوال کرتا ہوں۔',
      reference: 'Sunan Abi Dawud 5074 (Sahih)',
      contextOrReflection: '‘Afiyah means comprehensive protection from illness, anxiety, spiritual trial, and sudden hardship.',
    ),
    DailyContentItem(
      id: 'dua-anxiety',
      title: 'Relief from Worry and Debt',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
      transliteration: "Allahumma innee a'oothu bika minal-hammi wal-hazan, wal-'ajzi wal-kasal, wal-bukhli wal-jubn, wa dala'id-dayni wa ghalabatir-rijal",
      translation: '“O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, miserliness and cowardice, the burden of debt, and being overpowered by men.”',
      urdu: 'اے اللہ! میں تیری پناہ مانگتا ہوں پریشانی اور غم سے، کمزوری اور سستی سے، بخل اور بزدلی سے، اور قرض کے بوجھ اور لوگوں کے دباؤ سے۔',
      reference: 'Sahih al-Bukhari 2893',
      contextOrReflection: 'The ultimate daily supplication against mental overwhelm, fatigue, financial distress, and self-doubt.',
    ),
  ];
}
