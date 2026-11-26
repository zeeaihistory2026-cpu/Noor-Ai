// Structured offline content for Lifestyle, Travel, Beginner, Women's Corner,
// Kids Learning, and My Deen Sunnah Modules (Modules 9 P2, 15, 16, 17, 18).
import 'islamic_academy_data.dart';

class ArabicLetterCard {
  const ArabicLetterCard({
    required this.letter,
    required this.name,
    required this.sound,
    required this.exampleArabic,
    required this.exampleMeaning,
  });

  final String letter;
  final String name;
  final String sound;
  final String exampleArabic;
  final String exampleMeaning;
}

class GlossaryTerm {
  const GlossaryTerm({
    required this.term,
    required this.arabic,
    required this.definition,
  });

  final String term;
  final String arabic;
  final String definition;
}

class RoadmapMilestone {
  const RoadmapMilestone({
    required this.id,
    required this.week,
    required this.title,
    required this.detail,
  });

  final int id;
  final String week;
  final String title;
  final String detail;
}

abstract final class LifestyleGuidesData {
  // Module 15 P2: Travel Mode & Qasr/Jam' Guide
  static const List<GuideStep> travelSteps = [
    GuideStep(
      step: 1,
      title: 'When Qasr (Shortening Prayer) Begins',
      detail:
          'Once you depart your city boundaries intending a journey of ~77–89 km (approx. 48 miles), shorten 4-rak’ah obligatory prayers (Dhuhr, Asr, Isha) to 2 rak’ahs.',
      isObligatory: true,
      reference: 'Quran 4:101 • Sahih al-Bukhari 1086',
    ),
    GuideStep(
      step: 2,
      title: 'Duration & School Differences',
      detail:
          'Hanafi: stay intending under 15 days at destination remains traveler (Musafir). Shafi’i / Maliki / Hanbali: stay under 4 full days (excluding arrival/departure days).',
      reference: 'Classical Fiqh consensus & school thresholds',
    ),
    GuideStep(
      step: 3,
      title: 'Combining Prayers (Jam’)',
      detail:
          'Shafi’i, Maliki & Hanbali schools permit combining Dhuhr with Asr, and Maghrib with Isha while actively traveling (either Jam’ Taqdim at the earlier time or Jam’ Ta’khir at the later time).',
      reference: 'Sahih Muslim 705',
    ),
    GuideStep(
      step: 4,
      title: 'Praying Behind a Resident Imam',
      detail:
          'If a traveler prays behind a local (resident) Imam, follow the Imam and complete all 4 rak’ahs.',
      reference: 'Musnad Ahmad • Sahih Muslim 688',
    ),
  ];

  static const String travelDuaArabic =
      'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ';
  static const String travelDuaTranslit =
      'Subhanalladhi sakhkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila Rabbina lamunqalibun.';
  static const String travelDuaMeaning =
      'Glory be to Him who has subjected this to us, and we could never have had it (by our efforts), and verily to our Lord we shall return.';
  static const String travelDuaRef = 'Quran 43:13–14 • Sahih Muslim 1342';

  // Module 18 P2: New Muslim & Beginner Mode
  static const List<RoadmapMilestone> beginnerRoadmap = [
    RoadmapMilestone(
      id: 1,
      week: 'Week 1 · Days 1–7',
      title: 'Understand the Shahada & Allah’s Mercy',
      detail: 'Reflect on Tawhid (Oneness of Allah) and sincere daily intention.',
    ),
    RoadmapMilestone(
      id: 2,
      week: 'Week 1 · Days 1–7',
      title: 'Learn Wudu (Ablution)',
      detail: 'Practice the simple 4 obligatory washings using the Salah & Wudu Guide.',
    ),
    RoadmapMilestone(
      id: 3,
      week: 'Week 1 · Days 1–7',
      title: 'Memorize Surah Al-Fatihah',
      detail: 'Read Al-Fatihah slowly with audio transliteration (needed in every prayer).',
    ),
    RoadmapMilestone(
      id: 4,
      week: 'Week 2 · Days 8–14',
      title: 'Establish Fajr & Maghrib First',
      detail: 'Build steady anchors before expanding to all 5 daily prayers cleanly.',
    ),
    RoadmapMilestone(
      id: 5,
      week: 'Week 2 · Days 8–14',
      title: 'Learn Ruku, Sujud & Tashahhud',
      detail: 'Use the Step-by-Step Salah Guide while you build muscle memory.',
    ),
    RoadmapMilestone(
      id: 6,
      week: 'Week 3 · Days 15–21',
      title: 'Pray All 5 Daily Prayers Consistently',
      detail: 'Set gentle Adhan reminders and log completed prayers honestly.',
    ),
    RoadmapMilestone(
      id: 7,
      week: 'Week 3 · Days 15–21',
      title: 'Adopt Everyday Sunnah Phrases',
      detail: 'Bismillah before eating, Alhamdulillah after, Salam with fellow Muslims.',
    ),
    RoadmapMilestone(
      id: 8,
      week: 'Week 4 · Days 22–30',
      title: 'Understand Halal Essentials',
      detail: 'Learn basic dietary guidelines and use the Halal Ingredient Checker.',
    ),
    RoadmapMilestone(
      id: 9,
      week: 'Week 4 · Days 22–30',
      title: 'Attend Friday (Jumu’ah) Prayer & Community',
      detail: 'Join congregational Friday prayer and introduce yourself to local scholars.',
    ),
  ];

