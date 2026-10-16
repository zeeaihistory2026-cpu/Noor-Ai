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

  @override
  void initState() {
    super.initState();
    _checkAndAdvance();
  }

  Future<Widget> _resolveNextScreen() async {
    try {
      final auth = FirebaseRestService();
      // Fast check: do we have a stored session token on device? (Takes ~2ms)
      final hasSession = await auth.hasSession();
      if (hasSession) {
        return const NoorTabShell();
      }
      final profile = await auth.currentProfile().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      if (profile != null) {
        return const NoorTabShell();
      }
    } catch (_) {
      // Fall through to onboarding on error.
    }
    return const OnboardingScreen();
  }

  Future<void> _checkAndAdvance() async {
    // Start session verification and a brief 1-second branded splash in parallel
    final sessionFuture = _resolveNextScreen();
    final minSplashFuture = Future.delayed(const Duration(milliseconds: 1000));

    final results = await Future.wait([sessionFuture, minSplashFuture]);
    final nextScreen = results[0] as Widget;

    if (!mounted || _advanced) return;
    _advanced = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  void _advance() async {
    if (!mounted || _advanced) return;
    _advanced = true;
    final nextScreen = await _resolveNextScreen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
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
