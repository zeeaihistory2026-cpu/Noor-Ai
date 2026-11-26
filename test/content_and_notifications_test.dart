import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_ai_companion/data/noor_store.dart';
import 'package:noor_ai_companion/data/notification_plan.dart';
import 'package:noor_ai_companion/data/notification_service_io.dart';
import 'package:noor_ai_companion/data/offline_quran.dart';
import 'package:noor_ai_companion/data/quran_playback_plan.dart';
import 'package:noor_ai_companion/data/quran_service.dart';
import 'package:noor_ai_companion/data/daily_content_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('bundled editions contain all 114 surahs and 6236 ayahs', () async {
    for (final edition in [
      QuranService.editionArabic,
      QuranService.editionEnglish,
      QuranService.editionUrdu
    ]) {
      final surahs = (await OfflineQuran.load(edition))['surahs'] as List;
      expect(surahs, hasLength(114));
      expect(surahs.fold<int>(0, (sum, s) => sum + (s['ayahs'] as List).length),
          6236);
      for (final surah in surahs) {
        expect(
            (surah['ayahs'] as List)
                .every((a) => (a['text'] as String).isNotEmpty),
            isTrue);
      }
    }
    final last = await QuranService().fetchSurah(114);
    expect(last.ayahs, hasLength(6));
  });

  test('every daily Ayat matches its complete cited verses in all editions',
      () async {
    for (final item in DailyContentService.ayatList) {
      final match =
          RegExp(r'(\d+):(\d+)(?:-(\d+))?').firstMatch(item.reference)!;
      final surah = int.parse(match[1]!);
      final first = int.parse(match[2]!);
      final last = int.parse(match[3] ?? match[2]!);
      for (final edition in [
        (QuranService.editionArabic, item.arabic),
        (QuranService.editionEnglish, item.translation),
        (QuranService.editionUrdu, item.urdu),
      ]) {
        final ayahs =
            (await OfflineQuran.surah(surah, edition.$1))['ayahs'] as List;
        final expected = ayahs
            .sublist(first - 1, last)
            .map((ayah) => ayah['text'])
            .join(' ');
        expect(edition.$2, expected, reason: '${item.id} / ${edition.$1}');
      }
    }
  });

  test(
      'all 548 Mushaf pages preserve every supplied word in sixteen line slots',
      () async {
    final pages = await OfflineQuran.load('mushaf16');
    expect(pages, hasLength(548));
    final verseKeys = <String>{};
    for (int page = 1; page <= 548; page++) {
      final raw = pages['$page'];
      final parsed = QuranService.parseMushaf16PageJson(jsonEncode(raw), page);
      expect(parsed.lines, hasLength(16));
      final starts = (raw['verses'] as List)
          .where((v) => v['verse_number'] == 1)
          .map((v) => int.parse(v['verse_key'].split(':').first))
          .toSet();
      for (final surah in starts) {
        expect(
            parsed.lines
                .where(
                    (line) => line.isSurahHeader && line.surahNumber == surah)
                .length,
            lessThanOrEqualTo(1),
            reason: 'No duplicate surah banners on page $page');
      }
      final verses = raw['verses'] as List;
      final expectedWords =
          verses.fold<int>(0, (sum, v) => sum + (v['words'] as List).length);
      expect(parsed.lines.expand((line) => line.words).length, expectedWords,
          reason:
              'Words must never be replaced by a decorative header on page $page');
      for (final verse in verses) {
        verseKeys.add(verse['verse_key'] as String);
      }
    }
    expect(verseKeys, hasLength(6236));
    expect(await OfflineQuran.pageForSurah(114), 548);
    expect(await OfflineQuran.pageForSurah(1), 1);
    for (int juz = 1; juz <= 30; juz++) {
      expect(await OfflineQuran.pageForJuz(juz), inInclusiveRange(1, 548));
    }
  });

  test(
      'recitation plan honors ayah range, finite repetitions and pause lengths',
      () {
    final plan = buildQuranPlaybackPlan(
        ayahCount: 7, firstAyah: 3, lastAyah: 4, repeats: 3, pauseSeconds: 2);
    expect(plan.where((step) => !step.isSilence).map((step) => step.ayahIndex),
        [2, 2, 2, 3, 3, 3]);
    expect(
        plan.where((step) => step.isSilence).map((step) => step.silenceSeconds),
        [2, 2, 2, 2]);
    expect(buildQuranPlaybackPlan(ayahCount: 0), isEmpty);
    expect(
        buildQuranPlaybackPlan(ayahCount: 114).where((step) => !step.isSilence),
        hasLength(114));
  });

  test('fresh worship state is zero and complete prayer days grow real streaks',
      () async {
    expect(await NoorStore.getStreak('Salah'), 0);
    expect(await NoorStore.getPrayersList('2026-11-03'), everyElement(isFalse));
    await NoorStore.setPrayersList(
        '2026-11-02', [true, true, true, true, true]);
    await NoorStore.setPrayersList(
        '2026-11-03', [true, true, true, true, true]);
    expect(
        NoorStore.streakForDates(await NoorStore.completedSalahDates(),
            now: DateTime(2026, 11, 3)),
        2);
    await NoorStore.setPrayersList(
        '2026-11-03', [true, false, true, true, true]);
    expect(
        NoorStore.streakForDates(await NoorStore.completedSalahDates(),
            now: DateTime(2026, 11, 3)),
        1);
  });

  group('Android notification channel wiring', () {
    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    const timezone = MethodChannel('flutter_timezone');
    final calls = <MethodCall>[];
    setUp(() {
      calls.clear();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      NoorNotifications.resetForTesting();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(timezone, (call) async => 'Asia/Karachi');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        switch (call.method) {
          case 'initialize':
          case 'requestNotificationsPermission':
          case 'areNotificationsEnabled':
            return true;
          case 'getNotificationAppLaunchDetails':
            return {'notificationLaunchedApp': false};
          case 'canScheduleExactNotifications':
          case 'requestExactAlarmsPermission':
            return false;
          case 'zonedSchedule':
            final specifics =
                (call.arguments as Map)['platformSpecifics'] as Map;
            if (specifics['scheduleMode'] == 'exactAllowWhileIdle') {
              throw PlatformException(code: 'exact_alarms_not_permitted');
            }
            return null;
          default:
            return null;
        }
      });
    });
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      NoorNotifications.resetForTesting();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(timezone, null);
    });

    test('azan has a real raw sound and exact alarms fall back to inexact',
        () async {
      final when = DateTime.now().add(const Duration(hours: 1));
      final count = await NoorNotifications.schedulePlan([
        PlannedNotification(
            id: 10,
            group: 'Salah',
            title: 'Time for Fajr',
            body: 'Prayer time',
            scheduledAt: when,
            prayerName: 'Fajr'),
        PlannedNotification(
            id: 11,
            group: 'Daily Content',
            title: 'Ayat of the Day',
            body: 'Daily reading',
            scheduledAt: when,
            prayerName: 'Ayat of the Day'),
      ]);
      expect(count, 2);
      final scheduled =
          calls.where((call) => call.method == 'zonedSchedule').toList();
      expect(scheduled, hasLength(4));
      final azan = scheduled.first.arguments as Map;
      expect(azan['payload'], 'Salah|Fajr');
      expect(azan['platformSpecifics']['sound'], 'azan');
      expect(azan['platformSpecifics']['channelId'],
          NoorNotifications.azanChannelId);
      expect(
          (scheduled[1].arguments as Map)['platformSpecifics']['scheduleMode'],
          'inexactAllowWhileIdle');
      expect((scheduled.last.arguments as Map)['payload'],
          'Daily Content|Ayat of the Day');
    });

    test('an empty plan cancels pending notifications', () async {
      expect(await NoorNotifications.schedulePlan([]), 0);
      expect(calls.any((call) => call.method == 'cancelAll'), isTrue);
    });

    test(
        'explicit use requests exact alarms after silent initialization only once',
        () async {
      expect(await NoorNotifications.ensureReady(requestPermission: false),
          isTrue);
      expect(
          calls.where((call) => call.method == 'requestExactAlarmsPermission'),
          isEmpty);
      expect(await NoorNotifications.ensureReady(), isTrue);
      expect(await NoorNotifications.ensureReady(), isTrue);
      expect(
          calls.where((call) => call.method == 'requestExactAlarmsPermission'),
          hasLength(1));
    });
  });
}