  static const List<GlossaryTerm> glossary = [
    GlossaryTerm(
      term: 'Wudu',
      arabic: 'الوضوء',
      definition: 'Ritual washing of face, arms, head, and feet performed before Salah.',
    ),
    GlossaryTerm(
      term: 'Raka’ah',
      arabic: 'ركعة',
      definition: 'One full unit of prayer (standing recitation, bowing Ruku, and two prostrations Sujud).',
    ),
    GlossaryTerm(
      term: 'Fard',
      arabic: 'فرض',
      definition: 'Obligatory duty established by clear Quranic/Prophetic command (e.g., 5 daily prayers).',
    ),
    GlossaryTerm(
      term: 'Sunnah',
      arabic: 'سنة',
      definition: 'Prophetic teaching and practice of Prophet Muhammad (peace be upon him); rewarded when followed.',
    ),
    GlossaryTerm(
      term: 'Qibla',
      arabic: 'القبلة',
      definition: 'Direction facing the Kaaba in Makkah observed during prayer.',
    ),
    GlossaryTerm(
      term: 'Niyyah',
      arabic: 'النية',
      definition: 'Sincere conscious intention in the heart for an act of worship.',
    ),
    GlossaryTerm(
      term: 'Halal & Haram',
      arabic: 'حلال وحرام',
      definition: 'Lawful/permissible versus prohibited according to Islamic guidance.',
    ),
    GlossaryTerm(
      term: 'Tawakkul',
      arabic: 'التوكل',
      definition: 'Trusting and relying completely on Allah while taking honest practical means.',
    ),
    GlossaryTerm(
      term: 'Sadaqah',
      arabic: 'صدقة',
      definition: 'Voluntary charity — from money to a kind word or helping neighbor.',
    ),
    GlossaryTerm(
      term: 'Jumu’ah',
      arabic: 'الجمعة',
      definition: 'Congregational Friday noon prayer and sermon replacing Dhuhr for attendees.',
    ),
  ];

  // Module 16 P2: Muslim Women's Corner
  static const List<({String title, String ruling, String source})> womensFiqh = [
    (
      title: 'Salah During Menstruation & Post-Natal (Nifas)',
      ruling:
          'Daily prayers are excused completely during menstrual/post-natal days and do NOT need to be made up later — enabling Private Pause mode protects your streak guilt-free.',
      source: 'Sahih al-Bukhari 304 • Sahih Muslim 335',
    ),
    (
      title: 'Fasting (Sawm) & Qada',
      ruling:
          'Obligatory Ramadan fasts are paused during menstrual/post-natal days and made up on other days of the year when able. Missed days sync with your Qada Fasts counter.',
      source: 'Quran 2:184–185 • Sahih Muslim 335',
    ),
    (
      title: 'Dhikr, Dua & Listening to Qur’an',
      ruling:
          'All forms of remembrance (Tasbih, Istighfar, Duas, Salawat) and listening to Qur’an recitation remain open and deeply rewarded throughout every day.',
      source: 'Scholarly consensus',
    ),
    (
      title: 'Touching the Physical Mushaf vs. Digital Screen',
      ruling:
          'Hold physical Arabic Mushafs with Wudu; scholars differ regarding menstruating women reciting from memory or screens — many permit reading from phone/translation without touching Mushaf pages directly (check your Madhhab setting).',
      source: 'Comparative Fiqh guidance',
    ),
  ];

  static const List<({String title, String arabic, String translation, String ref})>
      parentingDuas = [
    (
      title: 'For Spouse & Righteous Offspring',
      arabic: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      translation:
          'Our Lord, grant us from among our spouses and offspring comfort to our eyes and make us a leader for the righteous.',
      ref: 'Quran 25:74',
    ),
    (
      title: 'For Steadfastness in Prayer for Family',
      arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      translation:
          'My Lord, make me an establisher of prayer, and from my descendants. Our Lord, and accept my supplication.',
      ref: 'Quran 14:40',
    ),
    (
      title: 'Prophetic Dua Protecting Children',
      arabic: 'أُعِيذُكُمَا بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
      translation:
          'I seek protection for you in the perfect words of Allah from every devil, harmful creature, and envious eye.',
      ref: 'Sahih al-Bukhari 3371',
    ),
  ];

