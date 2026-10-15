import 'package:flutter/material.dart';
import '../../app.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'goal_selection_screen.dart';

/// Page 37 — Onboarding. Explains the app promise:
/// "Learn. Practice. Grow." with setup personalization and an immediate
/// "Explore as Guest" option so new users are never blocked from prayer times.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _next(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const GoalSelectionScreen()));

  void _skipToApp(BuildContext context) => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => const NoorTabShell()));

  @override
  Widget build(BuildContext context) {
    return NoorScaffold(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NoorPrimaryButton(label: 'Get Started', onPressed: () => _next(context)),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextButton(
              onPressed: () => _skipToApp(context),
              style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
              child: Text(
                'Explore as Guest',
                style: NoorType.secondary.copyWith(
                  color: NoorColors.emeraldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _skipToApp(context),
                style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
                child: Text('Skip',
                    style: NoorType.body.copyWith(
                        color: NoorColors.emeraldDark,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const Spacer(),
            // Illustrated circle motif with Quran iconography
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [NoorColors.emeraldSoft, NoorColors.cream],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: NoorColors.gold.withValues(alpha: 0.5), width: 2),
                  boxShadow: NoorShadows.hero),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: NoorColors.emeraldDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_stories,
                        color: NoorColors.gold, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text('NOOR AI',
                      style: NoorType.display.copyWith(
                          fontSize: 24,
                          color: NoorColors.emeraldDark,
                          letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text('Faith • Guidance • Growth',
                      style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(SampleData.onboardingTitle,
                textAlign: TextAlign.center,
                style: NoorType.display),
            const SizedBox(height: 14),
            Text(SampleData.onboardingBody,
                textAlign: TextAlign.center,
                style: NoorType.body.copyWith(
                    color: NoorColors.mutedDark, height: 1.5)),
            const SizedBox(height: 24),
            // Step indicator for the setup flow (37 -> 38 -> 39 -> 40).
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: i == 0 ? 24 : 8,
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
