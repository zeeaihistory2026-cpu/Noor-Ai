import 'dart:async';
import 'package:flutter/material.dart';
import '../../app.dart';
import '../../data/firebase_rest_service.dart';
import '../../theme/noor_theme.dart';

/// Page 36 — Animated Splash Screen.
/// Clean, elegant opening: cream page, glowing emerald Islamic tile with
/// gold NOOR typography and star emblem, brand titles, and animated
/// loading pulse. Automatically transitions directly into the app shell.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _transitionTimer;
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    // Begin check and scheduled transition
    _checkAndAdvance();
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<Widget> _resolveNextScreen() async {
    try {
      final auth = FirebaseRestService();
      final hasSession = await auth.hasSession().timeout(
            const Duration(milliseconds: 600),
            onTimeout: () => false,
          );
      if (hasSession) {
        return const NoorTabShell();
      }
      final profile = await auth.currentProfile().timeout(
            const Duration(milliseconds: 600),
            onTimeout: () => null,
          );
      if (profile != null) {
        return const NoorTabShell();
      }
    } catch (_) {
      // Fall through to app start
    }
    return const NoorTabShell();
  }

  Future<void> _checkAndAdvance() async {
    final nextScreenFuture = _resolveNextScreen();
    // Allow the logo animation to be displayed for 1.8 seconds before starting
    _transitionTimer = Timer(const Duration(milliseconds: 1800), () async {
      final nextScreen = await nextScreenFuture;
      _advanceTo(nextScreen);
    });
  }

  void _advanceTo(Widget nextScreen) {
    if (!mounted || _advanced) return;
    _advanced = true;
    _transitionTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: nextScreen,
        ),
      ),
    );
  }

  void _advance() async {
    if (!mounted || _advanced) return;
    final next = await _resolveNextScreen();
    _advanceTo(next);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _advance,
      child: Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    // Glowing Emerald Islamic Medallion Tile
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            NoorColors.emeraldDark,
                            NoorColors.emeraldMid,
                            NoorColors.inkDeep,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: NoorColors.gold.withValues(alpha: 0.65),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NoorColors.emeraldDark.withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: NoorColors.gold.withValues(alpha: 0.25),
                            blurRadius: 16,
                            spreadRadius: -2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Subtle geometric Islamic star motif
                          Opacity(
                            opacity: 0.15,
                            child: Transform.rotate(
                              angle: 0.785398, // 45 deg
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: NoorColors.gold, width: 1.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.auto_stories_rounded,
                                color: NoorColors.gold,
                                size: 36,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'NOOR',
                                style: NoorType.display.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: NoorColors.gold,
                                  letterSpacing: 4,
                                ),
                              ),
                              Text(
                                'نُور',
                                style: NoorType.arabic(
                                  size: 13,
                                  color: NoorColors.gold.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'NOOR',
                      style: NoorType.display.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: NoorColors.emeraldDark,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AI Companion',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: NoorColors.ink,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: NoorColors.emeraldSoft.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Faith • Guidance • Growth',
                        style: NoorType.meta.copyWith(
                          color: NoorColors.emeraldDark,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(flex: 4),
                    // Elegant pulsing gold indicator dots
                    SizedBox(
                      height: 32,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 3; i++)
                            _PulseDot(index: i, controller: _controller),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  final int index;
  final AnimationController controller;
  const _PulseDot({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = (controller.value + (index * 0.25)) % 1.0;
        final scale = 0.8 + 0.4 * (1.0 - (t - 0.5).abs() * 2);
        final opacity = 0.4 + 0.6 * (1.0 - (t - 0.5).abs() * 2);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8 * scale,
          height: 8 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: NoorColors.gold.withValues(alpha: opacity.clamp(0.2, 1.0)),
          ),
        );
      },
    );
  }
}
