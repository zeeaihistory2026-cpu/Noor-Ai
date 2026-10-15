// NOOR smoke test: app boots to the Splash screen (Page 36)
// and the Enter NOOR button is present. Phase 7 first-run proof.
import 'package:flutter_test/flutter_test.dart';

import 'package:noor_ai_companion/app.dart';

void main() {
  testWidgets('App boots to Splash with Enter NOOR',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NoorApp());
    await tester.pump();

    expect(find.text('AI Companion'), findsWidgets);
    expect(find.text('Enter NOOR'), findsOneWidget);
  });
}
