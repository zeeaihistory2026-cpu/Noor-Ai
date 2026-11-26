import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app.dart';
import '../../data/auth_service.dart';
import '../../data/firebase_rest_service.dart';
import '../../data/noor_controller.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/muslim_go_mark.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.createAccount = false, this.authService});
  final bool createAccount;
  final AuthService? authService;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthService _auth = widget.authService ?? FirebaseRestService();
  late bool _register = widget.createAccount;
  bool _busy = false, _visible = false, _submitted = false;
  String? _error, _message;

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
      _submitted = true;
      _error = null;
      _message = null;
    });
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final result = _register
          ? await _auth.register(
              name: _name.text.trim(),
              email: _email.text.trim(),
              password: _password.text)
          : await _auth.login(
              email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      if (!result.ok) {
        setState(() => _error = result.error ?? 'Please try again.');
        return;
      }
      // Do not reuse another account's locally saved display name.
      final profile = result.profile;
      final name = (profile?.name.trim().isNotEmpty ?? false)
          ? profile!.name.trim()
          : _email.text.trim().split('@').first;
      final email = profile?.email ?? _email.text.trim();
      await NoorStore.setUserName(name);
      await NoorStore.setUserEmail(email);
      await NoorStore.setIsGuest(false);
      if (!mounted) return;
      TextInput.finishAutofillContext();
      NoorScope.read(context)
          ?.setUserProfile(name, email: email, isGuest: false);
      _enterApp();
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'We couldn’t sign you in. Check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _guest() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.logout();
      await NoorStore.setUserName('Guest');
      await NoorStore.setUserEmail('');
      await NoorStore.setIsGuest(true);
      if (!mounted) return;
      TextInput.finishAutofillContext(shouldSave: false);
      NoorScope.read(context)
          ?.setUserProfile('Guest', email: '', isGuest: true);
      _enterApp();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Couldn’t open guest mode. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _enterApp() => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const NoorTabShell()), (_) => false);

  Future<void> _resetPassword() async {
    if (_busy) return;
    if (AuthValidator.validateEmail(_email.text) != null) {
      setState(() {
        _error = 'Enter your email address above to reset your password.';
        _submitted = true;
      });
      return;
    }
    if (_auth is! PasswordResetService) {
      setState(() =>
          _error = 'Password reset isn’t available for this account provider.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final failure = await (_auth as PasswordResetService)
          .sendPasswordReset(_email.text.trim());
      if (!mounted) return;
      setState(() {
        _error = failure;
        if (failure == null) {
          _message =
              'If an account exists for this email, a reset link is on its way. Check your inbox and spam folder.';
        }
      });
    } catch (_) {
      if (mounted) {
        setState(
            () => _error = 'Couldn’t send the reset link. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _switchMode() {
    if (_busy) return;
    setState(() {
      _register = !_register;
      _submitted = false;
      _error = null;
      _message = null;
    });
    _form.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? NoorColors.darkTextPrimary : NoorColors.inkDeep;
    final muted = dark ? NoorColors.darkTextSecondary : NoorColors.mutedDark;
    final accent = dark ? NoorColors.darkGold : NoorColors.emeraldDark;
    return Scaffold(
      backgroundColor: dark ? NoorColors.darkBg : NoorColors.cream,
      body: SafeArea(
          child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Center(
                        child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: 440,
                          minHeight: (constraints.maxHeight - 48)
                              .clamp(0, double.infinity)),
                      child: AutofillGroup(
                          child: Form(
                        key: _form,
                        autovalidateMode: _submitted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(children: [
                                const MuslimGoMark(size: 52),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text('MuslimGo',
                                          style: NoorType.section
                                              .copyWith(color: ink)),
                                      Text('YOUR DAILY COMPANION',
                                          style: NoorType.brandCaption
                                              .copyWith(color: muted)),
                                    ]))
                              ]),
                              const SizedBox(height: 36),
                              Text(
                                  _register
                                      ? 'A little closer,\nevery day.'
                                      : 'Welcome back',
                                  style:
                                      NoorType.authTitle.copyWith(color: ink)),
                              const SizedBox(height: 12),
                              Text(
                                  _register
                                      ? 'Create your account to keep your Quran, worship and saved reflections together.'
                                      : 'Make space for what matters. Continue your Quran and worship journey.',
                                  style: NoorType.body.copyWith(color: muted)),
                              const SizedBox(height: 28),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: dark
                                        ? NoorColors.darkSurface
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color: dark
                                            ? NoorColors.darkBorder
                                            : NoorColors.hairline)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                          _register
                                              ? 'Create your account'
                                              : 'Login',
                                          style: NoorType.section
                                              .copyWith(color: ink)),
                                      const SizedBox(height: 22),
                                      if (_register) ...[
                                        _field(
                                            label: 'Name',
                                            hint: 'Your name',
                                            controller: _name,
                                            icon: Icons.person_outline,
                                            validator:
                                                AuthValidator.validateName,
                                            autofill: const [
                                              AutofillHints.name
                                            ],
                                            capitalization:
                                                TextCapitalization.words),
                                        const SizedBox(height: 18),
                                      ],
                                      _field(
                                          label: 'Email',
                                          hint: 'you@example.com',
                                          controller: _email,
                                          icon: Icons.mail_outline,
                                          validator:
                                              AuthValidator.validateEmail,
                                          keyboard: TextInputType.emailAddress,
                                          autofill: const [
                                            AutofillHints.username,
                                            AutofillHints.email
                                          ]),
                                      const SizedBox(height: 18),
                                      _field(
                                          label: 'Password',
                                          hint: _register
                                              ? 'At least 8 characters'
                                              : 'Your password',
                                          controller: _password,
                                          icon: Icons.lock_outline,
                                          validator: (value) => _register
                                              ? AuthValidator.validatePassword(
                                                  value)
                                              : value.isEmpty
                                                  ? 'Please enter your password.'
                                                  : null,
                                          autofill: [
                                            _register
                                                ? AutofillHints.newPassword
                                                : AutofillHints.password
                                          ],
                                          password: true),
                                      if (!_register)
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                                onPressed: _busy
                                                    ? null
                                                    : _resetPassword,
                                                child: Text('Forgot password?',
                                                    style: TextStyle(
                                                        color: accent)))),
                                      if (_register) ...[
                                        const SizedBox(height: 10),
                                        Text(
                                            'Use a unique password with at least 8 characters.',
                                            style: NoorType.meta
                                                .copyWith(color: muted))
                                      ],
                                      if (_error != null ||
                                          _message != null) ...[
                                        const SizedBox(height: 16),
                                        Semantics(
                                            liveRegion: true,
                                            child: Text(_error ?? _message!,
                                                style: NoorType.secondary
                                                    .copyWith(
                                                        color: _error != null
                                                            ? (dark
                                                                ? const Color(
                                                                    0xFFFFB4AB)
                                                                : NoorColors
                                                                    .error)
                                                            : accent))),
                                      ],
                                      const SizedBox(height: 22),
                                      FilledButton(
                                        onPressed: _busy ? null : _submit,
                                        style: FilledButton.styleFrom(
                                            backgroundColor:
                                                NoorColors.emeraldDark,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(0, 54),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16))),
                                        child: _busy
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                        semanticsLabel:
                                                            'Please wait'))
                                            : Text(
                                                _register
                                                    ? 'Create Account'
                                                    : 'Login',
                                                style: NoorType.button),
                                      ),
                                    ]),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                        _register
                                            ? 'Already have an account?'
                                            : 'New to MuslimGo?',
                                        style: NoorType.secondary
                                            .copyWith(color: muted)),
                                    TextButton(
                                        onPressed: _busy ? null : _switchMode,
                                        child: Text(
                                            _register
                                                ? 'Login'
                                                : 'Create account',
                                            style: TextStyle(
                                                color: accent,
                                                fontWeight: FontWeight.w700))),
                                  ]),
                              TextButton(
                                  onPressed: _busy ? null : _guest,
                                  child: Text('Continue as Guest',
                                      style: TextStyle(color: accent))),
                              Text(
                                  'Explore Quran, duas and prayer times without an account.',
                                  textAlign: TextAlign.center,
                                  style: NoorType.meta.copyWith(color: muted)),
                              const SizedBox(height: 12),
                            ]),
                      )),
                    )),
                  ))),
    );
  }

  Widget _field(
          {required String label,
          required String hint,
          required TextEditingController controller,
          required IconData icon,
          required String? Function(String) validator,
          required List<String> autofill,
          TextInputType? keyboard,
          TextCapitalization capitalization = TextCapitalization.none,
          bool password = false}) =>
      TextFormField(
        controller: controller,
        enabled: !_busy,
        validator: (value) => validator(value ?? ''),
        autofillHints: autofill,
        keyboardType: keyboard,
        textCapitalization: capitalization,
        obscureText: password && !_visible,
        autocorrect: false,
        enableSuggestions: !password,
        textInputAction: password ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: password ? (_) => _submit() : null,
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorMaxLines: 3,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: password
                ? IconButton(
                    tooltip: _visible ? 'Hide password' : 'Show password',
                    onPressed: _busy
                        ? null
                        : () => setState(() => _visible = !_visible),
                    icon: Icon(
                        _visible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 21))
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 17)),
      );
}
