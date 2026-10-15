import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/noor_controller.dart';
import 'package:noor_ai_companion/data/prayer_service.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';

double _luminance(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('Phase 4 — Midnight Emerald Palette & Contrast (WCAG AA/AAA)', () {
    test('Midnight Emerald tokens are strictly defined', () {
      expect(NoorColors.darkBg, const Color(0xFF061812));
      expect(NoorColors.darkSurface, const Color(0xFF0D271E));
      expect(NoorColors.darkCard, const Color(0xFF13382B));
      expect(NoorColors.darkBorder, const Color(0xFF173C30));
      expect(NoorColors.darkTextPrimary, const Color(0xFFEBF5F0));
      expect(NoorColors.darkTextSecondary, const Color(0xFF8CA89B));
      expect(NoorColors.darkGold, const Color(0xFFE5C158));
    });

    test('primary text meets WCAG AAA (>7:1) on dark background and surface', () {
      expect(_contrast(NoorColors.darkTextPrimary, NoorColors.darkBg),
          greaterThanOrEqualTo(7.0));
      expect(_contrast(NoorColors.darkTextPrimary, NoorColors.darkSurface),
          greaterThanOrEqualTo(7.0));
    });

    test('secondary text meets WCAG AA (>4.5:1) on dark background and surface', () {
      expect(_contrast(NoorColors.darkTextSecondary, NoorColors.darkBg),
          greaterThanOrEqualTo(4.5));
      expect(_contrast(NoorColors.darkTextSecondary, NoorColors.darkSurface),
          greaterThanOrEqualTo(4.5));
    });

    test('gold accents meet WCAG AAA (>7:1) on dark background and surface', () {
      expect(_contrast(NoorColors.darkGold, NoorColors.darkBg),
          greaterThanOrEqualTo(7.0));
      expect(_contrast(NoorColors.darkGold, NoorColors.darkSurface),
          greaterThanOrEqualTo(7.0));
    });

    test('NoorTheme.dark() constructs valid Material 3 dark ThemeData', () {
      final darkTheme = NoorTheme.dark();
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, NoorColors.darkBg);
      expect(darkTheme.cardTheme.color, NoorColors.darkCard);
      expect(darkTheme.colorScheme.surface, NoorColors.darkSurface);
      expect(darkTheme.colorScheme.secondary, NoorColors.darkGold);
    });
  });

  group('Phase 4 — Automatic Solar Switching (Post-Maghrib until Fajr)', () {
    final sampleDay = PrayerDay.sample();

    test('pre-dawn Tahajjud/Fajr (04:30 AM) is detected as night time', () {
      final preFajr = DateTime(2027, 1, 31, 4, 30);
      expect(sampleDay.isNightTime(preFajr), isTrue);
    });

    test('midday Dhuhr (12:30 PM) is detected as day time', () {
      final midday = DateTime(2027, 1, 31, 12, 30);
      expect(sampleDay.isNightTime(midday), isFalse);
    });

    test('afternoon Asr (04:00 PM) is detected as day time', () {
      final afternoon = DateTime(2027, 1, 31, 16, 0);
      expect(sampleDay.isNightTime(afternoon), isFalse);
    });

    test('post-Maghrib (07:30 PM) is detected as night time', () {
      final postMaghrib = DateTime(2027, 1, 31, 19, 30);
      expect(sampleDay.isNightTime(postMaghrib), isTrue);
    });

    test('late night Isha (11:00 PM) is detected as night time', () {
      final lateNight = DateTime(2027, 1, 31, 23, 0);
      expect(sampleDay.isNightTime(lateNight), isTrue);
    });
  });

  group('Phase 4 — NoorController Theme Preferences & Reactive Mode', () {
    test('controller defaults to solar switching', () {
      final controller = NoorController();
      expect(controller.themePreference, NoorThemePreference.solar);
      expect(controller.themePreferenceLabel, contains('Solar'));
    });

    test('explicit light and dark preferences override solar time', () async {
      final controller = NoorController();
      await controller.setThemePreference(NoorThemePreference.light);
      expect(controller.themeMode, ThemeMode.light);

      await controller.setThemePreference(NoorThemePreference.dark);
      expect(controller.themeMode, ThemeMode.dark);

      await controller.setThemePreference(NoorThemePreference.system);
      expect(controller.themeMode, ThemeMode.system);
    });
  });
}
