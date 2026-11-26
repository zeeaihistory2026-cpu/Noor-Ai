import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'sample_data.dart';

/// Phase 6 — local storage for MuslimGo.
///
/// Wraps `shared_preferences` for settings, streaks, the Salah log,
/// bookmarks and reminder toggles. Every read/write is defensive:
/// if the plugin is unavailable (web preview, unit test, first run
/// before [init]) an in-memory map is used instead, so callers NEVER
/// crash because storage is missing — they just get defaults
/// (which mirror [SampleData], keeping the UI identical offline).
class NoorStore {
  static Future<List<String>?> getGoals() async {
    final raw = await _readString('settings.goals');
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return null;
    }
  }

  static Future<void> setGoals(List<String> goals) =>
      _writeString('settings.goals', jsonEncode(goals));
  static Future<Map<String, String>?> getMaleNarrator(String language) async {
    final raw =
        await _readString('speech.maleVoice.${language.split('-').first}');
    if (raw == null) return null;
    try {
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setMaleNarrator(
          String language, Map<String, String> voice) =>
      _writeString(
          'speech.maleVoice.${language.split('-').first}', jsonEncode(voice));
  static final progressRevision = ValueNotifier<int>(0);
  static Future<(int, int)?> getReadingPosition() async {
    final raw = await _readString('quran.readingPosition');
    final parts = raw?.split(':');
    if (parts == null || parts.length != 2) return null;
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (surah == null ||
        surah < 1 ||
        surah > 114 ||
        ayah == null ||
        ayah < 1 ||
        ayah > 286) {
      return null;
    }
    return (surah, ayah);
  }

  static Future<void> setReadingPosition(int surah, int ayah) async {
    await _writeString('quran.readingPosition', '$surah:$ayah');
    progressRevision.value++;
  }

  NoorStore._();

  static SharedPreferences? _prefs;
  static bool _initAttempted = false;
  static Future<void>? _initFuture;
  static final Map<String, Object> _memory = <String, Object>{};

  /// Call once from main() if convenient. Safe to skip: every
  /// accessor lazily attempts init and falls back to memory.
  static Future<void> init() {
    if (_initAttempted) {
      return _initFuture ?? Future<void>.value();
    }
    _initAttempted = true;
    late final Future<void> future;
    future = () async {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (_) {
        _prefs = null; // In-memory fallback for this session.
      } finally {
        if (identical(_initFuture, future)) {
          _initFuture = null;
        }
      }
    }();
    _initFuture = future;
    return future;
  }

  static Future<SharedPreferences?> _getPrefs() async {
    if (_prefs == null && !_initAttempted) {
      await init();
    } else if (_initFuture != null) {
      await _initFuture;
    }
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

  /// AlAdhan calculation method. 1 = University of Islamic Sciences,
  /// Karachi — default for the Asia/Karachi user.
  static const keyCalculationMethod = 'settings.calculationMethod';
  static const defaultCalculationMethod = 1;

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

  // ---- User Identity --------------------------------------------------
  static Future<String?> getUserName() async => await _readString('user.name');

  static Future<void> setUserName(String name) =>
      _writeString('user.name', name);

  static Future<String?> getUserEmail() async =>
      await _readString('user.email');

  static Future<void> setUserEmail(String email) =>
      _writeString('user.email', email);

  static Future<bool> getIsGuest() async =>
      await _readBool('user.isGuest') ?? true;

  /// A default UI guest label is not a deliberate guest session.
  static Future<bool> hasGuestSession() async =>
      await _readBool('user.isGuest') == true && await getUserName() == 'Guest';

  static void resetForTesting() {
    _prefs = null;
    _initAttempted = false;
    _initFuture = null;
    _memory.clear();
  }

  static Future<void> setIsGuest(bool isGuest) =>
      _writeBool('user.isGuest', isGuest);

  static Future<void> clearUser() async {
    await setUserName('');
    await setUserEmail('');
    await setIsGuest(true);
  }

  // ---- Theme Preference (Phase 4: solar | light | dark | system) ------

  static Future<double> getTextScale() async =>
      ((await _readInt('settings.textScalePercent')) ?? 100) / 100;
  static Future<void> setTextScale(double scale) => _writeInt(
      'settings.textScalePercent', (scale.clamp(.9, 1.3) * 100).round());

  static const keyThemePreference = 'settings.themePreference';
  static const defaultThemePreference = 'light';

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
    progressRevision.value++;
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

  static Future<void> setTasbihTotalToday(String dateKey, int total) async {
    await _writeInt('tasbih.total.$dateKey', total);
    await recordActivity('Dhikr',
        date: DateTime.parse(dateKey), active: total > 0);
  }

  static Future<int> getTasbihSessions(String date) async =>
      await _readInt('tasbih.sessions.$date') ?? 0;
  static Future<void> setTasbihSessions(String date, int count) =>
      _writeInt('tasbih.sessions.$date', count);

  static Future<void> recordActivity(String kind,
      {DateTime? date, bool active = true}) async {
    final key = 'activity.$kind';
    final raw = await _readString(key);
    final dates = raw == null
        ? <String>{}
        : (jsonDecode(raw) as List).cast<String>().toSet();
    final day = date ?? DateTime.now();
    final label =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    if (active) {
      dates.add(label);
    } else {
      dates.remove(label);
    }
    await _writeString(key, jsonEncode(dates.toList()..sort()));
    progressRevision.value++;
  }

  static int streakForDates(Set<String> dates, {DateTime? now}) {
    final n = now ?? DateTime.now();
    var date = DateTime.utc(n.year, n.month, n.day);
    String label() => date.toIso8601String().split('T').first;
    if (!dates.contains(label())) date = date.subtract(const Duration(days: 1));
    int streak = 0;
    while (dates.contains(label())) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static Future<Set<String>> completedSalahDates() async {
    final log = await getSalahLog();
    return {
      for (final entry in log.entries)
        if (_prayerNames.every((name) =>
            entry.value[name] == true ||
            entry.value['${name[0].toUpperCase()}${name.substring(1)}'] ==
                true))
          entry.key
    };
  }

  static Future<int> activityStreak(String kind) async {
    if (kind == 'Salah') return streakForDates(await completedSalahDates());
    final raw = await _readString('activity.$kind');
    return streakForDates(
        raw == null ? {} : (jsonDecode(raw) as List).cast<String>().toSet());
  }

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

  // ---- Last Read 16-Line Mushaf Page -----------------------------------
  static const _lastMushafPageKey = 'mushaf.lastPage';

  static Future<int> getLastMushafPage() async {
    final str = await _readString(_lastMushafPageKey);
    return int.tryParse(str ?? '') ?? 2;
  }

  static Future<void> setLastMushafPage(int page) async {
    await _writeString(_lastMushafPageKey, '$page');
    await recordActivity('Quran');
  }

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

  /// Phase 6C: Stores JSON payload with explicit Time-To-Live expiration.
  static Future<void> cacheJsonWithTtl(
    String key,
    String data, {
    Duration ttl = const Duration(hours: 24),
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = now + ttl.inMilliseconds;
    final envelope = jsonEncode({
      'data': data,
      'savedAt': now,
      'expiresAt': expiresAt,
    });
    await _writeString('cache.ttl.$key', envelope);
    await _writeString('cache.$key', data);
  }

  /// Phase 6C: Returns cached payload if still valid within TTL, or null if expired or missing.
  static Future<String?> cachedJsonWithTtl(String key) async {
    final raw = await _readString('cache.ttl.$key');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = (decoded['expiresAt'] as num?)?.toInt() ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiresAt) {
        return null;
      }
      return decoded['data'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Phase 6C: Checks if cache is valid without reading entire payload.
  static Future<bool> isCacheValid(String key) async {
    final raw = await _readString('cache.ttl.$key');
    if (raw == null || raw.isEmpty) return false;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = (decoded['expiresAt'] as num?)?.toInt() ?? 0;
      return DateTime.now().millisecondsSinceEpoch <= expiresAt;
    } catch (_) {
      return false;
    }
  }

  /// Phase 6C: Invalidate/bust cache entry.
  static Future<void> invalidateCache(String key) async {
    await _writeString('cache.$key', '');
    await _writeString('cache.ttl.$key', '');
  }

  // ---- Sync Outbox (Phase 6B: Offline write queue) --------------------
  static const _kSyncOutbox = 'sync.outbox';

  static Future<List<Map<String, dynamic>>> getSyncOutbox() async {
    final raw = await _readString(_kSyncOutbox);
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

  static Future<void> enqueueSyncOperation(Map<String, dynamic> op) async {
    final list = await getSyncOutbox();
    final path = op['path'];
    final idx = path != null ? list.indexWhere((e) => e['path'] == path) : -1;
    if (idx >= 0) {
      list[idx] = op;
    } else {
      list.add(op);
    }
    await _writeString(_kSyncOutbox, jsonEncode(list));
  }

  static Future<void> removeSyncOperations(List<String> opIds) async {
    if (opIds.isEmpty) return;
    final list = await getSyncOutbox();
    list.removeWhere((e) => opIds.contains(e['id']));
    await _writeString(_kSyncOutbox, jsonEncode(list));
  }

  static Future<void> clearSyncOutbox() async {
    await _writeString(_kSyncOutbox, jsonEncode([]));
  }

  // ---- Daily Adhkar completions ----------------------------------------
  static Future<Set<String>> getAdhkarDoneIds(String dateKey) async {
    final raw = await _readString('adhkar.done.');
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      return (jsonDecode(raw) as List).map((e) => e.toString()).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<bool> toggleAdhkarDone(String dateKey, String id) async {
    final set = await getAdhkarDoneIds(dateKey);
    final added = set.add(id);
    if (!added) set.remove(id);
    await _writeString('adhkar.done.', jsonEncode(set.toList()));
    progressRevision.value++;
    return added;
  }

  // ---- Islamic Calendar moon-sighting offset (-2..+2 days) -------------
  static Future<int> getHijriOffsetDays() async =>
      ((await _readInt('calendar.hijriOffsetDays')) ?? 0).clamp(-2, 2);

  static Future<void> setHijriOffsetDays(int days) async {
    await _writeInt('calendar.hijriOffsetDays', days.clamp(-2, 2));
    progressRevision.value++;
  }

  // ---- Fasting tracker & Qada counters ---------------------------------
  static Future<Set<String>> getFastingDates() async {
    final raw = await _readString('fasting.dates');
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      return (jsonDecode(raw) as List).map((e) => e.toString()).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<bool> toggleFastingDate(String dateKey) async {
    final set = await getFastingDates();
    final added = set.add(dateKey);
    if (!added) set.remove(dateKey);
    await _writeString('fasting.dates', jsonEncode(set.toList()..sort()));
    progressRevision.value++;
    return added;
  }

  static Future<int> getQadaFasts() async =>
      (await _readInt('fasting.qadaCount')) ?? 0;

  static Future<void> setQadaFasts(int count) async {
    await _writeInt('fasting.qadaCount', count < 0 ? 0 : count);
    progressRevision.value++;
  }

  static Future<Map<String, int>> getQadaPrayers() async {
    final raw = await _readString('salah.qadaCounts');
    final defaults = {
      for (final p in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Witr'])
        p: 0,
    };
    if (raw == null || raw.isEmpty) return defaults;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        if (defaults.containsKey(entry.key)) {
          defaults[entry.key] = ((entry.value as num?)?.toInt() ?? 0).clamp(0, 99999);
        }
      }
      return defaults;
    } catch (_) {
      return defaults;
    }
  }

  static Future<void> setQadaPrayerCount(String prayer, int count) async {
    final map = await getQadaPrayers();
    map[prayer] = count < 0 ? 0 : count;
    await _writeString('salah.qadaCounts', jsonEncode(map));
    progressRevision.value++;
  }

  // ---- Zakat & Sadaqah history -----------------------------------------
  static Future<List<Map<String, dynamic>>> getZakatHistory() async =>
      _readMapList('finance.zakatHistory');

  static Future<void> addZakatRecord(Map<String, dynamic> record) async {
    final list = await getZakatHistory();
    list.insert(0, record);
    await _writeString(
        'finance.zakatHistory', jsonEncode(list.take(30).toList()));
    progressRevision.value++;
  }

  static Future<List<Map<String, dynamic>>> getSadaqahHistory() async =>
      _readMapList('finance.sadaqahHistory');

  static Future<void> addSadaqahRecord(Map<String, dynamic> record) async {
    final list = await getSadaqahHistory();
    list.insert(0, record);
    await _writeString(
        'finance.sadaqahHistory', jsonEncode(list.take(50).toList()));
    progressRevision.value++;
  }

  static Future<List<Map<String, dynamic>>> _readMapList(String key) async {
    final raw = await _readString(key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  // ---- AI Conversations history ----------------------------------------
  static Future<List<Map<String, dynamic>>> getAiConversations() async =>
      _readMapList('ai.conversations');

  static Future<void> saveAiConversation({
    required String question,
    required String answer,
    List<String> sourceRefs = const [],
  }) async {
    final list = await getAiConversations();
    list.removeWhere((e) => e['question'] == question);
    list.insert(0, {
      'question': question,
      'answer': answer,
      'refs': sourceRefs,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _writeString(
        'ai.conversations', jsonEncode(list.take(25).toList()));
  }

  static Future<void> clearAiConversations() =>
      _writeString('ai.conversations', jsonEncode(const []));

  // ---- Hajj & Umrah counters + packing checklist -----------------------
  static Future<int> getHajjTawafCount() async =>
      (await _readInt('hajj.tawafCount') ?? 0).clamp(0, 7);

  static Future<void> setHajjTawafCount(int count) =>
      _writeInt('hajj.tawafCount', count.clamp(0, 7));

  static Future<int> getHajjSaiCount() async =>
      (await _readInt('hajj.saiCount') ?? 0).clamp(0, 7);

  static Future<void> setHajjSaiCount(int count) =>
      _writeInt('hajj.saiCount', count.clamp(0, 7));

  static Future<List<String>> getHajjChecklistDone() =>
      _readStringList('hajj.checklistDone');

  static Future<void> setHajjChecklistDone(List<String> ids) =>
      _writeString('hajj.checklistDone', jsonEncode(ids));

  // ---- Halal scan history ----------------------------------------------
  static Future<List<Map<String, dynamic>>> getHalalScanHistory() =>
      _readMapList('halal.scanHistory');

  static Future<void> addHalalScanRecord(Map<String, dynamic> record) async {
    final list = await getHalalScanHistory();
    list.insert(0, record);
    await _writeString('halal.scanHistory', jsonEncode(list.take(25).toList()));
  }

  // ---- Women's Corner private exempt pause mode ------------------------
  static Future<bool> getCycleExemptMode() async =>
      await _readBool('worship.cycleExemptMode') ?? false;

  static Future<void> setCycleExemptMode(bool value) =>
      _writeBool('worship.cycleExemptMode', value);

  // ---- Beginner 30-day roadmap milestones ------------------------------
  static Future<List<int>> getBeginnerRoadmapDone() async {
    final raw = await _readString('learn.beginnerRoadmap');
    if (raw == null || raw.isEmpty) return <int>[];
    try {
      return (jsonDecode(raw) as List).map((e) => (e as num).toInt()).toList();
    } catch (_) {
      return <int>[];
    }
  }

  static Future<void> setBeginnerRoadmapDone(List<int> ids) =>
      _writeString('learn.beginnerRoadmap', jsonEncode(ids));

  // ---- Kids Surahs & quiz milestones -----------------------------------
  static Future<List<String>> getKidsCompletedSurahs() =>
      _readStringList('kids.completedSurahs');

  static Future<void> setKidsCompletedSurahs(List<String> ids) =>
      _writeString('kids.completedSurahs', jsonEncode(ids));

  static Future<int> getKidsQuizBest() async =>
      await _readInt('kids.quizBest') ?? 0;

  static Future<void> setKidsQuizBest(int score) async {
    final prev = await getKidsQuizBest();
    if (score > prev) await _writeInt('kids.quizBest', score);
  }

  // ---- My Deen Sunnah checklist & Gratitude journal --------------------
  static Future<List<String>> getSunnahDoneIds(String dateKey) =>
      _readStringList('deen.sunnah.$dateKey');

  static Future<void> setSunnahDoneIds(String dateKey, List<String> ids) =>
      _writeString('deen.sunnah.$dateKey', jsonEncode(ids));

  static Future<List<Map<String, dynamic>>> getGratitudeJournal() =>
      _readMapList('deen.gratitudeJournal');

  static Future<void> addGratitudeEntry(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    final list = await getGratitudeJournal();
    list.insert(0, {
      'text': clean,
      'date': DateTime.now().toIso8601String().split('T').first,
    });
    await _writeString('deen.gratitudeJournal', jsonEncode(list.take(40).toList()));
  }

  static Future<List<String>> _readStringList(String key) async {
    final raw = await _readString(key);
    if (raw == null || raw.isEmpty) return <String>[];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return <String>[];
    }
  }
}
