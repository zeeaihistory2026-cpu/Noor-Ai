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
class NoorController extends ChangeNotifier {
  NoorController({bool autoInit = true}) {
    if (autoInit) {
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
  PrayerDay? get liveDay => _liveDay;
  PrayerDay? get prayerDay => _liveDay;
  PrayerDay get activeDay => _liveDay ?? PrayerDay.sample();
  bool get isLive => _liveDay != null && _liveDay!.isLive;

  LocationModel _currentLocation = LocationModel.defaultLocation;
  LocationModel get currentLocation => _currentLocation;
  String get locationLabel => _currentLocation.label;
  double get latitude => _currentLocation.latitude;
  double get longitude => _currentLocation.longitude;

  Timer? _tickTimer;

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
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
    for (final s in NoorAppState.streaks) s.$1: s.$2,
  };
  Map<String, int> get streaks => Map.unmodifiable(_streaks);

  NoorThemePreference _themePreference = NoorThemePreference.solar;
  NoorThemePreference get themePreference => _themePreference;

  String get themePreferenceLabel => switch (_themePreference) {
        NoorThemePreference.solar => 'Solar (Auto post-Maghrib)',
        NoorThemePreference.light => 'Light',
        NoorThemePreference.dark => 'Midnight Emerald (Dark)',
        NoorThemePreference.system => 'System Default',
      };

  /// True if [now] is between Maghrib and Fajr (night window).
  bool isNightTime([DateTime? now]) {
    final day = _liveDay ?? PrayerDay.sample();
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
  NextPrayer get nextPrayer => activeDay.nextPrayer();

  /// Next-prayer label every screen should show right now:
  String get nextPrayerLabel {
    final day = _liveDay;
    if (day != null) {
      final next = day.nextPrayer();
      return '${next.displayName.toUpperCase()} ${next.timeLabel}';
    }
    return '${NoorAppState.nextPrayerName} ${NoorAppState.nextPrayerTime}';
  }

  String get sourceLabel => isLive ? 'Live' : NoorAppState.sourceLabel;

  /// Replace today's prayer day. All listening screens rebuild with the same times.
  void setLiveDay(PrayerDay day) {
    if (identical(_liveDay, day)) return;
    _liveDay = day;
    notifyListeners();
    unawaited(_autoScheduleNotifications(day));
  }

  Future<void> _autoScheduleNotifications(PrayerDay day) async {
    try {
      final toggles = await NoorStore.getAllReminderToggles();
      final plan = NotificationPlan.buildFullPlan(
        day: day,
        toggles: toggles,
      );
      await NoorNotifications.schedulePlan(plan);
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

  void setStreak(String label, int days) {
    if (_streaks[label] == days) return;
    final updated = Map<String, int>.from(_streaks);
    updated[label] = days;
    _streaks = updated;
    notifyListeners();
  }

  Future<void> loadLocation() async {
    try {
      final loc = await LocationService().getSavedLocation();
      _currentLocation = loc;
      notifyListeners();
      // Fetch today's prayer times for this location
      final day = await PrayerService().fetchTodayAuto();
      setLiveDay(day);
    } catch (e) {
      debugPrint('NoorController: Failed to load location: $e');
    }
  }

  Future<void> updateLocation(LocationModel loc) async {
    _currentLocation = loc;
    await LocationService().saveLocation(loc);
    notifyListeners();
    try {
      final day = await PrayerService().fetchTodayAuto(forceRefresh: true);
      setLiveDay(day);
    } catch (e) {
      debugPrint('NoorController: Failed to refresh prayer times for new location: $e');
    }
  }

  Future<void> setLocation(String city, {String country = 'Pakistan', double? lat, double? lng}) async {
    final loc = LocationModel(
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
    _tickTimer?.cancel();
    super.dispose();
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
    return context
        .dependOnInheritedWidgetOfExactType<NoorScope>()
        ?.notifier;
  }

  /// Read without listening (event handlers, initState).
  static NoorController? read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<NoorScope>();
    return scope?.notifier;
  }
}
