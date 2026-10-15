import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'goal_selection_screen.dart';

/// Page 37 — Onboarding. One focused screen that explains the app
/// promise: a large pale emerald circle marked QURAN, then
/// "Learn. Practice. Grow." with the one-line promise, a Skip link
/// top-right and a single Continue pill at the bottom.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _next(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const GoalSelectionScreen()));

  @override
  Widget build(BuildContext context) {
    return NoorScaffold(
      bottom:
          NoorPrimaryButton(label: 'Continue', onPressed: () => _next(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _next(context),
                style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                child: Text('Skip',
                    style: NoorType.body.copyWith(color: NoorColors.emeraldDark)),
              ),
            ),
            const Spacer(),
            // Pale circle hero from Page 37 (TODO: swap for the exact
            // exported artwork; shape/colour follow the PNG).
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  color: NoorColors.emeraldSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: NoorColors.sand, width: 2),
                  boxShadow: NoorShadows.card),
              alignment: Alignment.center,
              child: Text('QURAN',
                  style: NoorType.display.copyWith(color: NoorColors.emeraldDark,
                      letterSpacing: 1.5)),
            ),
            const SizedBox(height: 56),
            const Text(SampleData.onboardingTitle,
                textAlign: TextAlign.center,
                style: NoorType.display),
            const SizedBox(height: 16),
            Text(SampleData.onboardingBody,
                textAlign: TextAlign.center,
                style: NoorType.body.copyWith(color: NoorColors.mutedDark, height: 1.5)),
            const SizedBox(height: 28),
            // Step indicator for the setup flow (37 -> 38 -> 39 -> 40).
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: i == 0 ? 22 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                      color: i == 0 ? NoorColors.emeraldDark : NoorColors.sand,
                      borderRadius: BorderRadius.circular(4)),
                ),
            ]),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
