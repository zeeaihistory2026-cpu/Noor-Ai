import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'user_data_service.dart';
import 'session_store.dart';

/// Firebase backend via REST API (no native SDK needed).
/// - Auth: Firebase Auth REST API
/// - Database: Cloud Firestore REST API
///
/// Project: noor-ai-916ed
/// Accounts survive uninstalls — stored in Firebase, not on device.
class FirebaseRestService implements AuthService, PasswordResetService {
  FirebaseRestService({http.Client? client})
      : _client = client ?? http.Client();
  final http.Client _client;
  static const requestTimeout = Duration(seconds: 12);

  /// Compile-time configurable API Key via `--dart-define=FIREBASE_API_KEY=...` with default fallback.
  static const apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyAw_Az1vdkdXANXe22jw1dIO__XM2fTOKc',
  );
  static const projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'noor-ai-916ed',
  );

  static const _authBase = 'https://identitytoolkit.googleapis.com/v1';
  static const _firestoreBase =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  static const _kIdToken = 'fb.idToken';
  static const _kUid = 'fb.uid';
  static const _kRefreshToken = 'fb.refreshToken';
  static const _kName = 'fb.name';
  static const _kEmail = 'fb.email';
  static const _secSeed = 'NoorAi.SecureStorage.Seed.2026';

  /// Phase 6D: Cryptographically obfuscates tokens before storing in SharedPreferences.
  static String encryptToken(String plain) {
    if (plain.isEmpty) return '';
    final keyBytes = utf8.encode(_secSeed);
    final textBytes = utf8.encode(plain);
    final enc = List<int>.generate(
      textBytes.length,
      (i) => textBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return 'sec_${base64UrlEncode(enc)}';
  }

  /// Phase 6D: Decrypts tokens, maintaining transparent backward compatibility with legacy plaintext tokens.
  static String? decryptToken(String? stored) {
    if (stored == null || stored.isEmpty) return null;
    if (!stored.startsWith('sec_')) {
      return stored; // Legacy plaintext backward compatibility
    }
    try {
      final raw = base64Url.decode(stored.substring(4));
      final keyBytes = utf8.encode(_secSeed);
      final textBytes = List<int>.generate(
        raw.length,
        (i) => raw[i] ^ keyBytes[i % keyBytes.length],
      );
      return utf8.decode(textBytes);
    } catch (_) {
      return null;
    }
  }

  String? _idToken;
  String? _uid;

  Future<void> _loadSession() async {
    if (_idToken != null) return;
    _idToken = await SessionStore.read(_kIdToken);
    _uid = await SessionStore.read(_kUid);
  }

  Future<void> _saveSession(String idToken, String uid, String refreshToken,
      {String? name, String? email}) async {
    _idToken = idToken;
    _uid = uid;
    final prefs = await SharedPreferences.getInstance();
    if (await SessionStore.read(_kUid) != uid) {
      await prefs.remove(_kName);
      await prefs.remove(_kEmail);
    }
    await SessionStore.write(_kIdToken, idToken);
    await SessionStore.write(_kUid, uid);
    await SessionStore.write(_kRefreshToken, refreshToken);
    if (name != null && name.isNotEmpty) {
      await prefs.setString(_kName, encryptToken(name));
    }
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_kEmail, encryptToken(email));
    }
  }

  Future<void> _clearSession() async {
    _idToken = null;
    _uid = null;
    final prefs = await SharedPreferences.getInstance();
    await SessionStore.clear();
    await prefs.remove(_kName);
    await prefs.remove(_kEmail);
  }

  @override
  Future<bool> hasSession() async {
    final uid = await SessionStore.read(_kUid);
    final token = await SessionStore.read(_kIdToken);
    final refresh = await SessionStore.read(_kRefreshToken);
    return (uid != null && uid.isNotEmpty) &&
        ((token != null && token.isNotEmpty) ||
            (refresh != null && refresh.isNotEmpty));
  }

  /// Refresh the ID token using the refresh token.
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SessionStore.read(_kRefreshToken);
      if (refreshToken == null || refreshToken.isEmpty) return false;
      final resp = await _client.post(
        Uri.parse('https://securetoken.googleapis.com/v1/token?key=$apiKey'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
      ).timeout(requestTimeout);
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body);
      await _saveSession(
          data['id_token'], data['user_id'], data['refresh_token']);
      return true;
    } catch (_) {
      return false;
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
    try {
      final resp = await _client
          .post(
            Uri.parse('$_authBase/accounts:signUp?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'returnSecureToken': true,
            }),
          )
          .timeout(requestTimeout);
      final data = jsonDecode(resp.body);
      if (resp.statusCode != 200) {
        return AuthResult.failure(
            _friendlyError(data['error']?['message'] ?? 'UNKNOWN'));
      }
      await _saveSession(
        data['idToken'],
        data['localId'],
        data['refreshToken'] ?? '',
        name: name.trim(),
        email: email.trim(),
      );
      // Account creation is already successful. Ancillary profile writes must
      // never turn a valid account into a misleading signup failure.
      try {
        await _client
            .post(
              Uri.parse('$_authBase/accounts:update?key=$apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'idToken': data['idToken'],
                'displayName': name.trim(),
                'returnSecureToken': false
              }),
            )
            .timeout(const Duration(seconds: 4));
      } catch (_) {}
      try {
        await _setDoc('users/${data['localId']}', {
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
      unawaited(UserDataService.instance.flushOutbox());
      return AuthResult.success(
          AuthProfile(name: name.trim(), email: email.trim()),
          isLocalOnly: false);
    } catch (e) {
      return const AuthResult.failure(
          'Network error. Check connection and try again.');
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final error = AuthValidator.validateLogin(email: email, password: password);
    if (error != null) return AuthResult.failure(error);
    try {
      final resp = await _client
          .post(
            Uri.parse('$_authBase/accounts:signInWithPassword?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'returnSecureToken': true,
            }),
          )
          .timeout(requestTimeout);
      final data = jsonDecode(resp.body);
      if (resp.statusCode != 200) {
        return AuthResult.failure(
            _friendlyError(data['error']?['message'] ?? 'UNKNOWN'));
      }
      await _saveSession(
        data['idToken'],
        data['localId'],
        data['refreshToken'] ?? '',
        email: email.trim(),
      );
      // Load profile from Firestore
      final profile = await _getDoc('users/${data['localId']}');
      final name =
          profile?['name']?.toString() ?? data['displayName']?.toString() ?? '';
      if (name.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kName, encryptToken(name));
      }
      unawaited(UserDataService.instance.flushOutbox());
      return AuthResult.success(AuthProfile(name: name, email: email.trim()),
          isLocalOnly: false);
    } catch (e) {
      return const AuthResult.failure(
          'Network error. Check connection and try again.');
    }
  }

  @override
  Future<String?> sendPasswordReset(String email) async {
    final invalid = AuthValidator.validateEmail(email);
    if (invalid != null) return invalid;
    try {
      final resp = await _client
          .post(
            Uri.parse('$_authBase/accounts:sendOobCode?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
                {'requestType': 'PASSWORD_RESET', 'email': email.trim()}),
          )
          .timeout(requestTimeout);
      if (resp.statusCode == 200) return null;
      final data = jsonDecode(resp.body);
      final code = data['error']?['message']?.toString() ?? 'UNKNOWN';
      // Match Firebase's enumeration-safe response for unknown addresses.
      if (code == 'EMAIL_NOT_FOUND') return null;
      return _friendlyError(code);
    } catch (_) {
      return 'Couldn’t send the reset link. Check your connection and try again.';
    }
  }

  @override
  Future<AuthProfile?> currentProfile({bool forceRefresh = false}) async {
    await _loadSession();
    if (_idToken == null || _uid == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final cachedName = decryptToken(prefs.getString(_kName)) ?? '';
    final cachedEmail = decryptToken(prefs.getString(_kEmail)) ?? '';

    // Fast path: if cached profile exists locally and refresh isn't forced, return instantly!
    if (!forceRefresh && cachedEmail.isNotEmpty) {
      unawaited(_syncProfileInBackground());
      return AuthProfile(name: cachedName, email: cachedEmail);
    }

    try {
      final profile = await _getDoc('users/$_uid');
      if (profile != null) {
        final name = (profile['name'] ?? '').toString();
        final email = (profile['email'] ?? cachedEmail).toString();
        if (name.isNotEmpty) await prefs.setString(_kName, encryptToken(name));
        if (email.isNotEmpty) {
          await prefs.setString(_kEmail, encryptToken(email));
        }
        return AuthProfile(name: name, email: email);
      }
    } catch (e) {
      debugPrint('FirebaseRestService: Failed to fetch user profile doc: $e');
    }

    // Fallback: return cached profile if network was slow or failed
    if (cachedEmail.isNotEmpty) {
      return AuthProfile(name: cachedName, email: cachedEmail);
    }
    if (_uid != null && _uid!.isNotEmpty) {
      return AuthProfile(name: cachedName, email: cachedEmail);
    }
    return null;
  }

  Future<void> _syncProfileInBackground() async {
    try {
      final profile = await _getDoc('users/$_uid');
      if (profile != null) {
        final prefs = await SharedPreferences.getInstance();
        final name = (profile['name'] ?? '').toString();
        final email = (profile['email'] ?? '').toString();
        if (name.isNotEmpty) await prefs.setString(_kName, encryptToken(name));
        if (email.isNotEmpty) {
          await prefs.setString(_kEmail, encryptToken(email));
        }
      }
    } catch (e) {
      debugPrint('FirebaseRestService: _syncProfileInBackground error: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _clearSession();
    UserDataService.instance.cancelTimers();
  }

  // --- Firestore helpers ---

  Future<Map<String, dynamic>?> _getDoc(String path) async {
    await _loadSession();
    if (_idToken == null) return null;
    try {
      var resp = await _client.get(
        Uri.parse('$_firestoreBase/$path'),
        headers: {'Authorization': 'Bearer $_idToken'},
      ).timeout(const Duration(seconds: 4));
      // Token expired? Try refreshing once.
      if (resp.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (!refreshed) return null;
        resp = await _client.get(
          Uri.parse('$_firestoreBase/$path'),
          headers: {'Authorization': 'Bearer $_idToken'},
        ).timeout(const Duration(seconds: 4));
      }
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      return _fromFirestore(data['fields'] ?? {});
    } catch (_) {
      return null;
    }
  }

  Future<void> _setDoc(String path, Map<String, dynamic> data) async {
    await _loadSession();
    if (_idToken == null) return;
    await _client
        .patch(
          Uri.parse('$_firestoreBase/$path'),
          headers: {
            'Authorization': 'Bearer $_idToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'fields': _toFirestore(data)}),
        )
        .timeout(const Duration(seconds: 4));
  }

  Map<String, dynamic> _fromFirestore(Map<String, dynamic> fields) {
    final result = <String, dynamic>{};
    fields.forEach((k, v) {
      if (v is Map) {
        if (v.containsKey('stringValue')) {
          result[k] = v['stringValue'];
        } else if (v.containsKey('integerValue')) {
          result[k] = int.tryParse(v['integerValue'].toString());
        } else if (v.containsKey('booleanValue')) {
          result[k] = v['booleanValue'];
        } else if (v.containsKey('mapValue')) {
          result[k] = _fromFirestore(
              (v['mapValue']['fields'] ?? {}) as Map<String, dynamic>);
        }
      }
    });
    return result;
  }

  Map<String, dynamic> _toFirestore(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    data.forEach((k, v) {
      if (v is String) {
        fields[k] = {'stringValue': v};
      } else if (v is int) {
        fields[k] = {'integerValue': '$v'};
      } else if (v is bool) {
        fields[k] = {'booleanValue': v};
      } else if (v is Map) {
        fields[k] = {
          'mapValue': {'fields': _toFirestore(v as Map<String, dynamic>)}
        };
      }
    });
    return fields;
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'EMAIL_EXISTS':
        return 'This email is already registered. Please log in.';
      case 'INVALID_EMAIL':
        return 'Please enter a valid email address.';
      case 'WEAK_PASSWORD':
        return 'Password is too weak. Use at least 8 characters.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Too many attempts. Please wait a little before trying again.';
      case 'USER_DISABLED':
        return 'This account is disabled. Please contact support.';
      case 'OPERATION_NOT_ALLOWED':
        return 'Email sign-in is unavailable. Please try again later or continue as a guest.';
      case 'EMAIL_NOT_FOUND':
        return 'No account found with this email.';
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
