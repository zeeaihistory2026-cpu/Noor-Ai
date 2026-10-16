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
  String _textSize = 'Medium';

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
      // Keep fallback
    }
  }

  static const _iconsA = [
    Icons.person_outline,
    Icons.shield_outlined,
    Icons.notifications_none,
    Icons.language,
  ];
  static const _iconsP = [
    Icons.dark_mode_outlined,
    Icons.format_size, // Replaced by custom 'Aa' widget in builder
    Icons.headphones_outlined,
    Icons.cloud_outlined,
  ];
  static const _iconsS = [
    Icons.help_outline,
    Icons.chat_bubble_outline,
    Icons.info_outline,
    Icons.star_border,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = _userName.isNotEmpty ? _userName : 'Abdullah Khan';
    final displayEmail = _userEmail.isNotEmpty ? _userEmail : 'abdullah.khan@email.com';

    return Scaffold(
      backgroundColor: isDark ? NoorColors.darkBg : NoorColors.cream,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 148,
                  color: NoorColors.emeraldDark,
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: ShaderMask(
                          shaderCallback: (rect) => const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.transparent, Colors.white],
                            stops: [0, 0.3],
                          ).createShader(rect),
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            NoorAssets.settingsLanterns,
                            width: 140,
                            cacheWidth: 420,
                            height: 148,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Settings',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -32,
                  child: Material(
                    color: isDark ? NoorColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? NoorColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                          ),
                          boxShadow: isDark ? null : NoorShadows.card,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: NoorColors.emeraldDark,
                                border: Border.all(
                                  color: const Color(0xFFCDAA6D),
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const NoorLogoBadge(
                                size: 26,
                                color: Color(0xFFCDAA6D),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    displayEmail,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: isDark ? NoorColors.darkTextSecondary : const Color(0xFF737D78),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isDark ? NoorColors.darkTextSecondary : const Color(0xFF9CA79E),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 44),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _group(context, 'Account', SampleData.settingsAccount, _iconsA),
                  _group(context, 'App Preferences', SampleData.settingsPrefs, _iconsP),
                  _group(context, 'Support & About', SampleData.settingsSupport, _iconsS),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? NoorColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? NoorColors.darkBorder : const Color(0xFF166857),
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          await FirebaseRestService().logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: isDark ? NoorColors.darkGold : const Color(0xFF166857),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                color: isDark ? NoorColors.darkTextPrimary : const Color(0xFF166857),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: isDark ? NoorColors.darkSurface : Colors.white,
        selectedIndex: 3,
        onDestinationSelected: (idx) {
          Navigator.of(context).maybePop();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Quran',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'Worship',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    final controller = NoorScope.of(context);
    if (controller == null) return;
    final currentPref = controller.themePreference;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                Text(
                  'App Theme',
                  style: NoorType.screenTitle.copyWith(
                    color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how NOOR adjusts its display. Automatic Solar switches to Midnight Emerald between Maghrib and Fajr.',
                  style: NoorType.secondary.copyWith(
                    color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark,
                  ),
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

  void _showTextSizeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setModalState) => SafeArea(
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
                  Text(
                    'Text Size',
                    style: NoorType.screenTitle.copyWith(
                      color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adjust typography size for Quran reading and app navigation.',
                    style: NoorType.secondary.copyWith(
                      color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final size in ['Small', 'Medium', 'Large', 'Extra Large']) ...[
                    NoorOptionTile(
                      label: size,
                      sublabel: size == 'Medium' ? 'Default application scale (100%)' : 'Custom typography scale',
                      leading: const Icon(Icons.format_size, color: NoorColors.emeraldDark, size: 22),
                      selected: _textSize == size,
                      onTap: () {
                        setState(() => _textSize = size);
                        setModalState(() {});
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSimpleSheet(BuildContext context, String title, String description, IconData icon) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: NoorColors.emeraldSoft,
                      child: Icon(icon, color: NoorColors.emeraldDark, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: NoorType.screenTitle.copyWith(
                          fontSize: 20,
                          color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: NoorType.secondary.copyWith(
                    color: isDark ? NoorColors.darkTextSecondary : NoorColors.mutedDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: NoorColors.emerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  VoidCallback _settingsTarget(BuildContext c, String label) => switch (label) {
        'Profile' => () => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
        'Privacy & Security' => () => _showSimpleSheet(
              c,
              'Privacy & Security',
              'Your data is stored securely on your device and encrypted in cloud transit. Offline authentication tokens are obfuscated using local cryptographic seeds.',
              Icons.shield_outlined,
            ),
        'Notifications' => () => Navigator.of(c).push(
              MaterialPageRoute(builder: (_) => const ReminderCenterScreen()),
            ),
        'Language' => () => Navigator.of(c).push(
              MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
            ),
        'Theme' => () => _showThemeSheet(c),
        'Text Size' => () => _showTextSizeSheet(c),
        'Audio Settings' => () => _showSimpleSheet(
              c,
              'Audio Settings',
              'Configure high-bitrate Quran reciters, background playback, and auto-pause intervals for contemplative listening.',
              Icons.headphones_outlined,
            ),
        'Data & Storage' => () => _showSimpleSheet(
              c,
              'Data & Storage',
              'Hadith books and Quran audio are cached directly in app files to prevent system bloat. Storage can be purged without losing bookmarks.',
              Icons.cloud_outlined,
            ),
        'Help Center' => () => _showSimpleSheet(
              c,
              'Help Center',
              'Explore guides on using Noor AI Companion, Qibla compass calibration, Salah prayer tracking, and voice features.',
              Icons.help_outline,
            ),
        'Send Feedback' => () => _showSimpleSheet(
              c,
              'Send Feedback',
              'We value your suggestions and bug reports. Thank you for helping us improve Noor AI Companion for the Ummah.',
              Icons.chat_bubble_outline,
            ),
        'About NOOR' => () => _showSimpleSheet(
              c,
              'About NOOR AI Companion',
              'Version 1.2.0 (Build 42). Built with reverence, authentic sources (Bukhari, Muslim, Tirmidhi), and state-of-the-art mobile engineering.',
              Icons.info_outline,
            ),
        'Rate NOOR' => () => _showSimpleSheet(
              c,
              'Rate NOOR',
              'If NOOR has enriched your daily spiritual journey, please leave a 5-star review on the App Store or Google Play.',
              Icons.star_border,
            ),
        _ => () {},
      };

  Widget _buildLeading(String label, IconData defaultIcon, bool isDark) {
    if (label == 'Text Size') {
      return Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        child: Text(
          'Aa',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark,
          ),
        ),
      );
    }
    return Icon(
      defaultIcon,
      size: 22,
      color: isDark ? NoorColors.darkGold : NoorColors.emeraldDark,
    );
  }

  Widget _group(
    BuildContext c,
    String title,
    List<(String, String, String)> rows,
    List<IconData> icons,
  ) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    final controller = NoorScope.of(c);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? NoorColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 52,
                    color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                  ),
                Builder(
                  builder: (context) {
                    final label = rows[i].$1;
                    final subtitle = rows[i].$2;
                    String? rowValue;

                    if (label == 'Language') {
                      rowValue = rows[i].$3.isNotEmpty ? rows[i].$3 : 'English';
                    } else if (label == 'Theme') {
                      rowValue = controller?.themePreferenceLabel ?? 'System';
                    } else if (label == 'Text Size') {
                      rowValue = _textSize;
                    } else if (label == 'About NOOR') {
                      rowValue = rows[i].$3.isNotEmpty ? rows[i].$3 : 'v1.2.0';
                    }

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: i == 0
                            ? const BorderRadius.vertical(top: Radius.circular(16))
                            : (i == rows.length - 1
                                ? const BorderRadius.vertical(bottom: Radius.circular(16))
                                : BorderRadius.zero),
                        onTap: _settingsTarget(c, label),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              _buildLeading(label, icons[i], isDark),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w400,
                                        color: isDark ? NoorColors.darkTextSecondary : const Color(0xFF737D78),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (rowValue != null) ...[
                                Text(
                                  rowValue,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? NoorColors.darkGold : const Color(0xFF166857),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: isDark ? NoorColors.darkTextSecondary : const Color(0xFF9CA79E),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Geometric pointed-arch emblem matching the NOOR brand icon on Page 13.
class NoorLogoBadge extends StatelessWidget {
  final double size;
  final Color color;

  const NoorLogoBadge({
    super.key,
    this.size = 28,
    this.color = const Color(0xFFCDAA6D),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(
        painter: _NoorLogoPainter(color: color),
      ),
    );
  }
}

class _NoorLogoPainter extends CustomPainter {
  final Color color;
  const _NoorLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Draw 3 concentric pointed arches (ogival mihrab)
    final layers = [
      (w, h, 0.0, 0.0),
      (w * 0.72, h * 0.72, w * 0.14, h * 0.28),
      (w * 0.44, h * 0.44, w * 0.28, h * 0.56),
    ];

    for (final layer in layers) {
      final lw = layer.$1;
      final lh = layer.$2;
      final ox = layer.$3;
      final oy = layer.$4;

      final p = Path();
      p.moveTo(ox, oy + lh);
      p.lineTo(ox, oy + lh * 0.45);
      p.cubicTo(
        ox,
        oy + lh * 0.15,
        ox + lw * 0.35,
        oy,
        ox + lw * 0.5,
        oy,
      );
      p.cubicTo(
        ox + lw * 0.65,
        oy,
        ox + lw,
        oy + lh * 0.15,
        ox + lw,
        oy + lh * 0.45,
      );
      p.lineTo(ox + lw, oy + lh);
      p.close();
      canvas.drawPath(p, stroke);
    }

    // Central spire / finial line
    canvas.drawLine(
      Offset(w * 0.5, h * 0.3),
      Offset(w * 0.5, h),
      stroke..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _NoorLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
