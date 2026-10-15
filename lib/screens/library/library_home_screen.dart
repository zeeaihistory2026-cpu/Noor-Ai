import 'package:flutter/material.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../home/profile_screen.dart';
import '../home/settings_screen.dart';
import 'dua_library_screen.dart';
import 'hadith_library_screen.dart';
import 'saved_content_screen.dart';
import 'share_card_studio_screen.dart';

/// Library tab hub (Pages 15/18/19/33 entry). Keeps the design's
/// emerald/cream card language; each row pushes its real screen.
class LibraryHomeScreen extends StatelessWidget {
  const LibraryHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    void push(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    return SafeArea(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            children: [
          Text('Library',
              style: NoorType.screenTitle.copyWith(color: NoorColors.emeraldDark)),
          const SizedBox(height: 6),
          Text('Hadith, duas, share studio and saved content.',
              style: NoorType.secondary.copyWith(color: NoorColors.muted)),
          const SizedBox(height: 18),
          _row(context, Icons.menu_book_outlined, 'Hadith Library',
              'Authentic collections', () => push(const HadithLibraryScreen())),
          const SizedBox(height: 12),
          _row(
              context,
              Icons.volunteer_activism_outlined,
              'Dua & Adhkar',
              'Morning, evening & situations',
              () => push(const DuaLibraryScreen())),
          const SizedBox(height: 12),
          _row(
              context,
              Icons.image_outlined,
              'Share Card Studio',
              'Create beautiful share cards',
              () => push(const ShareCardStudioScreen())),
          const SizedBox(height: 12),
          _row(context, Icons.bookmark_border, 'Saved Content',
              'Bookmarks & notes', () => push(const SavedContentScreen())),
          const SizedBox(height: 12),
          _row(
              context,
              Icons.person_outline,
              'Profile',
              'Journey, goals & preferences',
              () => push(const ProfileScreen())),
          const SizedBox(height: 12),
          _row(
              context,
              Icons.settings_outlined,
              'Settings',
              'Account, theme, language & about',
              () => push(const SettingsScreen())),
        ]));
  }

  Widget _row(BuildContext context, IconData icon, String title, String sub,
          VoidCallback onTap) =>
      NoorCard(
          onTap: onTap,
          child: Row(children: [
            Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                    color: NoorColors.emeraldSoft, shape: BoxShape.circle),
                child: Icon(icon, color: NoorColors.emeraldDark, size: 22)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: NoorType.cardTitle),
                  const SizedBox(height: 3),
                  Text(sub,
                      style: NoorType.meta.copyWith(color: NoorColors.muted))
                ])),
            const Icon(Icons.chevron_right, color: NoorColors.muted, size: 19),
          ]));
}
