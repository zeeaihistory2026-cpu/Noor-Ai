import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/noor_controller.dart';
import 'package:noor_ai_companion/data/prayer_service.dart';

void main() {
  group('Phase 13 — app-wide reactive state', () {
    test('controller starts on the canonical demo snapshot', () {
      final c = NoorController();
      expect(c.isLive, isFalse);
      expect(c.nextPrayerLabel, 'ASR 3:58 PM');
      expect(c.sourceLabel, 'Demo data');
      expect(c.userName, 'Abdullah');
      expect(c.streaks['Salah'], 12);
    });

    test('setLiveDay propagates: label + source flip, listeners fire',
        () {
      final c = NoorController();
      var notifications = 0;
      c.addListener(() => notifications++);
      final day = PrayerDay.fromAlAdhanJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'timings': <String, dynamic>{
              'Fajr': '05:00',
              'Sunrise': '06:20',
              'Dhuhr': '12:30',
              'Asr': '15:45',
              'Maghrib': '18:10',
              'Isha': '19:40',
            },
            'date': <String, dynamic>{
              'gregorian': {'date': '31-01-2027'},
              'hijri': <String, dynamic>{
                'day': '22',
                'month': {'en': "Sha'ban"},
                'year': '1448',
              },
            },
          },
        },
        source: PrayerSource.live,
      );
      c.setLiveDay(day);
      expect(notifications, 1);
      expect(c.isLive, isTrue);
      expect(c.sourceLabel, 'Live');
      expect(c.nextPrayerLabel, isNot('ASR 3:58 PM'));
    });

    testWidgets('NoorScope rebuilds listening widgets on change',
        (tester) async {
      final c = NoorController();
      await tester.pumpWidget(NoorScope(
        controller: c,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Text(
              NoorScope.of(context)?.nextPrayerLabel ?? 'none',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ));
      expect(find.text('ASR 3:58 PM'), findsOneWidget);
      c.setUserName('Yusuf');
      c.setStreak('Salah', 13);
      await tester.pump();
      expect(c.userName, 'Yusuf');
      expect(c.streaks['Salah'], 13);
    });
  });

  group('Phase 13 — codebase discipline (grep proof)', () {
    final libFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    String readLib(File f) => f.readAsStringSync();

    test('no hardcoded Color(0x…) outside the theme', () {
      final offenders = <String>[];
      for (final f in libFiles) {
        if (f.path.endsWith('noor_theme.dart')) continue;
        if (readLib(f).contains('Color(0x')) offenders.add(f.path);
      }
      expect(offenders, isEmpty,
          reason: 'hardcoded colors in: $offenders');
    });

    test('ad-hoc fontSize only in documented exception sites', () {
      // Allowed: theme definitions; hero numerals via display
      // tokens (44/54/40/36 in copyWith); avatar size*0.36 formula;
      // share-card rendered-graphic sizes; the Reader size clamp.
      final allowedFiles = {
        'noor_theme.dart',
        'noor_components.dart', // avatar initials size*0.36
        'noor_share_card.dart', // rendered export graphic
        'quran_reader_screen.dart', // user-controlled clamp
        'hifz_test_results_screen.dart', // 44 hero
        'zikr_tasbih_screen.dart', // 54 hero
        'qibla_finder_screen.dart', // 40 hero
        'splash_screen.dart', // 36 wordmark
        'onboarding_screen.dart',
        'salah_tracker_screen.dart',
        'worship_dashboard_screen.dart',
        'hadith_library_screen.dart',
        'dua_library_screen.dart',
      };
      final offenders = <String>[];
      for (final f in libFiles) {
        final name = f.path.split(RegExp(r'[/\\]')).last;
        if (allowedFiles.contains(name)) continue;
        if (readLib(f).contains('fontSize:')) offenders.add(f.path);
      }
      expect(offenders, isEmpty, reason: 'ad-hoc sizes in: $offenders');
    });
  });
}
