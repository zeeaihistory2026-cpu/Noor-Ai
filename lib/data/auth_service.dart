import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'noor_store.dart';

/// Phase 9 — accounts layer (LOCAL PREP ONLY, no backend yet).
///
/// Pages 41/42 currently need: basic validation, a local profile
/// (name/email) and an honest "no account server yet" boundary.
/// [LocalAuthService] provides exactly that on top of [NoorStore]:
///
/// * The plain-text password is NEVER stored. Register keeps only
///   `sha256(email + ':' + password)` (package:crypto) as a local
///   placeholder hash. NOTE: plain SHA-256 is NOT production
///   password storage — the real backend (Phase 10+) must hash
///   server-side with Argon2id/bcrypt and issue tokens; this local
///   hash exists only so login can be exercised on-device with no
///   credential at rest.
/// * No network call is made and no "account created on a server"
///   claim exists anywhere. [AuthResult.isLocalOnly] is always true
///   for the local service, and the UI copy stays honest about it.
class AuthProfile {
  const AuthProfile({required this.name, required this.email});

  final String name;
  final String email;

  Map<String, dynamic> toJson() => {'name': name, 'email': email};

  factory AuthProfile.fromJson(Map<String, dynamic> json) => AuthProfile(
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
      );
}

class AuthResult {
  const AuthResult.success(this.profile)
      : ok = true,
        error = null,
        isLocalOnly = true;

  const AuthResult.failure(this.error)
      : ok = false,
        profile = null,
        isLocalOnly = true;

  final bool ok;
  final AuthProfile? profile;
  final String? error;

  /// True while only [LocalAuthService] exists (no backend).
  final bool isLocalOnly;
}

abstract interface class AuthService {
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResult> login({
    required String email,
    required String password,
  });

  Future<AuthProfile?> currentProfile();

  /// Check whether an authenticated session exists locally without network latency.
  Future<bool> hasSession();

  Future<void> logout();
}

/// Pure validation shared by the UI, the service and the tests.
class AuthValidator {
  AuthValidator._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateName(String name) =>
      name.trim().length >= 2 ? null : 'Please enter your name.';

  static String? validateEmail(String email) =>
      _emailPattern.hasMatch(email.trim())
          ? null
          : 'Please enter a valid email address.';

  static String? validatePassword(String password) =>
      password.length >= 8 ? null : 'Password must be at least 8 characters.';

  /// First error across the register form, or null when valid.
  static String? validateRegister({
    required String name,
    required String email,
    required String password,
  }) =>
      validateName(name) ?? validateEmail(email) ?? validatePassword(password);

  static String? validateLogin({
    required String email,
    required String password,
  }) =>
      validateEmail(email) ??
      (password.isEmpty ? 'Please enter your password.' : null);
}

class LocalAuthService implements AuthService {
  LocalAuthService();

  static const String _profileCacheKey = 'auth.profile';

  /// Local placeholder hash only — see the file header. The raw
  /// password is never written to storage.
  static String _hash(String email, String password) => sha256
      .convert(utf8.encode('${email.trim().toLowerCase()}:$password'))
      .toString();

  Future<Map<String, dynamic>?> _readRecord() async {
    final raw = await NoorStore.cachedJson(_profileCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final error = AuthValidator.validateRegister(
        name: name, email: email, password: password);
    if (error != null) return AuthResult.failure(error);

    final profile = AuthProfile(name: name.trim(), email: email.trim());
    final record = <String, dynamic>{
      ...profile.toJson(),
      // Placeholder hash only; plain password is never stored.
      'passwordHash': _hash(email, password),
      'isLocalOnly': true,
    };
    await NoorStore.cacheJson(_profileCacheKey, jsonEncode(record));
    await NoorStore.cacheJson(_sessionActiveKey, 'true');
    return AuthResult.success(profile);
  }

  static const _sessionActiveKey = 'local_auth_session_active_v1';

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final error = AuthValidator.validateLogin(email: email, password: password);
    if (error != null) return AuthResult.failure(error);

    final record = await _readRecord();
    if (record == null) {
      return const AuthResult.failure(
          'No local account yet — please create an account first.');
    }
    final storedEmail = record['email']?.toString() ?? '';
    if (storedEmail.toLowerCase() != email.trim().toLowerCase()) {
      return const AuthResult.failure(
          'This email does not match the local account on this device.');
    }
    if (record['passwordHash']?.toString() != _hash(email, password)) {
      return const AuthResult.failure(
          'Incorrect password for this device account.');
    }
    await NoorStore.cacheJson(_sessionActiveKey, 'true');
    return AuthResult.success(AuthProfile.fromJson(record));
  }

  @override
  Future<AuthProfile?> currentProfile() async {
    final record = await _readRecord();
    if (record == null) return null;
    final profile = AuthProfile.fromJson(record);
    return profile.email.isEmpty ? null : profile;
  }

  @override
  Future<bool> hasSession() async {
    final active = await NoorStore.cachedJson(_sessionActiveKey);
    if (active == 'false') return false;
    final record = await _readRecord();
    return record != null && (record['email']?.toString().isNotEmpty ?? false);
  }

  @override
  Future<void> logout() async {
    await NoorStore.cacheJson(_sessionActiveKey, 'false');
  }
}
