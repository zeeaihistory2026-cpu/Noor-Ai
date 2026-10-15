import 'package:flutter/widgets.dart';

import 'app_state.dart';
import 'prayer_service.dart';

/// Phase 13 — one app-wide reactive store.
///
/// Phase 12 gave every screen the same canonical demo values via
/// [NoorAppState], so screens could not contradict each other, but
/// the values were compile-time constants. This controller is the
/// live version: it holds today's prayer day (demo snapshot first,
/// replaced by the live AlAdhan result when it lands), the user's
/// profile and progress, and notifies every listening screen through
/// [NoorScope]. A change made once — live prayer times arriving,
/// a streak updating — propagates to all tabs without any screen
/// fetching its own copy.
class NoorController extends ChangeNotifier {
  NoorController();

  PrayerDay? _liveDay;
  PrayerDay? get liveDay => _liveDay;
  bool get isLive => _liveDay != null && _liveDay!.isLive;

  String _userName = NoorAppState.userName;
  String get userName => _userName;

  Map<String, int> _streaks = {
    for (final s in NoorAppState.streaks) s.$1: s.$2,
  };
  Map<String, int> get streaks => Map.unmodifiable(_streaks);

  /// Next-prayer label every screen should show right now: the live
  /// day's next prayer when we have one, otherwise the canonical
  /// demo snapshot (which matches the live fallback by construction).
  String get nextPrayerLabel {
    final day = _liveDay;
    if (day != null) {
      final next = day.nextPrayer();
      return '${next.name.toUpperCase()} ${next.timeLabel}';
    }
    return '${NoorAppState.nextPrayerName} ${NoorAppState.nextPrayerTime}';
  }

  String get sourceLabel => isLive ? 'Live' : NoorAppState.sourceLabel;

  /// Replace today's prayer day (called by Home after its live
  /// fetch, and by any future background refresh). All listening
  /// screens rebuild with the same times.
  void setLiveDay(PrayerDay day) {
    if (identical(_liveDay, day)) return;
    _liveDay = day;
    notifyListeners();
  }

  void setUserName(String name) {
    if (name == _userName || name.trim().isEmpty) return;
    _userName = name.trim();
    notifyListeners();
  }

  void setStreak(String label, int days) {
    if (_streaks[label] == days) return;
    _streaks = {..._streaks, label: days};
    notifyListeners();
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
