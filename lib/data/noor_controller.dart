import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'firebase_rest_service.dart';
import 'location_service.dart';
import 'noor_store.dart';
import 'notification_plan.dart';
import 'notification_service.dart';
import 'prayer_service.dart';
import 'user_data_service.dart';

/// Phase 4 — Theme Preference Modes:
/// [solar] switches to Midnight Emerald dark mode automatically between
/// Maghrib (sunset) and Fajr (dawn), and uses light mode during the day.
enum NoorThemePreference {
  solar,
  light,
  dark,
  system,
}

/// Phase 13 — one app-wide reactive store.
///
/// Holds today's prayer day, user's location, profile, streaks, and
/// notifies every listening screen through [NoorScope].
class NoorController extends ChangeNotifier with WidgetsBindingObserver {
  NoorController({bool autoInit = true}) {
    if (autoInit) {
      NoorStore.progressRevision.addListener(loadProgress);
      loadProgress();
      loadTextScale();
      loadUserProfile().catchError((e, st) {
        // Ignored or logged in test / headless environments
      });
      loadThemePreference().catchError((e, st) {
        // Ignored or logged in test / headless environments
      });
      unawaited(
        UserDataService.instance.flushOutbox().catchError((e, st) {
          // Ignored or logged in test / headless environments
          return 0;
        }),
      );
      if (!_isInTestEnvironment) {
        WidgetsBinding.instance.addObserver(this);
        loadLocation().catchError((e, st) {
          // Ignored or logged in test / headless environments
        });
        _startTickTimer();
      }
    }
  }

