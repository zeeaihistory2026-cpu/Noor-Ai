import 'package:flutter/material.dart';
import '../../data/daily_content_service.dart';
import '../../data/daily_content_actions.dart';
import '../../data/share_content.dart';
import '../library/share_card_studio_screen.dart';
import '../../data/firebase_rest_service.dart';
import '../../data/location_service.dart';
import '../../data/noor_store.dart';
import '../worship/salah_tracker_screen.dart';
import '../worship/prayer_settings_screen.dart';
import '../../data/noor_controller.dart';
import '../../data/prayer_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/quran_resume_card.dart';
import '../../widgets/prayer_hero_card.dart';
import 'ayat_of_the_day_screen.dart';
import 'dua_of_the_day_screen.dart';
import 'hadith_of_the_day_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../worship/zikr_tasbih_screen.dart';
import '../quran/quran_home_screen.dart';
import '../../widgets/daily_reflection_card.dart';
import '../library/hajj_umrah_screen.dart';
import '../library/halal_scanner_screen.dart';
import '../library/library_home_screen.dart';

/// Compact daily dashboard with current prayer times and saved reading progress.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  PrayerDay? _localDay;
  String _userName = '';
  int _ayahOffset = 0;
  final int _hadithOffset = 0;
  final int _duaOffset = 0;
  final _playback = DailyContentPlayback();
  Set<String> _savedIds = {};
  bool _savingDaily = false;
  @override
  void dispose() {
    _playback.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final ids = await NoorStore.getBookmarks();
    if (mounted) setState(() => _savedIds = ids.toSet());
  }

  Future<void> _saveDaily(DailyContentItem item, String kind) async {
    if (_savingDaily) return;
    _savingDaily = true;
    try {
      final saved = await DailyBookmarks.toggle(item, kind);
      await _loadSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                saved ? 'Saved to your library' : 'Removed from saved items')));
      }
    } finally {
      _savingDaily = false;
    }
  }

  void _audioChanged() {
    if (mounted) setState(() {});
    final error = _playback.error;
    if (mounted && error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      _playback.error = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLive();
    _loadSaved();
    _playback.addListener(_audioChanged);
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final savedName = await NoorStore.getUserName();
      if (savedName != null && savedName.isNotEmpty && mounted) {
        setState(() => _userName = savedName);
        return;
      }
      final profile = await FirebaseRestService().currentProfile();
      if (profile != null && mounted && profile.name.isNotEmpty) {
        setState(() => _userName = profile.name);
      }
    } catch (_) {}
  }

  /// Live next-prayer + Hijri from AlAdhan (using saved location / city).
  Future<void> _loadLive() async {
    try {
      // The app controller owns refreshes. A second request here can overwrite
      // a newer city or calculation method while the user is changing settings.
      if (NoorScope.read(context) != null) return;
      final day = await PrayerService().fetchTodayAuto();
      if (mounted) setState(() => _localDay = day);
    } catch (_) {
      // The local calculation remains available offline.
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final day = controller?.activeDay ??
        _localDay ??
        PrayerService.calculateOffline(
            location: LocationModel.defaultLocation,
            date: PrayerService.nowInLocation(LocationModel.defaultLocation));
    final next = controller?.nextPrayer ?? day.nextPrayer();
    final name = controller?.userName.isNotEmpty == true
        ? controller!.userName
        : _userName.isNotEmpty
            ? _userName
            : 'Guest';
    final accent = Theme.of(context).colorScheme.primary;
    final ayah = DailyContentService.getAyah(offset: _ayahOffset);
    final hadith = DailyContentService.getHadith(offset: _hadithOffset);
    final dua = DailyContentService.getDua(offset: _duaOffset);
    Future<void> open(Widget screen) async {
      await _playback.stop();
      if (!context.mounted) return;
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => screen));
      if (mounted) await _loadSaved();
    }

    Widget reminder(
            DailyContentItem item, String kind, IconData icon, Widget page) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NoorCard(
                key: ValueKey('home-$kind-card'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                radius: 18,
                onTap: () => open(page),
                child: Row(children: [
                  Container(
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? NoorColors.darkSurface
                              : NoorColors.emeraldSoft,
                          borderRadius: BorderRadius.circular(11)),
                      child: Icon(icon, color: accent, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            kind == 'hadith'
                                ? 'HADITH OF THE DAY'
                                : 'DAILY DUA',
                            style: NoorType.eyebrow.copyWith(color: accent)),
                        const SizedBox(height: 4),
                        Text(item.translation,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: NoorType.secondary),
                        const SizedBox(height: 3),
                        Text(item.reference,
                            style: NoorType.meta.copyWith(
                                color: NoorTheme.muted(context)))
                      ])),
                  IconButton(
                      tooltip: 'Read full $kind',
                      onPressed: () => open(page),
                      icon: const Icon(Icons.chevron_right, size: 21)),
                ])));
    return Material(
        color: Colors.transparent,
        child: SafeArea(
            child: RefreshIndicator(
          onRefresh: () async {
            if (controller != null) {
              await controller.loadLocation(forceRefresh: true);
            } else {
              await _loadLive();
            }
          },
          child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              children: [
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Assalamu Alaikum',
                            style: NoorType.secondary),
                        const SizedBox(height: 4),
                        Text(name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                NoorType.screenTitle.copyWith(color: accent)),
                      ])),
                  IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => open(const NotificationsScreen()),
                      icon: const Icon(Icons.notifications_none_outlined)),
                  const SizedBox(width: 8),
                  Semantics(
                      button: true,
                      label: 'Open Profile',
                      child: InkWell(
                          onTap: () => open(const ProfileScreen()),
                          customBorder: const CircleBorder(),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minWidth: 48, minHeight: 48),
                              child: Center(
                                  child: NoorAvatar(size: 42, name: name))))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: InkWell(
                          onTap: () async {
                            final picked =
                                await LocationService.showLocationPicker(
                                    context: context,
                                    current: controller?.currentLocation);
                            if (picked != null) {
                              await controller?.updateLocation(picked);
                              if (controller == null) await _loadLive();
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 16, color: accent),
                                    const SizedBox(width: 6),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                          Text(
                                              controller?.locationLabel ??
                                                  LocationModel
                                                      .defaultLocation.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: NoorType.meta.copyWith(
                                                  color: NoorTheme.foreground(
                                                      context))),
                                          Text(
                                              day.hijriDisplay.replaceAll(
                                                  ' (calculated)', ''),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: NoorType.meta.copyWith(
                                                  color:
                                                      NoorTheme.muted(context))),
                                        ])),
                                  ]))))),
                  IconButton(
                      tooltip: 'Prayer settings',
                      onPressed: () => open(const PrayerSettingsScreen()),
                      icon: const Icon(Icons.tune_outlined, size: 20)),
                ]),
                const SizedBox(height: 12),
                PrayerHeroCard(
                    key: const ValueKey('home-prayer'),
                    next: next,
                    onTap: () => open(const SalahTrackerScreen())),
                const SizedBox(height: 13),
                IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: _practice(Icons.menu_book_outlined, 'Quran',
                                () => open(const QuranHomeScreen()))),
                        const SizedBox(width: 9),
                        Expanded(
                            child: _practice(Icons.spa_outlined, 'Zikr',
                                () => open(const ZikrTasbihScreen()))),
                        const SizedBox(width: 9),
                        Expanded(
                            child: _practice(Icons.mosque_outlined, 'Salah',
                                () => open(const SalahTrackerScreen()))),
                      ]),
                ),
                const SizedBox(height: 9),
                IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: _practice(
                          Icons.location_city_outlined,
                          'Umrah & Hajj',
                          () => open(const HajjUmrahScreen()),
                          keyValue: 'home-umrah-hajj',
                        )),
                        const SizedBox(width: 9),
                        Expanded(
                            child: _practice(
                          Icons.qr_code_scanner_outlined,
                          'Halal Scanner',
                          () => open(const HalalScannerScreen(initialTab: 1)),
                          keyValue: 'home-halal-scanner',
                        )),
                      ]),
                ),
                const SizedBox(height: 20),
                Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Semantics(header: true, child: const Text('Daily inspiration',
                          style: NoorType.cardTitle)),
                      TextButton(
                          onPressed: () => open(const LibraryHomeScreen()),
                          child: const Text('Explore →'))
                    ]),
                const SizedBox(height: 10),
                DailyReflectionCard(
                    key: const ValueKey('home-ayah-card'),
                    item: ayah,
                    kind: 'ayah',
                    saved: _savedIds.contains('ayah:${ayah.id}'),
                    playing:
                        _playback.currentItemId == ayah.id && _playback.playing,
                    loading:
                        _playback.currentItemId == ayah.id && _playback.loading,
                    onOpen: () =>
                        open(AyatOfTheDayScreen(initialOffset: _ayahOffset)),
                    onListen: () =>
                        _playback.toggle(ayah, quran: true, context: context),
                    onSave: () => _saveDaily(ayah, 'ayah'),
                    onShare: () => open(ShareCardStudioScreen(
                        initialItem: ShareContentItem.fromDaily(
                            ayah, ShareContentType.ayah))),
                    onChange: () {
                      _playback.stop();
                      setState(() => _ayahOffset++);
                    }),
                const SizedBox(height: 12),
                reminder(hadith, 'hadith', Icons.auto_stories_outlined,
                    HadithOfTheDayScreen(initialOffset: _hadithOffset)),
                reminder(dua, 'dua', Icons.spa_outlined,
                    DuaOfTheDayScreen(initialOffset: _duaOffset)),
                const SizedBox(height: 8),
                const QuranResumeCard(compact: true),
              ]),
        )));
  }

  Widget _practice(IconData icon, String title, VoidCallback onTap,
          {String? keyValue}) =>
      NoorCard(
          key: ValueKey(keyValue ?? 'home-${title.toLowerCase()}'),
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
          onTap: onTap,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 7),
            Text(title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NoorType.meta)
          ]));
}
