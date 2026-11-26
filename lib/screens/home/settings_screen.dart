import 'package:flutter/material.dart';
import '../../data/noor_controller.dart';
import '../../data/noor_store.dart';
import '../../data/location_service.dart';
import '../../data/daily_content_actions.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../auth/login_screen.dart';
import '../onboarding/language_selection_screen.dart';
import '../quran/quran_audio_player_screen.dart';
import '../worship/prayer_settings_screen.dart';
import '../worship/reminder_center_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'English';
  double _scale = 1;
  final _speech = DailyContentPlayback();
  @override
  void initState() {
    super.initState();
    _load();
    _speech.addListener(_speechChanged);
  }

  @override
  void dispose() {
    _speech.removeListener(_speechChanged);
    _speech.dispose();
    super.dispose();
  }

  void _speechChanged() {
    if (mounted && _speech.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_speech.error!)));
      _speech.error = null;
    }
  }

  Future<void> _load() async {
    final language = await NoorStore.getLanguage();
    final scale = await NoorStore.getTextScale();
    if (mounted) {
      setState(() {
        _language = language;
        _scale = scale;
      });
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final scale = controller?.textScale ?? _scale;
    final theme = controller?.themePreferenceLabel ?? 'Light';
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
              const Text('Make MuslimGo yours', style: NoorType.screenTitle),
              const SizedBox(height: 6),
              const Text('Reading, prayer times and daily reminders.',
                  style: NoorType.secondary),
              const SizedBox(height: 24),
              _group('Appearance', [
                _row(Icons.light_mode_outlined, 'Theme', theme,
                    () => _themePicker(controller)),
                _row(Icons.text_fields_outlined, 'Text size',
                    '${(scale * 100).round()}%', () => _textPicker(controller)),
              ]),
              _group('Reading & audio', [
                _row(Icons.language_outlined, 'Reading language', _language,
                    () => _open(const LanguageSelectionScreen(editing: true))),
                _row(Icons.headphones_outlined, 'Quran recitation',
                    'Reciter, speed and playback range', () async {
                  final position = await NoorStore.getReadingPosition();
                  if (mounted) {
                    await _open(QuranAudioPlayerScreen(
                        surah: position?.$1 ?? 1,
                        initialAyah: position?.$2 ?? 1));
                  }
                }),
                _row(
                    Icons.record_voice_over_outlined,
                    'Daily male narrator',
                    'Preview and choose a voice for Hadith & Dua',
                    () => _speech.selectNarrator(context)),
              ]),
              _group('Prayer & reminders', [
                _row(
                    Icons.location_on_outlined,
                    'Location',
                    controller?.locationLabel ??
                        LocationModel.defaultLocation.label, () async {
                  final selected = await LocationService.showLocationPicker(
                      context: context, current: controller?.currentLocation);
                  if (selected != null) {
                    await controller?.updateLocation(selected);
                  }
                }),
                _row(
                    Icons.mosque_outlined,
                    'Prayer settings',
                    'Calculation method and Asr convention',
                    () => _open(const PrayerSettingsScreen())),
                _row(
                    Icons.notifications_none_outlined,
                    'Notifications',
                    'Azan, prayer and daily-content alerts',
                    () => _open(const ReminderCenterScreen())),
              ]),
              _group('Help & information', [
                _row(
                    Icons.offline_bolt_outlined,
                    'Offline content',
                    'What is available without internet',
                    () => _info('Offline content',
                        'The complete Arabic Quran, English and Urdu translations, and 548-page 16-line Mushaf are included. Opened Hadith editions cache on this device. Recorded Quran audio streams need an internet connection.')),
                _row(
                    Icons.shield_outlined,
                    'Privacy & security',
                    'Your account and saved data',
                    () => _info('Privacy & security',
                        'Your account session uses platform secure storage. Bookmarks, settings and worship progress are saved on this device. Keep your device protected and sign out before sharing it.')),
                _row(
                    Icons.help_outline,
                    'Help',
                    'Prayer times, notifications and reading',
                    () => _info('Help',
                        'Prayer times: choose your location, calculation method and Asr convention.\n\nNotifications: allow notifications and exact alarms, then use the tests in Notifications.\n\nReading: use the language tabs in the Quran Reader. Your reading position is saved.')),
                _row(
                    Icons.info_outline,
                    'About MuslimGo',
                    'Version 1.0.4',
                    () => showAboutDialog(
                            context: context,
                            applicationName: 'MuslimGo',
                            applicationVersion: '1.0.4',
                            children: [
                              const Text(
                                  'Quran, worship, duas and Hadith in one daily companion.')
                            ])),
              ]),
              if (controller?.isGuest != false)
                FilledButton(
                    onPressed: () => _open(const LoginScreen()),
                    child: const Text('Sign in / Create account'))
              else
                OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                                  title: const Text('Sign out?'),
                                  content: const Text(
                                      'Your saved items and worship log stay on this device.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: const Text('Cancel')),
                                    FilledButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Sign out'))
                                  ]));
                      if (confirmed != true) return;
                      await controller?.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (_) => false);
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out')),
            ])));
  }

  Widget _group(String title, List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: NoorType.eyebrow),
        const SizedBox(height: 10),
        NoorCard(
            padding: EdgeInsets.zero,
            radius: 18,
            child: Column(children: [
              for (int i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 54),
                rows[i]
              ]
            ])),
      ]));
  Widget _row(
          IconData icon, String title, String detail, VoidCallback onTap) =>
      ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          leading: Icon(icon,
              size: 22, color: Theme.of(context).colorScheme.primary),
          title: Text(title, style: NoorType.body),
          subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(detail, style: NoorType.meta)),
          trailing: const Icon(Icons.chevron_right, size: 20));
  void _info(String title, String description) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: NoorType.screenTitle),
                    const SizedBox(height: 14),
                    Text(description, style: NoorType.body),
                    const SizedBox(height: 20),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Done')))
                  ]))));
  void _themePicker(NoorController? controller) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Appearance', style: NoorType.screenTitle),
                    const SizedBox(height: 6),
                    const Text('Bright mode is the default.',
                        style: NoorType.secondary),
                    const SizedBox(height: 18),
                    for (final option in [
                      (
                        NoorThemePreference.light,
                        'Bright',
                        'Cream, white and emerald'
                      ),
                      (
                        NoorThemePreference.dark,
                        'Dark',
                        'Deep emerald and light text'
                      ),
                      (
                        NoorThemePreference.system,
                        'System',
                        'Follow your device'
                      ),
                      (
                        NoorThemePreference.solar,
                        'Sunset to dawn',
                        'Optional automatic night mode'
                      )
                    ])
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: NoorOptionTile(
                              label: option.$2,
                              sublabel: option.$3,
                              selected: (controller?.themePreference ??
                                      NoorThemePreference.light) ==
                                  option.$1,
                              onTap: () async {
                                await controller?.setThemePreference(option.$1);
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              })),
                  ]))));
  void _textPicker(NoorController? controller) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Text size', style: NoorType.screenTitle),
                    const SizedBox(height: 8),
                    const Text(
                        'Adjusts the app in addition to your device’s text-size setting.',
                        style: NoorType.secondary),
                    const SizedBox(height: 18),
                    for (final option in [
                      (0.9, 'Small'),
                      (1.0, 'Standard'),
                      (1.15, 'Large'),
                      (1.3, 'Extra large')
                    ])
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: NoorOptionTile(
                              label: option.$2,
                              selected: (controller?.textScale ?? _scale) ==
                                  option.$1,
                              onTap: () async {
                                if (controller != null) {
                                  await controller.setTextScale(option.$1);
                                } else {
                                  await NoorStore.setTextScale(option.$1);
                                }
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                                await _load();
                              })),
                  ]))));
}
