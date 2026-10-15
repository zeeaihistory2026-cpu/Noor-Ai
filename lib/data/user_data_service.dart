import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Syncs user data (prayers, zikr, streaks, bookmarks) to Firebase.
/// Uses the same auth session as FirebaseRestService.
class UserDataService {
  UserDataService._();
  static final UserDataService instance = UserDataService._();

  static const _projectId = 'noor-ai-916ed';
  static const _base =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fb.idToken');
  }

  Future<String?> _uid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fb.uid');
  }

  Future<void> _patch(String path, Map<String, dynamic> data) async {
    final token = await _token();
    if (token == null) return;
    try {
      await http.patch(
        Uri.parse('$_base/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fields': _toFs(data)}),
      );
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _get(String path) async {
    final token = await _token();
    if (token == null) return null;
    try {
      final resp = await http.get(
        Uri.parse('$_base/$path'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      return _fromFs((data['fields'] ?? {}) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // --- Prayer logs ---
  Future<void> savePrayers(String date, List<bool> done) async {
    final uid = await _uid();
    if (uid == null) return;
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final data = <String, dynamic>{};
    for (var i = 0; i < 5 && i < done.length; i++) {
      data[prayers[i]] = done[i];
    }
    await _patch('users/$uid/prayerLogs/$date', data);
  }

  Future<List<bool>?> loadPrayers(String date) async {
    final uid = await _uid();
    if (uid == null) return null;
    final data = await _get('users/$uid/prayerLogs/$date');
    if (data == null) return null;
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    return prayers.map((p) => (data[p] as bool?) ?? false).toList();
  }

  // --- Helpers ---
  Map<String, dynamic> _toFs(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    data.forEach((k, v) {
      if (v is String) {
        fields[k] = {'stringValue': v};
      } else if (v is int) {
        fields[k] = {'integerValue': '$v'};
      } else if (v is bool) {
        fields[k] = {'booleanValue': v};
      }
    });
    return fields;
  }

  Map<String, dynamic> _fromFs(Map<String, dynamic> fields) {
    final result = <String, dynamic>{};
    fields.forEach((k, v) {
      if (v is Map) {
        if (v.containsKey('stringValue')) {
          result[k] = v['stringValue'];
        } else if (v.containsKey('booleanValue')) {
          result[k] = v['booleanValue'];
        } else if (v.containsKey('integerValue')) {
          result[k] = int.tryParse(v['integerValue'].toString()) ?? 0;
        }
      }
    });
    return result;
  }
}
