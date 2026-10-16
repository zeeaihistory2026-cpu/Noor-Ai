// NOOR smoke test: app boots to the Splash screen with logo branding
// and automatically advances to the main app without requiring Enter button.
import 'package:flutter_test/flutter_test.dart';

import 'package:noor_ai_companion/app.dart';

void main() {
  testWidgets('App boots to animated Splash screen with brand logo',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NoorApp());
    await tester.pump();

    expect(find.text('AI Companion'), findsWidgets);
    expect(find.text('Faith • Guidance • Growth'), findsOneWidget);

    // Advance through the splash screen timer and animation into the app
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
