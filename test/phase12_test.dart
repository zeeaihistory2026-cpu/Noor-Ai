// Phase 12 tests: shared-state coherence, contrast tokens, Reader
// fallback integrity and the dead-handler proof. Pure logic only.
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/app_state.dart';
import 'package:noor_ai_companion/data/sample_data.dart';
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
  group('Phase 12 — NoorAppState single source of truth', () {
    test('date line pairs the demo Gregorian date with the design Hijri', () {
      expect(NoorAppState.gregorianLabel, 'Sunday, 31 Jan 2027');
      expect(
          NoorAppState.dateLine, 'Sunday, 31 Jan 2027 · 12 Sha\'ban 1448 AH');
    });

    test('prayer chain is internally consistent', () {
      expect(NoorAppState.nextPrayerName, 'ASR');
      expect(NoorAppState.nextPrayerTime, '3:58 PM');
      expect(NoorAppState.nextPrayerCountdown, '1h 18m');
      // Canonical list order matches the salah tracker rows.
      expect(NoorAppState.prayerTimes.first, ('Fajr', '5:32 AM'));
    });

    test('qibla demo values describe Karachi, not Makkah', () {
      expect(NoorAppState.locationLabel, 'Karachi, Pakistan');
      expect(NoorAppState.qiblaBearing, inInclusiveRange(267.0, 268.5));
      expect(NoorAppState.qiblaCardinal, 'West');
    });

    test('streak + journey lines agree', () {
      expect(NoorAppState.streaks.first, ('Salah', 12));
      expect(NoorAppState.journeyLine,
          '12-day Salah • 17-day Quran • 8-day Dhikr');
    });
  });

  group('Phase 12 — contrast tokens meet WCAG AA for small text', () {
    test('mutedDark on white and cream >= 4.5:1', () {
      expect(_contrast(NoorColors.mutedDark, Colors.white),
          greaterThanOrEqualTo(4.5));
      expect(_contrast(NoorColors.mutedDark, NoorColors.cream),
          greaterThanOrEqualTo(4.5));
    });

    test('goldDeep on white >= 4.5:1 (gold itself is large-text only)', () {
      expect(_contrast(NoorColors.goldDeep, Colors.white),
          greaterThanOrEqualTo(4.5));
    });

    test('NoorType locks Arabic/Urdu line heights and families', () {
      expect(NoorType.arabic().fontFamily, 'AmiriQuran');
      expect(NoorType.arabic().height, 1.9);
      expect(NoorType.urdu().fontFamily, 'NotoNastaliqUrdu');
      expect(NoorType.urdu().height, 2.1);
    });
  });

  group('Phase 12 — Reader fallback integrity', () {
    test('no mismatched sacred excerpt ships under the Al-Kahf header', () {
      final reader =
          File('lib/screens/quran/quran_reader_screen.dart').readAsStringSync();
      // The old fallback quoted a different Surah under this header.
      expect(reader.contains('Ankabut'), isFalse);
      expect(reader.contains('29:2'), isFalse);
      expect(
          reader.contains('Ayah text loads from the verified source.'), isTrue);
    });

    test('offline/sample copy is honestly labelled', () {
      expect(NoorAppState.sourceLabel, 'Demo data');
      expect(SampleData.sourcesConfidence,
          'Sources listed for this sample answer');
    });
  });

  group('Phase 12 — dead-handler proof', () {
    test('zero empty handlers/callbacks remain in lib/', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final text = entity.readAsStringSync();
          if (text.contains('() {}')) {
            offenders.add(entity.path);
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join(', '));
    });

    test('Phase 16 audit — no unconditional dead onPressed/onTap in lib/', () {
      // Every header chrome icon was wired to a real overflow-sheet
      // action. The single allowed `onPressed: null` is the visibly
      // dimmed (Opacity 0.38) fallback branch inside NoorPlainHeader
      // for screens that pass no actions — honestly disabled, never
      // fake-live. Conditional nulls (`_busy ? null`, boundary
      // `_index > 0 ? ... : null`) are real disabled states.
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final hit = RegExp(r'on(Pressed|Tap|Changed|LongPress): null')
              .hasMatch(line);
          if (!hit) continue;
          final conditional =
              line.contains('? null') || line.contains('?null');
          final allowedFallback =
              entity.path.endsWith('widgets/noor_share_card.dart');
          if (!conditional && !allowedFallback) {
            offenders.add('${entity.path}:${i + 1}');
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join(', '));
    });
  });
}
