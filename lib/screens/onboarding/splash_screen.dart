import 'dart:async';

import 'package:flutter/material.dart';
import '../../app.dart';
import '../../data/firebase_rest_service.dart';
import '../../theme/noor_theme.dart';
import 'onboarding_screen.dart';

/// Page 36 — Splash Screen. Calm premium opening: cream page, the
/// big emerald rounded tile with NOOR in gold, then "AI Companion",
/// "Faith • Guidance • Growth" in grey, and "Loading..." near the
/// bottom. Tapping the tile or the Enter NOOR button navigates on
/// (a real FilledButton/Navigator.push, so taps always fire).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _advanced = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-advance is the primary behaviour; Enter NOOR remains as
    // the immediate / fallback tap target. "Loading..." copy was
    // removed — it contradicted the button (SENIOR_REVIEW P0-6).
    _timer = Timer(const Duration(seconds: 3), _advance);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance() async {
    if (!mounted || _advanced) return;
    _advanced = true;
    // If the user is already logged in, skip onboarding/login and go
    // straight to the main app (with bottom navigation). Otherwise show onboarding.
    Widget next = const OnboardingScreen();
    try {
      final profile = await FirebaseRestService().currentProfile();
      if (profile != null && mounted) {
        next = const NoorTabShell();
      }
    } catch (_) {
      // Fall through to onboarding on error.
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Emerald tile cropped from Page 36 of the design
              // (assets/images/splash_motif.png); the cream gradient
              // below is only a fallback while that file loads.
              ClipRRect(
                borderRadius: BorderRadius.circular(NoorRadius.splashTile),
                child: Image.asset(
                  NoorAssets.splashMotif,
                  width: 190, cacheWidth: 570,
                  height: 190,
                  // Whole NOOR tile inside the box (Phase 11b):
                  // cover cropped the tile's rounded corners.
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      color: NoorColors.emeraldDark,
                      borderRadius:
                          BorderRadius.circular(NoorRadius.splashTile),
                    ),
                    child: Center(
                      child: Text('NOOR',
                          style: NoorType.tabular(NoorType.display.copyWith(fontSize: 36, color: NoorColors.gold,
                              letterSpacing: 2))),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Text('AI Companion',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text('Faith • Guidance • Growth',
                  style: NoorType.body.copyWith(color: NoorColors.mutedDark)),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                height: NoorSizes.buttonHeight,
                child: FilledButton(
                  onPressed: _advance,
                  style: FilledButton.styleFrom(
                    backgroundColor: NoorColors.emeraldDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(NoorRadius.button)),
                    // No textStyle override — it would drop the
                    // theme's label font (Manrope) from the button.
                  ),
                  child: Text('Enter NOOR',
                      style: NoorType.cardTitle.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 46),
            ],
          ),
        ),
      ),
    );
  }
}
