import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/location_service.dart';
import 'package:noor_ai_companion/data/prayer_service.dart';

void main() {
  final fixtures = jsonDecode(
      File('test/fixtures/prayer_reference_2026_11_04.json')
          .readAsStringSync()) as List;
  for (final row in fixtures.cast<Map>()) {
    test(
        '${row['city']} school ${row['school']} offline times agree with AlAdhan reference within 3 minutes',
        () {
      final day = PrayerDay.fromAlAdhanJson(
          Map<String, dynamic>.from(row['response'] as Map),
          source: PrayerSource.live);
      final offline = PrayerService.calculateOffline(
          location: LocationModel(
              city: row['city'] as String,
              country: 'Pakistan',
              latitude: (row['latitude'] as num).toDouble(),
              longitude: (row['longitude'] as num).toDouble(),
              timeZone: 'Asia/Karachi'),
          date: DateTime(2026, 11, 4),
          method: row['method'] as int,
          school: row['school'] as int);
      expect(day.timeZone, 'Asia/Karachi');
      for (final prayer in PrayerService.prayerOrder) {
        expect(
            offline.timings[prayer]!
                .difference(day.timings[prayer]!)
                .inSeconds
                .abs(),
            lessThanOrEqualTo(180),
            reason:
                '$prayer: offline ${offline.timings[prayer]}, API ${day.timings[prayer]}');
      }
    });
  }
}
