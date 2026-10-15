import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../data/app_state.dart';
import '../../data/firebase_rest_service.dart';
import '../../widgets/noor_components.dart';
import '../../widgets/noor_share_card.dart';
import '../library/saved_content_screen.dart';
import '../onboarding/goal_selection_screen.dart';
import '../onboarding/language_selection_screen.dart';
import '../onboarding/madhhab_preference_screen.dart';
import 'my_journey_screen.dart';
import 'settings_screen.dart';

/// Page 34 — Profile. Emerald header, profile initial circle,
/// user name, journey summary emerald card, then the 7
/// outline rows as drawn (chevron right), wired where screens exist.
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
      final profile = await FirebaseRestService().currentProfile();
      if (profile != null && mounted && profile.name.trim().isNotEmpty) {
        setState(() {
          _userName = profile.name.trim();
          _userEmail = profile.email;
        });
      }
    } catch (_) {
      // Keep blank until the real profile loads — never a placeholder name.
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
              const Center(child: NoorAvatar(size: 118)),
              const SizedBox(height: 16),
              Center(
                  child: Text(_userName,
                      style: NoorType.screenTitle)),
              if (_userEmail.isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                    child: Text(_userEmail,
                        style: NoorType.secondary.copyWith(color: NoorColors.muted))),
              ],
              const SizedBox(height: 4),
              Center(
                  child: Text(SampleData.profileTags,
                      style: NoorType.secondary.copyWith(color: NoorColors.muted))),
              const SizedBox(height: 20),
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
                  // Phase 16 audit: chevron only where a real target
                  // exists (Privacy/Subscription have no screen yet —
                  // no fake chevron, no dead tap).
                  trailing: targets[r] == null
                      ? null
                      : const Icon(Icons.chevron_right,
                          size: 19, color: NoorColors.mutedDark),
                  onTap: targets[r] == null ? null : () => push(targets[r]!),
                ),
                const SizedBox(height: 10),
              ],
            ])),
      ])),
    );
  }
}
