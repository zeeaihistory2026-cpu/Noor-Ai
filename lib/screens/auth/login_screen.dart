import 'package:flutter/material.dart';
import '../../app.dart';
import '../../data/auth_service.dart';
import '../../data/firebase_rest_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'create_account_screen.dart';

/// Page 42 — Login. "Welcome back / Continue your Quran and worship
/// journey." Email + Password pill inputs, a right-aligned "Forgot
/// password?" link, the emerald Login pill, and a "New to NOOR?
/// Create account" link that swaps back to Page 41.
/// Phase 9: wired to AuthService (LocalAuthService) — real
/// validation against the local on-device account only. No backend
/// exists yet, so "Forgot password?" honestly says so instead of
/// pretending to send a reset email.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = FirebaseRestService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  String? _emailError;
  String? _passwordError;
  bool _showPassword = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    setState(() {
      _emailError = AuthValidator.validateEmail(_email.text);
      _passwordError =
          _password.text.isEmpty ? 'Please enter your password.' : null;
    });
    if (_emailError != null || _passwordError != null) {
      setState(() => _busy = false);
      return;
    }
    final result =
        await _auth.login(email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!result.ok) {
      setState(() => _error = result.error);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NoorTabShell()), (_) => false);
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Password reset needs the account backend (not connected yet).')));
  }

  @override
  Widget build(BuildContext context) {
    return NoorScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
        children: [
          const Text('Welcome back', style: NoorType.screenTitle),
          const SizedBox(height: 10),
          const Text('Continue your Quran and worship journey.',
              style: NoorType.secondary),
          const SizedBox(height: 40),
          NoorFormField(
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              controller: _email,
              errorText: _emailError),
          const SizedBox(height: 22),
          NoorFormField(
              label: 'Password',
              hint: 'At least 8 characters',
              obscure: !_showPassword,
              controller: _password,
              errorText: _passwordError,
              suffixIcon: IconButton(
                icon: Icon(_showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                tooltip: _showPassword ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _showPassword = !_showPassword),
              )),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!,
                style: NoorType.secondary.copyWith(color: NoorColors.error)),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
              child: Text('Forgot password?',
                  style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 58,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: NoorColors.emeraldDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29)),
              ),
              child: Text(_busy ? 'Please wait…' : 'Login',
                  style: NoorType.cardTitle.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 22),
          // Phase 13: wrap at large OS text sizes instead of
          // overflowing the footer row (200% scale proof).
          Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
            Text('New to NOOR?  ',
                style: NoorType.secondary.copyWith(color: NoorColors.iconMuted)),
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const CreateAccountScreen())),
              style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
              child: Text('Create account',
                  style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
            ),
          ]),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const NoorTabShell()),
                  (_) => false),
              style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
              child: Text('Continue as Guest',
                  style: NoorType.secondary.copyWith(
                      color: NoorColors.mutedDark,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
