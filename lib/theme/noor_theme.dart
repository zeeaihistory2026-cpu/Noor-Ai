import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// NOOR design tokens — taken from the 42-page design palette.
class NoorColors {
  static const emerald = Color(0xFF0F5132);
  static const emeraldDark = Color(0xFF0B3D2E);
  static const emeraldMid = Color(0xFF135C46);
  static const emeraldSoft = Color(0xFFE7F3ED);
  static const gold = Color(0xFFD4AF37);
  static const goldSoft = Color(0xFFC8A96A);
  static const goldDeep = Color(0xFF7A5E14);
  static const cream = Color(0xFFF7F4EA);
  static const creamAlt = Color(0xFFF6F8F6);
  static const sand = Color(0xFFEDE7D6);
  static const ink = Color(0xFF1C1C1C);
  static const muted = Color(0xFF6D7F73);

  /// Darkened muted for text at small sizes (Phase 12 contrast pass):
  /// #4F6355 measures >= 4.6:1 on cream and white, where [muted]
  /// (3.87:1 / 4.26:1) fails WCAG AA for small text. [muted] stays
  /// for large/decorative use only.
  static const mutedDark = Color(0xFF4F6355);

  /// The one hairline colour (Phase 12 token enforcement): replaces
  /// the per-file near-identical #E3DED0/#E9E2D2/#EFE9DB variants.
  static const hairline = Color(0xFFE3DED0);

  /// Phase 13 additions: the near-duplicate hairlines/surfaces that
  /// screens previously hand-mixed per file, named once here.
  static const hairlineSoft = Color(0xFFF0EDE2);
  static const surfaceWarm = Color(0xFFFFFDF4);
  static const goldPale = Color(0xFFF3E5C3);
  static const amber = Color(0xFFF59E0B);
  static const success = Color(0xFF4ADE80);
  static const error = Color(0xFFB3261E);
  static const iconMuted = Color(0xFF8A948C);
  static const heatWeak = Color(0xFFCD6B52);
  static const heatMid = Color(0xFF8FB4A3);
  static const greyDisabled = Color(0xFFB9C4BC);
  static const inkDeep = Color(0xFF14231F);

  /// Phase 4 — Midnight Emerald Palette (Dark Mode):
  /// Construct the Midnight Emerald theme (#061812 / #0D271E).
  /// Exceeds WCAG AAA requirements for pre-dawn Fajr and Tahajjud reading.
  static const darkBg = Color(0xFF061812); // Midnight abyss background
  static const darkSurface = Color(0xFF0D271E); // Deep emerald night surface
  static const darkCard = Color(0xFF13382B); // Elevated dark card surface
  static const darkBorder = Color(0xFF173C30); // Subtle borders & dividers
  static const darkTextPrimary = Color(0xFFEBF5F0); // Primary text (>16:1 contrast)
  static const darkTextSecondary = Color(0xFF8CA89B); // Secondary text (>6:1 contrast)
  static const darkGold = Color(0xFFE5C158); // Accessible gold on emerald (>9:1 contrast)
}

/// The NOOR type scale (Phase 12, from SENIOR_REVIEW §3.6). Every
/// text role in the app maps to exactly one of these styles — no
/// per-screen sizes, no half-point sizes. Latin styles inherit the
/// app font (Manrope via [NoorTheme]); sacred-text styles name the
/// bundled fonts explicitly so device fallback can never substitute
/// an unsuitable Arabic/Urdu face.
class NoorType {
  static const display = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: NoorColors.ink,
      fontFeatures: [FontFeature.tabularFigures()]);
  static const screenTitle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      height: 1.2,
      color: NoorColors.ink);
  static const section = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: NoorColors.ink);
  static const cardTitle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: NoorColors.ink);
  static const body = TextStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: NoorColors.ink);
  static const secondary = TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      height: 1.45,
      color: NoorColors.mutedDark);
  static const meta = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: NoorColors.mutedDark);
  static const eyebrow = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 1.4,
      color: NoorColors.emeraldDark);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const numeric =
      TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

  /// Qur'anic / Arabic sacred text — bundled Amiri Quran face with
  /// the tall leading Uthmani diacritics need. Scale [size] via the
  /// Reader text-size control (clamped by callers).
  static TextStyle arabic({double size = 22, Color color = NoorColors.ink}) =>
      TextStyle(
          fontFamily: 'AmiriQuran',
          fontSize: size,
          fontWeight: FontWeight.w400,
          height: 1.9,
          color: color);

  /// Urdu translation text — bundled Noto Nastaliq Urdu with the
  /// ~2.1 leading Nastaliq ascenders require.
  static TextStyle urdu({double size = 16, Color color = NoorColors.ink}) =>
      TextStyle(
          fontFamily: 'NotoNastaliqUrdu',
          fontSize: size,
          fontWeight: FontWeight.w400,
          height: 2.1,
          color: color);

  /// Any style with tabular figures (times, countdowns, streaks).
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Spacing scale used across the design pages (cards sit on 20px
/// page padding, 16px gaps, 24px section breaks).
class NoorSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0; // page horizontal padding in the PNGs
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const page = EdgeInsets.symmetric(horizontal: xl);
  static const card = EdgeInsets.all(lg);
}

