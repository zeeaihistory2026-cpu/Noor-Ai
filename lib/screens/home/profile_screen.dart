import 'package:flutter/material.dart';
import '../../data/noor_controller.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../auth/login_screen.dart';
import '../library/saved_content_screen.dart';
import '../onboarding/goal_selection_screen.dart';
import 'my_journey_screen.dart';
import 'settings_screen.dart';
import '../../widgets/signature_arch.dart';
import '../worship/prayer_settings_screen.dart';
import '../onboarding/language_selection_screen.dart';
import '../worship/reminder_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Guest';
  String _email = '';
  String _language = 'English';
  String _madhhab = 'Hanafi';
  int _savedCount = 0;
  String _methodLabel = 'Karachi method';
  final _streaks = <String, int>{'Salah': 0, 'Quran': 0, 'Dhikr': 0};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await NoorStore.getUserName();
    final email = await NoorStore.getUserEmail();
    final language = await NoorStore.getLanguage();
    final madhhab = await NoorStore.getMadhhab();
    final bookmarks = await NoorStore.getBookmarks();
    final method = await NoorStore.getCalculationMethod();
    for (final kind in _streaks.keys.toList()) {
      _streaks[kind] = await NoorStore.activityStreak(kind);
    }
    if (!mounted) return;
    setState(() {
      _name = name == null || name.isEmpty ? 'Guest' : name;
      _email = email ?? '';
      _language = language;
      _madhhab = madhhab;
      _savedCount = bookmarks.length;
      _methodLabel = method == 1 ? 'Karachi method' : 'Method $method';
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final name =
        controller?.userName.isNotEmpty == true ? controller!.userName : _name;
    final email = controller?.userEmail.isNotEmpty == true
        ? controller!.userEmail
        : _email;
    final guest = controller?.isGuest ?? (name == 'Guest');
    final streaks = controller?.streaks ?? _streaks;
    final foreground = Theme.of(context).colorScheme.primary;
    return Scaffold(
        body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
                children: [
          Row(children: [
            if (Navigator.of(context).canPop()) BackButton(color: foreground),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('MUSLIMGO',
                      style:
                          NoorType.brandCaption.copyWith(letterSpacing: 2.8)),
                  const SizedBox(height: 5),
                  Text('Your space',
                      style: NoorType.display.copyWith(color: foreground)),
                ])),
            IconButton.filledTonal(
                tooltip: 'Open Settings',
                onPressed: () => _open(const SettingsScreen()),
                icon: const Icon(Icons.settings_outlined)),
          ]),
          const SizedBox(height: 22),
          Column(children: [
            Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          NoorColors.emeraldDark,
                          NoorColors.emeraldMid
                        ]),
                    borderRadius: BorderRadius.circular(26)),
                child: Stack(alignment: Alignment.topCenter, children: [
                  const Positioned.fill(
                      child: CustomPaint(painter: SignatureArchPainter())),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(18, 25, 18, 62),
                      child: Column(children: [
                        Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: NoorColors.cream,
                                border: Border.all(
                                    color: NoorColors.gold, width: 2)),
                            child: Center(
                                child: Text(name.characters.first.toUpperCase(),
                                    style: NoorType.display.copyWith(
                                        color: NoorColors.emeraldDark)))),
                        const SizedBox(height: 13),
                        Text('Assalamu Alaikum, $name',
                            textAlign: TextAlign.center,
                            style: NoorType.cardTitle
                                .copyWith(color: Colors.white)),
                        const SizedBox(height: 7),
                        Text(guest ? 'A little closer, every day.' : email,
                            textAlign: TextAlign.center,
                            style: NoorType.meta
                                .copyWith(color: NoorColors.onEmeraldMuted)),
                        const SizedBox(height: 14),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        NoorColors.gold.withValues(alpha: .45)),
                                color: Colors.white.withValues(alpha: .04)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.person_outline,
                                  color: NoorColors.gold, size: 13),
                              const SizedBox(width: 5),
                              Flexible(
                                  child: Text(
                                      guest ? 'GUEST ACCOUNT' : 'YOUR ACCOUNT',
                                      style: NoorType.brandCaption.copyWith(
                                          letterSpacing: 1,
                                          color: NoorColors.gold)))
                            ])),
                      ])),
                ])),
            Transform.translate(
                offset: const Offset(0, -25),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _panel(
                      padding: const EdgeInsets.symmetric(
                          vertical: 17, horizontal: 4),
                      child: IntrinsicHeight(
                          child: Row(children: [
                        for (final kind in ['Salah', 'Quran', 'Dhikr']) ...[
                          if (kind != 'Salah')
                            const VerticalDivider(
                                width: 1, indent: 6, endIndent: 6),
                          Expanded(
                              child: Semantics(
                                  label:
                                      '${streaks[kind] ?? 0} day $kind streak',
                                  child: Column(children: [
                                    Text('${streaks[kind] ?? 0}',
                                        style: NoorType.screenTitle
                                            .copyWith(color: foreground)),
                                    const SizedBox(height: 4),
                                    Text('$kind streak',
                                        textAlign: TextAlign.center,
                                        style: NoorType.eyebrow
                                            .copyWith(letterSpacing: 0)),
                                  ]))),
                        ],
                      ])),
                    ))),
          ]),
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Your essentials', style: NoorType.cardTitle),
                TextButton(
                    onPressed: () => _open(const MyJourneyScreen()),
                    child: const Text('View journey'))
              ]),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final large = MediaQuery.textScalerOf(context).scale(1) > 1.4 ||
                constraints.maxWidth < 290;
            final actions = [
              _action(
                  Icons.bookmark_border,
                  'Saved',
                  '$_savedCount ${_savedCount == 1 ? 'item' : 'items'}',
                  const SavedContentScreen()),
              _action(Icons.flag_outlined, 'Goals', 'Set intention',
                  const GoalSelectionScreen(editing: true)),
              _action(Icons.notifications_none_outlined, 'Reminders',
                  'Stay consistent', const ReminderCenterScreen()),
            ];
            if (large) {
              return Column(children: [
                for (final item in actions)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(width: double.infinity, child: item))
              ]);
            }
            return IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: actions[i])
                  ]
                ]));
          }),
          const SizedBox(height: 24),
          _panel(
              child: Column(children: [
            _row(Icons.mosque_outlined, 'Prayer preferences',
                '$_madhhab · $_methodLabel', const PrayerSettingsScreen()),
            const Divider(height: 1),
            _row(Icons.language_outlined, 'Reading language', _language,
                const LanguageSelectionScreen(editing: true)),
          ])),
          const SizedBox(height: 20),
          if (guest) ...[
            FilledButton(
                onPressed: () => _open(const LoginScreen()),
                child: const Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Text('Sign in / Create account'),
                      Icon(Icons.arrow_forward, size: 18)
                    ])),
            const SizedBox(height: 10),
            const Text('Your journey starts wherever you are.',
                textAlign: TextAlign.center, style: NoorType.meta),
          ] else
            OutlinedButton.icon(
                onPressed: () async {
                  await controller?.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out')),
        ])));
  }

  Widget _panel(
          {required Widget child,
          EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 18)}) =>
      Material(
          color: NoorTheme.surface(context),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? NoorColors.darkBorder
                      : NoorTheme.border(context))),
          clipBehavior: Clip.antiAlias,
          child: Padding(padding: padding, child: child));

  Widget _action(
          IconData icon, String label, String detail, Widget destination) =>
      Material(
          color: NoorTheme.surface(context),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? NoorColors.darkBorder
                      : NoorTheme.border(context))),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
              onTap: () => _open(destination),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24),
                        const SizedBox(height: 10),
                        Text(label,
                            textAlign: TextAlign.center,
                            style: NoorType.secondary),
                        const SizedBox(height: 3),
                        Text(detail,
                            textAlign: TextAlign.center,
                            style: NoorType.eyebrow.copyWith(letterSpacing: 0)),
                      ]))));

  Widget _row(IconData icon, String title, String detail, Widget destination) =>
      ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 9),
          onTap: () => _open(destination),
          leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? NoorColors.darkSurface
                      : NoorTheme.softSurface(context),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon,
                  size: 20, color: Theme.of(context).colorScheme.primary)),
          title: Text(title, style: NoorType.body),
          subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(detail, style: NoorType.meta)),
          trailing: const Icon(Icons.chevron_right, size: 20));
}
