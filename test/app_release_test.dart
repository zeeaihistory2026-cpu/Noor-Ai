import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_ai_companion/data/auth_service.dart';
import 'package:noor_ai_companion/data/daily_content_actions.dart';
import 'package:noor_ai_companion/data/daily_content_service.dart';
import 'package:noor_ai_companion/data/firebase_rest_service.dart';
import 'package:noor_ai_companion/data/location_service.dart';
import 'package:noor_ai_companion/data/noor_store.dart';
import 'package:noor_ai_companion/data/notification_plan.dart';
import 'package:noor_ai_companion/data/prayer_service.dart';
import 'package:noor_ai_companion/data/session_store.dart';
import 'package:noor_ai_companion/data/share_content.dart';
import 'package:noor_ai_companion/screens/auth/create_account_screen.dart';
import 'package:noor_ai_companion/screens/auth/login_screen.dart';
import 'package:noor_ai_companion/screens/library/share_card_studio_screen.dart';
import 'package:noor_ai_companion/screens/onboarding/splash_screen.dart';

class _Auth implements AuthService, PasswordResetService {
  int calls = 0;
  String? resetEmail;
  Completer<AuthResult>? pending;
  @override
  Future<AuthResult> login(
      {required String email, required String password}) async {
    calls++;
    return pending?.future ??
        const AuthResult.failure('Incorrect email or password.');
  }

  @override
  Future<AuthResult> register(
          {required String name,
          required String email,
          required String password}) =>
      login(email: email, password: password);
  @override
  Future<String?> sendPasswordReset(String email) async {
    resetEmail = email;
    return null;
  }