/// Corner radii from the design: cards 20–24, hero/next-prayer 24,
/// buttons 16, inputs pill/28, splash logo tile 44.
class NoorRadius {
  static const card = 20.0;
  static const cardSmall = 16.0; // Tier 2 selectable/input tiles
  static const heroCard = 24.0;
  static const button = 16.0;
  static const input = 28.0;
  static const chip = 999.0;
  static const splashTile = 44.0;
  static const sheet = 28.0;
}

/// Fixed sizes that recur in the PNGs.
class NoorSizes {
  static const buttonHeight = 52.0; // Standardized button height (Phase 3)
  static const bottomNavHeight = 64.0;
  static const streakCardHeight = 104.0;
  static const nextPrayerCardMinHeight = 132.0;
  static const appBarHeight = 56.0;
  static const avatar = 40.0;
  static const icon = 24.0;
}

/// Soft shadows used on white cards over cream (design uses very
/// light, wide shadows — never Material elevation).
class NoorShadows {
  static const card = [
    BoxShadow(color: Color(0x140B3D2E), blurRadius: 18, offset: Offset(0, 6)),
  ];
  static const hero = [
    BoxShadow(color: Color(0x260B3D2E), blurRadius: 22, offset: Offset(0, 10)),
  ];
}

/// Asset slots for REAL artwork exported from the user's design
/// files. Pixel-perfect fidelity requires these files — do not
/// substitute generated/generic mosque or lantern art.
/// Source folder:
/// ~/workspace/noor-design/NOOR_AI_Companion_Complete_UI_Pages_01-42/
class NoorAssets {
  static const nextPrayerMosque =
      'assets/images/next_prayer_mosque.png'; // Page 01 hero (dome + minarets, right side)
  static const aiHeaderMosque =
      'assets/images/ai_header_mosque.png'; // Page 12 header
  static const splashMotif = 'assets/images/splash_motif.png'; // Page 36
  static const lantern = 'assets/images/lantern.png'; // Pages 09/12 cards
  static const duaHands = 'assets/images/dua_hands.png'; // Page 01/08
  static const quranBannerVerse =
      'assets/images/quran_banner_verse.png'; // Page 11 quote banner (user's own crop, incl. brief Al-Isra 17:9 excerpt)
  static const quranRehal = 'assets/images/quran_rehal.png'; // Page 01/09
  static const surahCalligraphy =
      'assets/images/surah_calligraphy.png'; // Page 01 Continue Quran roundel
  static const playerArch =
      'assets/images/player_arch.png'; // Page 05 arch + Al-Kahf calligraphy
  static const reciterAvatar =
      'assets/images/reciter_avatar.png'; // Pages 02/03/05 reciter avatar (user's own design art, cropped from Page 03 mini player)
  static const salahHeaderMosque =
      'assets/images/salah_header_mosque.png'; // Page 06 header skyline
  static const salahLantern =
      'assets/images/salah_lantern.png'; // Page 06 Insights lantern
  static const salahProstration =
      'assets/images/salah_prostration.png'; // Page 06 Learn Salah illustration
  static const qiblaKaaba =
      'assets/images/qibla_kaaba.png'; // Page 10 compass centre
  static const qiblaMosque =
      'assets/images/qibla_mosque.png'; // Page 10 direction card
  static const worshipHeaderSkyline =
      'assets/images/worship_header_skyline.png'; // Page 14 header
  static const hadithLibraryHeader =
      'assets/images/hadith_library_header.png'; // Page 15 header skyline + lanterns
  static const hadithBooksLantern =
      'assets/images/hadith_books_lantern.png'; // Page 15 Build Your Knowledge
  static const hadithBookCover =
      'assets/images/hadith_book_cover.png'; // Page 15 featured book cover
  static const settingsLanterns =
      'assets/images/settings_lanterns.png'; // Page 13 header lantern (user's own crop)
  static const duaMedallion =
      'assets/images/dua_medallion.png'; // Page 08 dua card medallion (user's own crop)
  static const hadithDayMedallion =
      'assets/images/hadith_day_medallion.png'; // Page 09 Muhammad calligraphy medallion (user's own crop)
  static const hadithCoverBukhari =
      'assets/images/hadith_cover_bukhari.png'; // Page 15 featured cover (user's own crop)
  static const hadithCoverMuslim =
      'assets/images/hadith_cover_muslim.png'; // Page 15 featured cover (user's own crop)
  static const hadithCoverTirmidhi =
      'assets/images/hadith_cover_tirmidhi.png'; // Page 15 featured cover (user's own crop)
  static const hadithCoverDawud =
      'assets/images/hadith_cover_dawud.png'; // Page 15 featured cover (user's own crop)
}

class NoorTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NoorColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NoorColors.emerald,
        primary: NoorColors.emerald,
        secondary: NoorColors.gold,
        surface: Colors.white,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
        // Phase 12: the Material roles now mirror the NoorType
        // scale so theme-driven widgets and token-driven screens
        // speak the same typographic language.
        headlineMedium: GoogleFonts.manrope(
            textStyle: NoorType.screenTitle.copyWith(fontSize: 28),
            color: NoorColors.emeraldDark),
        titleLarge: GoogleFonts.manrope(textStyle: NoorType.screenTitle),
        titleMedium: GoogleFonts.manrope(textStyle: NoorType.cardTitle),
        bodyMedium: GoogleFonts.manrope(textStyle: NoorType.body),
        bodySmall: GoogleFonts.manrope(textStyle: NoorType.meta),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: const Color(0x140B3D2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NoorRadius.card)),
      ),
      // Phase 12: ONE switch dialect app-wide (Reminder Center and
      // Settings previously disagreed on proportions).
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : NoorColors.iconMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? NoorColors.emerald
                : NoorColors.sand),
        trackOutlineColor: WidgetStateProperty.all(NoorColors.hairline),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NoorColors.emerald,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(NoorRadius.button)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NoorColors.emeraldDark,
          side: const BorderSide(color: NoorColors.emeraldDark, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(NoorRadius.button)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: NoorColors.emeraldSoft,
        labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }

  /// Midnight Emerald dark theme (Phase 4):
  /// Tailored for pre-dawn Fajr and night Tahajjud reading.
  /// Deep forest black background (#061812), emerald night surface (#0D271E),
  /// elevated card (#13382B), subtle borders (#173C30), and gold accents (#E5C158).
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NoorColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: NoorColors.emeraldMid,
        secondary: NoorColors.darkGold,
        surface: NoorColors.darkSurface,
        onSurface: NoorColors.darkTextPrimary,
        outline: NoorColors.darkBorder,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
        headlineMedium: GoogleFonts.manrope(
            textStyle: NoorType.screenTitle.copyWith(fontSize: 28),
            color: NoorColors.darkGold),
        titleLarge: GoogleFonts.manrope(
            textStyle: NoorType.screenTitle.copyWith(color: NoorColors.darkTextPrimary)),
        titleMedium: GoogleFonts.manrope(
            textStyle: NoorType.cardTitle.copyWith(color: NoorColors.darkTextPrimary)),
        bodyMedium: GoogleFonts.manrope(
            textStyle: NoorType.body.copyWith(color: NoorColors.darkTextPrimary)),
        bodySmall: GoogleFonts.manrope(
            textStyle: NoorType.meta.copyWith(color: NoorColors.darkTextSecondary)),
      ),
      cardTheme: CardThemeData(
        color: NoorColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NoorRadius.card),
          side: const BorderSide(color: NoorColors.darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NoorColors.darkBorder,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? NoorColors.darkGold
                : Colors.white70),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? NoorColors.emeraldDark
                : NoorColors.darkCard),
        trackOutlineColor: WidgetStateProperty.all(NoorColors.darkBorder),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NoorColors.emerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NoorRadius.button)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NoorColors.darkGold,
          side: const BorderSide(color: NoorColors.darkGold, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NoorRadius.button)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: NoorColors.darkSurface,
        indicatorColor: NoorColors.emeraldMid,
        iconTheme: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const IconThemeData(color: NoorColors.darkGold)
                : const IconThemeData(color: NoorColors.darkTextSecondary)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: NoorColors.darkGold)
                : const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NoorColors.darkTextSecondary)),
      ),
    );
  }
}
