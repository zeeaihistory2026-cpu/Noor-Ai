/// Brief sample data only — mirrors the short snippets already shown
/// in the user's design. Full Qur'an/Hadith/Dua text must come from a
/// licensed/API source at runtime, not hard-coded reproductions.
class SampleData {
  static const userName = 'Abdullah';
  static const hijriDate = "12 Sha'ban 1448 AH";
  static const nextPrayer = 'ASR';
  static const nextPrayerTime = '03:46 PM';
  static const nextPrayerIn = '1h 18m remaining';

  static const streaks = [
    ('Salah', 12),
    ('Dhikr', 8),
    ('Quran', 17),
  ];

  // Very short excerpt + translation as shown on Page 01, with source.
  static const duaArabic = 'رَّبِّ زِدْنِي عِلْمًا';
  static const duaTransliteration = "Rabbi zidni 'ilma";
  static const duaTranslation = '"My Lord, increase me in knowledge."';
  static const duaSource = 'Quran 20:114';

  static const hadithArabic = 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ';
  static const hadithTranslation =
      '"Actions are (judged) only by intentions..."';
  static const hadithSource = 'Sahih al-Bukhari 1';

  static const continueSurah = 'Surah Al-Kahf';
  static const continueAyah = 'Ayah 18';
  static const continueProgress = 0.76;

  // Page 37 — Onboarding.
  static const onboardingTitle = 'Learn. Practice. Grow.';
  static const onboardingBody =
      'A personalized Islamic AI companion centered on Quran, authentic '
      'knowledge and daily worship.';

  // Page 38 — Goal Selection (title, subtitle).
  static const goals = [
    ('Q', 'Quran reading'),
    ('S', 'Salah consistency'),
    ('D', 'Dhikr habit'),
    ('M', 'Memorization'),
    ('L', 'Learn Islam'),
    ('D', 'Duas & Adhkar'),
    ('R', 'Revert journey'),
    ('I', 'Islamic studies'),
  ];

  // Page 39 — Language Selection (native label, english name).
  static const languages = [
    ('English', 'English'),
    ('اردو', 'Urdu'),
    ('العربية', 'Arabic'),
    ('Bahasa Indonesia', 'Indonesian'),
  ];

  // Page 40 — Madhhab Preference.
  static const madhhabOptions = [
    'Hanafi',
    "Shafi'i",
    'Maliki',
    'Hanbali',
    'Show all recognized opinions',
    "I'm not sure",
  ];

  // Page 11 — Quran Home. One brief attributed excerpt each, as drawn.
  static const quranBannerTranslation =
      '"Indeed, this Quran guides to that which is most just."';
  static const quranBannerSource = 'Al-Isra 17:9';
  static const dailyVerseTranslation =
      '"And remember your Lord when you forget."';
  static const dailyVerseSource = 'Al-Kahf 18:24';
  static const continueQuranSurah = 'Al-Kahf';
  static const continueQuranDetail = 'The Cave • Ayah 18 of 110';
  static const continueQuranNote = 'Last read · 76% through the Surah';

  // Page 03 — Reader. One verse shown as placeholder, as drawn.
  static const readerAyahNumber = 18;
  static const readerPrevAyahNumber = 19;
  static const readerSourceEn = 'English Translation (Saheeh International)';
  static const readerSourceUr = 'Urdu Translation (Fateh Muhammad Jalandhari)';

  // Page 05 — Audio Player.
  static const playerReciter = 'Mishary Rashid Alafasy';
  static const playerPosition = '02:34';
  static const playerDuration = '34:56';
  static const playerProgress = 0.12;

  // Page 06 — Salah Tracker.
  static const salahTimes = [
    ('Fajr', '5:32 AM'),
    ('Dhuhr', '12:45 PM'),
    ('Asr', '3:58 PM'),
    ('Maghrib', '5:56 PM'),
    ('Isha', '7:23 PM'),
  ];

  // Page 07 — Tasbih.
  static const dhikrList = [
    ('SubhanAllah', 'Glory be to Allah', 27, 33),
    ('Alhamdulillah', 'All praise is for Allah', 33, 33),
    ('Allahu Akbar', 'Allah is the Greatest', 21, 33),
  ];