  @override
  Future<bool> hasSession() async => false;
  @override
  Future<AuthProfile?> currentProfile() async => null;
  @override
  Future<void> logout() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PrayerService.clearCache();
  });

  test(
      'signup stays successful when profile services fail after account creation',
      () async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('accounts:signUp')) {
        return http.Response(
            jsonEncode({
              'idToken': 'test-token',
              'localId': 'new-user',
              'refreshToken': 'test-refresh'
            }),
            200);
      }
      throw http.ClientException('profile service offline');
    });
    final result = await FirebaseRestService(client: client).register(
        name: 'Ayesha', email: 'ayesha@example.test', password: 'password123');
    expect(result.ok, isTrue);
    expect(result.isLocalOnly, isFalse);
    expect(await SessionStore.read('fb.uid'), 'new-user');
    expect((await SharedPreferences.getInstance()).getString('fb.idToken'),
        isNull);
  });

  test('legacy credentials migrate to secure storage and are erased on logout',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'fb.uid', FirebaseRestService.encryptToken('old-user'));
    await prefs.setString(
        'fb.idToken', FirebaseRestService.encryptToken('old-token'));
    expect(await FirebaseRestService().hasSession(), isTrue);
    expect(prefs.getString('fb.uid'), isNull);
    await FirebaseRestService().logout();
    expect(await SessionStore.read('fb.uid'), isNull);
    expect(await FirebaseRestService().hasSession(), isFalse);
  });

  test(
      'password reset sends Firebase reset request and hides unknown-email status',
      () async {
    final auth = FirebaseRestService(client: MockClient((request) async {
      expect(request.url.path, endsWith('accounts:sendOobCode'));
      expect(jsonDecode(request.body),
          {'requestType': 'PASSWORD_RESET', 'email': 'person@example.test'});
      return http.Response('{"error":{"message":"EMAIL_NOT_FOUND"}}', 400);
    }));
    expect(await auth.sendPasswordReset(' person@example.test '), isNull);
  });

  test(
      'daily Dua and Hadith bookmarks persist independently with original citations',
      () async {
    final dua = DailyContentService.getDua();
    final hadith = DailyContentService.getHadith();
    expect(await DailyBookmarks.toggle(dua, 'dua'), isTrue);
    expect(await DailyBookmarks.toggle(hadith, 'hadith'), isTrue);
    expect(await DailyBookmarks.isSaved(dua, 'dua'), isTrue);
    expect(await DailyBookmarks.toggle(dua, 'dua'), isFalse);
    expect(await DailyBookmarks.isSaved(hadith, 'hadith'), isTrue);
    final card = ShareContentItem.fromDaily(hadith, ShareContentType.hadith);
    expect(card.reference, hadith.reference);
    expect(card.arabicText, hadith.arabic);
  });

  test('offline calculation respects Hanafi Asr and location timezone', () {
    final date = DateTime(2026, 11, 2);
    final hanafi = PrayerService.calculateOffline(
        location: LocationModel.defaultLocation, date: date, school: 1);
    final standard = PrayerService.calculateOffline(
        location: LocationModel.defaultLocation, date: date, school: 0);
    expect(hanafi.timings['Asr']!.isAfter(standard.timings['Asr']!), isTrue);
    expect(hanafi.timings['Fajr']!.timeZoneOffset, const Duration(hours: 5));
    expect(hanafi.timings['Fajr']!.hour, inInclusiveRange(4, 6));
    final next = hanafi.nextPrayer(now: DateTime.utc(2026, 11, 2, 0));
    expect(next.time.isAfter(DateTime.utc(2026, 11, 2, 0)), isTrue);
  });

  test(
      'prayer API gets chosen method and Asr school; offline plan covers seven days',
      () async {
    await NoorStore.setCalculationMethod(3);
    await NoorStore.setMadhhab('Hanafi');
    final service = PrayerService(client: MockClient((request) async {
      expect(request.url.queryParameters['method'], '3');
      expect(request.url.queryParameters['school'], '1');
      return http.Response('unavailable', 503);
    }));
    final day = await service.fetchForLocationDate(
        LocationModel.defaultLocation, DateTime(2026, 11, 2));
    expect(day.source, PrayerSource.calculated);
    final days = [
      for (int i = 0; i < 7; i++)
        PrayerService.calculateOffline(
            location: LocationModel.defaultLocation,
            date: DateTime(2026, 11, 2 + i))
    ];
    final plan = NotificationPlan.buildUpcomingPlan(
        days: days, toggles: {}, now: DateTime.utc(2026, 11, 1, 19));
    final fajr = plan.where((e) => e.prayerName == 'Fajr').toList();
    expect(fajr, hasLength(14));
    expect(fajr.map((e) => e.id).toSet(), hasLength(14));
    expect(
        plan.every(
            (e) => !e.scheduledAt.isBefore(DateTime.utc(2026, 11, 1, 19))),
        isTrue);
  });

  testWidgets('new install and stale display name route to login',
      (tester) async {
    await NoorStore.setUserName('Previous user');
    await tester
        .pumpWidget(MaterialApp(home: SplashScreen(authService: _Auth())));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'invalid signup validates locally and fits small screens at 200% text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = _Auth();
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!),
        home: CreateAccountScreen(authService: auth)));
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(auth.calls, 0);
    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login disables alternate actions while request is pending',
      (tester) async {
    final auth = _Auth()..pending = Completer<AuthResult>();
    await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: auth)));
    await tester.enterText(
        find.byType(TextFormField).at(0), 'person@example.test');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(auth.calls, 1);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    for (final button
        in tester.widgetList<TextButton>(find.byType(TextButton))) {
      expect(button.onPressed, isNull);
    }
    auth.pending!
        .complete(const AuthResult.failure('Incorrect email or password.'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('reset password works without filling the password field',
      (tester) async {
    final auth = _Auth();
    await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: auth)));
    await tester.enterText(
        find.byType(TextFormField).first, 'person@example.test');
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(auth.resetEmail, 'person@example.test');
    expect(find.textContaining('a reset link is on its way'), findsOneWidget);
  });

  testWidgets(
      'Studio preserves selected daily item instead of substituting default',
      (tester) async {
    final item = ShareContentItem.fromDaily(
        DailyContentService.getDua(), ShareContentType.dua);
    await tester.pumpWidget(
        MaterialApp(home: ShareCardStudioScreen(initialItem: item)));
    expect(find.text(item.reference), findsWidgets);
    expect(find.text(item.text), findsWidgets);
  });
}