  // Module 17 P3: Kids Islamic Learning
  static const List<ArabicLetterCard> arabicAlphabet = [
    ArabicLetterCard(letter: 'أ', name: 'Alif', sound: 'a', exampleArabic: 'اللَّه', exampleMeaning: 'Allah'),
    ArabicLetterCard(letter: 'ب', name: 'Ba', sound: 'b', exampleArabic: 'بَيْت', exampleMeaning: 'House'),
    ArabicLetterCard(letter: 'ت', name: 'Ta', sound: 't', exampleArabic: 'تَمْر', exampleMeaning: 'Dates'),
    ArabicLetterCard(letter: 'ث', name: 'Tha', sound: 'th', exampleArabic: 'ثَوَاب', exampleMeaning: 'Reward'),
    ArabicLetterCard(letter: 'ج', name: 'Jim', sound: 'j', exampleArabic: 'جَنَّة', exampleMeaning: 'Paradise'),
    ArabicLetterCard(letter: 'ح', name: 'Ha', sound: 'h (deep)', exampleArabic: 'حَمْد', exampleMeaning: 'Praise'),
    ArabicLetterCard(letter: 'خ', name: 'Kha', sound: 'kh', exampleArabic: 'خَيْر', exampleMeaning: 'Goodness'),
    ArabicLetterCard(letter: 'د', name: 'Dal', sound: 'd', exampleArabic: 'دُعَاء', exampleMeaning: 'Supplication'),
    ArabicLetterCard(letter: 'ذ', name: 'Dhal', sound: 'dh', exampleArabic: 'ذِكْر', exampleMeaning: 'Remembrance'),
    ArabicLetterCard(letter: 'ر', name: 'Ra', sound: 'r', exampleArabic: 'رَحْمَة', exampleMeaning: 'Mercy'),
    ArabicLetterCard(letter: 'ز', name: 'Zay', sound: 'z', exampleArabic: 'زَكَاة', exampleMeaning: 'Charity'),
    ArabicLetterCard(letter: 'س', name: 'Sin', sound: 's', exampleArabic: 'سَلَام', exampleMeaning: 'Peace'),
    ArabicLetterCard(letter: 'ش', name: 'Shin', sound: 'sh', exampleArabic: 'شُكْر', exampleMeaning: 'Gratitude'),
    ArabicLetterCard(letter: 'ص', name: 'Sad', sound: 's (heavy)', exampleArabic: 'صَلَاة', exampleMeaning: 'Prayer'),
    ArabicLetterCard(letter: 'ض', name: 'Dad', sound: 'd (heavy)', exampleArabic: 'ضُحَى', exampleMeaning: 'Morning light'),
    ArabicLetterCard(letter: 'ط', name: 'Taa', sound: 't (heavy)', exampleArabic: 'طَهُور', exampleMeaning: 'Purity'),
    ArabicLetterCard(letter: 'ظ', name: 'Zaa', sound: 'z (heavy)', exampleArabic: 'ظُهْر', exampleMeaning: 'Noon prayer'),
    ArabicLetterCard(letter: 'ع', name: 'Ayn', sound: '‘a', exampleArabic: 'عِلْم', exampleMeaning: 'Knowledge'),
    ArabicLetterCard(letter: 'غ', name: 'Ghayn', sound: 'gh', exampleArabic: 'غَفُور', exampleMeaning: 'Forgiving'),
    ArabicLetterCard(letter: 'ف', name: 'Fa', sound: 'f', exampleArabic: 'فَجْر', exampleMeaning: 'Dawn'),
    ArabicLetterCard(letter: 'ق', name: 'Qaf', sound: 'q', exampleArabic: 'قُرْآن', exampleMeaning: 'Quran'),
    ArabicLetterCard(letter: 'ك', name: 'Kaf', sound: 'k', exampleArabic: 'كِتَاب', exampleMeaning: 'Book'),
    ArabicLetterCard(letter: 'ل', name: 'Lam', sound: 'l', exampleArabic: 'لُطْف', exampleMeaning: 'Gentleness'),
    ArabicLetterCard(letter: 'م', name: 'Mim', sound: 'm', exampleArabic: 'مَسْجِد', exampleMeaning: 'Mosque'),
    ArabicLetterCard(letter: 'ن', name: 'Nun', sound: 'n', exampleArabic: 'نُور', exampleMeaning: 'Light'),
    ArabicLetterCard(letter: 'ه', name: 'Ha', sound: 'h', exampleArabic: 'هِدَايَة', exampleMeaning: 'Guidance'),
    ArabicLetterCard(letter: 'و', name: 'Waw', sound: 'w', exampleArabic: 'وُضُوء', exampleMeaning: 'Ablution'),
    ArabicLetterCard(letter: 'ي', name: 'Ya', sound: 'y', exampleArabic: 'يَقِين', exampleMeaning: 'Certainty'),
  ];

