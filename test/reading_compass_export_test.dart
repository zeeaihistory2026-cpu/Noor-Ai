import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_ai_companion/data/compass_service.dart';
import 'package:noor_ai_companion/data/noor_store.dart';
import 'package:noor_ai_companion/data/share_content.dart';
import 'package:noor_ai_companion/data/share_export_service.dart';
import 'package:noor_ai_companion/widgets/noor_share_card.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('reading position starts empty and persists the selected surah and ayah',
      () async {
    expect(await NoorStore.getReadingPosition(), isNull);
    await NoorStore.setReadingPosition(2, 255);
    expect(await NoorStore.getReadingPosition(), (2, 255));
    NoorStore.resetForTesting();
    expect(await NoorStore.getReadingPosition(), (2, 255));
  });

  test('compass alignment handles north wraparound, accuracy and phone tilt',
      () {
    expect(const CompassReading(359, 0, 0, 3).offsetTo(1), 2);
    expect(const CompassReading(1, 0, 0, 3).offsetTo(359), -2);
    expect(const CompassReading(359, 0, 0, 3).alignedWith(1), isTrue);
    expect(const CompassReading(359, 0, 0, 0).alignedWith(1), isFalse);
    expect(const CompassReading(359, 50, 0, 3).alignedWith(1), isFalse);
    expect(const CompassReading(90, 0, 0, 3).alignedWith(1), isFalse);
  });

  for (final format in [
    ShareFormats.instagramPost,
    ShareFormats.storyReel,
    ShareFormats.facebookPost,
    ShareFormats.square
  ]) {
    testWidgets('${format.id} card exports at its stated PNG dimensions',
        (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Center(
        child: SizedBox(
            width: 250,
            child: RepaintBoundary(
                key: key,
                child: NoorShareCard(
                  aspect: format.aspectRatio,
                  item: const ShareContentItem(
                      id: 'export',
                      type: ShareContentType.ayah,
                      title: 'Daily Ayah',
                      text: 'Seek help through patience and prayer.',
                      arabicText: 'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
                      reference: 'Quran 2:45',
                      tags: []),
                ))),
      ))));
      await tester.pump();
      final capture = ShareExportService.capturePng(key, format: format);
      await tester.pump();
      final bytes = await tester.runAsync(() => capture);
      expect(bytes, isNotNull);
      final header = ByteData.sublistView(bytes!);
      expect(header.getUint32(16), format.exportWidth);
      expect(header.getUint32(20), format.exportHeight);
      expect(tester.takeException(), isNull);
    });
  }
}
