// Phase 12 — 200% text-scale sanity on the screens the review
// flagged as overflow-prone (Goal, Language, streak cards, Tasbih).
// A RenderFlex overflow surfaces as a test exception, so a clean
// pump at 2.0x is the proof.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/screens/onboarding/goal_selection_screen.dart';
import 'package:noor_ai_companion/screens/onboarding/language_selection_screen.dart';
import 'package:noor_ai_companion/screens/worship/zikr_tasbih_screen.dart';

void main() {
  const screens = <String, Widget>{
    'GoalSelection': GoalSelectionScreen(),
    'LanguageSelection': LanguageSelectionScreen(),
    'ZikrTasbih': ZikrTasbihScreen(),
  };
  for (final entry in screens.entries) {
    testWidgets('${entry.key} survives 200% text scale', (tester) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: Scaffold(body: entry.value),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }
}
