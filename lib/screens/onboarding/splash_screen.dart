import 'dart:async';
import 'package:flutter/material.dart';
import '../../app.dart';
import '../../data/auth_service.dart';
import '../../data/firebase_rest_service.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/muslim_go_mark.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.authService});
  final AuthService? authService;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();
  Timer? _timer;
  late final Future<bool> _session;
  @override
  void initState() {
    super.initState();
    _session = _canEnter();
    _timer = Timer(const Duration(milliseconds: 1200), _advance);
  }

  Future<bool> _canEnter() async {
    try {
      return await (widget.authService ?? FirebaseRestService())
              .hasSession()
              .timeout(const Duration(seconds: 2)) ||
          await NoorStore.hasGuestSession();
    } catch (_) {
      return false;
    }
  }

  Future<void> _advance() async {
    final enter = await _session;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) =>
          enter ? const NoorTabShell() : const LoginScreen(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.emeraldDark,
        body: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: (constraints.maxHeight - 56)
                                  .clamp(0, double.infinity)),
                          child: Center(
                            child: FadeTransition(
                                opacity: MediaQuery.disableAnimationsOf(context)
                                    ? const AlwaysStoppedAnimation(1)
                                    : _animation,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const MuslimGoMark(size: 148),
                                      const SizedBox(height: 20),
                                      Text('MuslimGo',
                                          style: NoorType.display.copyWith(
                                              color: Colors.white,
                                              fontSize: 38,
                                              letterSpacing: -1)),
                                      const SizedBox(height: 12),
                                      Text('AI Companion',
                                          style: NoorType.section.copyWith(
                                              color: NoorColors.goldSoft,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 30),
                                      Text('Faith • Guidance • Growth',
                                          textAlign: TextAlign.center,
                                          style: NoorType.secondary.copyWith(
                                              color:
                                                  NoorColors.onEmeraldMuted)),
                                      const SizedBox(height: 40),
                                      const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: NoorColors.goldSoft,
                                              semanticsLabel:
                                                  'Opening MuslimGo')),
                                    ])),
                          )),
                    ))),
      );
}
