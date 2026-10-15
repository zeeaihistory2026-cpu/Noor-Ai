import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'user_data_service.dart';

/// Firebase backend via REST API (no native SDK needed).
/// - Auth: Firebase Auth REST API
/// - Database: Cloud Firestore REST API
///
/// Project: noor-ai-916ed
/// Accounts survive uninstalls — stored in Firebase, not on device.
class FirebaseRestService implements AuthService {
  static const _apiKey = 'AIzaSyAw_Az1vdkdXANXe22jw1dIO__XM2fTOKc'; // Replaced at build from config
  static const _projectId = 'noor-ai-916ed';

  static const _authBase = 'https://identitytoolkit.googleapis.com/v1';
  static const _firestoreBase =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

  String? _idToken;
  String? _uid;

  Future<void> _loadSession() async {
    if (_idToken != null) return;
    final prefs = await SharedPreferences.getInstance();
    _idToken = prefs.getString('fb.idToken');
    _uid = prefs.getString('fb.uid');
  }

  Future<void> _saveSession(String idToken, String uid, String refreshToken) async {
    _idToken = idToken;
    _uid = uid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fb.idToken', idToken);
    await prefs.setString('fb.uid', uid);
    await prefs.setString('fb.refreshToken', refreshToken);
  }

  Future<void> _clearSession() async {
    _idToken = null;
    _uid = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fb.idToken');
    await prefs.remove('fb.uid');
    await prefs.remove('fb.refreshToken');
  }

  /// Refresh the ID token using the refresh token.
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('fb.refreshToken');
      if (refreshToken == null) return false;
      final resp = await http.post(
        Uri.parse('https://securetoken.googleapis.com/v1/token?key=$_apiKey'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=refresh_token&refresh_token=$refreshToken',
      );
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
      final resp = await http.post(
        Uri.parse('$_authBase/accounts:signUp?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode != 200) {
        return AuthResult.failure(
            _friendlyError(data['error']?['message'] ?? 'UNKNOWN'));
      }
      await _saveSession(data['idToken'], data['localId'], data['refreshToken'] ?? '');
      // Store profile in Firestore
      await _setDoc('users/${data['localId']}', {
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });
      unawaited(UserDataService.instance.flushOutbox());
      return AuthResult.success(
          AuthProfile(name: name.trim(), email: email.trim()));
    } catch (e) {
      return const AuthResult.failure('Network error. Check connection and try again.');
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
      final resp = await http.post(
        Uri.parse('$_authBase/accounts:signInWithPassword?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode != 200) {
        return AuthResult.failure(
            _friendlyError(data['error']?['message'] ?? 'UNKNOWN'));
      }
      await _saveSession(data['idToken'], data['localId'], data['refreshToken'] ?? '');
      // Load profile from Firestore
      final profile = await _getDoc('users/${data['localId']}');
      final name = profile?['name']?.toString() ?? '';
      unawaited(UserDataService.instance.flushOutbox());
      return AuthResult.success(
          AuthProfile(name: name, email: email.trim()));
    } catch (e) {
      return const AuthResult.failure('Network error. Check connection and try again.');
    }
  }

  @override
  Future<AuthProfile?> currentProfile() async {
    await _loadSession();
    if (_idToken == null || _uid == null) return null;
    try {
      final profile = await _getDoc('users/$_uid');
      if (profile == null) return null;
      return AuthProfile(
        name: (profile['name'] ?? '').toString(),
        email: (profile['email'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _clearSession();
  }

  // --- Firestore helpers ---

  Future<Map<String, dynamic>?> _getDoc(String path) async {
    await _loadSession();
    if (_idToken == null) return null;
    var resp = await http.get(
      Uri.parse('$_firestoreBase/$path'),
      headers: {'Authorization': 'Bearer $_idToken'},
    );
    // Token expired? Try refreshing once.
    if (resp.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (!refreshed) return null;
      resp = await http.get(
        Uri.parse('$_firestoreBase/$path'),
        headers: {'Authorization': 'Bearer $_idToken'},
      );
    }
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body);
    return _fromFirestore(data['fields'] ?? {});
  }

  Future<void> _setDoc(String path, Map<String, dynamic> data) async {
    await _loadSession();
    if (_idToken == null) return;
    await http.patch(
      Uri.parse('$_firestoreBase/$path'),
      headers: {
        'Authorization': 'Bearer $_idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fields': _toFirestore(data)}),
    );
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
        return 'Password is too weak. Use at least 6 characters.';
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