  // Pages 12/23 — AI.
  static const suggestedQuestions = [
    'What does the Quran say about patience?',
    'How can I improve my Salah?',
    'What are the benefits of Dhikr?',
    'Tell me about Laylatul Qadr',
  ];
  static const popularTopics = ['Quran', 'Hadith', 'Fiqh', 'Akhlaq', 'Seerah'];
  static const recentChats = [
    ('Is it permissible to fast on doubt?', '10:30 AM'),
    ('Best duas for morning and evening', 'Yesterday'),
    ('Virtues of Surah Al-Kahf', '2 days ago'),
  ];

  // Page 24 — AI Answer Sources. Descriptive summary only (as drawn),
  // sources cited by reference — no religious text reproduced.
  static const sourcesQuestion = 'Explain the importance of Tahajjud';
  static const sourcesSummary =
      'Tahajjud is a voluntary night prayer that can strengthen '
      'devotion, reflection and private worship. This sample answer '
      'lists Quran and Hadith references below to read in context.';
  static const sourcesRefs = 'Quran 17:79  •  Sahih Muslim 1163';
  static const sourcesConfidence = 'Sources listed for this sample answer';

  // Page 25 — Compare Madhhab Opinions. One-line descriptive summaries
  // of recognized positions, exactly as drawn — descriptive compare
  // only, not original rulings.
  static const madhhabQuestion = 'Does touching spouse break wudu?';
  static const madhhabRows = [
    (
      'Hanafi',
      'Your preference',
      'Generally does not invalidate wudu by itself.'
    ),
    (
      "Shafi'i",
      'Recognized view',
      'Direct skin contact may invalidate wudu in many cases.'
    ),
    (
      'Maliki',
      'Recognized view',
      'Depends on intent or desire in the detailed ruling.'
    ),
    ('Hanbali', 'Recognized view', 'Has conditions and scholarly detail.'),
  ];

  // Page 26 — Voice AI Companion.
  static const voicePromptSample = 'What is the best time for Tahajjud?';
  static const voiceSuggestions = [
    'Explain an Ayah',
    'Find a Dua',
    'Ask about Salah'
  ];

  // Page 10 — Qibla Finder (sample bearing; live sensor TODO in code).
  static const qiblaDegrees = 295;
  static const qiblaDirection = 'North West';
  static const qiblaDistance = 'Distance to Kaaba: 4,254 km';
  static const qiblaSaved = [
    ('Home', 'Lahore, Pakistan', '296° NW'),
    ('Work', 'Dubai, UAE', '288° WNW'),
  ];

  // Page 14 — Worship Dashboard (as drawn).
  static const worshipQuote = '"And establish prayer for My remembrance."';
  static const worshipQuoteSource = 'Ta-Ha 20:14';
  static const worshipPrayers = [
    ('Fajr', '04:12 AM'),
    ('Sunrise', '05:36 AM'),
    ('Zuhr', '01:05 PM'),
    ('Asr', '04:28 PM'),
    ('Maghrib', '07:04 PM'),
    ('Isha', '08:34 PM'),
  ];
  static const worshipTools = [
    'Qibla Finder',
    'Tasbeeh',
    'Duas',
    'Daily Adhkar',
    'Islamic Calendar',
    'Fasting Tracker',
    'Salaah Tracker',
    'Zakat Calculator',
  ];

  // Page 31 — Reminder Center (label, time) groups as drawn.
  static const reminderSalah = [
    ('Fajr', '5:07 AM'),
    ('Dhuhr', '12:24 PM'),
    ('Asr', '4:11 PM'),
    ('Maghrib', '6:52 PM'),
    ('Isha', '8:18 PM'),
  ];
  static const reminderWorship = [
    ('Morning Adhkar', '7:00 AM'),
    ('Evening Adhkar', '6:20 PM'),
    ('Daily Zikr & Tasbih', '9:00 PM'),
    ('Quran', '6:30 AM'),
  ];
  static const reminderDaily = [
    ('Ayat of the Day', '6:00 AM'),
    ('Dua of the Day', '8:00 AM'),
    ('Hadith of the Day', '12:00 PM'),
    ('Quote of the Day', '4:00 PM'),
  ];

  // Page 27 — Hifz AI Test. Brief cue fragment only, as drawn.
  static const hifzCueArabic = 'وَإِذْ قَالَ رَبُّكَ';
  static const hifzRange = 'Pages 25-28';
  static const hifzRangeSurah = 'Al-Baqarah • Juz 1';

  // Page 28 — Hifz Test Results (as drawn).
  static const hifzAccuracy = 93;
  static const hifzResultRows = [
    ('Ayah 38', 'Missed one word', 'Review'),
    ('Ayah 40', 'Repeated phrase', 'Review'),
    ('Ayah 42', 'Long hesitation', 'Practice'),
  ];
  static const hifzSuggestion =
      'Repeat page 26 twice today, then retest Ayat 38-42.';

