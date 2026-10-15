import 'package:flutter/material.dart';
import '../../app.dart';
import '../../data/auth_service.dart';
import '../../data/firebase_rest_service.dart';
import '../../data/firebase_rest_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'login_screen.dart';

/// Page 41 — Create Account. "Create your account / Begin your
/// personalized Deen journey." Name, Email and Password fields in
/// white pill inputs, the emerald Create Account pill, and an
/// "Already have an account? Login" link that swaps to Page 42.
/// Phase 9: wired to AuthService (LocalAuthService). Validation is
/// real; the account is LOCAL-ONLY (no backend yet) and only a
/// placeholder hash is stored — never the plain password.
/// Submitting enters the 5-tab shell, as drawn.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthService _auth = FirebaseRestService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _showPassword = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
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
      _nameError = AuthValidator.validateName(_name.text);
      _emailError = AuthValidator.validateEmail(_email.text);
      _passwordError = AuthValidator.validatePassword(_password.text);
    });
    if (_nameError != null || _emailError != null || _passwordError != null) {
      setState(() => _busy = false);
      return;
    }
    final result = await _auth.register(
        name: _name.text, email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!result.ok) {
      setState(() => _error = result.error);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NoorTabShell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return NoorScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
        children: [
          const Text('Create your account', style: NoorType.screenTitle),
          const SizedBox(height: 10),
          const Text('Begin your personalized Deen journey.',
              style: NoorType.secondary),
          const SizedBox(height: 40),
          NoorFormField(
              label: 'Name',
              hint: 'Your name',
              controller: _name,
              errorText: _nameError),
          const SizedBox(height: 22),
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
            const SizedBox(height: 16),
            Text(_error!,
                style: NoorType.secondary.copyWith(color: NoorColors.error)),
          ],
          const SizedBox(height: 36),
          SizedBox(
            height: 58,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: NoorColors.emeraldDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29)),
              ),
              child: Text(_busy ? 'Please wait…' : 'Create Account',
                  style: NoorType.cardTitle.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 22),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Already have an account?  ',
                style: NoorType.secondary.copyWith(color: NoorColors.iconMuted)),
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
              style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
              child: Text('Login',
                  style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
            ),
          ]),
        ],
      ),
    );
  }
}
