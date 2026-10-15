import 'package:flutter/material.dart';
import 'data/noor_controller.dart';
import 'theme/noor_theme.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/home/home_dashboard_screen.dart';
import 'screens/quran/quran_home_screen.dart';
import 'screens/ai/ai_assistant_home_screen.dart';
import 'screens/worship/worship_dashboard_screen.dart';
import 'screens/library/library_home_screen.dart';

class NoorApp extends StatefulWidget {
  const NoorApp({super.key});

  @override
  State<NoorApp> createState() => _NoorAppState();
}

class _NoorAppState extends State<NoorApp> {
  // Phase 13: the one app-wide reactive store lives for the whole
  // app lifetime; every tab reads the same live prayer/profile/
  // progress state through NoorScope instead of fetching its own.
  final NoorController _controller = NoorController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        /* Rebuild MaterialApp on controller/theme update */
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NoorScope(
      controller: _controller,
      child: MaterialApp(
        title: 'NOOR AI Companion',
        debugShowCheckedModeBanner: false,
        theme: NoorTheme.light(),
        darkTheme: NoorTheme.dark(),
        // Phase 4: Dynamic themeMode resolving solar automatic switching
        // (dark mode post-Maghrib until Fajr) and user preferences.
        themeMode: _controller.themeMode,
        // Phase 13 RTL: an Arabic/Urdu interface locale mirrors the
        // whole layout (rows, padding, bubbles), not just the text.
        builder: (context, child) {
          final lang = Localizations.localeOf(context).languageCode;
          final rtl = lang == 'ar' || lang == 'ur';
          return Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}

/// 5-tab shell from the design: Home / Quran / AI / Worship / Library.
/// Tab roots are the design pages 01, 11, 12, 14, 15-hub; every other
/// screen is pushed with Navigator from cards/lists inside the tabs.
class NoorTabShell extends StatefulWidget {
  final int initialTab;
  const NoorTabShell({super.key, this.initialTab = 0});

  /// Switch the global tab from anywhere in the app hierarchy.
  /// If [popToRoot] is true, unwinds the Navigator stack back to the root tab shell.
  static void switchTab(BuildContext context, int tabIndex, {bool popToRoot = false}) {
    if (popToRoot) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    final state = context.findAncestorStateOfType<_NoorTabShellState>() ??
        _NoorTabShellState.activeInstance;
    if (state != null) {
      state.setTab(tabIndex);
    }
  }

  @override
  State<NoorTabShell> createState() => _NoorTabShellState();
}

class _NoorTabShellState extends State<NoorTabShell> {
  static _NoorTabShellState? activeInstance;
  late int _index;

  @override
  void initState() {
    super.initState();
    activeInstance = this;
    _index = widget.initialTab.clamp(0, 4);
  }

  @override
  void dispose() {
    if (activeInstance == this) {
      activeInstance = null;
    }
    super.dispose();
  }

  void setTab(int i) {
    if (mounted) {
      setState(() => _index = i.clamp(0, 4));
    }
  }

  static const _tabs = [
    HomeDashboardScreen(),
    QuranHomeScreen(),
    AiAssistantHomeScreen(),
    WorshipDashboardScreen(),
    LibraryHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? NoorColors.darkBg : NoorColors.cream,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        backgroundColor: isDark ? NoorColors.darkSurface : Colors.white,
        selectedIndex: _index,
        onDestinationSelected: setTab,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Quran'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'AI'),
          NavigationDestination(
              icon: Icon(Icons.mosque_outlined),
              selectedIcon: Icon(Icons.mosque),
              label: 'Worship'),
          NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: 'Library'),
        ],
      ),
    );
  }
}
