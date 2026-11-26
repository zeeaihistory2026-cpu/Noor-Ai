import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_rest_service.dart';

/// Tokens live in platform secure storage. Legacy preference values migrate
/// once and are removed only after a successful secure write.
abstract final class SessionStore {
  static const storage = FlutterSecureStorage();
  static const keys = ['fb.idToken', 'fb.uid', 'fb.refreshToken'];

  static Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(key);
    if (legacy != null) {
      final value = FirebaseRestService.decryptToken(legacy);
      if (value != null && value.isNotEmpty) {
        await storage.write(key: key, value: value);
        await prefs.remove(key);
        return value;
      }
    }
    return storage.read(key: key);
  }

  static Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in keys) {
      await storage.delete(key: key);
      await prefs.remove(key);
    }
  }
}
