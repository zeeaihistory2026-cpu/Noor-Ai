import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../data/app_state.dart';
import '../../data/firebase_rest_service.dart';
import '../../data/noor_controller.dart';
import '../../data/noor_store.dart';
import '../../widgets/noor_components.dart';
import '../auth/login_screen.dart';
import '../library/saved_content_screen.dart';
import '../onboarding/goal_selection_screen.dart';
import '../onboarding/language_selection_screen.dart';
import '../onboarding/madhhab_preference_screen.dart';
import 'my_journey_screen.dart';
import 'settings_screen.dart';

/// Page 34 — Profile. Emerald header, profile initial circle,
/// user name, journey summary emerald card, then the outline rows
/// as drawn, and sign in / sign out actions.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final savedName = await NoorStore.getUserName();
      final savedEmail = await NoorStore.getUserEmail();
      if (savedName != null && savedName.isNotEmpty && mounted) {
        setState(() {
          _userName = savedName;
          _userEmail = savedEmail ?? '';
        });
        return;
      }
      final profile = await FirebaseRestService().currentProfile();
      if (profile != null && mounted && profile.name.trim().isNotEmpty) {
        setState(() {
          _userName = profile.name.trim();
          _userEmail = profile.email;
        });
      }
    } catch (_) {
      // Handled
    }
  }

  static IconData _profileIcon(String r) => switch (r) {
        'Goals & Preferences' => Icons.flag_outlined,
        'Madhhab Preference' => Icons.menu_book_outlined,
        'Language' => Icons.language,
        'Saved Content' => Icons.bookmark_border,
        'Privacy' => Icons.shield_outlined,
        'Subscription' => Icons.workspace_premium_outlined,
        _ => Icons.settings_outlined,
      };

  static String? _profileValue(String r) => switch (r) {
        'Goals & Preferences' => 'Quran · Salah',
        'Madhhab Preference' => 'Hanafi',
        'Language' => 'English',
        'Saved Content' => '12 items',
        'Subscription' => 'Free',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final currentName = (controller?.userName.isNotEmpty == true)
        ? controller!.userName
        : (_userName.isNotEmpty ? _userName : '');
    final currentEmail = (controller?.userEmail.isNotEmpty == true)
        ? controller!.userEmail
        : _userEmail;
    final isGuest = controller?.isGuest ?? (currentName.isEmpty || currentName == 'Guest');
    final displayName = currentName.isNotEmpty ? currentName : (isGuest ? 'Guest User' : 'Believer');

    void push(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    final targets = <String, Widget>{
      'Goals & Preferences': const GoalSelectionScreen(),
      'Madhhab Preference': const MadhhabPreferenceScreen(),
      'Language': const LanguageSelectionScreen(),
      'Saved Content': const SavedContentScreen(),
      'Settings': const SettingsScreen(),
    };

    return Scaffold(
      backgroundColor: NoorColors.cream,
      body: SafeArea(
          child: Column(children: [
        NoorPlainHeader(title: 'Profile', moreActions: [
          (
            Icons.settings_outlined,
            'Open Settings',
            () => push(const SettingsScreen())
          ),
          (
            Icons.bookmark_border,
            'Saved Content',
            () => push(const SavedContentScreen())
          ),
        ]),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
              Center(child: NoorAvatar(size: 118, name: displayName)),
              const SizedBox(height: 16),
              Center(
                  child: Text(displayName,
                      style: NoorType.screenTitle)),
              if (currentEmail.isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                    child: Text(currentEmail,
                        style: NoorType.secondary.copyWith(color: NoorColors.muted))),
              ],
              const SizedBox(height: 4),
              Center(
                  child: Text(SampleData.profileTags,
                      style: NoorType.secondary.copyWith(color: NoorColors.muted))),
              const SizedBox(height: 16),
              if (isGuest) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NoorRadius.card),
                    border: Border.all(color: NoorColors.gold.withValues(alpha: 0.5)),
                    boxShadow: NoorShadows.card,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NoorColors.gold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_outlined,
                            color: NoorColors.emeraldDark, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sync Your Journey',
                                style: NoorType.secondary.copyWith(
                                    fontWeight: FontWeight.w700, color: NoorColors.ink)),
                            const SizedBox(height: 2),
                            Text('Sign in or register to preserve streaks and data.',
                                style: NoorType.meta.copyWith(color: NoorColors.muted)),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => push(const LoginScreen()),
                        style: FilledButton.styleFrom(
                          backgroundColor: NoorColors.emeraldDark,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Material(
                  color: NoorColors.emeraldDark,
                  borderRadius: BorderRadius.circular(NoorRadius.card),
                  child: InkWell(
                      onTap: () => push(const MyJourneyScreen()),
                      borderRadius: BorderRadius.circular(NoorRadius.card),
                      child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: NoorColors.emeraldDark,
                              borderRadius:
                                  BorderRadius.circular(NoorRadius.card)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Journey',
                                    style: NoorType.cardTitle.copyWith(color: Colors.white)),
                                const SizedBox(height: 7),
                                Text(NoorAppState.journeyLine,
                                    style: NoorType.secondary.copyWith(color: Colors.white70)),
                              ])))),
              const SizedBox(height: 18),
              for (final r in SampleData.profileRows) ...[
                NoorListRow(
                  title: r,
                  leading: Icon(_profileIcon(r), color: NoorColors.emeraldDark),
                  value: _profileValue(r),
                  trailing: targets[r] == null
                      ? null
                      : const Icon(Icons.chevron_right,
                          size: 19, color: NoorColors.mutedDark),
                  onTap: targets[r] == null ? null : () => push(targets[r]!),
                ),
                const SizedBox(height: 10),
              ],
              if (!isGuest) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await controller?.logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, size: 18, color: NoorColors.error),
                    label: Text('Log Out',
                        style: NoorType.secondary.copyWith(
                            color: NoorColors.error, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: NoorColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NoorRadius.button)),
                    ),
                  ),
                ),
              ],
            ])),
      ])),
    );
  }
}
