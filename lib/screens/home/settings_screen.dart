import 'package:flutter/material.dart';
import '../../data/firebase_rest_service.dart';
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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: ListView(padding: EdgeInsets.zero, children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
                height: 168,
                color: NoorColors.emeraldDark,
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
                child: Stack(children: [
                  // Full-width header band (Page 13): the crop's patterned
                  // emerald fills the header, lantern hanging at right.
                  // Lantern strip at natural scale, right side only
                  // (Phase 11b): stretching this tall crop across the
                  // full header width blew the lantern up and cropped
                  // it at the edge. Left edge fades into the emerald.
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NoorRadius.card),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(NoorRadius.card),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ProfileScreen())),
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(NoorRadius.card),
                              boxShadow: NoorShadows.card),
                          child: Row(children: [
                            const NoorAvatar(size: 54),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(_userName,
                                      style: NoorType.cardTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 3),
                                  Text(_userEmail,
                                      style: NoorType.meta.copyWith(color: NoorColors.muted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ])),
                            const Icon(Icons.chevron_right,
                                color: NoorColors.muted, size: 20),
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
                        height: 54,
                        child: OutlinedButton.icon(
                            icon: const Icon(Icons.logout,
                                size: 19, color: NoorColors.emeraldDark),
                            label: const Text('Log Out',
                                style: TextStyle(
                                    color: NoorColors.ink,
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
                                    borderRadius: BorderRadius.circular(14)),
                                side: const BorderSide(
                                    color: NoorColors.hairline)))),
                  ])),
        ])),
      );
  VoidCallback? _settingsTarget(BuildContext c, String label) =>
      switch (label) {
        'Profile' => () => Navigator.of(c)
            .push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
        'Notifications' => () => Navigator.of(c).push(
            MaterialPageRoute(builder: (_) => const ReminderCenterScreen())),
        'Language' => () => Navigator.of(c).push(
            MaterialPageRoute(builder: (_) => const LanguageSelectionScreen())),
        _ => null,
      };

  Widget _group(BuildContext c, String title,
          List<(String, String, String)> rows, List<IconData> icons) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: NoorType.cardTitle),
        const SizedBox(height: 12),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NoorRadius.card),
                border: Border.all(color: NoorColors.hairline)),
            child: Column(children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  const Divider(
                      height: 1, indent: 62, color: NoorColors.hairline),
                NoorListRow(
                  title: rows[i].$1,
                  leading:
                      Icon(icons[i], size: 22, color: NoorColors.emeraldDark),
                  subtitle: rows[i].$2,
                  value: rows[i].$3.isEmpty ? null : rows[i].$3,
                  onTap: _settingsTarget(c, rows[i].$1),
                  trailing: _settingsTarget(c, rows[i].$1) == null
                      ? null
                      : const Icon(Icons.chevron_right,
                          size: 18, color: NoorColors.mutedDark),
                ),
              ],
            ])),
        const SizedBox(height: 20),
      ]);
}
