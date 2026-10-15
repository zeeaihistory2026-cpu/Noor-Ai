import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/share_content.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';
import 'package:noor_ai_companion/widgets/noor_share_card.dart';

/// Phase 14 — dedicated capture for the two auto-filled streak
/// cards (Namaz 12 / Zikr 8, the app's canonical streak values).
/// Kept beside previews_test.dart so the main 43-page golden set
/// stays aligned with the user's 42 design pages.
Future<void> _loadCaptureFonts() async {
  final sdk = Platform.environment['FLUTTER_ROOT'] ??
      '${Platform.environment['HOME']}/workspace/flutter-sdk';
  final fontsDir = '$sdk/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, String file) async {
    final bytes = await File('$fontsDir/$file').readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  await load('Roboto', 'Roboto-Regular.ttf');
  await load('Roboto', 'Roboto-Bold.ttf');
  await load('MaterialIcons', 'MaterialIcons-Regular.otf');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadCaptureFonts();
  });
  testWidgets('preview share streak cards', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final cards = ShareContent.streakCards();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
      home: Scaffold(
        backgroundColor: NoorColors.cream,
        body: Center(
          child: RepaintBoundary(
            child: Container(
              color: NoorColors.cream,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 380,
                    height: 430,
                    child: NoorShareCard(streak: cards[0]),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 380,
                    height: 430,
                    child: NoorShareCard(streak: cards[1], style: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(find.byType(RepaintBoundary).last,
        matchesGoldenFile('../previews/share_streak_cards14.png'));
    expect(tester.takeException(), isNull);
  });
}
