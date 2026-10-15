import 'package:flutter/material.dart';
import '../../data/firebase_rest_service.dart';
import '../../data/noor_controller.dart';
import '../../data/sample_data.dart';
import '../../widgets/noor_components.dart';
import '../auth/login_screen.dart';
import '../onboarding/language_selection_screen.dart';
import '../worship/reminder_center_screen.dart';
import '../../theme/noor_theme.dart';
import 'profile_screen.dart';

/// Page 13 — Settings. Dark emerald header with the real lantern
/// crop from the user's Page 13 PNG, overlapping profile card
/// (user name + email), then Account / App Preferences /
/// Support & About grouped rows with right-side values, Log Out.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await FirebaseRestService().currentProfile();
      if (profile != null && mounted) {
        setState(() {
          _userName = profile.name;
          _userEmail = profile.email;
        });
      }
    } catch (_) {
      // Keep blank until the real profile loads — never placeholder data.
    }
  }

  static const _iconsA = [
    Icons.person_outline,
    Icons.shield_outlined,
    Icons.notifications_none,
    Icons.language
  ];
  static const _iconsP = [
    Icons.dark_mode_outlined,
    Icons.format_size,
    Icons.headphones_outlined,
    Icons.cloud_outlined
  ];
  static const _iconsS = [
    Icons.help_outline,
    Icons.chat_bubble_outline,
    Icons.info_outline,
    Icons.star_border
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? NoorColors.darkBg : NoorColors.cream,
      body: SafeArea(
          child: ListView(padding: EdgeInsets.zero, children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(
              height: 168,
              color: NoorColors.emeraldDark,
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
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
                            stops: [0, 0.3]).createShader(rect),
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(NoorAssets.settingsLanterns,
                            width: 140,
                            cacheWidth: 420,
                            height: 168,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink()))),
                Row(children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 19),
                      onPressed: () => Navigator.of(context).maybePop()),
                  Expanded(
                      child: Text('Settings',
                          textAlign: TextAlign.center,
                          style: NoorType.screenTitle.copyWith(color: Colors.white))),
                  const SizedBox(width: 48),
                ]),
              ])),
          Positioned(
              left: 20,
              right: 20,
              bottom: -38,
              child: Material(
                  color: isDark ? NoorColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(NoorRadius.card),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(NoorRadius.card),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ProfileScreen())),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: isDark ? NoorColors.darkCard : Colors.white,
                            borderRadius:
                                BorderRadius.circular(NoorRadius.card),
                            border: isDark ? Border.all(color: NoorColors.darkBorder) : null,
                            boxShadow: isDark ? null : NoorShadows.card),
                        child: Row(children: [
                          const NoorAvatar(size: 54),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                Text(_userName,
                                    style: NoorType.cardTitle.copyWith(
                                        color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Text(_userEmail,
                                    style: NoorType.meta.copyWith(
                                        color: isDark ? NoorColors.darkTextSecondary : NoorColors.muted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ])),
                          Icon(Icons.chevron_right,
                              color: isDark ? NoorColors.darkTextSecondary : NoorColors.muted, size: 20),
                        ])),
                  ))),
        ]),
        const SizedBox(height: 54),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _group(context, 'Account', SampleData.settingsAccount,
                      _iconsA),
                  _group(context, 'App Preferences', SampleData.settingsPrefs,
                      _iconsP),
                  _group(context, 'Support & About',
                      SampleData.settingsSupport, _iconsS),
                  const SizedBox(height: 6),
                  SizedBox(
                      width: double.infinity,
                      height: NoorSizes.buttonHeight,
                      child: OutlinedButton.icon(
                          icon: Icon(Icons.logout,
                              size: 19,
                              color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark),
                          label: Text('Log Out',
                              style: TextStyle(
                                  color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
                                  fontWeight: FontWeight.w700)),
                          onPressed: () async {
                            await FirebaseRestService().logout();
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (_) => false);
                          },
                          style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(NoorRadius.button)),
                              side: BorderSide(
                                  color: isDark ? NoorColors.darkBorder : NoorColors.hairline)))),
                ])),
      ])),
    );
  }

  void _showThemeSheet(BuildContext context) {
    final controller = NoorScope.of(context);
    if (controller == null) return;
    final currentPref = controller.themePreference;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('App Theme',
                    style: NoorType.screenTitle.copyWith(
                        color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink)),
                const SizedBox(height: 4),
                Text(
                  'Choose how NOOR adjusts its display. Automatic Solar switches to Midnight Emerald between Maghrib and Fajr.',
                  style: NoorType.secondary.copyWith(
                      color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark),
                ),
                const SizedBox(height: 18),
                NoorOptionTile(
                  label: 'Solar (Auto post-Maghrib)',
                  sublabel: 'Midnight Emerald at night (sunset to dawn); cream in daylight',
                  leading: const Icon(Icons.wb_twilight, color: NoorColors.amber, size: 22),
                  selected: currentPref == NoorThemePreference.solar,
                  onTap: () {
                    controller.setThemePreference(NoorThemePreference.solar);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const SizedBox(height: 10),
                NoorOptionTile(
                  label: 'Midnight Emerald (Dark)',
                  sublabel: 'Always deep forest dark mode (#061812 / #0D271E)',
                  leading: const Icon(Icons.dark_mode, color: NoorColors.gold, size: 22),
                  selected: currentPref == NoorThemePreference.dark,
                  onTap: () {
                    controller.setThemePreference(NoorThemePreference.dark);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const SizedBox(height: 10),
                NoorOptionTile(
                  label: 'Light (Cream & Emerald)',
                  sublabel: 'Classic warm cream background and crisp white cards',
                  leading: const Icon(Icons.light_mode, color: NoorColors.amber, size: 22),
                  selected: currentPref == NoorThemePreference.light,
                  onTap: () {
                    controller.setThemePreference(NoorThemePreference.light);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const SizedBox(height: 10),
                NoorOptionTile(
                  label: 'System Default',
                  sublabel: 'Follow your device operating system theme setting',
                  leading: const Icon(Icons.settings_brightness, color: NoorColors.mutedDark, size: 22),
                  selected: currentPref == NoorThemePreference.system,
                  onTap: () {
                    controller.setThemePreference(NoorThemePreference.system);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  VoidCallback? _settingsTarget(BuildContext c, String label) =>
      switch (label) {
        'Profile' => () => Navigator.of(c)
            .push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
        'Notifications' => () => Navigator.of(c).push(
            MaterialPageRoute(builder: (_) => const ReminderCenterScreen())),
        'Language' => () => Navigator.of(c).push(
            MaterialPageRoute(builder: (_) => const LanguageSelectionScreen())),
        'Theme' => () => _showThemeSheet(c),
        _ => null,
      };

  Widget _group(BuildContext c, String title,
      List<(String, String, String)> rows, List<IconData> icons) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final controller = NoorScope.of(c);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: NoorType.cardTitle.copyWith(
              color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink)),
      const SizedBox(height: 12),
      Container(
          decoration: BoxDecoration(
              color: isDark ? NoorColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(NoorRadius.card),
              border: Border.all(
                  color: isDark ? NoorColors.darkBorder : NoorColors.hairline)),
          child: Column(children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                Divider(
                    height: 1,
                    indent: 62,
                    color: isDark ? NoorColors.darkBorder : NoorColors.hairline),
              NoorListRow(
                title: rows[i].$1,
                leading: Icon(icons[i],
                    size: 22,
                    color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark),
                subtitle: rows[i].$2,
                value: rows[i].$1 == 'Theme'
                    ? (controller?.themePreferenceLabel ?? rows[i].$3)
                    : (rows[i].$3.isEmpty ? null : rows[i].$3),
                onTap: _settingsTarget(c, rows[i].$1),
                trailing: _settingsTarget(c, rows[i].$1) == null
                    ? null
                    : Icon(Icons.chevron_right,
                        size: 18,
                        color: isDark
                            ? NoorColors.darkTextSecondary
                            : NoorColors.mutedDark),
              ),
            ],
          ])),
      const SizedBox(height: 20),
    ]);
  }
}