  // Page 29 — Revision Planner (title, detail, minutes, progress).
  static const revisionRows = [
    ('New lesson', '½ page • Page 31', 10, 0.5),
    ('Recent revision', 'Pages 26-30', 7, 0.8),
    ('Old revision', 'Pages 21-25', 8, 0.6),
  ];

  // Page 30 — Weak-page insight (as drawn).
  static const heatmapInsight = 'Page 5 caused errors in 3 recent tests.';

  // Pages 15/16 — Hadith library & chapters (names/counts only).
  static const hadithBooks = [
    ('Sahih Al-Bukhari', 'Imam Muhammad ibn Ismail Al-Bukhari', '7,563 Hadith'),
    ('Sahih Muslim', 'Imam Muslim ibn Al-Hajjaj', '4,301 Hadith'),
    ("Jami' At Tirmidhi", 'Imam Muhammad At-Tirmidhi', '3,956 Hadith'),
    ('Sunan Abu Dawud', 'Imam Abu Dawud', '4,803 Hadith'),
    ('Sunan An-Nasai', 'Imam An-Nasai', '5,578 Hadith'),
    ('Sunan Ibn Majah', 'Imam Ibn Majah', '4,341 Hadith'),
    ('Riyad-us-Saliheen', 'Imam An-Nawawi', '1,900 Hadith'),
  ];
  static const hadithCategories = [
    ('Aqidah', '1,234 Hadith'),
    ('Ibadah', '2,345 Hadith'),
    ('Akhlaq', '1,876 Hadith'),
    ('Muamalat', '1,654 Hadith'),
    ('Family', '1,234 Hadith'),
    ('Food & Drink', '985 Hadith'),
    ('Jihad', '564 Hadith'),
    ('Medicine', '456 Hadith'),
  ];
  static const hadithChapters = [
    ('Book of Revelation', 'Hadith 1-7 • 7 narrations'),
    ('Book of Faith', 'Hadith 8-58 • 51 narrations'),
    ('Book of Knowledge', 'Hadith 59-134 • 76 narrations'),
    ('Book of Wudu', 'Hadith 135-247 • 113 narrations'),
    ('Book of Ghusl', 'Hadith 248-293 • 46 narrations'),
    ('Book of Prayer', 'Hadith 349-520 • 172 narrations'),
    ('Book of Adhan', 'Hadith 603-875 • 273 narrations'),
  ];

  // Page 18 — Dua & Adhkar categories (names/counts only).
  static const duaCategories = [
    ('Morning Adhkar', '15 authentic remembrances', 'Morning'),
    ('Evening Adhkar', '16 authentic remembrances', 'Evening'),
    ('Before Sleep', '8 duas and adhkar', 'Situations'),
    ('After Salah', '7 remembrances', 'Morning'),
    ('For Knowledge', '5 authentic duas', 'Situations'),
    ('For Protection', '9 authentic duas', 'Situations'),
    ('Travel', '6 duas and sunnah reminders', 'Situations'),
    ('Forgiveness', '10 duas and adhkar', 'Evening'),
  ];