  static const List<({int surah, String name, String ayahs, String focus})>
      kidsSurahs = [
    (surah: 1, name: 'Surah Al-Fatihah', ayahs: '7 Ayahs', focus: 'Recited in every prayer'),
    (surah: 108, name: 'Surah Al-Kawthar', ayahs: '3 Ayahs', focus: 'Shortest Surah in the Quran'),
    (surah: 103, name: 'Surah Al-Asr', ayahs: '3 Ayahs', focus: 'Value of time, faith & patience'),
    (surah: 112, name: 'Surah Al-Ikhlas', ayahs: '4 Ayahs', focus: 'Oneness of Allah (Tawhid)'),
    (surah: 113, name: 'Surah Al-Falaq', ayahs: '5 Ayahs', focus: 'Morning & bedtime protection'),
    (surah: 114, name: 'Surah An-Nas', ayahs: '6 Ayahs', focus: 'Seeking refuge with Allah'),
  ];

  static const List<({String title, String phrase, String detail})> kidsManners = [
    (
      title: 'Greeting With Peace',
      phrase: 'As-Salamu Alaikum',
      detail: 'Smile and greet parents, teachers, and friends warmly.',
    ),
    (
      title: 'Before Eating & Drinking',
      phrase: 'Bismillah (Right hand)',
      detail: 'Thank Allah and say Alhamdulillah when finished.',
    ),
    (
      title: 'Being Kind to Parents & Animals',
      phrase: 'Speak softly & help',
      detail: 'Prophet Muhammad (peace be upon him) was always gentle and truthful.',
    ),
  ];

  static const List<QuizQuestion> kidsQuizzes = [
    QuizQuestion(
      topic: 'Daily Dua',
      prompt: 'What do Muslims say before starting to eat or drink?',
      options: ['Alhamdulillah', 'Bismillah', 'Allahu Akbar', 'SubhanAllah'],
      correctIndex: 1,
      explanation: 'Saying Bismillah ("In the name of Allah") brings blessing to our meal.',
    ),
    QuizQuestion(
      topic: 'Short Surahs',
      prompt: 'Which Surah is recited in every unit (Raka’ah) of prayer?',
      options: ['Surah Al-Fatihah', 'Surah Al-Kawthar', 'Surah Al-Fil', 'Surah An-Nasr'],
      correctIndex: 0,
      explanation: 'Surah Al-Fatihah is the Opening chapter recited in every prayer.',
    ),
    QuizQuestion(
      topic: 'Good Manners',
      prompt: 'How should we greet Muslims when we meet them?',
      options: ['SubhanAllah', 'As-Salamu Alaikum', 'Astaghfirullah', 'InshaAllah'],
      correctIndex: 1,
      explanation: 'As-Salamu Alaikum means "Peace be upon you".',
    ),
    QuizQuestion(
      topic: 'Arabic Alphabet',
      prompt: 'Which letter is the very first letter of the Arabic alphabet?',
      options: ['Ba', 'Jim', 'Alif', 'Ya'],
      correctIndex: 2,
      explanation: 'Alif (أ / ا) is the first letter of the Arabic alphabet.',
    ),
  ];

  // Module 9 P2: My Deen Daily Sunnah Habits
  static const List<({String id, String title, String subtitle})> sunnahHabits = [
    (id: 'duha', title: 'Pray Duha (2+ Rak’ah)', subtitle: 'Mid-morning voluntary prayer'),
    (id: 'kursi', title: 'Ayat al-Kursi After Salah', subtitle: 'After obligatory prayers'),
    (id: 'adhkar', title: 'Morning & Evening Adhkar', subtitle: 'Daily remembrance protection'),
    (id: 'mulk', title: 'Read Surah Al-Mulk Before Sleep', subtitle: 'Protection of the grave'),
    (id: 'salawat', title: 'Send Salawat on the Prophet', subtitle: 'Especially on Fridays (peace be upon him)'),
    (id: 'kindness', title: 'A Smile or Charity Today', subtitle: 'Every act of kindness is Sadaqah'),
  ];
}

