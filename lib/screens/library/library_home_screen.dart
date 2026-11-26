import 'package:flutter/material.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../home/profile_screen.dart';
import '../home/settings_screen.dart';
import '../worship/fasting_ramadan_screen.dart';
import '../worship/islamic_calendar_screen.dart';
import '../worship/salah_guide_screen.dart';
import '../worship/zakat_calculator_screen.dart';
import 'dua_library_screen.dart';
import 'hadith_library_screen.dart';
import 'hajj_umrah_screen.dart';
import 'islamic_academy_screen.dart';
import 'saved_content_screen.dart';
import 'share_card_studio_screen.dart';

/// Library & Knowledge hub. Surfaces the core Hadith/Dua collections,
/// new offline Islamic learning & worship tools, studio, and preferences.
class LibraryHomeScreen extends StatelessWidget {
  const LibraryHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    void push(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
return Material(
      color: NoorTheme.background(context),
      child: SafeArea(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            children: [
          Semantics(
              header: true,
              child: Text('Library',
                  style: NoorType.screenTitle
                      .copyWith(color: NoorTheme.foreground(context)))),
          const SizedBox(height: 6),
          Text('Hadith, duas, learning guides, worship calculators & studio.',
              style: NoorType.secondary
                  .copyWith(color: NoorTheme.muted(context))),
          const SizedBox(height: 18),
          Semantics(
              header: true,
              child: Text('KNOWLEDGE & GUIDES',
                  style: NoorType.eyebrow
                      .copyWith(color: NoorTheme.muted(context)))),
          const SizedBox(height: 10),
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
              Icons.school_outlined,
              'Islamic Academy',
              '5 Pillars, 99 Names & knowledge quiz',
              () => push(const IslamicAcademyScreen())),
          const SizedBox(height: 12),
          _row(
              context,
              Icons.accessibility_new_outlined,
              'Salah & Wudu Guide',
              'Step-by-step prayer, Qada & Tahajjud',
              () => push(const SalahGuideScreen())),
          const SizedBox(height: 12),
          _row(
              context,
              Icons.mosque_outlined,
              'Hajj & Umrah Guide',
              'Ritual steps, Ihram rules, Tawaf & Sa\'i counters',
              () => push(const HajjUmrahScreen())),
          const SizedBox(height: 18),
          Semantics(
              header: true,
              child: Text('WORSHIP TOOLS & STUDIO',
                  style: NoorType.eyebrow
                      .copyWith(color: NoorTheme.muted(context)))),
          const SizedBox(height: 10),
          _row(
              context,
              Icons.nights_stay_outlined,
              'Fasting & Ramadan Tracker',
              'Suhoor/Iftar times, Qada & Sunnah fasts',
              () => push(const FastingRamadanScreen())),
          const SizedBox(height: 12),
          _row(
              context,
              Icons.calendar_month_outlined,
              'Hijri Calendar & Events',
              'Moon sighting adjustment & date converter',
              () => push(const IslamicCalendarScreen())),
          const SizedBox(height: 12),
          _row(
              context,
              Icons.calculate_outlined,
              'Zakat & Sadaqah Calculator',
              'Nisab threshold check & donation ledger',
              () => push(const ZakatCalculatorScreen())),
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
        ])),
    );
  }

  Widget _row(BuildContext context, IconData icon, String title, String sub,
          VoidCallback onTap) =>
      NoorCard(
          onTap: onTap,
          child: Row(children: [
            Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: NoorTheme.softSurface(context),
                    shape: BoxShape.circle),
                child: Icon(icon, color: NoorTheme.accent(context), size: 22)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: NoorType.cardTitle),
                  const SizedBox(height: 3),
                  Text(sub,
                      style: NoorType.meta
                          .copyWith(color: NoorTheme.muted(context)))
                ])),
            ExcludeSemantics(
                child: Icon(Icons.chevron_right,
                    color: NoorTheme.muted(context), size: 19)),
          ]));
}
