import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/screens/auth/create_account_screen.dart';
import 'package:noor_ai_companion/screens/auth/login_screen.dart';
import 'package:noor_ai_companion/screens/home/settings_screen.dart';
import 'package:noor_ai_companion/screens/library/saved_content_screen.dart';
import 'package:noor_ai_companion/screens/worship/reminder_center_screen.dart';
import 'package:noor_ai_companion/screens/ai/ai_chat_screen.dart';

/// Phase 13 — 200% OS text-scale proof on six more screens (the
/// Phase 12 pass covered Goal/Language/Tasbih). At 2.0x the layout
/// must scroll/wrap, never throw a RenderFlex overflow.
void main() {
  final screens = <String, Widget>{
    'Create Account 41': const CreateAccountScreen(),
    'Login 42': const LoginScreen(),
    'Settings 13': const SettingsScreen(),
    'Saved 33': const SavedContentScreen(),
    'Reminders 31': const ReminderCenterScreen(),
    'AI Chat 23': const AiChatScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} survives 200% text scale', (tester) async {
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: entry.value,
      ));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull,
          reason: '${entry.key} overflowed at 200% text scale');
    });
  }
}