  // Phase 5 — Pages 19-22 Share suite (brief excerpt already in code above).
  static const shareFormats = [
    'Instagram Post 4:5',
    'Story / Reel 9:16',
    'Facebook Post 1.91:1',
    'Square 1:1',
  ];
  static const shareThemes = ['Cream', 'Green', 'Dark', 'Photo'];
  static const reelStyles = [
    'Soft Fade',
    'Elegant Reveal',
    'Arabic Writing',
    'Glow'
  ];
  static const shareTargets = [
    ('I', 'Instagram'),
    ('T', 'TikTok'),
    ('F', 'Facebook'),
    ('W', 'WhatsApp'),
    ('S', 'Save Image'),
    ('C', 'Copy text'),
  ];
  // Page 32 — My Journey (label, pct, detail) as drawn.
  static const journeyRows = [
    ('Salah', 93, '26 / 28 prayers'),
    ('Quran', 71, '5 / 7 days'),
    ('Dhikr', 100, '7 / 7 days'),
    ('Learning', 60, '3 / 5 lessons'),
  ];
  static const journeyInsight =
      'Your most consistent Quran time is after Fajr. Make this your regular routine?';
  // Page 33 — Saved (title, note, tag) as drawn. Brief snippets only.
  static const savedRows = [
    ('Quran 94:6', 'Indeed, with hardship comes ease.', 'Saved Ayah'),
    ('Sahih al-Bukhari 1', 'Actions are judged by intentions.', 'Hadith'),
    ('Dua for knowledge', 'Rabbi zidni ilma', 'Dua'),
    (
      'Patience in Islam',
      'Sources and reflection saved from AI chat.',
      'AI Note'
    ),
    ('Surah Al-Kahf', 'Personal reflection on Ayah 10.', 'Quran note'),
  ];
  static const savedFilters = ['All', 'Quran', 'Hadith', 'Duas', 'AI Notes'];
  // Page 34 — Profile rows as drawn.
  static const profileName = 'Abdullah Khan';
  static const profileTags = 'Learning • Quran • Worship';
  static const profileJourney = '12 day Salah • 17 day Quran • 8 day Dhikr';
  static const profileRows = [
    'Goals & Preferences',
    'Madhhab Preference',
    'Language',
    'Saved Content',
    'Privacy',
    'Subscription',
    'Settings',
  ];
  // Page 35 — Notifications (title, body, initial) grouped as drawn.
  static const notifToday = [
    ('Fajr reminder', 'Fajr begins in 15 minutes. Prepare for prayer.', 'F'),
    ('Ayat of the Day', '“Verily, in the remembrance of Allah do hearts find rest.” (13:28)', 'A'),
    ('Daily Zikr', 'Take a peaceful moment for SubhanAllah, Alhamdulillah & Allahu Akbar.', 'Z'),
    ('Daily Dua', 'Your Dua of the Day is ready: “Rabbana atina fid-dunya hasanah...”', 'D'),
    ('Hadith of the Day', '“The best among you are those who have the best manners.”', 'H'),
    ('Quote of the Day', '“Patience is not the ability to wait, but how you act while waiting.”', 'Q'),
    ('Quran', 'Continue Surah Al-Kahf from Ayah 18.', 'Q'),
  ];
  static const notifEarlier = [
    ('Hifz plan', "Today's revision plan is ready.", 'H'),
    ('Hadith', 'New Hadith of the Day available.', 'H'),
    ('AI insight', 'Your strongest Quran habit is after Fajr.', 'A'),
  ];
  // Page 13 — Settings groups (icon name kept in screen; label, sub, value).
  static const settingsAccount = [
    ('Profile', 'View and edit your profile', ''),
    ('Privacy & Security', 'Manage your privacy and security', ''),
    ('Notifications', 'Customize your notifications', ''),
    ('Language', 'Choose your preferred language', 'English'),
  ];
  static const settingsPrefs = [
    ('Theme', 'Choose your app theme', 'System'),
    ('Text Size', 'Adjust text size for better reading', 'Medium'),
    ('Audio Settings', 'Manage audio playback preferences', ''),
    ('Data & Storage', 'Manage offline data and storage', ''),
  ];
  static const settingsSupport = [
    ('Help Center', 'Get help and FAQ', ''),
    ('Send Feedback', 'Share your thoughts with us', ''),
    ('About NOOR', 'App info, version and updates', 'v1.2.0'),
    ('Rate NOOR', 'Rate us on the app store', ''),
  ];
  static const settingsEmail = 'abdullah.khan@email.com';

  // Pages 11/02 — surah rows (number, english name, meaning, ayahs, page).
  // Arabic names are the surah titles only (proper names, not verses).
  static const surahs = [
    (1, 'Al-Fatihah', 'The Opening', 7, 1, 'الْفَاتِحَة'),
    (2, 'Al-Baqarah', 'The Cow', 286, 2, 'الْبَقَرَة'),
    (3, 'Aal-e-Imran', 'The Family of Imran', 200, 50, 'آل عِمْرَان'),
    (4, 'An-Nisa', 'The Women', 176, 77, 'النِّسَاء'),
    (5, "Al-Ma'idah", 'The Table', 120, 106, 'الْمَائِدَة'),
    (6, "Al-An'am", 'The Cattle', 165, 128, 'الْأَنْعَام'),
    (7, "Al-A'raf", 'The Heights', 206, 151, 'الْأَعْرَاف'),
    (8, 'Al-Anfal', 'The Spoils of War', 75, 177, 'الْأَنْفَال'),
    (9, 'At-Tawbah', 'The Repentance', 129, 187, 'التَّوْبَة'),
    (10, 'Yunus', 'Jonah', 109, 208, 'يُونُس'),
  ];
}