  static bool get _isInTestEnvironment {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  PrayerDay? _liveDay;
  PrayerDay? _nextDay;
  PrayerDay? get liveDay => _liveDay;
  PrayerDay? get prayerDay => _liveDay;
  PrayerDay get activeDay =>
      _liveDay ??
      PrayerService.calculateOffline(
          location: _currentLocation,
          date: PrayerService.nowInLocation(_currentLocation));
  bool get isLive => _liveDay != null && _liveDay!.isLive;

  LocationModel _currentLocation = LocationModel.defaultLocation;
  LocationModel get currentLocation => _currentLocation;
  String get locationLabel => _currentLocation.label;
  double get latitude => _currentLocation.latitude;
  double get longitude => _currentLocation.longitude;

  Timer? _tickTimer;
  bool _refreshingDay = false;
  bool _disposed = false;
  int _locationRequest = 0;

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = PrayerService.nowInLocation(_currentLocation);
      final fajr = _liveDay?.timings['Fajr'];
      if (!_refreshingDay &&
          fajr != null &&
          (fajr.year != now.year ||
              fajr.month != now.month ||
              fajr.day != now.day)) {
        _refreshingDay = true;
        loadLocation().whenComplete(() => _refreshingDay = false);
      }
      notifyListeners();
    });
  }

  String _userName = '';
  String _userEmail = '';
  bool _isGuest = true;

  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => !_isGuest && _userName.isNotEmpty;

  Map<String, int> _streaks = {
    for (final s in NoorAppState.streaks) s.$1: 0,
  };
  Map<String, int> get streaks => Map.unmodifiable(_streaks);

  double _textScale = 1;
  double get textScale => _textScale;
  Future<void> loadTextScale() async {
    final value = await NoorStore.getTextScale();
    if (!_disposed && value != _textScale) {
      _textScale = value;
      notifyListeners();
    }
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(.9, 1.3);
    await NoorStore.setTextScale(_textScale);
    notifyListeners();
  }

  NoorThemePreference _themePreference = NoorThemePreference.light;
  NoorThemePreference get themePreference => _themePreference;

  String get themePreferenceLabel => switch (_themePreference) {
        NoorThemePreference.solar => 'Solar (Auto post-Maghrib)',
        NoorThemePreference.light => 'Light',
        NoorThemePreference.dark => 'Midnight Emerald (Dark)',
        NoorThemePreference.system => 'System Default',
      };

  /// True if [now] is between Maghrib and Fajr (night window).
  bool isNightTime([DateTime? now]) {
    final day = activeDay;
    return day.isNightTime(now);
  }

  /// Current active [ThemeMode] resolving solar timing, explicit dark/light,
  /// or system OS setting.
  ThemeMode get themeMode => switch (_themePreference) {
        NoorThemePreference.light => ThemeMode.light,
        NoorThemePreference.dark => ThemeMode.dark,
        NoorThemePreference.system => ThemeMode.system,
        NoorThemePreference.solar =>
          isNightTime() ? ThemeMode.dark : ThemeMode.light,
      };

  /// Current next prayer accurately evaluated for this exact second:
  NextPrayer get nextPrayer => activeDay.nextPrayer(nextDay: _nextDay);

  /// Next-prayer label every screen should show right now:
  String get nextPrayerLabel {
    final next = nextPrayer;
    return '${next.displayName.toUpperCase()} ${next.timeLabel}';
  }

  String get sourceLabel => switch (_liveDay?.source) {
        PrayerSource.live => 'Live',
        PrayerSource.cache => 'Saved for today',
        PrayerSource.calculated => 'Calculated offline',
        _ => 'Calculated for selected city',
      };

  /// Replace today's prayer day. All listening screens rebuild with the same times.
  void setLiveDay(PrayerDay day) {
    if (identical(_liveDay, day)) return;
    _liveDay = day;
    notifyListeners();
    unawaited(_autoScheduleNotifications(day));
  }

  Future<void> _autoScheduleNotifications(PrayerDay day) async {
    if (_isInTestEnvironment) return;
    try {
      final toggles = await NoorStore.getAllReminderToggles();
      final days = await PrayerService().upcomingDays(today: day, count: 7);
      if (_disposed || !identical(_liveDay, day)) return;
      final plan = NotificationPlan.buildUpcomingPlan(
        days: days,
        toggles: toggles,
      );
      await NoorNotifications.schedulePlan(plan, requestPermission: false);
    } catch (e) {
      debugPrint('NoorController: auto-schedule notification error: $e');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      // 1. Check local persistent store first for instant UI response
      final savedName = await NoorStore.getUserName();
      final savedEmail = await NoorStore.getUserEmail();
      final isGuestVal = await NoorStore.getIsGuest();
      if (savedName != null && savedName.trim().isNotEmpty) {
        _userName = savedName.trim();
        _userEmail = (savedEmail ?? '').trim();
        _isGuest = isGuestVal;
        notifyListeners();
        return;
      }

      // 2. Try loading from active auth session
      final auth = FirebaseRestService();
      final hasSession = await auth.hasSession();
      if (hasSession) {
        final profile = await auth.currentProfile();
        if (profile != null && profile.name.trim().isNotEmpty) {
          _userName = profile.name.trim();
          _userEmail = profile.email.trim();
          _isGuest = false;
          await NoorStore.setUserName(_userName);
          await NoorStore.setUserEmail(_userEmail);
          await NoorStore.setIsGuest(false);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('NoorController: loadUserProfile error: $e');
    }
  }

  void setUserProfile(String name, {String? email, bool isGuest = false}) {
    _userName = name.trim();
    if (email != null) _userEmail = email.trim();
    _isGuest = isGuest;
    NoorStore.setUserName(_userName);
    if (email != null) NoorStore.setUserEmail(_userEmail);
    NoorStore.setIsGuest(isGuest);
    notifyListeners();
  }

  void setUserName(String name) {
    if (name.trim().isEmpty) return;
    _userName = name.trim();
    _isGuest = false;
    NoorStore.setUserName(_userName);
    NoorStore.setIsGuest(false);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await FirebaseRestService().logout();
    } catch (_) {}
    _userName = '';
    _userEmail = '';
    _isGuest = true;
    await NoorStore.clearUser();
    notifyListeners();
  }

  Future<void> loadProgress() async {
    final values = <String, int>{};
    for (final kind in ['Salah', 'Dhikr', 'Quran']) {
      values[kind] = await NoorStore.activityStreak(kind);
    }
    if (_disposed) return;
    _streaks = values;
    notifyListeners();
  }

  void setStreak(String label, int days) {
    if (_streaks[label] == days) return;
    final updated = Map<String, int>.from(_streaks);
    updated[label] = days;
    _streaks = updated;
    notifyListeners();
  }

  Future<void> loadLocation({bool forceRefresh = false}) async {
    final request = ++_locationRequest;
    try {
      final location = await LocationService().getSavedLocation();
      if (_disposed || request != _locationRequest) return;
      _currentLocation = location;
      final method = await NoorStore.getCalculationMethod();
      final school = await NoorStore.getMadhhab() == 'Hanafi' ? 1 : 0;
      if (_disposed || request != _locationRequest) return;
      final now = PrayerService.nowInLocation(location);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      _nextDay = PrayerService.calculateOffline(
          location: location, date: tomorrow, method: method, school: school);
      setLiveDay(PrayerService.calculateOffline(
          location: location,
          date: PrayerService.nowInLocation(location),
          method: method,
          school: school));
      final service = PrayerService();
      final live = await service.fetchForLocationDate(location, now,
          forceRefresh: forceRefresh);
      if (!_disposed && request == _locationRequest) setLiveDay(live);
      if (_disposed || request != _locationRequest) return;
      final next = await service.fetchForLocationDate(location, tomorrow,
          forceRefresh: forceRefresh);
      if (!_disposed && request == _locationRequest) {
        _nextDay = next;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Prayer refresh unavailable: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_disposed) {
      unawaited(loadLocation());
    }
  }

  Future<void> updateLocation(LocationModel location) async {
    await LocationService().saveLocation(location);
    await loadLocation();
  }

  Future<void> setLocation(String city,
      {String country = 'Pakistan', double? lat, double? lng}) async {
    final known = LocationService.popularCities
        .where((item) =>
            item.city.toLowerCase() == city.toLowerCase() &&
            item.country.toLowerCase() == country.toLowerCase())
        .firstOrNull;
    if (lat == null && lng == null && known != null) {
      await updateLocation(known);
      return;
    }
    final loc = LocationModel(
      timeZone: known?.timeZone,
      city: city,
      country: country,
      latitude: lat ?? 0,
      longitude: lng ?? 0,
      isLive: lat != null && lng != null && lat != 0,
    );
    await updateLocation(loc);
  }

  Future<void> setThemePreference(NoorThemePreference pref) async {
    if (_themePreference == pref) return;
    _themePreference = pref;
    try {
      await NoorStore.setThemePreference(pref.name);
    } catch (e) {
      debugPrint('NoorController: Failed to persist theme preference: $e');
    }
    notifyListeners();
  }

  Future<void> loadThemePreference() async {
    try {
      final raw = await NoorStore.getThemePreference();
      for (final p in NoorThemePreference.values) {
        if (p.name == raw) {
          if (_themePreference != p) {
            _themePreference = p;
            notifyListeners();
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('NoorController: Failed to load theme preference: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    NoorStore.progressRevision.removeListener(loadProgress);
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}

/// InheritedNotifier bridge so any screen can read/listen to the
/// single [NoorController] without a package dependency.
class NoorScope extends InheritedNotifier<NoorController> {
  const NoorScope({
    super.key,
    required NoorController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Listen (rebuild on change). Returns null outside the scope so
  /// isolated screen tests keep working on canonical state.
  static NoorController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NoorScope>()?.notifier;
  }

  /// Read without listening (event handlers, initState).
  static NoorController? read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<NoorScope>();
    return scope?.notifier;
  }
}
