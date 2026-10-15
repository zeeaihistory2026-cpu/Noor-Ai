import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sample_data.dart';

/// Phase 6 — local storage for NOOR.
///
/// Wraps `shared_preferences` for settings, streaks, the Salah log,
/// bookmarks and reminder toggles. Every read/write is defensive:
/// if the plugin is unavailable (web preview, unit test, first run
/// before [init]) an in-memory map is used instead, so callers NEVER
/// crash because storage is missing — they just get defaults
/// (which mirror [SampleData], keeping the UI identical offline).
class NoorStore {
  NoorStore._();

  static SharedPreferences? _prefs;
  static bool _initAttempted = false;
  static final Map<String, Object> _memory = <String, Object>{};

  /// Call once from main() if convenient. Safe to skip: every
  /// accessor lazily attempts init and falls back to memory.
  static Future<void> init() async {
    if (_initAttempted) return;
    _initAttempted = true;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null; // In-memory fallback for this session.
    }
  }

  static Future<SharedPreferences?> _getPrefs() async {
    if (_prefs == null && !_initAttempted) await init();
    return _prefs;
  }

  // ---- Low-level helpers (never throw) -------------------------------

  static Future<String?> _readString(String key) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      try {
        return prefs.getString(key);
      } catch (_) {
        /* fall through to memory */
      }
    }
    final v = _memory[key];
    return v is String ? v : null;
  }

  static Future<void> _writeString(String key, String value) async {
    _memory[key] = value;
    final prefs = await _getPrefs();
    if (prefs != null) {
      try {
        await prefs.setString(key, value);
      } catch (_) {
        /* memory copy already kept */
      }
    }
  }

  static Future<int?> _readInt(String key) async {
    final s = await _readString(key);
    return s == null ? null : int.tryParse(s);
  }

  static Future<void> _writeInt(String key, int value) =>
      _writeString(key, value.toString());

  static Future<bool?> _readBool(String key) async {
    final s = await _readString(key);
    if (s == 'true') return true;
    if (s == 'false') return false;
    return null;
  }

  static Future<void> _writeBool(String key, bool value) =>
      _writeString(key, value ? 'true' : 'false');

  // ---- Settings (Pages 13/31/39/40) ----------------------------------

  /// AlAdhan calculation method. 5 = University of Islamic Sciences,
  /// Karachi — default for the Asia/Karachi user.
  static const keyCalculationMethod = 'settings.calculationMethod';
  static const defaultCalculationMethod = 5;

  static Future<int> getCalculationMethod() async =>
      await _readInt(keyCalculationMethod) ?? defaultCalculationMethod;

  static Future<void> setCalculationMethod(int method) =>
      _writeInt(keyCalculationMethod, method);

  static Future<String> getLanguage() async =>
      await _readString('settings.language') ?? 'English';

  static Future<void> setLanguage(String language) =>
      _writeString('settings.language', language);

  static Future<String> getMadhhab() async =>
      await _readString('settings.madhhab') ?? 'Hanafi';

  static Future<void> setMadhhab(String madhhab) =>
      _writeString('settings.madhhab', madhhab);

  static Future<String> getCity() async =>
      await _readString('settings.city') ?? 'Karachi';

  static Future<void> setCity(String city) =>
      _writeString('settings.city', city);

  static Future<String> getCountry() async =>
      await _readString('settings.country') ?? 'Pakistan';

  static Future<void> setCountry(String country) =>
      _writeString('settings.country', country);

  // ---- Theme Preference (Phase 4: solar | light | dark | system) ------

  static const keyThemePreference = 'settings.themePreference';
  static const defaultThemePreference = 'solar';

  static Future<String> getThemePreference() async =>
      await _readString(keyThemePreference) ?? defaultThemePreference;

  static Future<void> setThemePreference(String pref) =>
      _writeString(keyThemePreference, pref);

  // ---- Reminder toggles (Page 31) -------------------------------------

  static String _reminderKey(String id) => 'reminders.$id';

  static Future<bool> getReminderEnabled(String id,
          {bool defaultValue = true}) async =>
      await _readBool(_reminderKey(id)) ?? defaultValue;

  static Future<void> setReminderEnabled(String id, bool enabled) =>
      _writeBool(_reminderKey(id), enabled);

  /// All Page 31 toggles in one map, keyed by the row label
  /// (Fajr, Dhuhr, Asr, Maghrib, Isha, Morning Adhkar, ...).
  static Future<Map<String, bool>> getAllReminderToggles() async {
    final labels = <String>[
      for (final r in SampleData.reminderSalah) r.$1,
      for (final r in SampleData.reminderWorship) r.$1,
      for (final r in SampleData.reminderDaily) r.$1,
    ];
    final out = <String, bool>{};
    for (final label in labels) {
      out[label] = await getReminderEnabled(label);
    }
    return out;
  }

  // ---- Streaks (Pages 01/06/07/32) ------------------------------------

  static Future<int> getStreak(String kind) async {
    final v = await _readInt('streaks.$kind');
    if (v != null) return v;
    // Offline default mirrors the design's sample streaks.
    for (final s in SampleData.streaks) {
      if (s.$1 == kind) return s.$2;
    }
    return 0;
  }

  static Future<void> setStreak(String kind, int days) =>
      _writeInt('streaks.$kind', days);

  // ---- Salah log (Page 06) --------------------------------------------
  // Stored as JSON: {"2026-10-06": {"Fajr": true, "Asr": false}}

  static const _salahLogKey = 'salah.log';

  static Future<Map<String, Map<String, bool>>> getSalahLog() async {
    final raw = await _readString(_salahLogKey);
    if (raw == null || raw.isEmpty) return <String, Map<String, bool>>{};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((day, prayers) => MapEntry(
            day,
            (prayers as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v == true)),
          ));
    } catch (_) {
      return <String, Map<String, bool>>{};
    }
  }

  static Future<void> setSalahDone(
      String dateKey, String prayer, bool done) async {
    final log = await getSalahLog();
    final day = log.putIfAbsent(dateKey, () => <String, bool>{});
    day[prayer] = done;
    await _writeString(_salahLogKey, jsonEncode(log));
  }

  static Future<bool> isSalahDone(String dateKey, String prayer) async {
    final log = await getSalahLog();
    return log[dateKey]?[prayer] ?? false;
  }

  static const _prayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  static Future<List<bool>> getPrayersList(String dateKey) async {
    final log = await getSalahLog();
    final day = log[dateKey];
    if (day == null) return List.filled(5, false);
    return [
      day['fajr'] ?? day['Fajr'] ?? false,
      day['dhuhr'] ?? day['Dhuhr'] ?? false,
      day['asr'] ?? day['Asr'] ?? false,
      day['maghrib'] ?? day['Maghrib'] ?? false,
      day['isha'] ?? day['Isha'] ?? false,
    ];
  }

  static Future<void> setPrayersList(String dateKey, List<bool> done) async {
    final log = await getSalahLog();
    final day = log.putIfAbsent(dateKey, () => <String, bool>{});
    for (var i = 0; i < 5 && i < done.length; i++) {
      day[_prayerNames[i]] = done[i];
    }
    await _writeString(_salahLogKey, jsonEncode(log));
  }

  // ---- Tasbih Counts & Today's Total ----------------------------------
  static const _tasbihCountsKey = 'tasbih.counts';

  static Future<Map<String, int>> getTasbihCounts() async {
    final raw = await _readString(_tasbihCountsKey);
    if (raw == null || raw.isEmpty) return <String, int>{};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return <String, int>{};
    }
  }

  static Future<void> setTasbihCount(String id, int count) async {
    final counts = await getTasbihCounts();
    counts[id] = count;
    await _writeString(_tasbihCountsKey, jsonEncode(counts));
  }

  static Future<void> setAllTasbihCounts(Map<String, int> counts) async {
    await _writeString(_tasbihCountsKey, jsonEncode(counts));
  }

  static Future<int> getTasbihTotalToday(String dateKey) async {
    final v = await _readInt('tasbih.total.$dateKey');
    return v ?? 0;
  }

  static Future<void> setTasbihTotalToday(String dateKey, int total) =>
      _writeInt('tasbih.total.$dateKey', total);

  // ---- Custom Dhikrs --------------------------------------------------
  static const _customDhikrsKey = 'tasbih.customDhikrs';

  static Future<List<Map<String, dynamic>>> getCustomDhikrs() async {
    final raw = await _readString(_customDhikrsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> saveCustomDhikr(Map<String, dynamic> dhikrMap) async {
    final list = await getCustomDhikrs();
    final idx = list.indexWhere((d) => d['id'] == dhikrMap['id']);
    if (idx >= 0) {
      list[idx] = dhikrMap;
    } else {
      list.insert(0, dhikrMap);
    }
    await _writeString(_customDhikrsKey, jsonEncode(list));
  }

  static Future<void> deleteCustomDhikr(String id) async {
    final list = await getCustomDhikrs();
    list.removeWhere((d) => d['id'] == id);
    await _writeString(_customDhikrsKey, jsonEncode(list));
  }

  // ---- Bookmarks (Pages 02/03/33) --------------------------------------
  // IDs are opaque strings chosen by the caller, e.g. 'quran:18:18',
  // 'hadith:bukhari:1', 'dua:knowledge'.

  static const _bookmarksKey = 'bookmarks.ids';

  static Future<List<String>> getBookmarks() async {
    final raw = await _readString(_bookmarksKey);
    if (raw == null || raw.isEmpty) return <String>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return <String>[];
    }
  }

  /// Toggles [id]; returns true if it is now bookmarked.
  static Future<bool> toggleBookmark(String id) async {
    final ids = await getBookmarks();
    final nowBookmarked = !ids.contains(id);
    if (nowBookmarked) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await _writeString(_bookmarksKey, jsonEncode(ids));
    return nowBookmarked;
  }

  static Future<bool> isBookmarked(String id) async =>
      (await getBookmarks()).contains(id);

  // ---- Rich Saved Items (Bookmarks & Notes) ----------------------------
  static const _savedItemsKey = 'saved.richItems';

  static Future<List<Map<String, dynamic>>> getSavedItems() async {
    final raw = await _readString(_savedItemsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> saveRichItem({
    required String id,
    required String title,
    required String subtitle,
    required String tag,
  }) async {
    final list = await getSavedItems();
    final idx = list.indexWhere((e) => e['id'] == id);
    final item = {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'tag': tag,
      'createdAt': DateTime.now().toIso8601String(),
    };
    if (idx >= 0) {
      list[idx] = item;
    } else {
      list.insert(0, item);
    }
    await _writeString(_savedItemsKey, jsonEncode(list));
    // Also keep the simple ID list in sync
    final ids = await getBookmarks();
    if (!ids.contains(id)) {
      ids.add(id);
      await _writeString(_bookmarksKey, jsonEncode(ids));
    }
  }

  static Future<void> removeRichItem(String id) async {
    final list = await getSavedItems();
    list.removeWhere((e) => e['id'] == id);
    await _writeString(_savedItemsKey, jsonEncode(list));
    final ids = await getBookmarks();
    if (ids.contains(id)) {
      ids.remove(id);
      await _writeString(_bookmarksKey, jsonEncode(ids));
    }
  }

  // ---- Generic JSON cache (used by the live services) -----------------

  static Future<void> cacheJson(String key, String json) =>
      _writeString('cache.$key', json);

  static Future<String?> cachedJson(String key) => _readString('cache.$key');
}
