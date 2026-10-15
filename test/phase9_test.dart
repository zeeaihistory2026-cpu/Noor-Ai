// Phase 9 tests: auth validation + AI local fallback honesty.
// These exercise pure/service logic only — no live backend, no
// network, no real audio device is claimed or needed.
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/ai_service.dart';
import 'package:noor_ai_companion/data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 9 — AuthValidator', () {
    test('rejects bad email and short password, accepts valid form', () {
      expect(AuthValidator.validateEmail('not-an-email'), isNotNull);
      expect(AuthValidator.validateEmail('a@b.co'), isNull);
      expect(AuthValidator.validatePassword('short'), isNotNull);
      expect(AuthValidator.validatePassword('longenough'), isNull);
      expect(
        AuthValidator.validateRegister(
            name: 'Ab', email: 'a@b.co', password: 'longenough'),
        isNull,
      );
      expect(
        AuthValidator.validateRegister(
            name: '', email: 'bad', password: 'short'),
        isNotNull,
      );
    });

    test('LocalAuthService registers then logs in with same password',
        () async {
      SharedPreferences.setMockInitialValues({});
      final auth = LocalAuthService();
      final reg = await auth.register(
          name: 'Test User',
          email: 'test@example.com',
          password: 'password123');
      expect(reg.ok, isTrue);
      expect(reg.isLocalOnly, isTrue);
      final bad = await auth.login(
          email: 'test@example.com', password: 'wrongpassword');
      expect(bad.ok, isFalse);
      final good =
          await auth.login(email: 'test@example.com', password: 'password123');
      expect(good.ok, isTrue);
      expect(good.profile?.name, 'Test User');
    });
  });

  group('Phase 9 — AI fallback honesty', () {
    test('NoorAi falls back to labelled sample answers (not live)', () async {
      final ai = NoorAi();
      expect(ai.isLive, isFalse);
      final answer = await ai.ask('What does Islam say about patience?');
      expect(answer.isSample, isTrue);
      expect(answer.text, isNotEmpty);
      expect(answer.sourceRefs, isNotEmpty);
    });

    test('HttpAiService stub throws until a backend is provided', () async {
      expect(
        () => const HttpAiService().ask('anything'),
        throwsUnimplementedError,
      );
    });
  });
}
