import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/firebase_rest_service.dart';
import '../worship/salah_tracker_screen.dart';
import '../../data/noor_controller.dart';
import '../../data/prayer_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../ai/ai_assistant_home_screen.dart';
import '../quran/quran_reader_screen.dart';
import 'dua_of_the_day_screen.dart';
import 'hadith_of_the_day_screen.dart';
import 'my_journey_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

/// Page 01 — Home Dashboard. Greeting + Hijri date, Next Prayer
/// ASR card with the mosque artwork cropped from the design,
/// Salah/Dhikr/Quran streak cards, Dua of the Day, Hadith of the
/// Day, Continue Quran (Al-Kahf 76%) and Ask AI input.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  // Initialised from the design's sample data so the screen renders
  // identically offline; replaced in place when live data arrives.
  String _hijriDate = NoorAppState.hijriLabel;
  String _nextPrayer = NoorAppState.nextPrayerName;
  String _nextPrayerTime = NoorAppState.nextPrayerTime;
  String _nextPrayerIn = '${NoorAppState.nextPrayerCountdown} remaining';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadLive();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final profile = await FirebaseRestService().currentProfile();
      if (profile != null && mounted) {
        setState(() => _userName = profile.name);
      }
    } catch (_) {}
  }

  /// Phase 6: live next-prayer + Hijri from AlAdhan, with the
  /// service's cache/sample fallback. UI layout is unchanged —
  /// only the four strings below are swapped when live data lands.
  Future<void> _loadLive() async {
    try {
      final service = PrayerService();
      final day = await service.fetchTodayByCity();
      if (!mounted || !day.isLive) return;
      final next = day.nextPrayer();
      // Phase 13: publish the live day to the app-wide store so
      // every other screen shows the same times (one truth, live).
      NoorScope.read(context)?.setLiveDay(day);
      setState(() {
        _hijriDate = day.hijriDisplay;
        _nextPrayer = next.name.toUpperCase();
        _nextPrayerTime = next.timeLabel;
        _nextPrayerIn = next.remainingLabel;
      });
    } catch (_) {
      // Sample values already on screen — never break offline.
    }
  }

  @override
  Widget build(BuildContext context) {
    void push(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          // Greeting row (bell with red dot + dome avatar in design).
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assalamu Alaikum,',
                        style: NoorType.body),
                    const SizedBox(height: 2),
                    Text(_userName.isNotEmpty ? _userName : '',
                        style: NoorType.display.copyWith(color: NoorColors.emeraldDark)),
                    const SizedBox(height: 3),
                    Text(_hijriDate,
                        style: NoorType.secondary.copyWith(color: NoorColors.emerald)),
                  ]),
            ),
            Stack(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: NoorShadows.card),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none,
                      color: NoorColors.ink, size: 21),
                  onPressed: () => push(const NotificationsScreen()),
                ),
              ),
              const Positioned(
                  right: 11,
                  top: 10,
                  child: CircleAvatar(
                      radius: 4, backgroundColor: NoorColors.gold)),
            ]),
            const SizedBox(width: 12),
            // Avatar shows the logged-in user's initials; tap opens profile.
            GestureDetector(
              onTap: () => push(const ProfileScreen()),
              child: NoorAvatar(size: 46, name: _userName),
            ),
          ]),
          const SizedBox(height: 18),
          // Next Prayer hero — mosque art cropped from Page 01 (tappable to Salah Tracker).
          Semantics(
            button: true,
            label: 'Next prayer: $_nextPrayer at $_nextPrayerTime, tap to open Salah Tracker',
            child: Container(
              constraints: const BoxConstraints(
                  minHeight: NoorSizes.nextPrayerCardMinHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(NoorRadius.heroCard),
                boxShadow: NoorShadows.hero,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(NoorRadius.heroCard),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [NoorColors.emeraldDark, NoorColors.emeraldMid]),
                  ),
                  child: InkWell(
                    onTap: () => push(const SalahTrackerScreen()),
                    splashColor: NoorColors.gold.withValues(alpha: 0.25),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Stack(children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: ShaderMask(
                            shaderCallback: (rect) => const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Colors.transparent, Colors.white],
                                stops: [0, 0.6]).createShader(rect),
                            blendMode: BlendMode.dstIn,
                            child: Image.asset(NoorAssets.nextPrayerMosque,
                                width: 218,
                                cacheWidth: 654,
                                fit: BoxFit.cover,
                                alignment: Alignment.centerRight,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink())),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 150, 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('NEXT PRAYER',
                                      style: NoorType.meta.copyWith(color: Colors.white70,
                                          letterSpacing: 1.2)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Tracker',
                                            style: NoorType.meta.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 3),
                                        const Icon(Icons.arrow_forward_ios,
                                            size: 8, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(_nextPrayer,
                                  style: NoorType.display.copyWith(color: Colors.white)),
                              const SizedBox(height: 2),
                              Text(_nextPrayerTime,
                                  style: NoorType.screenTitle.copyWith(color: NoorColors.gold)),
                              const SizedBox(height: 8),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.schedule,
                                    color: Colors.white70, size: 15),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(_nextPrayerIn,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white70)),
                                ),
                              ]),
                            ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const NoorSectionLabel('Your Streaks'),
              Semantics(
                button: true,
                label: 'View all streaks',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => push(const MyJourneyScreen()),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.center,
                      child:
                          Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('View All',
                            style: NoorType.secondary.copyWith(color: NoorColors.emerald)),
                        const Icon(Icons.arrow_forward,
                            size: 15, color: NoorColors.emerald),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < NoorAppState.streaks.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                _streakCard(
                    [
                      'assets/images/streak_salah.png',
                      'assets/images/streak_dhikr.png',
                      'assets/images/streak_quran.png'
                    ][i],
                    NoorAppState.streaks[i].$1, NoorAppState.streaks[i].$2),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _contentCard(
            context,
            title: 'DUA OF THE DAY',
            arabic: SampleData.duaArabic,
            body:
                '${SampleData.duaTransliteration}\n${SampleData.duaTranslation}\n${SampleData.duaSource}',
            art: NoorAssets.duaHands,
            action: 'Share',
            onTap: () => push(const DuaOfTheDayScreen()),
          ),
          _contentCard(
            context,
            title: 'HADITH OF THE DAY',
            arabic: SampleData.hadithArabic,
            body: '${SampleData.hadithTranslation}\n${SampleData.hadithSource}',
            art: NoorAssets.quranRehal,
            action: 'Share',
            onTap: () => push(const HadithOfTheDayScreen()),
          ),
          NoorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NoorSectionLabel('Continue Quran'),
                          SizedBox(height: 10),
                          Text(SampleData.continueSurah,
                              style: NoorType.screenTitle),
                          SizedBox(height: 3),
                          Text(SampleData.continueAyah, style: NoorType.meta),
                          SizedBox(height: 14),
                        ]),
                  ),
                  ClipOval(
                    child: Image.asset(NoorAssets.surahCalligraphy,
                        width: 78,
                        cacheWidth: 234,
                        height: 78,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 78,
                            height: 78,
                            color: NoorColors.emeraldDark)),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                          value: SampleData.continueProgress,
                          minHeight: 6,
                          color: NoorColors.emerald,
                          backgroundColor: NoorColors.sand),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('76%', style: NoorType.tabular(NoorType.meta)),
                ]),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.menu_book, size: 19),
                    label: const Text('Continue Reading'),
                    onPressed: () => push(const QuranReaderScreen()),
                    style: FilledButton.styleFrom(
                      backgroundColor: NoorColors.emeraldDark,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(NoorRadius.button)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                color: NoorColors.emeraldSoft,
                borderRadius: BorderRadius.circular(NoorRadius.heroCard)),
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.auto_awesome, color: NoorColors.emerald, size: 17),
                const SizedBox(width: 7),
                Text('ASK YOUR AI COMPANION',
                    style: NoorType.meta.copyWith(letterSpacing: 0.6,
                        color: NoorColors.emeraldDark)),
              ]),
              const SizedBox(height: 6),
              Text("I'm here to help you in your journey.",
                  style: NoorType.secondary.copyWith(color: NoorColors.muted)),
              const SizedBox(height: 12),
              TextField(
                readOnly: true,
                onTap: () => push(const AiAssistantHomeScreen()),
                decoration: InputDecoration(
                  hintText: 'Ask anything about Islam...',
                  hintStyle:
                      NoorType.secondary.copyWith(color: NoorColors.muted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: NoorColors.emeraldDark, shape: BoxShape.circle),
                    child: const Icon(Icons.mic, color: Colors.white, size: 19),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NoorRadius.input),
                      borderSide: BorderSide.none),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _streakCard(String assetPath, String label, int days) {
    return Expanded(
      child: Container(
        height: NoorSizes.streakCardHeight + 18,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NoorRadius.card),
            boxShadow: NoorShadows.card),
        padding: const EdgeInsets.all(13),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Image.asset(assetPath, width: 26, height: 26, fit: BoxFit.contain),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: NoorType.secondary),
            ),
          ]),
          const SizedBox(height: 8),
          Text('$days',
              textAlign: TextAlign.center,
              style: NoorType.screenTitle),
          Text('Day Streak',
              textAlign: TextAlign.center,
              style: NoorType.meta.copyWith(color: NoorColors.muted)),
          const SizedBox(height: 8),
          // One flame badge + the real count (Phase 12): five
          // flames previously showed 4 lit for 12, 8 and 17 days
          // alike — decoration pretending to be data.
          Semantics(
            label: '$label streak, $days days',
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Icon(Icons.local_fire_department,
                  size: 15, color: NoorColors.amber),
              const SizedBox(width: 4),
              Text('$days days', style: NoorType.meta),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _contentCard(BuildContext context,
      {required String title,
      required String arabic,
      required String body,
      required String art,
      required String action,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NoorCard(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: NoorSectionLabel(title)),
            const Icon(Icons.bookmark_border,
                size: 18, color: NoorColors.muted),
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(arabic,
                        textDirection: TextDirection.rtl,
                        style: NoorType.arabic(size: 20)),
                    const SizedBox(height: 8),
                    Text(body,
                        style: NoorType.secondary.copyWith(height: 1.55)),
                  ]),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(art,
                  width: 92,
                  cacheWidth: 276,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 92, height: 92, color: NoorColors.emeraldSoft)),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.volume_up_outlined, size: 18),
              label: const Text('Listen'),
            ),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.favorite_border, size: 18),
              label: const Text('Save'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.share, size: 16),
              label: Text(action),
              style: FilledButton.styleFrom(
                backgroundColor: NoorColors.emeraldDark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
