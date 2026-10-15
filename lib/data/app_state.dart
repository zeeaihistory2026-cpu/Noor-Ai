import 'sample_data.dart';

/// Phase 12 — the app's single source of truth.
///
/// Before this file, every screen carried its own sample numbers, so
/// the date, prayer times, location, avatar and progress changed
/// from screen to screen (SENIOR_REVIEW Critical #3 / §2.1). Now:
///
/// * [NoorAppState.demo] is the ONE canonical demo snapshot. Every
///   screen that shows the user's name, today's date, prayer times,
///   location, streaks or continue-reading reads it from here.
/// * Live services (PrayerService / QuranService) replace these
///   values at runtime; the demo snapshot is only the offline /
///   first-frame fallback, and [isDemo] + [sourceLabel] say so
///   wherever the distinction matters.
/// * SampleData remains the design-content store (brief attributed
///   excerpts, lists); anything that is a *fact about today or the
///   user* lives here instead, so it can only be stated once.
class NoorAppState {
  const NoorAppState._();

  /// True while the canonical snapshot below is what screens show.
  /// Flip in one place when live state is hoisted app-wide; screens
  /// already phrase sample-derived facts through [sourceLabel].
  static const bool isDemo = true;
  static const String sourceLabel = 'Demo data';

  // ---- The user (one identity, one avatar treatment) --------------
  static const String userName = SampleData.userName; // Abdullah
  static const String fullName = SampleData.profileName; // Abdullah Khan
  static const String initials = 'AK';
  static const String email = SampleData.settingsEmail;

  // ---- Place (Karachi until device location exists) ---------------
  static const String city = 'Karachi';
  static const String country = 'Pakistan';
  static const String locationLabel = 'Karachi, Pakistan';
  static const double latitude = 24.8608;
  static const double longitude = 67.0011;

  /// Qibla bearing for [latitude]/[longitude], degrees clockwise
  /// from north (great-circle to Makkah). Matches the value
  /// PrayerService.computeQiblaBearing returns for these coordinates,
  /// so the demo state and the live fallback can never disagree.
  static const double qiblaBearing = 267.7;
  static const String qiblaCardinal = 'West';
  static const String qiblaDistanceLabel = '2,800 km to the Kaaba';

  // ---- Today (one date, stated once) ------------------------------
  /// Demo "today". The Hijri label is the design's; the Gregorian
  /// date + weekday are derived from this value, so the two
  /// calendars can never be paired impossibly on screen again.
  static final DateTime demoDate = DateTime(2027, 1, 31);
  static const String hijriLabel = SampleData.hijriDate; // 12 Sha'ban 1448 AH

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// "Sunday, 31 Jan 2027" — derived, never hand-typed per screen.
  static String get gregorianLabel =>
      '${_weekdays[demoDate.weekday - 1]}, ${demoDate.day} '
      '${_months[demoDate.month - 1]} ${demoDate.year}';

  /// "Sunday, 31 Jan 2027 · 12 Sha'ban 1448 AH" — the one date line.
  static String get dateLine => '$gregorianLabel · $hijriLabel';

  // ---- Prayer times (one "today" for every screen) ----------------
  /// Canonical demo times. Home, Salah, Worship and Reminders all
  /// read this list (Reminders add their lead-time labels), so Fajr
  /// can never be 5:32 on one screen and 5:07 on another.
  static const List<(String, String)> prayerTimes = SampleData.salahTimes;
  static const String sunriseTime = '5:36 AM';

  /// The demo "next prayer": the same prayer, at the same time, with
  /// the same countdown on Home / Salah / Worship.
  static const String nextPrayerName = 'ASR';
  static const String nextPrayerTime = '3:58 PM';
  static const String nextPrayerCountdown = '1h 18m';
  static const String nextPrayerCountdownLabel = 'Time until Asr · 1h 18m';

  // ---- Progress (one set of numbers) ------------------------------
  static const List<(String, int)> streaks = SampleData.streaks; // 12/8/17
  static const String journeyLine = '12-day Salah • 17-day Quran • 8-day Dhikr';

  // ---- Continue reading (Reader, Quran Home and Surah List agree) -
  static const String continueSurah = 'Al-Kahf';
  static const String continueSurahLabel = 'Surah Al-Kahf';
  static const int continueAyah = 18;
  static const String continueDetail = 'Ayah 18 of 110';
  static const String continueNote = 'Last read · 76% through the Surah';
  static const double continueProgress = 0.76;
}
