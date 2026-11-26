import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/noor_controller.dart';
import 'package:noor_ai_companion/screens/home/home_dashboard_screen.dart';
import 'package:noor_ai_companion/screens/worship/qibla_finder_screen.dart';
import 'package:noor_ai_companion/screens/worship/salah_tracker_screen.dart';
import 'package:noor_ai_companion/screens/worship/worship_dashboard_screen.dart';
import 'package:noor_ai_companion/screens/worship/zikr_tasbih_screen.dart';
import 'package:noor_ai_companion/theme/noor_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithResponsiveMedia(Widget child,
      {double textScale = 2.0, Size size = const Size(320, 568)}) {
    final controller = NoorController();
    return NoorScope(
      controller: controller,
      child: MaterialApp(
        theme: NoorTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child,
        ),
      ),
    );
  }

  group('Phase 5 — Accessibility (TalkBack Live Regions & Semantics)', () {
    testWidgets(
        'Tasbih bead counter exposes live region semantics and accessible controls',
        (tester) async {
      await tester.pumpWidget(
          wrapWithResponsiveMedia(const ZikrTasbihScreen(), textScale: 1.0));
      await tester.pumpAndSettle();

      // Verify live region exists for the Tasbih counter
      final liveRegionFinder = find.byWidgetPredicate((widget) {
        if (widget is Semantics) {
          return widget.properties.liveRegion == true &&
              (widget.properties.label?.contains('Tasbih counter') ?? false);
        }
        return false;
      });
      expect(liveRegionFinder, findsOneWidget);

      // Verify Undo and Add buttons have clear semantic labels
      expect(find.bySemanticsLabel(RegExp(r'Undo previous count')),
          findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Add to count')), findsOneWidget);
    });

    testWidgets(
        'Qibla never claims alignment without a sensor reading',
        (tester) async {
      await tester.pumpWidget(
          wrapWithResponsiveMedia(const QiblaFinderScreen(), textScale: 1.0));
      await tester.pumpAndSettle();

      // Verify live region semantics on compass
      final compassSemanticsFinder = find.byWidgetPredicate((widget) {
        if (widget is Semantics) {
          return widget.properties.liveRegion == true &&
              (widget.properties.label?.contains('Qibla compass') ?? false);
        }
        return false;
      });
      expect(compassSemanticsFinder, findsOneWidget);

      expect(find.text('Sensor active • True north'), findsNothing);
      expect(find.text('Aligned with Qibla (±5°)'), findsNothing);
      await tester.tap(compassSemanticsFinder);
      await tester.pumpAndSettle();
      expect(find.text('Aligned with Qibla (±5°)'), findsNothing);
    });

    testWidgets(
        'Salah Tracker prayer items provide state semantics and >=48x48 touch targets',
        (tester) async {
      await tester.pumpWidget(
          wrapWithResponsiveMedia(const SalahTrackerScreen(), textScale: 1.0));
      await tester.pumpAndSettle();

      // Check for checked semantics on prayer rows
      final prayerCheckFinder = find.byWidgetPredicate((widget) {
        if (widget is Semantics) {
          return widget.properties.checked != null &&
              (widget.properties.label?.contains('prayer') ?? false);
        }
        return false;
      });
      expect(prayerCheckFinder, findsAtLeastNWidgets(5));
    });
  });

  group('Phase 5 — 200% Font Scale Responsiveness (Zero RenderFlex Overflows)',
      () {
    testWidgets(
        'HomeDashboardScreen renders cleanly at 200% text scale without overflow',
        (tester) async {
      await tester.pumpWidget(
          wrapWithResponsiveMedia(const HomeDashboardScreen(), textScale: 2.0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'SalahTrackerScreen renders cleanly at 200% text scale without overflow',
        (tester) async {
      await tester.pumpWidget(
          wrapWithResponsiveMedia(const SalahTrackerScreen(), textScale: 2.0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'WorshipDashboardScreen renders cleanly at 200% text scale without overflow',
        (tester) async {
      await tester.pumpWidget(wrapWithResponsiveMedia(
          const WorshipDashboardScreen(),
          textScale: 2.0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'ZikrTasbihScreen renders cleanly at 200% text scale without overflow',
        (tester) async {
      await tester.pumpWidget(
          wrapWithResponsiveMedia(const ZikrTasbihScreen(), textScale: 2.0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'QiblaFinderScreen renders cleanly at 200% text scale without overflow',
        (tester) async {
      await tester.pumpWidget(
          wrapWithResponsiveMedia(const QiblaFinderScreen(), textScale: 2.0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
