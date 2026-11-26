// Authentic structured data for P1 modules:
// - Module 08: Islamic Academy (Five Pillars of Islam, Six Pillars of Iman,
//   99 Names of Allah, and interactive self-check quiz)
// - Module 02: Wudu, Ghusl & Step-by-Step Salah Guide
// - Module 13: Hajj & Umrah Guide + Ihram rules & Pilgrimage Duas

class PillarItem {
  const PillarItem({
    required this.number,
    required this.title,
    required this.arabic,
    required this.summary,
    required this.reference,
  });

  final int number;
  final String title;
  final String arabic;
  final String summary;
  final String reference;
}

class AsmaName {
  const AsmaName(this.number, this.arabic, this.transliteration, this.meaning);

  final int number;
  final String arabic;
  final String transliteration;
  final String meaning;
}

class GuideStep {
  const GuideStep({
    required this.step,
    required this.title,
    required this.detail,
    this.arabic,
    this.transliteration,
    this.translation,
    this.reference,
    this.isObligatory = false,
  });

  final int step;
  final String title;
  final String detail;
  final String? arabic;
  final String? transliteration;
  final String? translation;
  final String? reference;
  final bool isObligatory;
}

class QuizQuestion {
  const QuizQuestion({
    required this.topic,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String topic;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class SalahRakaatInfo {
  const SalahRakaatInfo({
    required this.prayer,
    required this.sunnahBefore,
    required this.fard,
    required this.sunnahAfter,
    required this.note,
  });

  final String prayer;
  final int sunnahBefore;
  final int fard;
  final int sunnahAfter;
  final String note;
}

abstract final class IslamicAcademyData {
  static const List<PillarItem> fivePillars = [
    PillarItem(
      number: 1,
      title: 'Shahadah (Declaration of Faith)',
      arabic: 'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ',
      summary:
          'Testifying with sincerity that none has the right to be worshipped except Allah, and that Muhammad (peace be upon him) is His Messenger.',
      reference: 'Sahih al-Bukhari 8 • Sahih Muslim 16',
    ),
    PillarItem(
      number: 2,
      title: 'Salah (Five Daily Prayers)',
      arabic: 'الصَّلَاةُ',
      summary:
          'Establishing the five obligatory daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) at their prescribed times with purification and devotion.',
      reference: 'Quran 2:43 • Sahih al-Bukhari 8',
    ),
    PillarItem(
      number: 3,
      title: 'Zakat (Obligatory Charity)',
      arabic: 'الزَّكَاةُ',
      summary:
          'Purifying wealth by giving an annual share (generally 2.5%) of qualifying savings and assets held above Nisab for one lunar year.',
      reference: 'Quran 9:60 • Sahih al-Bukhari 1395',
    ),
    PillarItem(
      number: 4,
      title: 'Sawm (Fasting in Ramadan)',
      arabic: 'صَوْمُ رَمَضَانَ',
      summary:
          'Abstaining from food, drink, and marital relations from dawn (Fajr) until sunset (Maghrib) during the blessed month of Ramadan.',
      reference: 'Quran 2:183 • Sahih al-Bukhari 1891',
    ),
    PillarItem(
      number: 5,
      title: 'Hajj (Pilgrimage to Makkah)',
      arabic: 'حَجُّ الْبَيْتِ',
      summary:
          'Performing the pilgrimage to the Sacred House (Kaaba) in Makkah once in a lifetime for those who are physically and financially able.',
      reference: 'Quran 3:97 • Sahih Muslim 1337',
    ),
  ];

  static const List<PillarItem> sixPillarsOfIman = [
    PillarItem(
      number: 1,
      title: 'Belief in Allah',
      arabic: 'الإِيمَانُ بِاللَّهِ',
      summary:
          'Affirming Allah’s Lordship, sole right to worship, and His Most Beautiful Names and Attributes without partner or likeness.',
      reference: 'Quran 112:1-4 • Sahih Muslim 8',
    ),
    PillarItem(
      number: 2,
      title: 'Belief in the Angels',
      arabic: 'الإِيمَانُ بِالْمَلَائِكَةِ',
      summary:
          'Believing in the noble angels created from light who carry out Allah’s commands, including Jibreel, Mikael, and Israfil.',
      reference: 'Quran 2:285 • Sahih Muslim 8',
    ),
    PillarItem(
      number: 3,
      title: 'Belief in the Revealed Books',
      arabic: 'الإِيمَانُ بِالْكُتُبِ',
      summary:
          'Believing in Allah’s original revelations to His messengers—Torah, Gospel, Psalms—and the Noble Quran as the final preserved scripture.',
      reference: 'Quran 4:136 • Sahih Muslim 8',
    ),
    PillarItem(
      number: 4,
      title: 'Belief in the Messengers',
      arabic: 'الإِيمَانُ بِالرُّسُلِ',
      summary:
          'Believing in all prophets and messengers sent by Allah, from Adam through Nuh, Ibrahim, Musa, Isa, to the final Messenger Muhammad (peace be upon them all).',
      reference: 'Quran 2:285 • Sahih Muslim 8',
    ),
    PillarItem(
      number: 5,
      title: 'Belief in the Last Day',
      arabic: 'الإِيمَانُ بِالْيَوْمِ الْآخِرِ',
      summary:
          'Believing in resurrection, accountability before Allah, the Balance of deeds, Paradise (Jannah), and Hellfire (Jahannam).',
      reference: 'Quran 2:4 • Sahih Muslim 8',
    ),
    PillarItem(
      number: 6,
      title: 'Belief in Divine Decree (Qadr)',
      arabic: 'الإِيمَانُ بِالْقَدَرِ',
      summary:
          'Believing that Allah knows, has written, wills, and creates all things—both good and adversity—with wisdom while humans choose responsibly.',
      reference: 'Quran 54:49 • Sahih Muslim 8',
    ),
  ];

  static const List<AsmaName> namesOfAllah = [
    AsmaName(1, 'الرَّحْمَٰنُ', 'Ar-Rahman', 'The Most Gracious'),
    AsmaName(2, 'الرَّحِيمُ', 'Ar-Rahim', 'The Most Merciful'),
    AsmaName(3, 'الْمَلِكُ', 'Al-Malik', 'The King and Owner of Dominion'),
    AsmaName(4, 'الْقُدُّوسُ', 'Al-Quddus', 'The Absolutely Pure'),
    AsmaName(5, 'السَّلَامُ', 'As-Salam', 'The Source of Peace and Safety'),
    AsmaName(6, 'الْمُؤْمِنُ', 'Al-Mu’min', 'The Giver of Faith and Security'),
    AsmaName(7, 'الْمُهَيْمِنُ', 'Al-Muhaymin', 'The Guardian, The Overseer'),
    AsmaName(8, 'الْعَزِيزُ', 'Al-Aziz', 'The Almighty'),
    AsmaName(9, 'الْجَبَّارُ', 'Al-Jabbar', 'The Compeller, The Restorer'),
    AsmaName(10, 'الْمُتَكَبِّرُ', 'Al-Mutakabbir', 'The Supreme, The Majestic'),
    AsmaName(11, 'الْخَالِقُ', 'Al-Khaliq', 'The Creator'),
    AsmaName(12, 'الْبَارِئُ', 'Al-Bari’', 'The Evolver, Maker from Nothing'),
    AsmaName(13, 'الْمُصَوِّرُ', 'Al-Musawwir', 'The Fashioner of Forms'),
    AsmaName(14, 'الْغَفَّارُ', 'Al-Ghaffar', 'The Repeatedly Forgiving'),
    AsmaName(15, 'الْقَهَّارُ', 'Al-Qahhar', 'The All-Prevailing Subduer'),
    AsmaName(16, 'الْوَهَّابُ', 'Al-Wahhab', 'The Supreme Bestower'),
    AsmaName(17, 'الرَّزَّاقُ', 'Ar-Razzaq', 'The Provider'),
    AsmaName(18, 'الْفَتَّاحُ', 'Al-Fattah', 'The Opener, The Judge'),
    AsmaName(19, 'الْعَلِيمُ', 'Al-Alim', 'The All-Knowing'),
    AsmaName(20, 'الْقَابِضُ', 'Al-Qabid', 'The Withholder'),
    AsmaName(21, 'الْبَاسِطُ', 'Al-Basit', 'The Expander'),
    AsmaName(22, 'الْخَافِضُ', 'Al-Khafid', 'The Reducer, The Humbler'),
    AsmaName(23, 'الرَّافِعُ', 'Ar-Rafi’', 'The Exalter, The Elevator'),
    AsmaName(24, 'الْمُعِزُّ', 'Al-Mu’izz', 'The Honourer'),
    AsmaName(25, 'الْمُذِلُّ', 'Al-Mudhill', 'The Dishonourer'),
    AsmaName(26, 'السَّمِيعُ', 'As-Sami’', 'The All-Hearing'),
    AsmaName(27, 'الْبَصِيرُ', 'Al-Basir', 'The All-Seeing'),
    AsmaName(28, 'الْحَكَمُ', 'Al-Hakam', 'The Impartial Judge'),
    AsmaName(29, 'الْعَدْلُ', 'Al-Adl', 'The Utterly Just'),
    AsmaName(30, 'اللَّطِيفُ', 'Al-Latif', 'The Subtle One, Most Gentle'),
    AsmaName(31, 'الْخَبِيرُ', 'Al-Khabir', 'The All-Aware'),
    AsmaName(32, 'الْحَلِيمُ', 'Al-Halim', 'The Most Forbearing'),
    AsmaName(33, 'الْعَظِيمُ', 'Al-Azim', 'The Magnificent'),
    AsmaName(34, 'الْغَفُورُ', 'Al-Ghafur', 'The Forgiving, All-Concealing'),
    AsmaName(35, 'الشَّكُورُ', 'Ash-Shakur', 'The Most Appreciative'),
    AsmaName(36, 'الْعَلِيُّ', 'Al-Aliyy', 'The Most High'),
    AsmaName(37, 'الْكَبِيرُ', 'Al-Kabir', 'The Greatest'),
    AsmaName(38, 'الْحَفِيظُ', 'Al-Hafiz', 'The Preserver'),
    AsmaName(39, 'الْمُقِيتُ', 'Al-Muqit', 'The Sustainer'),
    AsmaName(40, 'الْحَسِيبُ', 'Al-Hasib', 'The Reckoner'),
    AsmaName(41, 'الْجَلِيلُ', 'Al-Jalil', 'The Majestic'),
    AsmaName(42, 'الْكَرِيمُ', 'Al-Karim', 'The Most Generous'),
    AsmaName(43, 'الرَّقِيبُ', 'Ar-Raqib', 'The Watchful'),
    AsmaName(44, 'الْمُجِيبُ', 'Al-Mujib', 'The Responsive'),
    AsmaName(45, 'الْوَاسِعُ', 'Al-Wasi’', 'The All-Encompassing'),
    AsmaName(46, 'الْحَكِيمُ', 'Al-Hakim', 'The All-Wise'),
    AsmaName(47, 'الْوَدُودُ', 'Al-Wadud', 'The Most Loving'),
    AsmaName(48, 'الْمَجِيدُ', 'Al-Majid', 'The Glorious'),
    AsmaName(49, 'الْبَاعِثُ', 'Al-Ba’ith', 'The Resurrector'),
    AsmaName(50, 'الشَّهِيدُ', 'Ash-Shahid', 'The Witness'),
    AsmaName(51, 'الْحَقُّ', 'Al-Haqq', 'The Absolute Truth'),
    AsmaName(52, 'الْوَكِيلُ', 'Al-Wakil', 'The Trustee, Disposer of Affairs'),
    AsmaName(53, 'الْقَوِيُّ', 'Al-Qawiyy', 'The All-Strong'),
    AsmaName(54, 'الْمَتِينُ', 'Al-Matin', 'The Firm, Steadfast'),
    AsmaName(55, 'الْوَلِيُّ', 'Al-Waliyy', 'The Protecting Associate'),
    AsmaName(56, 'الْحَمِيدُ', 'Al-Hamid', 'The Praiseworthy'),
    AsmaName(57, 'الْمُحْصِي', 'Al-Muhsi', 'The All-Enumerating'),
    AsmaName(58, 'الْمُبْدِئُ', 'Al-Mubdi’', 'The Originator'),
    AsmaName(59, 'الْمُعِيدُ', 'Al-Mu’id', 'The Restorer'),
    AsmaName(60, 'الْمُحْيِي', 'Al-Muhyi', 'The Giver of Life'),
    AsmaName(61, 'الْمُمِيتُ', 'Al-Mumit', 'The Creator of Death'),
    AsmaName(62, 'الْحَيُّ', 'Al-Hayy', 'The Ever-Living'),
    AsmaName(63, 'الْقَيُّومُ', 'Al-Qayyum', 'The Sustainer of All Existence'),
    AsmaName(64, 'الْوَاجِدُ', 'Al-Wajid', 'The Perceiver, Finder'),
    AsmaName(65, 'الْمَاجِدُ', 'Al-Majid', 'The Illustrious, Noble'),
    AsmaName(66, 'الْوَاحِدُ', 'Al-Wahid', 'The One'),
    AsmaName(67, 'الصَّمَدُ', 'As-Samad', 'The Eternal Refuge'),
    AsmaName(68, 'الْقَادِرُ', 'Al-Qadir', 'The Omnipotent'),
    AsmaName(69, 'الْمُقْتَدِرُ', 'Al-Muqtadir', 'The Creator of All Power'),
    AsmaName(70, 'الْمُقَدِّمُ', 'Al-Muqaddim', 'The Expediter'),
    AsmaName(71, 'الْمُؤَخِّرُ', 'Al-Mu’akhkhir', 'The Delayer'),
    AsmaName(72, 'الْأَوَّلُ', 'Al-Awwal', 'The First'),
    AsmaName(73, 'الْآخِرُ', 'Al-Akhir', 'The Last'),
    AsmaName(74, 'الظَّاهِرُ', 'Az-Zahir', 'The Manifest'),
    AsmaName(75, 'الْبَاطِنُ', 'Al-Batin', 'The Hidden One'),
    AsmaName(76, 'الْوَالِي', 'Al-Wali', 'The Governor, Patron'),
    AsmaName(77, 'الْمُتَعَالِي', 'Al-Muta’ali', 'The Self-Exalted'),
    AsmaName(78, 'الْبَرُّ', 'Al-Barr', 'The Source of Goodness'),
    AsmaName(79, 'التَّوَّابُ', 'At-Tawwab', 'The Ever-Pardoning'),
    AsmaName(80, 'الْمُنْتَقِمُ', 'Al-Muntaqim', 'The Avenger'),
    AsmaName(81, 'الْعَفُوُّ', 'Al-Afuww', 'The Pardoner'),
    AsmaName(82, 'الرَّؤُوفُ', 'Ar-Ra’uf', 'The Most Kind'),
    AsmaName(83, 'مَالِكُ الْمُلْكِ', 'Malik-ul-Mulk', 'Master of the Kingdom'),
    AsmaName(84, 'ذُو الْجَلَالِ وَالْإِكْرَامِ', 'Dhul-Jalali wal-Ikram', 'Lord of Glory and Honour'),
    AsmaName(85, 'الْمُقْسِطُ', 'Al-Muqsit', 'The Equitable'),
    AsmaName(86, 'الْجَامِعُ', 'Al-Jami’', 'The Gatherer'),
    AsmaName(87, 'الْغَنِيُّ', 'Al-Ghaniyy', 'The Self-Sufficient'),
    AsmaName(88, 'الْمُغْنِي', 'Al-Mughni', 'The Enricher'),
    AsmaName(89, 'الْمَانِعُ', 'Al-Mani’', 'The Withholder of Harm'),
    AsmaName(90, 'الضَّارُّ', 'Ad-Darr', 'The Distresser (by Wisdom)'),
    AsmaName(91, 'النَّافِعُ', 'An-Nafi’', 'The Propitious, Benefactor'),
    AsmaName(92, 'النُّورُ', 'An-Nur', 'The Light'),
    AsmaName(93, 'الْهَادِي', 'Al-Hadi', 'The Guide'),
    AsmaName(94, 'الْبَدِيعُ', 'Al-Badi’', 'The Incomparable Originator'),
    AsmaName(95, 'الْبَاقِي', 'Al-Baqi', 'The Everlasting'),
    AsmaName(96, 'الْوَارِثُ', 'Al-Warith', 'The Inheritor'),
    AsmaName(97, 'الرَّشِيدُ', 'Ar-Rashid', 'The Guide to the Right Path'),
    AsmaName(98, 'الصَّبُورُ', 'As-Sabur', 'The Patient'),
    AsmaName(99, 'الأَحَدُ', 'Al-Ahad', 'The Unique, Indivisible One'),
  ];

  static const List<GuideStep> wuduSteps = [
    GuideStep(
      step: 1,
      title: 'Intention (Niyyah) & Bismillah',
      detail:
          'Make the intention in your heart to purify yourself for Salah, then begin with Bismillah.',
      arabic: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah',
      translation: 'In the name of Allah.',
      reference: 'Sunan Abu Dawud 101',
    ),
    GuideStep(
      step: 2,
      title: 'Wash Both Hands (3x)',
      detail: 'Wash both hands up to the wrists three times, cleaning between the fingers.',
    ),
    GuideStep(
      step: 3,
      title: 'Rinse Mouth & Nose (3x)',
      detail:
          'Rinse your mouth thoroughly three times, then sniff water gently into the nostrils and blow it out three times using your left hand.',
    ),
    GuideStep(
      step: 4,
      title: 'Wash Entire Face (3x)',
      detail:
          'Wash the whole face from the hairline to the chin and from ear to ear three times.',
      isObligatory: true,
      reference: 'Quran 5:6',
    ),
    GuideStep(
      step: 5,
      title: 'Wash Both Arms to Elbows (3x)',
      detail:
          'Wash the right forearm including the elbow three times, then the left forearm including the elbow three times.',
      isObligatory: true,
      reference: 'Quran 5:6',
    ),
    GuideStep(
      step: 6,
      title: 'Wipe Head & Ears (1x)',
      detail:
          'With wet hands, wipe over the head from front to back and back to front, then wipe inside and behind the ears.',
      isObligatory: true,
      reference: 'Quran 5:6 • Sunan Abu Dawud 121',
    ),
    GuideStep(
      step: 7,
      title: 'Wash Both Feet to Ankles (3x)',
      detail:
          'Wash the right foot including the ankle three times, cleaning between the toes, then repeat with the left foot.',
      isObligatory: true,
      reference: 'Quran 5:6',
    ),
    GuideStep(
      step: 8,
      title: 'Dua After Wudu',
      detail: 'Recite the testimony and supplication after completing Wudu.',
      arabic:
          'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
      transliteration:
          "Ashhadu an la ilaha illallahu wahdahu la sharika lahu wa ashhadu anna Muhammadan 'abduhu wa rasuluh",
      translation:
          'I bear witness that none has the right to be worshipped except Allah alone, without partner, and I bear witness that Muhammad is His slave and Messenger.',
      reference: 'Sahih Muslim 234',
    ),
  ];

  static const List<GuideStep> ghuslSteps = [
    GuideStep(
      step: 1,
      title: 'Intention (Niyyah) & Bismillah',
      detail:
          'Form the sincere intention in the heart to perform major ritual purification (Ghusl) and say Bismillah.',
      arabic: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah',
    ),
    GuideStep(
      step: 2,
      title: 'Wash Hands & Private Area',
      detail:
          'Wash both hands three times, then wash the private parts thoroughly with the left hand to remove any impurity.',
      reference: 'Sahih al-Bukhari 248',
    ),
    GuideStep(
      step: 3,
      title: 'Perform Complete Wudu',
      detail:
          'Perform a complete Wudu just as for Salah (you may wash your feet immediately or at the end).',
      reference: 'Sahih al-Bukhari 248',
    ),
    GuideStep(
      step: 4,
      title: 'Rinse Mouth & Nose Thoroughly',
      detail:
          'Ensure water reaches the entire mouth and nostrils (obligatory in Hanafi fiqh; integral to Wudu in all schools).',
      isObligatory: true,
    ),
    GuideStep(
      step: 5,
      title: 'Pour Water Over Head & Entire Body',
      detail:
          'Pour water three times over the head ensuring it reaches the roots of the hair, then wash the entire body starting with the right side and then the left, leaving no dry spot.',
      isObligatory: true,
      reference: 'Quran 5:6 • Sahih al-Bukhari 248',
    ),
  ];

  static const List<GuideStep> salahSteps = [
    GuideStep(
      step: 1,
      title: 'Face Qibla & Intention (Niyyah)',
      detail:
          'Ensure Wudu, clean clothes/place, and proper dress; face the Qibla and intend the specific prayer in your heart.',
      isObligatory: true,
    ),
    GuideStep(
      step: 2,
      title: 'Takbir al-Ihram & Opening (Qiyam)',
      detail:
          'Raise your hands and say Allahu Akbar to enter prayer, place right hand over left, then recite the opening supplication, Surah Al-Fatihah, and a surah or verses.',
      arabic: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest.',
      isObligatory: true,
      reference: 'Sahih al-Bukhari 757',
    ),
    GuideStep(
      step: 3,
      title: 'Ruku (Bowing)',
      detail:
          'Say Allahu Akbar, bow with a straight back and hands resting on knees, and praise Allah three times.',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      transliteration: "Subhana Rabbiyal-'Azim",
      translation: 'Glory be to my Lord, the Almighty.',
      isObligatory: true,
      reference: 'Sunan Abu Dawud 870',
    ),
    GuideStep(
      step: 4,
      title: 'Standing from Ruku (Qawmah)',
      detail: 'Rise upright to a calm standing posture while reciting:',
      arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ • رَبَّنَا وَلَكَ الْحَمْدُ',
      transliteration: "Sami'Allahu liman hamidah • Rabbana wa lakal-hamd",
      translation: 'Allah hears those who praise Him. Our Lord, to You belongs all praise.',
      isObligatory: true,
      reference: 'Sahih al-Bukhari 789',
    ),
    GuideStep(
      step: 5,
      title: 'First Sujud (Prostration)',
      detail:
          'Go down saying Allahu Akbar with forehead, nose, both palms, knees, and toes touching the ground.',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      transliteration: "Subhana Rabbiyal-A'la",
      translation: 'Glory be to my Lord, the Most High.',
      isObligatory: true,
      reference: 'Sunan Abu Dawud 870',
    ),
    GuideStep(
      step: 6,
      title: 'Sitting Between Prostrations (Jalsah)',
      detail: 'Sit calmly upright between the two prostrations and ask forgiveness:',
      arabic: 'رَبِّ اغْفِرْ لِي رَبِّ اغْفِرْ لِي',
      transliteration: 'Rabbighfir li, Rabbighfir li',
      translation: 'My Lord, forgive me; my Lord, forgive me.',
      isObligatory: true,
      reference: 'Sunan Abu Dawud 874',
    ),
    GuideStep(
      step: 7,
      title: 'Second Sujud & Subsequent Raka’at',
      detail:
          'Perform the second Sujud with the same stillness, then stand for the next Raka’ah or sit for Tashahhud.',
      isObligatory: true,
    ),
    GuideStep(
      step: 8,
      title: 'Tashahhud, Salawat & Taslim',
      detail:
          'In the final sitting, recite At-Tahiyyat, Salawat upon the Prophet (peace be upon him), a brief dua, then end prayer turning right and left with Salam.',
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      transliteration: 'Assalamu alaykum wa rahmatullah',
      translation: 'Peace and mercy of Allah be upon you.',
      isObligatory: true,
      reference: 'Sahih Muslim 402 • 582',
    ),
  ];

  static const List<SalahRakaatInfo> rakaatTable = [
    SalahRakaatInfo(
      prayer: 'Fajr',
      sunnahBefore: 2,
      fard: 2,
      sunnahAfter: 0,
      note: '2 Sunnah Mu’akkadah before Fard',
    ),
    SalahRakaatInfo(
      prayer: 'Dhuhr / Zuhr',
      sunnahBefore: 4,
      fard: 4,
      sunnahAfter: 2,
      note: '4 Sunnah before, 4 Fard, 2 Sunnah after (Jumu’ah: 2 Fard)',
    ),
    SalahRakaatInfo(
      prayer: 'Asr',
      sunnahBefore: 4,
      fard: 4,
      sunnahAfter: 0,
      note: '4 Sunnah Ghayr Mu’akkadah (optional) before 4 Fard',
    ),
    SalahRakaatInfo(
      prayer: 'Maghrib',
      sunnahBefore: 0,
      fard: 3,
      sunnahAfter: 2,
      note: '3 Fard followed by 2 Sunnah Mu’akkadah',
    ),
    SalahRakaatInfo(
      prayer: 'Isha',
      sunnahBefore: 4,
      fard: 4,
      sunnahAfter: 2,
      note: '4 Fard, 2 Sunnah Mu’akkadah, plus Witr (1 or 3 Raka’at)',
    ),
  ];

  static const List<GuideStep> umrahSteps = [
    GuideStep(
      step: 1,
      title: 'Ihram Before Miqat',
      detail:
          'Perform Ghusl, wear Ihram garments (two unstitched white cloths for men; modest regular dress for women), make intention for Umrah, and begin Talbiyah.',
      arabic:
          'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
      transliteration:
          'Labbayk Allahumma labbayk, labbayka la sharika laka labbayk. Innal-hamda wan-ni’mata laka wal-mulk, la sharika lak.',
      translation:
          'Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Verily all praise, grace, and dominion belong to You. You have no partner.',
      reference: 'Sahih al-Bukhari 1549',
      isObligatory: true,
    ),
    GuideStep(
      step: 2,
      title: 'Tawaf Around the Kaaba (7 Circuits)',
      detail:
          'Enter Masjid al-Haram humbly, start at the Black Stone (Hajar al-Aswad) line, keep the Kaaba to your left, and complete 7 counter-clockwise circuits with dhikr and dua.',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      transliteration:
          'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar',
      translation:
          'Our Lord, grant us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      reference: 'Quran 2:201 • Sunan Abu Dawud 1892',
      isObligatory: true,
    ),
    GuideStep(
      step: 3,
      title: 'Two Raka’at Behind Maqam Ibrahim & Zamzam',
      detail:
          'Pray 2 Raka’at behind Maqam Ibrahim (or anywhere in the Haram if crowded) and drink Zamzam water with heartfelt dua.',
      reference: 'Quran 2:125',
    ),
    GuideStep(
      step: 4,
      title: 'Sa’i Between Safa and Marwah (7 Laps)',
      detail:
          'Begin at Mount Safa facing the Kaaba, recite the Quranic verse (2:158), walk to Marwah (1 lap), and return (lap 2), finishing at Marwah on lap 7.',
      arabic: 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ',
      transliteration: 'Innas-Safa wal-Marwata min sha’a’irillah',
      translation: 'Indeed, As-Safa and Al-Marwah are among the symbols of Allah.',
      reference: 'Quran 2:158 • Sahih Muslim 1218',
      isObligatory: true,
    ),
    GuideStep(
      step: 5,
      title: 'Halq or Taqsir (Exit Ihram)',
      detail:
          'Men shave the head (Halq, preferred) or trim hair evenly (Taqsir); women trim a fingertip’s length from the ends of their hair. Umrah is now complete.',
      reference: 'Sahih al-Bukhari 1727',
      isObligatory: true,
    ),
  ];

  static const List<GuideStep> hajjDays = [
    GuideStep(
      step: 1,
      title: '8 Dhul-Hijjah — Day of Tarwiyah (Mina)',
      detail:
          'Enter Ihram for Hajj (for Tamattu’), travel to Mina, and pray Dhuhr, Asr, Maghrib, Isha, and Fajr shortened (Qasr) without combining.',
      reference: 'Sahih Muslim 1218',
    ),
    GuideStep(
      step: 2,
      title: '9 Dhul-Hijjah — Day of Arafah',
      detail:
          'Proceed to Arafah after sunrise; combine Dhuhr & Asr at Dhuhr time and spend the afternoon in sincere dua and repentance until sunset.',
      isObligatory: true,
      reference: 'Sunan at-Tirmidhi 889 ("Hajj is Arafah")',
    ),
    GuideStep(
      step: 3,
      title: 'Night at Muzdalifah',
      detail:
          'After sunset at Arafah, travel to Muzdalifah, combine Maghrib & Isha, collect pebbles, and rest until Fajr.',
      reference: 'Sahih Muslim 1218',
    ),
    GuideStep(
      step: 4,
      title: '10 Dhul-Hijjah — Yawm an-Nahr (Eid al-Adha)',
      detail:
          'Return to Mina: stone Jamrat al-Aqabah (7 pebbles), offer sacrifice (Hady), shave/trim hair (Halq/Taqsir), and perform Tawaf al-Ifadah & Sa’i.',
      isObligatory: true,
      reference: 'Sahih al-Bukhari 1734',
    ),
    GuideStep(
      step: 5,
      title: '11–13 Dhul-Hijjah — Days of Tashriq',
      detail:
          'Stay in Mina, stone all three Jamarat after Dhuhr each day (7 pebbles each), and conclude with Tawaf al-Wada (Farewell Tawaf) before leaving Makkah.',
      reference: 'Sahih al-Bukhari 1755',
    ),
  ];

  static const List<String> ihramAllowed = [
    'Wearing an Ihram belt/pouch, wristwatch, eyeglasses, or supportive strap.',
    'Washing body or hair gently with unscented soap without pulling hairs.',
    'Carrying an umbrella for shade or resting under tents and shaded walkways.',
    'Trimming clothing adjustments cleanly BEFORE intending Ihram at the Miqat.',
  ];

  static const List<({String id, String title, String note})> pilgrimageChecklist = [
    (id: 'sheets', title: '2 Unstitched White Ihram Sheets & Belt', note: 'Plus spare safety clips or waist pouch'),
    (id: 'sandals', title: 'Comfortable Open Sandals', note: 'Expose ankles & upper foot bone cleanly for men'),
    (id: 'toiletries', title: 'Unscented Soap, Lip Balm & Tissue', note: 'Avoid perfumed soaps and wipes during Ihram'),
    (id: 'bag', title: 'Compact Shoe Drawstring Bag & Prayer Mat', note: 'Carry shoes comfortably inside Masjid al-Haram'),
    (id: 'health', title: 'Prescription Medicines & Hydration Bottle', note: 'Electrolytes & unscented anti-chafing balm'),
    (id: 'docs', title: 'Nusuk Permit, Passport Copy & Dua Pocket Guide', note: 'Offline backup stored locally'),
  ];

  static const List<String> ihramProhibitions = [
    'Cutting or removing hair or trimming nails while in Ihram.',
    'Applying perfume or scented products on body or Ihram garments.',
    'For men: wearing stitched/fitted clothing or covering the head or ankles.',
    'For women: wearing niqab (face veil) or gloves (may drape cloth loosely when needed).',
    'Hunting land game, cutting sacred trees in the Haram, marital relations, or arguing/quarreling.',
  ];

  static const List<QuizQuestion> academyQuizzes = [
    QuizQuestion(
      topic: 'Pillars of Islam',
      prompt: 'Which pillar of Islam involves purifying qualifying wealth held for one lunar year?',
      options: ['Salah', 'Zakat', 'Sawm', 'Hajj'],
      correctIndex: 1,
      explanation: 'Zakat is the obligatory annual charity (typically 2.5% above Nisab).',
    ),
    QuizQuestion(
      topic: 'Quran',
      prompt: 'Which Surah in the Holy Quran does NOT begin with Bismillah?',
      options: ['Surah Al-Fatihah', 'Surah Al-Kahf', 'Surah At-Tawbah (9)', 'Surah Al-Ikhlas'],
      correctIndex: 2,
      explanation: 'Surah At-Tawbah (Surah 9) is the only Surah without a leading Bismillah.',
    ),
    QuizQuestion(
      topic: 'Purification',
      prompt: 'How many obligatory (Fard) parts of Wudu are explicitly mentioned in Quran 5:6?',
      options: ['Four', 'Six', 'Eight', 'Ten'],
      correctIndex: 0,
      explanation:
          'Quran 5:6 mentions four: washing the face, washing arms to elbows, wiping the head, and washing feet to ankles.',
    ),
    QuizQuestion(
      topic: 'Fasting',
      prompt: 'Which six voluntary fasts after Ramadan carry the reward of fasting the whole year?',
      options: ['Six of Muharram', 'Six of Rajab', 'Six of Shawwal', 'Six of Dhul-Hijjah'],
      correctIndex: 2,
      explanation:
          'In Sahih Muslim 1164, fasting Ramadan followed by six days of Shawwal is likened to fasting a lifetime.',
    ),
    QuizQuestion(
      topic: 'Hajj',
      prompt: 'On which date of Dhul-Hijjah do pilgrims stand in the plain of Arafah?',
      options: ['8 Dhul-Hijjah', '9 Dhul-Hijjah', '10 Dhul-Hijjah', '12 Dhul-Hijjah'],
      correctIndex: 1,
      explanation: '9 Dhul-Hijjah is the Day of Arafah, the central pillar of Hajj.',
    ),
  ];
}

