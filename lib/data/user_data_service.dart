import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'noor_store.dart';

enum SyncState { idle, syncing, synced, offlinePending, error }

/// Syncs user data (prayers, zikr, streaks, bookmarks) to Firebase Firestore REST.
/// Features:
/// - Resilient auto-token refresh on 401 Unauthorized
/// - Offline write queue (outbox) with automatic replay on connectivity
/// - Debounced batched writes to prevent network spam during rapid counter/checkbox taps
/// - Real-time [syncState] ValueNotifier for reactive UI indicators
class UserDataService {
  UserDataService._();
  static final UserDataService instance = UserDataService._();

  static const _apiKey = 'AIzaSyAw_Az1vdkdXANXe22jw1dIO__XM2fTOKc';
  static const _projectId = 'noor-ai-916ed';
  static const _base =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

  final ValueNotifier<SyncState> syncState = ValueNotifier<SyncState>(SyncState.idle);

  Timer? _prayerDebounceTimer;
  final Map<String, List<bool>> _pendingPrayers = {};

  Timer? _tasbihDebounceTimer;
  final Map<String, int> _pendingTasbih = {};

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fb.idToken');
  }

  Future<String?> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fb.refreshToken');
  }

  Future<String?> _uid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fb.uid');
  }

  Future<bool> _refreshIdToken() async {
    try {
      final rf = await _refreshToken();
      if (rf == null || rf.isEmpty) return false;
      final resp = await http.post(
        Uri.parse('https://securetoken.googleapis.com/v1/token?key=$_apiKey'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=refresh_token&refresh_token=$rf',
      );
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body);
      final newIdToken = data['id_token']?.toString();
      final newRf = data['refresh_token']?.toString();
      if (newIdToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fb.idToken', newIdToken);
        if (newRf != null) await prefs.setString('fb.refreshToken', newRf);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response?> _authenticatedPatch(String path, Map<String, dynamic> data) async {
    var token = await _token();
    if (token == null) return null;

    try {
      var resp = await http.patch(
        Uri.parse('$_base/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fields': _toFs(data)}),
      );

      // Auto-refresh token if 401
      if (resp.statusCode == 401) {
        final refreshed = await _refreshIdToken();
        if (refreshed) {
          token = await _token();
          resp = await http.patch(
            Uri.parse('$_base/$path'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'fields': _toFs(data)}),
          );
        }
      }
      return resp;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _authenticatedGet(String path) async {
    var token = await _token();
    if (token == null) return null;

    try {
      var resp = await http.get(
        Uri.parse('$_base/$path'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 401) {
        final refreshed = await _refreshIdToken();
        if (refreshed) {
          token = await _token();
          resp = await http.get(
            Uri.parse('$_base/$path'),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      }

      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      return _fromFs((data['fields'] ?? {}) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Cancels any active debounce timers (used during teardown and testing).
  void cancelTimers() {
    _prayerDebounceTimer?.cancel();
    _prayerDebounceTimer = null;
    _tasbihDebounceTimer?.cancel();
    _tasbihDebounceTimer = null;
  }

  // --- Prayer logs ---

  /// Saves 5 prayer states for [date].
  /// Debounces rapid consecutive taps (unless [immediate] is true).
  /// Enqueues into offline outbox if network or auth fails.
  Future<void> savePrayers(String date, List<bool> done, {bool immediate = false}) async {
    _pendingPrayers[date] = List<bool>.from(done);

    if (immediate) {
      _prayerDebounceTimer?.cancel();
      await _executePendingPrayer(date);
      return;
    }

    _prayerDebounceTimer?.cancel();
    _prayerDebounceTimer = Timer(const Duration(milliseconds: 1200), () {
      _executePendingPrayer(date);
    });
  }

  Future<void> _executePendingPrayer(String date) async {
    final done = _pendingPrayers[date];
    if (done == null) return;

    final uid = await _uid();
    if (uid == null) {
      // User is offline or not logged in; queue locally
      await NoorStore.enqueueSyncOperation({
        'id': 'prayer_$date',
        'type': 'prayers',
        'path': 'users/local/prayerLogs/$date',
        'data': {'prayers': done, 'date': date},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      syncState.value = SyncState.offlinePending;
      return;
    }

    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final data = <String, dynamic>{};
    for (var i = 0; i < 5 && i < done.length; i++) {
      data[prayers[i]] = done[i];
    }
    data['updatedAt'] = DateTime.now().toIso8601String();

    syncState.value = SyncState.syncing;
    final path = 'users/$uid/prayerLogs/$date';
    final resp = await _authenticatedPatch(path, data);

    if (resp != null && resp.statusCode >= 200 && resp.statusCode < 300) {
      syncState.value = SyncState.synced;
      _pendingPrayers.remove(date);
    } else {
      // Offline fallback: save to outbox
      await NoorStore.enqueueSyncOperation({
        'id': 'prayer_$date',
        'type': 'prayers',
        'path': path,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      syncState.value = SyncState.offlinePending;
    }
  }

  Future<List<bool>?> loadPrayers(String date) async {
    final uid = await _uid();
    if (uid == null) return null;
    final data = await _authenticatedGet('users/$uid/prayerLogs/$date');
    if (data == null) return null;
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    return prayers.map((p) => (data[p] as bool?) ?? false).toList();
  }

  // --- Tasbih Sync ---

  /// Saves today's tasbih total count with debouncing.
  Future<void> saveTasbihTotal(String date, int total, {bool immediate = false}) async {
    _pendingTasbih[date] = total;

    if (immediate) {
      _tasbihDebounceTimer?.cancel();
      await _executePendingTasbih(date);
      return;
    }

    _tasbihDebounceTimer?.cancel();
    _tasbihDebounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _executePendingTasbih(date);
    });
  }

  Future<void> _executePendingTasbih(String date) async {
    final total = _pendingTasbih[date];
    if (total == null) return;

    final uid = await _uid();
    final path = 'users/${uid ?? 'local'}/tasbihLogs/$date';
    final data = {
      'total': total,
      'date': date,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (uid == null) {
      await NoorStore.enqueueSyncOperation({
        'id': 'tasbih_$date',
        'type': 'tasbih',
        'path': path,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      syncState.value = SyncState.offlinePending;
      return;
    }

    syncState.value = SyncState.syncing;
    final resp = await _authenticatedPatch(path, data);
    if (resp != null && resp.statusCode >= 200 && resp.statusCode < 300) {
      syncState.value = SyncState.synced;
      _pendingTasbih.remove(date);
    } else {
      await NoorStore.enqueueSyncOperation({
        'id': 'tasbih_$date',
        'type': 'tasbih',
        'path': path,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      syncState.value = SyncState.offlinePending;
    }
  }

  Future<int?> loadTasbihTotal(String date) async {
    final uid = await _uid();
    if (uid == null) return null;
    final data = await _authenticatedGet('users/$uid/tasbihLogs/$date');
    if (data == null) return null;
    return (data['total'] as int?) ?? 0;
  }

  // --- Outbox Flush & Replay ---

  /// Flushes pending offline operations to Firestore.
  /// Safely exits without throwing if offline or not logged in.
  Future<int> flushOutbox() async {
    final uid = await _uid();
    final outbox = await NoorStore.getSyncOutbox();
    if (outbox.isEmpty) {
      syncState.value = SyncState.synced;
      return 0;
    }

    if (uid == null) {
      syncState.value = SyncState.offlinePending;
      return 0;
    }

    syncState.value = SyncState.syncing;
    final List<String> successfullySynced = [];

    for (final op in outbox) {
      var path = op['path']?.toString() ?? '';
      if (path.contains('/local/')) {
        path = path.replaceFirst('/local/', '/$uid/');
      }
      final rawData = op['data'];
      final Map<String, dynamic> payload =
          rawData is Map ? Map<String, dynamic>.from(rawData) : {};

      final resp = await _authenticatedPatch(path, payload);
      if (resp != null && resp.statusCode >= 200 && resp.statusCode < 300) {
        final opId = op['id']?.toString();
        if (opId != null) successfullySynced.add(opId);
      } else {
        // Still offline or server unreachable; pause flush
        syncState.value = SyncState.offlinePending;
        break;
      }
    }

    if (successfullySynced.isNotEmpty) {
      await NoorStore.removeSyncOperations(successfullySynced);
    }

    final remaining = await NoorStore.getSyncOutbox();
    syncState.value = remaining.isEmpty ? SyncState.synced : SyncState.offlinePending;
    return successfullySynced.length;
  }

  // --- Helpers for Firestore REST API ---

  Map<String, dynamic> _toFs(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    data.forEach((k, v) {
      if (v is String) {
        fields[k] = {'stringValue': v};
      } else if (v is int) {
        fields[k] = {'integerValue': '$v'};
      } else if (v is double) {
        fields[k] = {'doubleValue': v};
      } else if (v is bool) {
        fields[k] = {'booleanValue': v};
      } else if (v is List) {
        fields[k] = {
          'arrayValue': {
            'values': v.map((item) {
              if (item is bool) return {'booleanValue': item};
              if (item is int) return {'integerValue': '$item'};
              return {'stringValue': item.toString()};
            }).toList(),
          }
        };
      } else if (v is Map) {
        fields[k] = {
          'mapValue': {'fields': _toFs(Map<String, dynamic>.from(v))}
        };
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
        } else if (v.containsKey('doubleValue')) {
          result[k] = double.tryParse(v['doubleValue'].toString()) ?? 0.0;
        } else if (v.containsKey('arrayValue')) {
          final list = v['arrayValue']['values'] as List<dynamic>? ?? [];
          result[k] = list.map((elem) {
            if (elem is Map) {
              if (elem.containsKey('booleanValue')) return elem['booleanValue'];
              if (elem.containsKey('integerValue')) return int.tryParse(elem['integerValue'].toString()) ?? 0;
              return elem['stringValue'] ?? '';
            }
            return elem;
          }).toList();
        } else if (v.containsKey('mapValue')) {
          result[k] = _fromFs((v['mapValue']['fields'] ?? {}) as Map<String, dynamic>);
        }
      }
    });
    return result;
  }
}
